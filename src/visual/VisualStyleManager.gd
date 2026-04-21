class_name VisualStyleManager
extends Node
## Visual Style Rendering Manager
## Управляет переключением между Minecraft (voxel) и Anime стилями рендеринга
## Обеспечивает максимальную совместимость и переключение на лету

signal style_changed(style_name: String)
signal quality_changed(quality_level: int)
signal voxel_mode_enabled(enabled: bool)
signal anime_mode_enabled(enabled: bool)

enum VisualStyle { MINECRAFT, ANIME }
enum QualityLevel { LOW, MEDIUM, HIGH, ULTRA }

@export var default_style: VisualStyle = VisualStyle.ANIME
@export var default_quality: QualityLevel = QualityLevel.HIGH
@export var enable_voxel_shadows: bool = true
@export var enable_anime_outlines: bool = true

var current_style: VisualStyle
var current_quality: QualityLevel
var voxel_world: Node = null
var anime_style_manager: Node = null
var is_voxel_mode_active: bool = false
var is_anime_mode_active: bool = true

# Конфигурации качества для обоих стилей
const QUALITY_CONFIGS = {
    QualityLevel.LOW: {
        "shadow_quality": 1,
        "ssao_enabled": false,
        "ssr_enabled": false,
        "glow_enabled": true,
        "glow_levels": 3,
        "fps_cap": 30,
        "voxel_render_distance": 2,
        "anime_outline_width": 0.01
    },
    QualityLevel.MEDIUM: {
        "shadow_quality": 2,
        "ssao_enabled": true,
        "ssr_enabled": false,
        "glow_enabled": true,
        "glow_levels": 5,
        "fps_cap": 60,
        "voxel_render_distance": 4,
        "anime_outline_width": 0.02
    },
    QualityLevel.HIGH: {
        "shadow_quality": 4,
        "ssao_enabled": true,
        "ssr_enabled": true,
        "glow_enabled": true,
        "glow_levels": 7,
        "fps_cap": 120,
        "voxel_render_distance": 8,
        "anime_outline_width": 0.03
    },
    QualityLevel.ULTRA: {
        "shadow_quality": 8,
        "ssao_enabled": true,
        "ssr_enabled": true,
        "glow_enabled": true,
        "glow_levels": 10,
        "fps_cap": 0,
        "voxel_render_distance": 16,
        "anime_outline_width": 0.04
    }
}

# Пресеты стилей
const STYLE_PRESETS = {
    VisualStyle.MINECRAFT: {
        "name": "Minecraft/Voxel",
        "description": "Блочный воксельный стиль",
        "features": ["voxels", "blocks", "chunk_loading"]
    },
    VisualStyle.ANIME: {
        "name": "Anime/Cel-Shader",
        "description": "Аниме стиль с cel-shading и контурами",
        "features": ["cel_shading", "outlines", "bloom"]
    }
}


func _ready() -> void:
    _find_managers()
    apply_style(default_style)
    apply_quality(default_quality)
    print("[VisualStyleManager] Initialized with %s style and %s quality" % [
        VisualStyle.keys()[default_style], 
        QualityLevel.keys()[default_quality]
    ])


func _find_managers() -> void:
    """Поиск существующих менеджеров рендеринга"""
    # Поиск VoxelWorld
    var voxel_nodes = get_tree().get_nodes_in_group("voxel_world")
    if not voxel_nodes.is_empty():
        voxel_world = voxel_nodes[0]
    else:
        # Попытка найти по имени
        voxel_world = get_node_or_null("/root/VoxelWorld")
    
    # Поиск AnimeStyleManager
    if has_node("/root/AnimeStyleManager"):
        anime_style_manager = get_node("/root/AnimeStyleManager")
    elif Engine.has_singleton("AnimeStyleManager"):
        anime_style_manager = Engine.get_singleton("AnimeStyleManager")


func apply_style(style: VisualStyle) -> void:
    """Применение визуального стиля"""
    if current_style == style:
        return
    
    # Отключаем текущий стиль
    if current_style == VisualStyle.MINECRAFT:
        _disable_voxel_mode()
    elif current_style == VisualStyle.ANIME:
        _disable_anime_mode()
    
    # Включаем новый стиль
    current_style = style
    
    if style == VisualStyle.MINECRAFT:
        _enable_voxel_mode()
    elif style == VisualStyle.ANIME:
        _enable_anime_mode()
    
    style_changed.emit(STYLE_PRESETS[style]["name"])
    print("[VisualStyleManager] Style switched to: %s" % STYLE_PRESETS[style]["name"])


func _enable_voxel_mode() -> void:
    """Включение режима Minecraft/Voxel"""
    is_voxel_mode_active = true
    
    if voxel_world:
        voxel_world.set_process(true)
        if voxel_world.has_method("update_chunks"):
            var player_pos = _get_player_position()
            if player_pos != Vector3.ZERO:
                voxel_world.update_chunks(player_pos)
    
    # Настройка рендеринга для вокселей
    _configure_voxel_rendering()
    
    voxel_mode_enabled.emit(true)
    print("[VisualStyleManager] Voxel mode enabled")


func _disable_voxel_mode() -> void:
    """Отключение режима Minecraft/Voxel"""
    is_voxel_mode_active = false
    
    if voxel_world:
        voxel_world.set_process(false)
    
    voxel_mode_enabled.emit(false)
    print("[VisualStyleManager] Voxel mode disabled")


func _enable_anime_mode() -> void:
    """Включение режима Anime"""
    is_anime_mode_active = true
    
    if anime_style_manager:
        if anime_style_manager.has_method("apply_preset"):
            anime_style_manager.apply_preset(anime_style_manager.current_preset if anime_style_manager.has_property("current_preset") else 0)
    
    # Настройка рендеринга для аниме стиля
    _configure_anime_rendering()
    
    anime_mode_enabled.emit(true)
    print("[VisualStyleManager] Anime mode enabled")


func _disable_anime_mode() -> void:
    """Отключение режима Anime"""
    is_anime_mode_active = false
    
    # Можно временно отключить пост-обработку
    if anime_style_manager and anime_style_manager.has_node("AnimeWorldEnvironment"):
        var env = anime_style_manager.get_node("AnimeWorldEnvironment")
        if env is WorldEnvironment:
            env.environment.glow_enabled = false
    
    anime_mode_enabled.emit(false)
    print("[VisualStyleManager] Anime mode disabled")


func _configure_voxel_rendering() -> void:
    """Настройка рендеринга для воксельного режима"""
    var config = QUALITY_CONFIGS[current_quality]
    
    # Настройка дальности прорисовки вокселей
    if voxel_world:
        if voxel_world.has_variable("render_distance"):
            voxel_world.render_distance = config["voxel_render_distance"]
        elif voxel_world.has_method("set_render_distance"):
            voxel_world.call("set_render_distance", config["voxel_render_distance"])
    
    # Тени для вокселей
    if enable_voxel_shadows:
        RenderingServer.environment_set_sdf_roughness_layers(config["shadow_quality"])


func _configure_anime_rendering() -> void:
    """Настройка рендеринга для аниме режима"""
    var config = QUALITY_CONFIGS[current_quality]
    
    # Настройка ширины контуров
    if anime_style_manager:
        # Обновление параметров шейдеров
        if anime_style_manager.has_method("_update_shader_params"):
            var root = get_tree().current_scene
            if root:
                var preset_config = _get_anime_preset_config()
                anime_style_manager._update_shader_params(root, preset_config)


func _get_anime_preset_config() -> Dictionary:
    """Получение конфигурации текущего пресета аниме"""
    if anime_style_manager and anime_style_manager.has_constant("PRESET_CONFIGS"):
        var presets = anime_style_manager.get("PRESET_CONFIGS")
        var current_preset = anime_style_manager.get("current_preset") if anime_style_manager.has_property("current_preset") else 0
        if presets and current_preset != null:
            return presets[current_preset]
    
    # Значения по умолчанию
    return {
        "saturation": 1.3,
        "brightness": 1.05,
        "contrast": 1.1,
        "shadow_threshold": 0.3,
        "highlight_threshold": 0.85,
        "rim_intensity": 0.6
    }


func apply_quality(level: QualityLevel) -> void:
    """Применение настроек качества"""
    current_quality = level
    var config = QUALITY_CONFIGS[level]
    
    # Применение настроек к обоим стилям
    _apply_global_quality_settings(config)
    
    # Специфичные настройки для каждого стиля
    if current_style == VisualStyle.MINECRAFT:
        _configure_voxel_rendering()
    elif current_style == VisualStyle.ANIME:
        _configure_anime_rendering()
    
    quality_changed.emit(level)
    print("[VisualStyleManager] Quality set to: %s" % QualityLevel.keys()[level])


func _apply_global_quality_settings(config: Dictionary) -> void:
    """Глобальные настройки качества"""
    var viewport = get_viewport()
    
    # SSAO
    if anime_style_manager and anime_style_manager.has_node("AnimeWorldEnvironment"):
        var env = anime_style_manager.get_node("AnimeWorldEnvironment")
        if env is WorldEnvironment and env.environment:
            env.environment.ssao_enabled = config["ssao_enabled"]
            env.environment.glow_enabled = config["glow_enabled"]
            env.environment.glow_level_count = config["glow_levels"]
    
    # FPS cap (требует дополнительной реализации)
    if config["fps_cap"] > 0:
        Engine.max_fps = config["fps_cap"]
    else:
        Engine.max_fps = 0  # Без ограничений


func toggle_style() -> void:
    """Переключение между стилями"""
    var next_style = VisualStyle.ANIME if current_style == VisualStyle.MINECRAFT else VisualStyle.MINECRAFT
    apply_style(next_style)


func set_voxel_mode(enabled: bool) -> void:
    """Установка режима вокселей"""
    if enabled:
        apply_style(VisualStyle.MINECRAFT)
    else:
        apply_style(VisualStyle.ANIME)


func set_anime_mode(enabled: bool) -> void:
    """Установка режима аниме"""
    if enabled:
        apply_style(VisualStyle.ANIME)
    else:
        apply_style(VisualStyle.MINECRAFT)


func get_current_style_info() -> Dictionary:
    """Получение информации о текущем стиле"""
    return {
        "style": VisualStyle.keys()[current_style],
        "style_name": STYLE_PRESETS[current_style]["name"],
        "quality": QualityLevel.keys()[current_quality],
        "voxel_active": is_voxel_mode_active,
        "anime_active": is_anime_mode_active,
        "features": STYLE_PRESETS[current_style]["features"]
    }


func get_available_styles() -> Array:
    """Получение списка доступных стилей"""
    var styles = []
    for style in STYLE_PRESETS:
        styles.append({
            "id": style,
            "name": STYLE_PRESETS[style]["name"],
            "description": STYLE_PRESETS[style]["description"],
            "features": STYLE_PRESETS[style]["features"]
        })
    return styles


func _get_player_position() -> Vector3:
    """Получение позиции игрока"""
    var player = get_tree().get_first_node_in_group("player")
    if player and player is Node3D:
        return player.global_position
    return Vector3.ZERO


func register_voxel_world(world: Node) -> void:
    """Регистрация VoxelWorld"""
    voxel_world = world
    print("[VisualStyleManager] VoxelWorld registered")


func register_anime_manager(manager: Node) -> void:
    """Регистрация AnimeStyleManager"""
    anime_style_manager = manager
    print("[VisualStyleManager] AnimeStyleManager registered")


func save_settings() -> Dictionary:
    """Сохранение настроек"""
    return {
        "style": current_style,
        "quality": current_quality,
        "enable_voxel_shadows": enable_voxel_shadows,
        "enable_anime_outlines": enable_anime_outlines
    }


func load_settings(settings: Dictionary) -> void:
    """Загрузка настроек"""
    if settings.has("style"):
        apply_style(settings["style"])
    if settings.has("quality"):
        apply_quality(settings["quality"])
    if settings.has("enable_voxel_shadows"):
        enable_voxel_shadows = settings["enable_voxel_shadows"]
    if settings.has("enable_anime_outlines"):
        enable_anime_outlines = settings["enable_anime_outlines"]
    print("[VisualStyleManager] Settings loaded")
