// Anime Style Post-Processing Shader
shader_type canvas_item;

uniform float saturation = 1.3;
uniform float brightness = 1.05;
uniform float contrast = 1.1;
uniform vec3 tint_color : source_color = vec3(1.0, 0.98, 1.02);
float bloom_threshold = 0.8;
float bloom_intensity = 0.4;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // Increase saturation
    vec3 hsv = rgb2hsv(color.rgb);
    hsv.y *= saturation;
    hsv.y = clamp(hsv.y, 0.0, 1.0);
    vec3 saturated = hsv2rgb(hsv);
    
    // Adjust brightness and contrast
    vec3 adjusted = (saturated - 0.5) * contrast + 0.5;
    adjusted *= brightness;
    
    // Apply subtle anime tint
    adjusted *= tint_color;
    
    // Soft bloom-like glow for highlights
    float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    if (luminance > bloom_threshold) {
        float bloom_factor = (luminance - bloom_threshold) * bloom_intensity;
        adjusted += vec3(bloom_factor);
    }
    
    COLOR = vec4(adjusted, color.a);
}

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
