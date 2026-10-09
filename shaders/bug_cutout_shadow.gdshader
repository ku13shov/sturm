shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.025, 0.015, 0.012, 0.52);
uniform float blur_radius_pixels : hint_range(0.0, 48.0, 1.0) = 18.0;

void fragment() {
	vec2 radius = TEXTURE_PIXEL_SIZE * blur_radius_pixels;
	float alpha = texture(TEXTURE, UV).a * 0.28;
	alpha += (texture(TEXTURE, UV + vec2(radius.x, 0.0)).a + texture(TEXTURE, UV - vec2(radius.x, 0.0)).a
		+ texture(TEXTURE, UV + vec2(0.0, radius.y)).a + texture(TEXTURE, UV - vec2(0.0, radius.y)).a) * 0.12;
	alpha += (texture(TEXTURE, UV + radius).a + texture(TEXTURE, UV - radius).a
		+ texture(TEXTURE, UV + vec2(radius.x, -radius.y)).a + texture(TEXTURE, UV + vec2(-radius.x, radius.y)).a) * 0.06;
	COLOR = vec4(shadow_color.rgb, shadow_color.a * alpha);
}
