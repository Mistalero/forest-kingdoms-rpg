// Anime Style Outline Shader (Back-face method)
shader_type spatial;
render_mode unshaded, cull_front, depth_draw_never;

uniform vec3 outline_color : source_color = vec3(0.0, 0.0, 0.0);
uniform float outline_width = 0.02;

varying vec3 world_normal;

void vertex() {
    world_normal = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    
    // Expand vertices along normal for outline effect
    vec3 expanded_vertex = VERTEX + NORMAL * outline_width;
    VERTEX = expanded_vertex;
}

void fragment() {
    ALBEDO = outline_color;
    ALPHA = 1.0;
}
