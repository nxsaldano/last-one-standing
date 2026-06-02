shader_type canvas_item;

// tweak these in the Inspector after
uniform float intensity  : hint_range(0.0, 1.0) = 0.45;
uniform float smoothness : hint_range(0.0, 1.0) = 0.45;

void fragment() {
    // UV goes from 0,0 (top-left) to 1,1 (bottom-right)
    // subtracting 0.5 makes the CENTER be 0,0
    vec2 uv = UV - vec2(0.5);

    // distance from center → 0 at center, ~0.7 at corners
    float dist = length(uv);

    // smoothstep turns that distance into a 0→1 dark edge
    float vignette = smoothstep(smoothness, smoothness + intensity, dist);

    // output: black color, alpha = vignette (transparent center, dark edges)
    COLOR = vec4(0.0, 0.0, 0.0, vignette);
}