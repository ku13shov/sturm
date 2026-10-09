shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.16, 0.045, 0.02, 1.0);
uniform float shadow_opacity : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec2 centered_uv = (UV - vec2(0.5)) * vec2(2.0);
	float distance_from_center = length(centered_uv);
	float soft_ellipse = 1.0 - smoothstep(0.68, 1.0, distance_from_center);
	COLOR = vec4(shadow_color.rgb, soft_ellipse * shadow_opacity);
}
