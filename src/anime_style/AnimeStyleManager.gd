class_name AnimeStyleManager
extends Node
## Anime Style Rendering Manager
## Manages cel-shading, outlines, and post-processing for anime-style visuals
## Ensures no Minecraft-like blocky appearance

signal style_changed(style_name: String)
signal quality_changed(quality_level: int)

enum QualityLevel { LOW, MEDIUM, HIGH, ULTRA }
enum StylePreset { DEFAULT, VIBRANT, SOFT, DRAMATIC }

@export var default_quality: QualityLevel = QualityLevel.HIGH
@export var default_preset: StylePreset = StylePreset.DEFAULT

var current_quality: QualityLevel
var current_preset: StylePreset
var world_environment: WorldEnvironment
var viewport: Viewport

# Style presets configuration
const PRESET_CONFIGS = {
    StylePreset.DEFAULT: {
        "saturation": 1.3,
        "brightness": 1.05,
        "contrast": 1.1,
        "shadow_threshold": 0.3,
        "highlight_threshold": 0.85,
        "rim_intensity": 0.6
    },
    StylePreset.VIBRANT: {
        "saturation": 1.5,
        "brightness": 1.1,
        "contrast": 1.2,
        "shadow_threshold": 0.25,
        "highlight_threshold": 0.8,
        "rim_intensity": 0.8
    },
    StylePreset.SOFT: {
        "saturation": 1.15,
        "brightness": 1.0,
        "contrast": 1.05,
        "shadow_threshold": 0.35,
        "highlight_threshold": 0.9,
        "rim_intensity": 0.4
    },
    StylePreset.DRAMATIC: {
        "saturation": 1.4,
        "brightness": 0.95,
        "contrast": 1.3,
        "shadow_threshold": 0.2,
        "highlight_threshold": 0.75,
        "rim_intensity": 0.9
    }
}

# Quality configurations
const QUALITY_CONFIGS = {
    QualityLevel.LOW: {
        "shadow_quality": 1,
        "ssao_enabled": false,
        "ssr_enabled": false,
        "glow_enabled": true,
        "glow_levels": 3,
        "fps_cap": 30
    },
    QualityLevel.MEDIUM: {
        "shadow_quality": 2,
        "ssao_enabled": true,
        "ssr_enabled": false,
        "glow_enabled": true,
        "glow_levels": 5,
        "fps_cap": 60
    },
    QualityLevel.HIGH: {
        "shadow_quality": 4,
        "ssao_enabled": true,
        "ssr_enabled": true,
        "glow_enabled": true,
        "glow_levels": 7,
        "fps_cap": 120
    },
    QualityLevel.ULTRA: {
        "shadow_quality": 8,
        "ssao_enabled": true,
        "ssr_enabled": true,
        "glow_enabled": true,
        "glow_levels": 10,
        "fps_cap": 0  # Unlimited
    }
}


func _ready() -> void:
    _setup_environment()
    _setup_post_processing()
    apply_quality(default_quality)
    apply_preset(default_preset)
    print("[AnimeStyleManager] Initialized with %s quality and %s preset" % [QualityLevel.keys()[default_quality], StylePreset.keys()[default_preset]])


func _setup_environment() -> void:
    """Setup WorldEnvironment for anime-style rendering"""
    world_environment = WorldEnvironment.new()
    world_environment.name = "AnimeWorldEnvironment"
    
    var env = Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky_custom_energy = 1.2
    env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.ambient_light_energy = 0.8
    
    # Glow settings for anime bloom effect
    env.glow_enabled = true
    env.glow_intensity = 0.8
    env.glow_bloom = 0.5
    env.glow_strength = 1.2
    
    # DoF disabled for crisp anime look
    env.dof_blur_enabled = false
    
    # SSAO for depth
    env.ssao_enabled = true
    env.ssao_intensity = 0.3
    
    world_environment.environment = env
    get_tree().current_scene.add_child(world_environment)


func _setup_post_processing() -> void:
    """Setup viewport for post-processing"""
    viewport = get_viewport()
    viewport.use_hdr_2d = true
    viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA


func apply_quality(level: QualityLevel) -> void:
    """Apply quality settings"""
    if not world_environment or not world_environment.environment:
        return
    
    var config = QUALITY_CONFIGS[level]
    var env = world_environment.environment
    
    env.ssao_enabled = config["ssao_enabled"]
    env.glow_enabled = config["glow_enabled"]
    env.glow_level_count = config["glow_levels"]
    
    # Shadow quality
    RenderingServer.environment_set_sdf_roughness_layers(config["shadow_quality"])
    
    current_quality = level
    quality_changed.emit(level)
    print("[AnimeStyleManager] Quality set to: %s" % QualityLevel.keys()[level])


func apply_preset(preset: StylePreset) -> void:
    """Apply anime style preset"""
    var config = PRESET_CONFIGS[preset]
    
    # Update post-processing shader parameters if available
    var root = get_tree().current_scene
    if root:
        _update_shader_params(root, config)
    
    current_preset = preset
    style_changed.emit(StylePreset.keys()[preset])
    print("[AnimeStyleManager] Preset applied: %s" % StylePreset.keys()[preset])


func _update_shader_params(node: Node, config: Dictionary) -> void:
    """Recursively update shader parameters in scene tree"""
    if node is MeshInstance3D:
        var material = node.get_surface_override_material(0)
        if material and material is ShaderMaterial:
            var shader = material.shader
            if shader:
                # Set shader uniforms based on preset
                material.set_shader_parameter("shadow_threshold", config["shadow_threshold"])
                material.set_shader_parameter("highlight_threshold", config["highlight_threshold"])
                material.set_shader_parameter("rim_intensity", config["rim_intensity"])
    
    for child in node.get_children():
        _update_shader_params(child, config)


func setup_anime_material(base_mesh: MeshInstance3D, 
                          base_color: Color = Color(1.0, 0.9, 0.95),
                          outline_width: float = 0.02) -> ShaderMaterial:
    """Create and apply anime-style material to a mesh"""
    
    var material = ShaderMaterial.new()
    var shader = load("res://src/anime_style/shaders/anime_fragment.gdshader")
    if shader:
        material.shader = shader
        material.set_shader_parameter("base_color", base_color)
    
    # Apply material
    base_mesh.set_surface_override_material(0, material)
    
    # Create outline mesh
    _create_outline(base_mesh, outline_width)
    
    return material


func _create_outline(mesh: MeshInstance3D, width: float) -> void:
    """Create outline using back-face culling method"""
    var outline_mesh = mesh.mesh.create_duplicate() as Mesh
    if not outline_mesh:
        return
    
    var outline_mat = ShaderMaterial.new()
    var shader = load("res://src/anime_style/shaders/anime_outline.gdshader")
    if shader:
        outline_mat.shader = shader
        outline_mat.set_shader_parameter("outline_width", width)
    
    var outline_instance = MeshInstance3D.new()
    outline_instance.name = mesh.name + "_Outline"
    outline_instance.mesh = outline_mesh
    outline_instance.set_surface_override_material(0, outline_mat)
    
    mesh.add_child(outline_instance)


func get_current_config() -> Dictionary:
    """Get current style configuration"""
    return {
        "quality": QualityLevel.keys()[current_quality],
        "preset": StylePreset.keys()[current_preset],
        "preset_values": PRESET_CONFIGS[current_preset],
        "quality_values": QUALITY_CONFIGS[current_quality]
    }


func switch_to_next_preset() -> void:
    """Cycle through presets"""
    var next_idx = (int(current_preset) + 1) % StylePreset.size()
    apply_preset(next_idx)


func switch_to_next_quality() -> void:
    """Cycle through quality levels"""
    var next_idx = (int(current_quality) + 1) % QualityLevel.size()
    apply_quality(next_idx)
