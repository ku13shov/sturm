class_name GroundShadow
extends Sprite2D

@export_group("Тень")
## Пользовательская текстура тени; пустое значение создаёт мягкий эллипс автоматически.
@export var shadow_texture: Texture2D
## Ширина тени, px; увеличение делает тень шире.
@export var width_px: float = 128.0
## Непрозрачность тени, доля 0–1; увеличение делает тень темнее.
@export_range(0.0, 1.0, 0.01) var opacity: float = 0.35
## Смещение тени вниз, px; увеличение опускает тень дальше от объекта.
@export var base_drop_px: float = 26.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	z_index = -3
	show_behind_parent = true
	# Sprite2D.offset is exposed by the native class and is used here as the
	# configurable light-direction offset. Convert it to a node position so it
	# remains in the same screen-pixel space as base_drop_px.
	var configured_offset: Vector2 = offset
	offset = Vector2.ZERO
	position = configured_offset
	if shadow_texture == null:
		shadow_texture = _create_default_shadow_texture()
	_apply_visual_scale()

func _create_default_shadow_texture() -> Texture2D:
	const TEXTURE_WIDTH: int = 128
	const TEXTURE_HEIGHT: int = 64
	var image: Image = Image.create(TEXTURE_WIDTH, TEXTURE_HEIGHT, false, Image.FORMAT_RGBA8)
	var center: Vector2 = Vector2(float(TEXTURE_WIDTH) * 0.5, float(TEXTURE_HEIGHT) * 0.5)
	var half_size: Vector2 = Vector2(float(TEXTURE_WIDTH) * 0.5, float(TEXTURE_HEIGHT) * 0.5)
	for y: int in TEXTURE_HEIGHT:
		for x: int in TEXTURE_WIDTH:
			var distance: float = absf(float(x) - center.x) / half_size.x + absf(float(y) - center.y) / half_size.y
			var alpha: float = 1.0 if distance <= 0.75 else 1.0 - smoothstep(0.75, 1.0, distance)
			image.set_pixel(x, y, Color(0.16, 0.045, 0.02, alpha))
	return ImageTexture.create_from_image(image)

func _apply_visual_scale() -> void:
	if shadow_texture == null:
		return
	var texture_size: Vector2 = shadow_texture.get_size()
	if texture_size.x <= 0.0:
		return
	texture = shadow_texture
	scale = Vector2.ONE * (width_px / texture_size.x)
	modulate = Color(1.0, 1.0, 1.0, opacity)

func set_shadow_width(value: float) -> void:
	width_px = maxf(value, 0.0)
	_apply_visual_scale()
