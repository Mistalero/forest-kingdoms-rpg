class_name VisualConfig
extends Resource

## ==========================================
## VISUAL CONFIGURATION RESOURCE
## ==========================================
## Центральный ресурс для хранения всех настроек отображения.
## Поддерживает пресеты, сериализацию в JSON и горячее применение.
## Полностью опционален и не ломает существующую логику.

# --- ИДЕНТИФИКАЦИЯ ---
@export_group("General")
@export var config_name: String = "Default Preset"
@export var config_version: String = "1.0.0"
@export var author: String = "System"

# --- СТИЛЬ РЕНДЕРИНГА ---
@export_group("Render Style")
@export_enum("Minecraft/Voxel", "Anime/Cel-Shader", "Realistic/PBR", "Hybrid") var render_style: String = "Minecraft/Voxel"
@export var enable_voxel_geometry: bool = true
@export var enable_anime_shading: bool = false
@export var enable_outline_pass: bool = false
@export var outline_color: Color = Color.BLACK
@export var outline_width: float = 1.0

# --- КАЧЕСТВО И ПРОИЗВОДИТЕЛЬНОСТЬ ---
@export_group("Quality & Performance")
@export_enum("Low", "Medium", "High", "Ultra", "Custom") var quality_preset: String = "High"
@export var target_fps: int = 60
@export var max_draw_distance: float = 100.0
@export var lod_bias: float = 0.5
@export var max_particles: int = 5000
@export var shadow_quality: int = 2 # 0: Off, 1: Low, 2: Medium, 3: High, 4: Ultra
@export var texture_quality: int = 2 # 0: Low, 1: Medium, 2: High
@export var anisotropic_filtering: int = 4 # 0, 2, 4, 8, 16

# --- ОСВЕЩЕНИЕ И ОКРУЖЕНИЕ (ENVIRONMENT) ---
@export_group("Lighting & Environment")
@export var enable_gi: bool = false # Global Illumination
@export var gi_mode: int = 0 # 0: Voxel GI, 1: SDFGI
@export var ambient_light_color: Color = Color(0.3, 0.3, 0.35)
@export var ambient_light_energy: float = 0.3
@export var sky_type: int = 0 # 0: Procedural, 1: Panorama, 2: Color
@export var sky_color: Color = Color(0.6, 0.7, 0.9)
@export var fog_enabled: bool = true
@export var fog_color: Color = Color(0.6, 0.7, 0.9)
@export var fog_density: float = 0.02
@export var sun_angle: Vector2 = Vector2(45, -45)
@export var sun_color: Color = Color(1.0, 0.95, 0.9)
@export var sun_intensity: float = 1.0

# --- ПОСТ-ОБРАБОТКА (POST-PROCESSING) ---
@export_group("Post-Processing")
@export var enable_bloom: bool = true
@export var bloom_intensity: float = 0.8
@export var bloom_threshold: float = 0.9
@export var enable_ssr: bool = false # Screen Space Reflections
@export var ssr_quality: int = 1
@export var enable_ssao: bool = true # Screen Space Ambient Occlusion
@export var ssao_quality: int = 1
@export var enable_dof: bool = false # Depth of Field
@export var dof_blur_amount: float = 0.1
@export var enable_vignette: bool = false
@export var vignette_strength: float = 0.3
@export var enable_color_correction: bool = false
@export var color_correction_saturation: float = 1.0
@export var color_correction_contrast: float = 1.0
@export var enable_chromatic_aberration: bool = false
@export var chromatic_aberration_strength: float = 0.02
@export var enable_film_grain: bool = false
@export var film_grain_strength: float = 0.1
@export var enable_motion_blur: bool = false
@export var motion_blur_intensity: float = 0.5

# --- СПЕЦИФИЧНЫЕ НАСТРОЙКИ VOXEL (MINECRAFT) ---
@export_group("Voxel Specifics")
@export var voxel_chunk_size: int = 16
@export var voxel_mesh_merge_distance: int = 2
@export var enable_smooth_lighting: bool = true
@export var enable_fancy_leaves: bool = false
@export var enable_connected_textures: bool = true
@export var cloud_type: int = 1 # 0: None, 1: Voxel, 2: Volumetric
@export var water_reflection_quality: int = 1 # 0: Off, 1: Simple, 2: Planar

# --- СПЕЦИФИЧНЫЕ НАСТРОЙКИ ANIME ---
@export_group("Anime Specifics")
@export var toon_ramp_levels: int = 3
@export var rim_light_intensity: float = 0.5
@export var rim_light_color: Color = Color.WHITE
@export var hair_shadow_offset: float = 0.05
@export var eye_parallax_strength: float = 0.1
@export var enable_special_effects: bool = true # Sparkles, speed lines, etc.

# --- UI И HUD ---
@export_group("UI & HUD")
@export var ui_scale: float = 1.0
@export var ui_theme_variant: String = "Default"
@export var show_fps_counter: bool = false
@export var show_debug_info: bool = false
@export var crosshair_style: int = 0 # 0: Dot, 1: Circle, 2: Cross, 3: Custom
@export var hide_ui_in_photoshoot: bool = true

# --- МЕТОДЫ ---

## Сохранить конфиг в файл JSON
func save_to_file(path: String = "user://visual_config.json") -> Error:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()
	
	var data = {
		"config_name": config_name,
		"render_style": render_style,
		"enable_voxel_geometry": enable_voxel_geometry,
		"enable_anime_shading": enable_anime_shading,
		"quality_preset": quality_preset,
		"target_fps": target_fps,
		"max_draw_distance": max_draw_distance,
		"lod_bias": lod_bias,
		"shadow_quality": shadow_quality,
		"texture_quality": texture_quality,
		"anisotropic_filtering": anisotropic_filtering,
		"enable_gi": enable_gi,
		"ambient_light_color": ambient_light_color.to_html(),
		"ambient_light_energy": ambient_light_energy,
		"sky_color": sky_color.to_html(),
		"fog_enabled": fog_enabled,
		"fog_color": fog_color.to_html(),
		"fog_density": fog_density,
		"sun_color": sun_color.to_html(),
		"sun_intensity": sun_intensity,
		"enable_bloom": enable_bloom,
		"bloom_intensity": bloom_intensity,
		"enable_ssr": enable_ssr,
		"enable_ssao": enable_ssao,
		"voxel_chunk_size": voxel_chunk_size,
		"enable_smooth_lighting": enable_smooth_lighting,
		"toon_ramp_levels": toon_ramp_levels,
		"rim_light_intensity": rim_light_intensity,
		"ui_scale": ui_scale,
		"show_fps_counter": show_fps_counter
	}
	
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return OK

## Загрузить конфиг из файла JSON
func load_from_file(path: String = "user://visual_config.json") -> Error:
	if not FileAccess.file_exists(path):
		return ERR_FILE_NOT_FOUND
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return FileAccess.get_open_error()
	
	var json_str = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_str)
	if error != OK:
		push_error("Failed to parse visual config JSON: " + json.get_error_message())
		return ERR_PARSE_ERROR
	
	var data = json.get_data()
	if not data is Dictionary:
		return ERR_INVALID_DATA
	
	# Применяем данные (упрощенно, только основные поля для примера)
	if data.has("config_name"): config_name = data["config_name"]
	if data.has("render_style"): render_style = data["render_style"]
	if data.has("enable_voxel_geometry"): enable_voxel_geometry = data["enable_voxel_geometry"]
	if data.has("enable_anime_shading"): enable_anime_shading = data["enable_anime_shading"]
	if data.has("quality_preset"): quality_preset = data["quality_preset"]
	if data.has("target_fps"): target_fps = data["target_fps"]
	if data.has("max_draw_distance"): max_draw_distance = data["max_draw_distance"]
	if data.has("lod_bias"): lod_bias = data["lod_bias"]
	if data.has("shadow_quality"): shadow_quality = data["shadow_quality"]
	if data.has("texture_quality"): texture_quality = data["texture_quality"]
	if data.has("anisotropic_filtering"): anisotropic_filtering = data["anisotropic_filtering"]
	if data.has("enable_gi"): enable_gi = data["enable_gi"]
	if data.has("ambient_light_energy"): ambient_light_energy = data["ambient_light_energy"]
	if data.has("fog_enabled"): fog_enabled = data["fog_enabled"]
	if data.has("fog_density"): fog_density = data["fog_density"]
	if data.has("sun_intensity"): sun_intensity = data["sun_intensity"]
	if data.has("enable_bloom"): enable_bloom = data["enable_bloom"]
	if data.has("bloom_intensity"): bloom_intensity = data["bloom_intensity"]
	if data.has("enable_ssr"): enable_ssr = data["enable_ssr"]
	if data.has("enable_ssao"): enable_ssao = data["enable_ssao"]
	if data.has("voxel_chunk_size"): voxel_chunk_size = data["voxel_chunk_size"]
	if data.has("enable_smooth_lighting"): enable_smooth_lighting = data["enable_smooth_lighting"]
	if data.has("toon_ramp_levels"): toon_ramp_levels = data["toon_ramp_levels"]
	if data.has("rim_light_intensity"): rim_light_intensity = data["rim_light_intensity"]
	if data.has("ui_scale"): ui_scale = data["ui_scale"]
	if data.has("show_fps_counter"): show_fps_counter = data["show_fps_counter"]
	
	# Цвета нужно конвертировать обратно
	if data.has("ambient_light_color"): ambient_light_color = Color.html(data["ambient_light_color"])
	if data.has("sky_color"): sky_color = Color.html(data["sky_color"])
	if data.has("fog_color"): fog_color = Color.html(data["fog_color"])
	if data.has("sun_color"): sun_color = Color.html(data["sun_color"])
	
	return OK

## Применить пресет качества (автоматически настраивает множество параметров)
func apply_quality_preset(preset: String):
	quality_preset = preset
	match preset:
		"Low":
			target_fps = 30
			max_draw_distance = 50.0
			lod_bias = 0.8
			shadow_quality = 0
			texture_quality = 0
			anisotropic_filtering = 0
			enable_gi = false
			enable_bloom = false
			enable_ssr = false
			enable_ssao = false
			voxel_chunk_size = 32
			toon_ramp_levels = 2
		"Medium":
			target_fps = 60
			max_draw_distance = 80.0
			lod_bias = 0.6
			shadow_quality = 1
			texture_quality = 1
			anisotropic_filtering = 2
			enable_gi = false
			enable_bloom = true
			bloom_intensity = 0.5
			enable_ssr = false
			enable_ssao = true
			ssao_quality = 0
			voxel_chunk_size = 24
			toon_ramp_levels = 3
		"High":
			target_fps = 60
			max_draw_distance = 100.0
			lod_bias = 0.4
			shadow_quality = 2
			texture_quality = 2
			anisotropic_filtering = 4
			enable_gi = true
			gi_mode = 1 # SDFGI
			enable_bloom = true
			bloom_intensity = 0.8
			enable_ssr = true
			ssr_quality = 1
			enable_ssao = true
			ssao_quality = 1
			voxel_chunk_size = 16
			toon_ramp_levels = 4
		"Ultra":
			target_fps = 144
			max_draw_distance = 150.0
			lod_bias = 0.2
			shadow_quality = 4
			texture_quality = 2
			anisotropic_filtering = 16
			enable_gi = true
			gi_mode = 0 # Voxel GI (если доступно)
			enable_bloom = true
			bloom_intensity = 1.2
			enable_ssr = true
			ssr_quality = 2
			enable_ssao = true
			ssao_quality = 2
			enable_dof = true
			enable_motion_blur = true
			voxel_chunk_size = 16
			toon_ramp_levels = 5
		"Custom":
			pass # Ничего не меняем, пользователь сам настроил

## Создать копию конфига
func duplicate_config() -> VisualConfig:
	return self.duplicate()
