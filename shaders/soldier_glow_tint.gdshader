shader_type canvas_item;
render_mode blend_add;

// Заменяет голубой оттенок маски свечения на tint, сохраняя яркость.
// amount = 0: оригинальный цвет маски, 1: полностью цвет tint.
uniform vec4 tint : source_color = vec4(1.0, 0.6, 0.12, 1.0);
uniform float amount : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float l = max(COLOR.r, max(COLOR.g, COLOR.b));
	// Самое яркое ядро остаётся чуть светлее, как «раскалённая» середина.
	vec3 hot = mix(tint.rgb, vec3(1.0), smoothstep(0.75, 1.0, l) * 0.5);
	COLOR = vec4(mix(COLOR.rgb, hot * l, amount), COLOR.a);
}
