shader_type canvas_item;
// Белая вспышка попадания для бункера. В Godot 4 в fragment() цвет COLOR уже равен текстуре * modulate,
// поэтому текстуру второй раз не умножаем (иначе цвет возводится в квадрат и бункер выглядит тёмным).

uniform float hit_flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	COLOR = vec4(mix(COLOR.rgb, vec3(1.0), hit_flash), COLOR.a);
}
