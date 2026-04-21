extends Node

## Polymorphic Visual Controller.
## Manages rendering modes (Voxel, Anime, 2D, Isometric, Text, etc.)
## Completely isolated from game logic.

signal render_mode_changed(mode: String)
signal quality_changed(level: int)

enum RenderMode { VOXEL, ANIME, SPRITE_2D, ISOMETRIC, TEXT_ONLY, ASCII }
enum QualityLevel { LOW, MEDIUM, HIGH, ULTRA }

var current_mode: RenderMode = RenderMode.VOXEL
var current_quality: QualityLevel = QualityLevel.MEDIUM
var user_preferences: Dictionary = {}

# References to specific renderers (loaded dynamically)
var active_renderer: Node = null

func _ready():
	_load_user_preferences()
	_apply_render_mode(current_mode)

func _load_user_preferences():
	# Load from config file or local storage
	# For now, defaults
	user_preferences["mode"] = "voxel"
	user_preferences["quality"] = "medium"
	
	if user_preferences.has("mode"):
		set_mode_by_string(user_preferences["mode"])
	if user_preferences.has("quality"):
		set_quality_by_string(user_preferences["quality"])

func apply_user_preferences():
	_load_user_preferences()
	_apply_render_mode(current_mode)

func set_mode_by_string(mode_str: String):
	match mode_str.to_lower():
		"voxel", "minecraft":
			current_mode = RenderMode.VOXEL
		"anime", "cel":
			current_mode = RenderMode.ANIME
		"2d", "sprite":
			current_mode = RenderMode.SPRITE_2D
		"isometric", "iso":
			current_mode = RenderMode.ISOMETRIC
		"text", "tty":
			current_mode = RenderMode.TEXT_ONLY
		"ascii":
			current_mode = RenderMode.ASCII
		_:
			current_mode = RenderMode.VOXEL
	
	_apply_render_mode(current_mode)

func set_quality_by_string(qual_str: String):
	match qual_str.to_lower():
		"low":
			current_quality = QualityLevel.LOW
		"medium":
			current_quality = QualityLevel.MEDIUM
		"high":
			current_quality = QualityLevel.HIGH
		"ultra":
			current_quality = QualityLevel.ULTRA
		_:
			current_quality = QualityLevel.MEDIUM
	
	_apply_quality(current_quality)

func toggle_style():
	# Simple toggle between Voxel and Anime for quick switching
	if current_mode == RenderMode.VOXEL:
		set_mode_by_string("anime")
	else:
		set_mode_by_string("voxel")

func _apply_render_mode(mode: RenderMode):
	print("[Visual] Applying render mode: ", RenderMode.keys()[mode])
	
	# Cleanup old renderer
	if active_renderer:
		active_renderer.queue_free()
		active_renderer = null
	
	# Load new renderer based on mode
	var renderer_path = ""
	match mode:
		RenderMode.VOXEL:
			renderer_path = "res://src/visual/renderers/VoxelRenderer.gd"
		RenderMode.ANIME:
			renderer_path = "res://src/visual/renderers/AnimeRenderer.gd"
		RenderMode.SPRITE_2D:
			renderer_path = "res://src/visual/renderers/Sprite2DRenderer.gd"
		RenderMode.ISOMETRIC:
			renderer_path = "res://src/visual/renderers/IsometricRenderer.gd"
		RenderMode.TEXT_ONLY:
			renderer_path = "res://src/visual/renderers/TextRenderer.gd"
		RenderMode.ASCII:
			renderer_path = "res://src/visual/renderers/AsciiRenderer.gd"
	
	if ResourceLoader.exists(renderer_path):
		var script = load(renderer_path)
		active_renderer = Node.new()
		active_renderer.set_script(script)
		add_child(active_renderer)
		print("[Visual] Renderer loaded: ", renderer_path)
	else:
		push_warning("[Visual] Renderer not found: ", renderer_path, ". Using fallback.")
		# Fallback to a simple node if specific renderer missing
		active_renderer = Node.new()
		add_child(active_renderer)
	
	render_mode_changed.emit(RenderMode.keys()[mode])
	_apply_quality(current_quality)

func _apply_quality(level: QualityLevel):
	print("[Visual] Applying quality level: ", QualityLevel.keys()[level])
	
	# Adjust rendering settings based on quality
	# This would interact with the active_renderer to change LOD, shadows, etc.
	match level:
		QualityLevel.LOW:
			ProjectSettings.set_setting("rendering/quality/shadows/enabled", false)
			ProjectSettings.set_setting("rendering/quality/filters/msaa/mode", 0) # Disabled
		QualityLevel.MEDIUM:
			ProjectSettings.set_setting("rendering/quality/shadows/enabled", true)
			ProjectSettings.set_setting("rendering/quality/filters/msaa/mode", 2) # 2x
		QualityLevel.HIGH:
			ProjectSettings.set_setting("rendering/quality/shadows/enabled", true)
			ProjectSettings.set_setting("rendering/quality/filters/msaa/mode", 3) # 4x
		QualityLevel.ULTRA:
			ProjectSettings.set_setting("rendering/quality/shadows/enabled", true)
			ProjectSettings.set_setting("rendering/quality/filters/msaa/mode", 3) # 4x
			# Enable extra post-processing here
	
	quality_changed.emit(level)
