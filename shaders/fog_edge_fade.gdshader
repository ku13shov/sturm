shader_type canvas_item;
uniform float edge_softness : hint_range(0.05, 1.0) = 0.75;
void fragment() {
	vec4 base_color = texture(TEXTURE, UV) * COLOR;
	float edge_distance = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float fade_amount = smoothstep(0.0, edge_softness, edge_distance);
	COLOR = vec4(base_color.rgb, base_color.a * (1.0 - fade_amount));
}
