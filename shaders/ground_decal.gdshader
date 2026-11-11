shader_type canvas_item;
// Мягкое пятно земли: размывает рваный край и плавно растворяет пятно к границе эллипса.

// Размер ячейки листа в пикселях текстуры.
uniform vec2 cell_size = vec2(512.0, 341.0);
// Уровень размытия альфы (больше = мягче край).
uniform float blur_lod : hint_range(0.0, 5.0) = 3.0;
// Полуоси эллипса растворения в долях ячейки.
uniform vec2 radii = vec2(0.40, 0.43);
// С какого расстояния от центра (0–1) пятно начинает таять.
uniform float feather_start : hint_range(0.0, 1.0) = 0.35;
uniform vec3 tint_color : source_color = vec3(0.86, 0.80, 0.77);
uniform float opacity : hint_range(0.0, 1.0) = 0.8;

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	vec3 rgb = texture(TEXTURE, UV).rgb;
	float a = textureLod(TEXTURE, UV, blur_lod).a;
	a = smoothstep(0.05, 0.95, a);
	vec2 local = local_pos / cell_size;
	float d = length(local / radii);
	float feather = 1.0;
	COLOR = vec4(rgb * tint_color, a * feather * opacity);
}
