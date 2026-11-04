shader_type canvas_item;
// Белая вспышка попадания для листового солдата. Материал вешается только на время вспышки.

uniform float hit_flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 modulate_color = COLOR;
	vec4 base = texture(TEXTURE, UV);
	vec3 tinted = base.rgb * modulate_color.rgb;
	COLOR = vec4(mix(tinted, vec3(1.0), hit_flash), base.a * modulate_color.a);
}
