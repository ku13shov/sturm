shader_type canvas_item;

void fragment() {
	vec2 centered_uv = (UV - vec2(0.5)) * vec2(2.0, 2.0);
	float distance_from_center = length(centered_uv);
	float softness = 1.0 - smoothstep(0.45, 1.0, distance_from_center);
	COLOR = vec4(0.05, 0.02, 0.01, softness * 0.75);
}
