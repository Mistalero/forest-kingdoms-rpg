extends Node
class_name VisualController

## Полиморфный контроллер визуализации
## Поддерживает переключение между режимами на лету без остановки игры

signal mode_changed(mode: String)
signal quality_changed(quality: String)

enum RenderMode {
VOXEL,      # Minecraft стиль
ANIME,      # Cel-shading аниме
DIMENSION_2D,   # Классическое 2D
ISOMETRIC,  # Изометрия
SPRITE_3D,  # Спрайтовое 3D
TEXT,       # Текстовый режим
ASCII       # ASCII графика
}

var current_mode: RenderMode = RenderMode.VOXEL
var current_quality: String = "high"
var renderers: Dictionary = {}
var active_renderer: Node = null
var paused: bool = false

# Настройки качества
var quality_settings: Dictionary = {
"low": {"shadow": false, "aa": false, "resolution_scale": 0.5},
"medium": {"shadow": true, "aa": false, "resolution_scale": 0.75},
"high": {"shadow": true, "aa": true, "resolution_scale": 1.0},
"ultra": {"shadow": true, "aa": true, "resolution_scale": 1.5, "raytracing": true}
}

func _ready():
print("[VisualController] Инициализация визуального контроллера")
register_renderers()
set_render_mode("voxel")

func register_renderers():
"""Регистрирует все доступные рендереры"""
var renderer_paths = {
"voxel": "res://src/visual/renderers/VoxelRenderer.gd",
"anime": "res://src/visual/renderers/AnimeRenderer.gd",
"2d": "res://src/visual/renderers/Renderer2D.gd",
"isometric": "res://src/visual/renderers/IsometricRenderer.gd",
"sprite3d": "res://src/visual/renderers/Sprite3DRenderer.gd",
"text": "res://src/visual/renderers/TextRenderer.gd",
"ascii": "res://src/visual/renderers/ASCIIRenderer.gd"
}

for name, path in renderer_paths:
if ResourceLoader.exists(path):
var script = load(path)
var renderer = Node.new()
renderer.set_script(script)
add_child(renderer)
renderers[name] = renderer
print("[VisualController] Рендерер зарегистрирован: %s" % name)
else:
push_warning("[VisualController] Рендерер не найден: %s" % path)

func set_render_mode(mode_name: String):
"""Переключает режим рендеринга на лету"""
mode_name = mode_name.to_lower()

# Определяем enum режима
match mode_name:
"voxel": current_mode = RenderMode.VOXEL
"anime": current_mode = RenderMode.ANIME
"2d": current_mode = RenderMode.DIMENSION_2D
"isometric": current_mode = RenderMode.ISOMETRIC
"sprite3d": current_mode = RenderMode.SPRITE_3D
"text": current_mode = RenderMode.TEXT
"ascii": current_mode = RenderMode.ASCII
_: 
push_error("[VisualController] Неизвестный режим: %s" % mode_name)
return

# Деактивируем текущий рендерер
if active_renderer:
active_renderer.set_process(false)
active_renderer.visible = false

# Активируем новый рендерер
if renderers.has(mode_name):
active_renderer = renderers[mode_name]
active_renderer.set_process(true)
active_renderer.visible = true
print("[VisualController] Режим изменен на: %s" % mode_name)
mode_changed.emit(mode_name)
else:
push_error("[VisualController] Рендерер не активирован: %s" % mode_name)

func set_quality(quality: String):
"""Применяет настройки качества"""
quality = quality.to_lower()
if not quality_settings.has(quality):
push_error("[VisualController] Неизвестное качество: %s" % quality)
return

current_quality = quality
var settings = quality_settings[quality]

# Применяем настройки к проекту
ProjectSettings.set_setting("rendering/lights_and_shadows/use_gi", settings.get("shadow", false))
ProjectSettings.set_setting("rendering/anti_aliasing/quality", settings.get("aa", false))
ProjectSettings.set_setting("display/window/size/viewport_width", int(1920 * settings.get("resolution_scale", 1.0)))
ProjectSettings.set_setting("display/window/size/viewport_height", int(1080 * settings.get("resolution_scale", 1.0)))

print("[VisualController] Качество установлено: %s" % quality)
quality_changed.emit(quality)

# Уведомляем активный рендерер
if active_renderer and active_renderer.has_method("apply_quality"):
active_renderer.apply_quality(settings)

func pause_rendering(paused_state: bool):
"""Приостанавливает или возобновляет рендеринг"""
paused = paused_state
if active_renderer:
active_renderer.set_process(not paused_state)

func get_supported_modes() -> Array:
"""Возвращает список поддерживаемых режимов"""
return renderers.keys()

func get_current_mode_info() -> Dictionary:
"""Возвращает информацию о текущем режиме"""
return {
"mode": RenderMode.keys()[current_mode].to_lower(),
"quality": current_quality,
"paused": paused,
"available_modes": get_supported_modes()
}
