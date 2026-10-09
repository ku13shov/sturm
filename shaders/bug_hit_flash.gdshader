shader_type canvas_item;

uniform float hit_flash : hint_range(0.0, 1.0) = 0.0;
uniform float flash_strength : hint_range(0.0, 2.0) = 0.8;
uniform float bottom_shade_strength : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	float flash = clamp(hit_flash * flash_strength, 0.0, 1.0);
	float bottom_gradient = smoothstep(0.8, 1.0, UV.y);
	float shade = 1.0 - bottom_gradient * bottom_shade_strength * 1.142857;
	vec3 shaded = base.rgb * shade;
	COLOR = vec4(mix(shaded, vec3(1.0), flash), base.a);
}
