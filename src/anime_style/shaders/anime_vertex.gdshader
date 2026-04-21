// Anime Style Cel Shading Vertex Shader
shader_type spatial;
render_mode unshaded, cull_back, depth_draw_opaque;

varying vec3 world_normal;
varying vec3 world_position;
varying float depth_value;

void vertex() {
    world_normal = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    world_position = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    depth_value = -world_position.z;
}
