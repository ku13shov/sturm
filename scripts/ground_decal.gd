class_name GroundDecal
extends Sprite2D
## Тёмное пятно земли под зданием. Одна текстура res://assets/map/dark_earth_patch.webp с чёткими ступенчатыми
## краями, сжатая по вертикали под изометрию. Пятно полностью непрозрачное, поэтому при пересечении
## пятен базы и башен прозрачность не складывается и тёмной полосы нет. Отражение выбирается по позиции здания.

const PATCH_PATH := "res://assets/map/dark_earth_patch.webp"
## Какую долю ширины текстуры занимает само пятно (остальное пустое поле).
const PATCH_FILL_OF_TEXTURE := 0.96

@export_group("Пятно")
## Ширина видимого пятна, px мира.
@export var width_px: float = 130.0
## Сжатие по вертикали под изометрическое основание (1 = круглое).
@export_range(0.3, 1.0, 0.01) var vertical_squash: float = 0.58
## Затемнение пятна (умножение цвета): светлее = ближе к земле, темнее = контрастнее.
@export var tint: Color = Color(0.74, 0.6, 0.57)

var _final_scale: Vector2 = Vector2.ONE
var _tween: Tween


func _ready() -> void:
	name = "GroundDecal"
	show_behind_parent = true
	self_modulate = tint
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	texture = load(PATCH_PATH) as Texture2D
	if texture == null:
		queue_free()
		return
	var host: Node2D = get_parent() as Node2D
	var seed_value: int = 0
	if host != null:
		seed_value = int(absf(host.position.x) * 7.0 + absf(host.position.y) * 13.0)
	flip_h = (seed_value >> 2) % 2 == 1
	apply_width()


## Подгоняет масштаб так, чтобы видимое пятно было шириной width_px.
func apply_width() -> void:
	if texture == null:
		return
	var patch_px: float = texture.get_size().x * PATCH_FILL_OF_TEXTURE
	var uniform_scale: float = width_px / patch_px
	_final_scale = Vector2(uniform_scale, uniform_scale * vertical_squash)
	scale = _final_scale


## Пятно «проявляется» за время стройки: растёт и становится непрозрачным.
func appear(duration: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	modulate.a = 0.0
	scale = _final_scale * 0.75
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, maxf(duration, 0.1))
	_tween.tween_property(self, "scale", _final_scale, maxf(duration, 0.1)).set_ease(Tween.EASE_OUT)
