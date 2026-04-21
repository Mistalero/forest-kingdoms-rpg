# Anime Style Rendering System

## 🎨 Overview
Complete anime-style rendering system for Forest Kingdoms RPG, replacing any blocky/Minecraft-like visuals with smooth cel-shaded anime aesthetics.

## ✨ Features

### Core Rendering
- **Cel Shading**: Discrete lighting steps (shadow/midtone/highlight)
- **Rim Lighting**: Character outline glow for depth separation
- **Black Outlines**: Classic anime-style edge detection
- **Post-Processing**: Enhanced saturation, brightness, and bloom

### Quality Levels
- **LOW**: Basic cel-shading, minimal effects (30 FPS target)
- **MEDIUM**: SSAO enabled, 5-level glow (60 FPS target)
- **HIGH**: Full SSR, 7-level glow (120 FPS target)
- **ULTRA**: Maximum quality, unlimited FPS

### Style Presets
- **DEFAULT**: Balanced anime look
- **VIBRANT**: High saturation, dramatic lighting
- **SOFT**: Gentle colors, subtle shadows
- **DRAMATIC**: High contrast, intense rim lighting

## 📁 File Structure

```
src/anime_style/
├── shaders/
│   ├── anime_vertex.gdshader      # Vertex processing
│   ├── anime_fragment.gdshader    # Cel-shading logic
│   ├── anime_outline.gdshader     # Black outline effect
│   └── anime_postprocess.gdshader # Screen-space effects
├── AnimeStyleManager.gd           # Main manager singleton
└── README.md                      # This file
```

## 🚀 Usage

### As Autoload (Recommended)
1. Add `AnimeStyleManager` to Project → Project Settings → Autoload
2. Access globally via `AnimeStyleManager`

### Basic API

```gdscript
# Change quality
AnimeStyleManager.apply_quality(AnimeStyleManager.QualityLevel.HIGH)

# Apply style preset
AnimeStyleManager.apply_preset(AnimeStyleManager.StylePreset.VIBRANT)

# Cycle through options
AnimeStyleManager.switch_to_next_preset()
AnimeStyleManager.switch_to_next_quality()

# Get current config
var config = AnimeStyleManager.get_current_config()
print("Current: ", config.quality, " - ", config.preset)

# Apply anime material to mesh
var material = AnimeStyleManager.setup_anime_material(
    my_mesh_instance,
    Color(0.9, 0.7, 0.8),  # Pink base color
    0.02                    # Outline width
)
```

### Signals

```gdscript
func _ready():
    AnimeStyleManager.style_changed.connect(_on_style_changed)
    AnimeStyleManager.quality_changed.connect(_on_quality_changed)

func _on_style_changed(style_name: String):
    print("Style changed to: ", style_name)

func _on_quality_changed(level: int):
    print("Quality level: ", level)
```

## 🎮 Integration

### With SkeleRealms
```gdscript
# Apply anime style to character models
func setup_character(entity: SkeleRealmsEntity):
    var mesh = entity.get_node_or_null("MeshInstance3D")
    if mesh:
        AnimeStyleManager.setup_anime_material(mesh, Color(1.0, 0.9, 0.9))
```

### With Bare Metal MUD
```bash
# Commands available in MUD mode
anime preset vibrant
anime quality high
anime next
anime info
```

### With World Generation
```gdscript
# Apply to generated terrain
func _on_terrain_generated(mesh: MeshInstance3D):
    AnimeStyleManager.setup_anime_material(
        mesh, 
        Color(0.6, 0.8, 0.4),  # Grass green
        0.03
    )
```

## ⚙️ Shader Parameters

### Fragment Shader Uniforms
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `base_color` | vec3 | (1.0, 0.8, 0.9) | Main surface color |
| `shadow_color` | vec3 | (0.6, 0.4, 0.5) | Shadow area color |
| `highlight_color` | vec3 | (1.0, 0.95, 0.98) | Highlight color |
| `shadow_threshold` | float | 0.3 | Shadow cutoff point |
| `highlight_threshold` | float | 0.85 | Highlight cutoff point |
| `rim_intensity` | float | 0.6 | Rim light strength |
| `rim_color` | vec3 | (0.7, 0.8, 1.0) | Rim light color |

### Outline Shader Uniforms
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `outline_color` | vec3 | (0.0, 0.0, 0.0) | Outline color (black) |
| `outline_width` | float | 0.02 | Outline thickness |

### Post-Process Uniforms
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `saturation` | float | 1.3 | Color saturation multiplier |
| `brightness` | float | 1.05 | Brightness adjustment |
| `contrast` | float | 1.1 | Contrast enhancement |
| `tint_color` | vec3 | (1.0, 0.98, 1.02) | Overall color tint |

## 🎯 Performance Tips

1. **Use LOW quality** for older hardware or large battles
2. **Disable outlines** on distant objects
3. **Batch materials** with same parameters
4. **LOD system**: Reduce outline width for far meshes

```gdscript
# Example LOD-based outline
func update_lod(mesh: MeshInstance3D, distance: float):
    var width = max(0.005, 0.02 * (1.0 - distance / 100.0))
    var outline = mesh.get_node_or_null("MeshOutline")
    if outline:
        outline.material_override.set_shader_parameter("outline_width", width)
```

## 🔧 Customization

### Create Custom Preset
```gdscript
var custom_preset = {
    "saturation": 1.6,
    "brightness": 1.15,
    "contrast": 1.25,
    "shadow_threshold": 0.28,
    "highlight_threshold": 0.82,
    "rim_intensity": 0.75
}

# Apply manually to shaders
for mesh in get_tree().get_nodes_in_group("characters"):
    var mat = mesh.get_surface_override_material(0)
    if mat and mat is ShaderMaterial:
        for param in custom_preset:
            mat.set_shader_parameter(param, custom_preset[param])
```

### Dynamic Style Changes
```gdscript
# Combat intensifies style
func enter_combat():
    AnimeStyleManager.apply_preset(AnimeStyleManager.StylePreset.DRAMATIC)

func exit_combat():
    AnimeStyleManager.apply_preset(AnimeStyleManager.StylePreset.DEFAULT)
```

## 📝 Notes

- **No Minecraft associations**: Smooth meshes only, no voxels visible
- **HDR required**: Enable HDR in project settings for best results
- **FXAA recommended**: Use FXAA anti-aliasing for clean edges
- **Mobile support**: LOW/MEDIUM presets optimized for mobile

## 🐛 Troubleshooting

**Issue**: Outlines flickering  
**Solution**: Increase `outline_width` or enable depth pre-pass

**Issue**: Colors too dark  
**Solution**: Increase `brightness` and `ambient_light_energy`

**Issue**: Performance drop  
**Solution**: Lower quality level, disable SSR/SSAO

**Issue**: No rim lighting  
**Solution**: Check normal maps, ensure meshes have proper UVs

---

*Forest Kingdoms RPG - Anime Style System v1.0*
