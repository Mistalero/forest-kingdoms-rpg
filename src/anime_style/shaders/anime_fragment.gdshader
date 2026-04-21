// Anime Style Cel Shading Fragment Shader
shader_type spatial;
render_mode unshaded, cull_back, depth_draw_opaque;

uniform vec3 base_color : source_color = vec3(1.0, 0.8, 0.9);
uniform vec3 shadow_color : source_color = vec3(0.6, 0.4, 0.5);
uniform vec3 highlight_color : source_color = vec3(1.0, 0.95, 0.98);
uniform float shadow_threshold = 0.3;
uniform float highlight_threshold = 0.85;
uniform float rim_intensity = 0.6;
uniform vec3 rim_color : source_color = vec3(0.7, 0.8, 1.0);

varying vec3 world_normal;
varying vec3 world_position;
varying float depth_value;

void fragment() {
    vec3 normal = normalize(world_normal);
    vec3 view_dir = normalize(-world_position);
    vec3 light_dir = normalize(vec3(0.5, 0.8, 0.3));
    
    // Calculate lighting
    float ndotl = dot(normal, light_dir);
    float ndotv = dot(normal, view_dir);
    
    // Cel shading with discrete steps
    vec3 final_color;
    if (ndotl > highlight_threshold) {
        final_color = highlight_color;
    } else if (ndotl > shadow_threshold) {
        final_color = base_color;
    } else {
        final_color = shadow_color;
    }
    
    // Rim lighting for anime effect
    float rim = 1.0 - max(0.0, ndotv);
    rim = pow(rim, 3.0) * rim_intensity;
    final_color += rim_color * rim;
    
    // Outline effect using depth-based approach
    ALPHA = 1.0;
    ALBEDO = final_color;
}
