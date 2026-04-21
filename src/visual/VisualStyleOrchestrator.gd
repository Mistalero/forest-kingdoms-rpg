class_name VisualStyleOrchestrator
extends Node

## ==========================================
## VISUAL STYLE ORCHESTRATOR
## ==========================================
## Центральный контроллер для управления всеми визуальными системами.
## Обеспечивает максимальные возможности настройки отображения.
## Полностью опционален, не модифицирует существующие файлы.
## Поддерживает горячее переключение стилей и настроек.

signal style_changed(new_style: String)
signal quality_changed(new_quality: String)
signal config_applied(config: VisualConfig)
signal setting_changed(setting_name: String, new_value: Variant)

## Текущая активная конфигурация
var current_config: VisualConfig:
	set(value):
		current_config = value
		config_applied.emit(current_config)
	get:
		if not current_config:
			current_config = VisualConfig.new()
		return current_config

## Ссылки на внешние менеджеры (автоматическое обнаружение)
var voxel_world: Node = null
var anime_style_manager: Node = null
var environment: Environment = null
var viewport: Viewport = null

## Кэш ссылок на ноды сцены
var _scene_cache: Dictionary = {}

## Флаг инициализации
var _is_initialized: bool = false


func _ready():
	# Отложенная инициализация для гарантии загрузки сцены
	call_deferred("_initialize")


func _initialize():
	if _is_initialized:
		return
	
	_is_initialized = true
	
	# Автоматическое обнаружение компонентов
	_discover_components()
	
	# Загрузка сохраненной конфигурации
	_load_saved_config()
	
	print("[VisualStyleOrchestrator] Инициализация завершена. Стиль: %s" % current_config.render_style)


## Автоматическое обнаружение всех визуальных компонентов в сцене
func _discover_components():
	# Поиск VoxelWorld
	voxel_world = _find_node_by_class("VoxelWorld")
	if voxel_world:
		print("[VisualStyleOrchestrator] Обнаружен VoxelWorld")
	
	# Поиск AnimeStyleManager
	anime_style_manager = _find_node_by_class("AnimeStyleManager")
	if anime_style_manager:
		print("[VisualStyleOrchestrator] Обнаружен AnimeStyleManager")
	
	# Поиск Environment
	environment = _find_environment()
	if environment:
		print("[VisualStyleOrchestrator] Обнаружен Environment")
	
	# Получение Viewport
	viewport = get_viewport()
	if viewport:
		print("[VisualStyleOrchestrator] Viewport получен")


## Рекурсивный поиск ноды по имени класса
func _find_node_by_class(class_name: String, root: Node = null) -> Node:
	if root == null:
		root = get_tree().current_scene
	
	if root == null:
		root = get_tree().root
	
	for node in root.get_children():
		if node.get_class() == class_name or (node.has_method("get_script") and node.get_script() and node.get_script().get_path().get_file() == class_name + ".gd"):
			return node
		
		var found = _find_node_by_class(class_name, node)
		if found:
			return found
	
	return null


## Поиск Environment в текущей сцене
func _find_environment() -> Environment:
	# Проверка WorldEnvironment
	var world_env = _find_node_by_class("WorldEnvironment")
	if world_env and world_env.has_method("get_environment"):
		return world_env.get_environment()
	
	# Проверка viewport environment
	if viewport and viewport.environment:
		return viewport.environment
	
	return null


## Загрузка сохраненной конфигурации
func _load_saved_config():
	var config_path = "user://visual_config.json"
	if FileAccess.file_exists(config_path):
		current_config = VisualConfig.new()
		var error = current_config.load_from_file(config_path)
		if error == OK:
			print("[VisualStyleOrchestrator] Конфигурация загружена: %s" % current_config.config_name)
			apply_config(current_config)
		else:
			push_error("[VisualStyleOrchestrator] Ошибка загрузки конфига: %d" % error)
	else:
		print("[VisualStyleOrchestrator] Сохраненный конфиг не найден, используется конфигурация по умолчанию")
		current_config = VisualConfig.new()


## ==========================================
## ПРИМЕНЕНИЕ КОНФИГУРАЦИИ
## ==========================================

## Применить полную конфигурацию
func apply_config(config: VisualConfig):
	current_config = config.duplicate_config()
	
	# Применение всех категорий настроек
	_apply_render_style()
	_apply_quality_settings()
	_apply_environment_settings()
	_apply_post_processing()
	_apply_voxel_specifics()
	_apply_anime_specifics()
	_apply_ui_settings()
	
	# Сохранение конфигурации
	config.save_to_file()
	
	config_applied.emit(current_config)
	print("[VisualStyleOrchestrator] Конфигурация применена: %s" % config.config_name)


## Применить только стиль рендеринга
func _apply_render_style():
	match current_config.render_style:
		"Minecraft/Voxel":
			set_voxel_mode(true)
			set_anime_mode(false)
		"Anime/Cel-Shader":
			set_voxel_mode(false)
			set_anime_mode(true)
		"Realistic/PBR":
			set_voxel_mode(false)
			set_anime_mode(false)
			_enable_pbr_mode()
		"Hybrid":
			_enable_hybrid_mode()
	
	setting_changed.emit("render_style", current_config.render_style)


## Применить настройки качества
func _apply_quality_settings():
	current_config.apply_quality_preset(current_config.quality_preset)
	
	# Применение FPS лимита
	Engine.max_fps = current_config.target_fps
	
	# Применение настроек рендеринга через Project Settings
	ProjectSettings.set_setting("rendering/limits/3d/textures/canvas_max_texture_size", pow(2, 10 + current_config.texture_quality))
	ProjectSettings.set_setting("rendering/limits/3d/textures/compression_limit", current_config.texture_quality)
	
	# Применение анизотропной фильтрации
	ProjectSettings.set_setting("rendering/textures/filter/anisotropic_filtering_level", current_config.anisotropic_filtering)
	
	quality_changed.emit(current_config.quality_preset)
	setting_changed.emit("quality_preset", current_config.quality_preset)


## Применить настройки окружения
func _apply_environment_settings():
	if not environment:
		push_warning("[VisualStyleOrchestrator] Environment не найден, пропускаем настройку окружения")
		return
	
	# Базовое освещение
	environment.ambient_light_color = current_config.ambient_light_color
	environment.ambient_light_energy = current_config.ambient_light_energy
	
	# Небо
	match current_config.sky_type:
		0: # Procedural
			environment.sky = Sky.new()
			environment.background_mode = Environment.BG_SKY
		1: # Panorama
			environment.sky = Sky.new()
			environment.background_mode = Environment.BG_SKY
		2: # Color
			environment.background_color = current_config.sky_color
			environment.background_mode = Environment.BG_COLOR
	
	# Туман
	environment.fog_enabled = current_config.fog_enabled
	if current_config.fog_enabled:
		environment.fog_color = current_config.fog_color
		environment.fog_density = current_config.fog_density
	
	# Солнце (если есть DirectionalLight)
	_apply_sun_settings()
	
	setting_changed.emit("environment", current_config)


## Настройка солнца
func _apply_sun_settings():
	# Поиск основного источника света
	var sun = _find_node_by_class("DirectionalLight3D")
	if sun:
		sun.rotation_degrees = Vector3(current_config.sun_angle.x, current_config.sun_angle.y, 0)
		if sun.has_method("set_light_color"):
			sun.set_light_color(current_config.sun_color)
		if sun.has_method("set_light_energy"):
			sun.set_light_energy(current_config.sun_intensity)


## Применить пост-обработку
func _apply_post_processing():
	if not environment:
		return
	
	# Bloom
	environment.glow_enabled = current_config.enable_bloom
	if current_config.enable_bloom:
		environment.glow_intensity = current_config.bloom_intensity
		environment.glow_threshold = current_config.bloom_threshold
	
	# SSR
	environment.ssr_enabled = current_config.enable_ssr
	if current_config.enable_ssr:
		environment.ssr_roughness_limit = current_config.ssr_quality * 0.25
	
	# SSAO
	environment.ssao_enabled = current_config.enable_ssao
	if current_config.enable_ssao:
		environment.ssao_quality = current_config.ssao_quality
	
	# DOF
	environment.dof_blur_enabled = current_config.enable_dof
	if current_config.enable_dof:
		environment.dof_blur_amount = current_config.dof_blur_amount
	
	# Vignette
	environment.vignette_enabled = current_config.enable_vignette
	if current_config.enable_vignette:
		environment.vignette_strength = current_config.vignette_strength
	
	# Chromatic Aberration
	environment.chromatic_aberration_enabled = current_config.enable_chromatic_aberration
	if current_config.enable_chromatic_aberration:
		environment.chromatic_aberration_strength = current_config.chromatic_aberration_strength
	
	# Film Grain
	environment.film_grain_enabled = current_config.enable_film_grain
	if current_config.enable_film_grain:
		environment.film_grain_strength = current_config.film_grain_strength
	
	# Motion Blur (через Viewport)
	if viewport:
		viewport.use_taa = current_config.enable_motion_blur
	
	setting_changed.emit("post_processing", current_config)


## Применить специфичные настройки Voxel
func _apply_voxel_specifics():
	if voxel_world:
		if voxel_world.has_method("set_chunk_size"):
			voxel_world.set_chunk_size(current_config.voxel_chunk_size)
		if voxel_world.has_method("set_mesh_merge_distance"):
			voxel_world.set_mesh_merge_distance(current_config.voxel_mesh_merge_distance)
		if voxel_world.has_method("set_smooth_lighting"):
			voxel_world.set_smooth_lighting(current_config.enable_smooth_lighting)
		if voxel_world.has_method("set_fancy_leaves"):
			voxel_world.set_fancy_leaves(current_config.enable_fancy_leaves)
		if voxel_world.has_method("set_connected_textures"):
			voxel_world.set_connected_textures(current_config.enable_connected_textures)
	
	setting_changed.emit("voxel_specifics", current_config)


## Применить специфичные настройки Anime
func _apply_anime_specifics():
	if anime_style_manager:
		if anime_style_manager.has_method("set_toon_ramp_levels"):
			anime_style_manager.set_toon_ramp_levels(current_config.toon_ramp_levels)
		if anime_style_manager.has_method("set_rim_light_intensity"):
			anime_style_manager.set_rim_light_intensity(current_config.rim_light_intensity)
		if anime_style_manager.has_method("set_rim_light_color"):
			anime_style_manager.set_rim_light_color(current_config.rim_light_color)
		if anime_style_manager.has_method("set_hair_shadow_offset"):
			anime_style_manager.set_hair_shadow_offset(current_config.hair_shadow_offset)
		if anime_style_manager.has_method("set_eye_parallax_strength"):
			anime_style_manager.set_eye_parallax_strength(current_config.eye_parallax_strength)
		if anime_style_manager.has_method("set_special_effects_enabled"):
			anime_style_manager.set_special_effects_enabled(current_config.enable_special_effects)
	
	setting_changed.emit("anime_specifics", current_config)


## Применить настройки UI
func _apply_ui_settings():
	# Масштаб UI
	var root = get_tree().root
	if root and root.get_child_count() > 0:
		var first_child = root.get_child(0)
		if first_child is CanvasLayer or first_child is Control:
			first_child.scale = Vector2(current_config.ui_scale, current_config.ui_scale)
	
	setting_changed.emit("ui_settings", current_config)


## ==========================================
## УПРАВЛЕНИЕ СТИЛЯМИ
## ==========================================

## Переключиться в режим Voxel (Minecraft)
func set_voxel_mode(enabled: bool):
	current_config.enable_voxel_geometry = enabled
	current_config.enable_anime_shading = !enabled if enabled else current_config.enable_anime_shading
	
	if voxel_world and voxel_world.has_method("set_visible"):
		voxel_world.set_visible(enabled)
	
	if enabled:
		current_config.render_style = "Minecraft/Voxel"
	
	style_changed.emit(current_config.render_style)
	print("[VisualStyleOrchestrator] Режим Voxel: %s" % ("ВКЛ" if enabled else "ВЫКЛ"))


## Переключиться в режим Anime
func set_anime_mode(enabled: bool):
	current_config.enable_anime_shading = enabled
	current_config.enable_voxel_geometry = !enabled if enabled else current_config.enable_voxel_geometry
	
	if anime_style_manager and anime_style_manager.has_method("set_active"):
		anime_style_manager.set_active(enabled)
	
	if enabled:
		current_config.render_style = "Anime/Cel-Shader"
	
	style_changed.emit(current_config.render_style)
	print("[VisualStyleOrchestrator] Режим Anime: %s" % ("ВКЛ" if enabled else "ВЫКЛ"))


## Переключить стиль на противоположный
func toggle_style():
	if current_config.render_style == "Minecraft/Voxel":
		set_anime_mode(true)
	else:
		set_voxel_mode(true)


## Включить гибридный режим
func _enable_hybrid_mode():
	set_voxel_mode(true)
	set_anime_mode(true)
	current_config.render_style = "Hybrid"
	style_changed.emit(current_config.render_style)


## Включить PBR режим
func _enable_pbr_mode():
	set_voxel_mode(false)
	set_anime_mode(false)
	current_config.render_style = "Realistic/PBR"
	style_changed.emit(current_config.render_style)


## ==========================================
## УПРАВЛЕНИЕ КАЧЕСТВОМ
## ==========================================

## Применить пресет качества
func apply_quality_preset(preset: String):
	current_config.quality_preset = preset
	current_config.apply_quality_preset(preset)
	_apply_quality_settings()
	_apply_environment_settings()
	_apply_post_processing()


## Установить конкретное значение настройки
func set_setting(setting_name: String, value: Variant):
	if current_config.has_setting(setting_name):
		current_config.set(setting_name, value)
		setting_changed.emit(setting_name, value)
		
		# Переприменение затронутых категорий
		if setting_name.begins_with("voxel_"):
			_apply_voxel_specifics()
		elif setting_name.begins_with("anime_"):
			_apply_anime_specifics()
		elif setting_name.begins_with("enable_") or setting_name.begins_with("bloom_") or setting_name.begins_with("ssr_") or setting_name.begins_with("ssao_"):
			_apply_post_processing()
		elif setting_name.begins_with("ambient_") or setting_name.begins_with("sky_") or setting_name.begins_with("fog_") or setting_name.begins_with("sun_"):
			_apply_environment_settings()


## Получить текущее значение настройки
func get_setting(setting_name: String) -> Variant:
	if current_config.has_setting(setting_name):
		return current_config.get(setting_name)
	return null


## ==========================================
## УТИЛИТЫ
## ==========================================

## Получить информацию о текущем стиле
func get_current_style_info() -> Dictionary:
	return {
		"style_name": current_config.render_style,
		"quality_preset": current_config.quality_preset,
		"voxel_enabled": current_config.enable_voxel_geometry,
		"anime_enabled": current_config.enable_anime_shading,
		"fps_target": current_config.target_fps,
		"draw_distance": current_config.max_draw_distance,
		"shadow_quality": current_config.shadow_quality,
		"texture_quality": current_config.texture_quality,
		"post_processing_enabled": current_config.enable_bloom or current_config.enable_ssr or current_config.enable_ssao
	}


## Сбросить конфигурацию к значениям по умолчанию
func reset_to_defaults():
	current_config = VisualConfig.new()
	apply_config(current_config)
	print("[VisualStyleOrchestrator] Конфигурация сброшена к значениям по умолчанию")


## Создать новый пресет на основе текущих настроек
func create_preset(name: String) -> VisualConfig:
	var new_config = current_config.duplicate_config()
	new_config.config_name = name
	return new_config


## Экспорт конфигурации в JSON строку
func export_to_json() -> String:
	var data = {}
	for property in current_config.get_property_list():
		if property.usage & PROPERTY_USAGE_STORAGE:
			data[property.name] = current_config.get(property.name)
	return JSON.stringify(data, "\t")


## Импорт конфигурации из JSON строки
func import_from_json(json_string: String) -> Error:
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		return error
	
	var data = json.get_data()
	if not data is Dictionary:
		return ERR_INVALID_DATA
	
	var new_config = VisualConfig.new()
	for key in data:
		if new_config.has_setting(key):
			new_config.set(key, data[key])
	
	apply_config(new_config)
	return OK


## Проверка наличия настройки в конфиге
func has_setting(setting_name: String) -> bool:
	return current_config.has_setting(setting_name)


## Получить список всех доступных настроек
func get_all_settings() -> Array:
	var settings = []
	for property in current_config.get_property_list():
		if property.usage & PROPERTY_USAGE_STORAGE:
			settings.append(property.name)
	return settings
