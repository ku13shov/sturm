shader_type canvas_item;
render_mode blend_add, unshaded;

uniform vec4 glow_color : source_color = vec4(1.0, 0.22, 0.025, 1.0);
uniform float glow_strength : hint_range(0.0, 3.0, 0.05) = 1.2;
uniform float pulse_speed : hint_range(0.0, 10.0, 0.1) = 2.6;
uniform float blur_pixels : hint_range(0.0, 16.0, 0.5) = 5.0;

void fragment() {
	vec2 radius = TEXTURE_PIXEL_SIZE * blur_pixels;
	float mask = texture(TEXTURE, UV).a * 0.4;
	mask += (texture(TEXTURE, UV + vec2(radius.x, 0.0)).a
		+ texture(TEXTURE, UV - vec2(radius.x, 0.0)).a
		+ texture(TEXTURE, UV + vec2(0.0, radius.y)).a
		+ texture(TEXTURE, UV - vec2(0.0, radius.y)).a) * 0.1;
	float pulse = 0.72 + 0.28 * sin(TIME * pulse_speed);
	float energy = mask * glow_strength * pulse;
	COLOR = vec4(glow_color.rgb * energy, energy);
}
