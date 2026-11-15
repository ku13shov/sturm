class_name RockFormation
extends StaticBody2D
## Скальное образование: один из 4 спрайтов (large, medium_a, medium_b, small).
## Коллизия: один эллипс по следу скалы на земле (параметры foot_* в VARIANTS), без верхушки спрайта.

## width_px: ширина скалы в мире (без отражения), weight: доля появления среди всех скал.
## След на земле (эллипс, на который скала реально опирается), стартовые значения, подбираются по отладочной отрисовке:
## foot_rx и foot_ry: полуоси в долях ширины скалы в мире, foot_dy: смещение центра следа вниз от центра картинки в долях высоты картинки.
## block_ry: вертикальная полуось блокирующего эллипса (запрет строить и ходить) в долях ширины скалы. Нижний край совпадает
## с краем следа, а вверх эллипс растёт, чтобы закрыть то, что скала перекрывает на экране (там нельзя строить).
const VARIANTS: Array = [
	{"texture": preload("res://assets/map/rock_large.webp"), "width_px": 300.0, "weight": 0.15, "foot_rx": 0.39, "foot_ry": 0.18, "foot_dy": 0.17, "block_ry": 0.30},
	{"texture": preload("res://assets/map/rock_medium_a.webp"), "width_px": 210.0, "weight": 0.25, "foot_rx": 0.40, "foot_ry": 0.21, "foot_dy": 0.22, "block_ry": 0.32},
	{"texture": preload("res://assets/map/rock_medium_b.webp"), "width_px": 175.0, "weight": 0.25, "foot_rx": 0.40, "foot_ry": 0.21, "foot_dy": 0.22, "block_ry": 0.30},
	{"texture": preload("res://assets/map/rock_small.webp"), "width_px": 115.0, "weight": 0.35, "foot_rx": 0.36, "foot_ry": 0.19, "foot_dy": 0.19, "block_ry": 0.30},
]

## Число точек полигона коллизии-эллипса.
const COLLISION_POINTS: int = 24

var _variant_index: int = 0


static func pick_variant(rng: RandomNumberGenerator) -> int:
	var roll: float = rng.randf()
	var accumulated: float = 0.0
	for index: int in VARIANTS.size():
		var data: Dictionary = VARIANTS[index] as Dictionary
		accumulated += float(data["weight"])
		if roll < accumulated:
			return index
	return VARIANTS.size() - 1


## Ставит спрайт, масштаб, коллизию. Возвращает полуширину скалы в мире (px).
## Вызывать до отражения по X и до add_child.
func apply_variant(index: int, size_jitter: float = 1.0) -> float:
	var data: Dictionary = VARIANTS[clampi(index, 0, VARIANTS.size() - 1)] as Dictionary
	_variant_index = clampi(index, 0, VARIANTS.size() - 1)
	var texture: Texture2D = data["texture"] as Texture2D
	var sprite: Sprite2D = get_node("Sprite") as Sprite2D
	sprite.texture = texture
	var texture_size: Vector2 = texture.get_size()
	var rock_scale: float = float(data["width_px"]) / texture_size.x * size_jitter
	scale = Vector2.ONE * rock_scale
	_build_collision(index, texture)
	return texture_size.x * 0.5 * rock_scale


## Отражает скалу по X (коллизия отражается вместе со спрайтом).
func set_flipped(flipped: bool) -> void:
	scale.x = absf(scale.x) * (-1.0 if flipped else 1.0)


## След скалы на земле: эллипс в координатах родителя (entities-local), с учётом масштаба и size_jitter.
## Возвращает {"center": Vector2, "rx": float, "ry": float}. Отражение по X на симметричный эллипс не влияет.
## Вызывать после apply_variant.
func footprint_in_world() -> Dictionary:
	return footprint_at(_variant_index, absf(scale.x), position)


## Блокирующий эллипс (запрет строить и ходить): нижний край на уровне края следа, вверх растёт до block_ry,
## чтобы закрыть часть скалы над следом (за скалой строить нельзя, иначе скала перекроет здание).
## Возвращает {"center": Vector2, "rx": float, "ry": float}. Вызывать после apply_variant.
func blocking_ellipse_in_world() -> Dictionary:
	return blocking_ellipse_at(_variant_index, absf(scale.x), position)


## Масштаб узла для варианта и разброса размера (то же, что ставит apply_variant).
static func scale_for(index: int, size_jitter: float = 1.0) -> float:
	var data: Dictionary = VARIANTS[clampi(index, 0, VARIANTS.size() - 1)] as Dictionary
	var texture_size: Vector2 = (data["texture"] as Texture2D).get_size()
	return float(data["width_px"]) / texture_size.x * size_jitter


## Ширина скалы в мире (px) для варианта и разброса размера.
static func world_width_for(index: int, size_jitter: float = 1.0) -> float:
	var data: Dictionary = VARIANTS[clampi(index, 0, VARIANTS.size() - 1)] as Dictionary
	return float(data["width_px"]) * size_jitter


## След скалы без создания узла: rock_scale это абсолютное значение scale узла (scale_for), pos это position узла.
static func footprint_at(index: int, rock_scale: float, pos: Vector2) -> Dictionary:
	var data: Dictionary = VARIANTS[clampi(index, 0, VARIANTS.size() - 1)] as Dictionary
	var texture_size: Vector2 = (data["texture"] as Texture2D).get_size()
	var world_width: float = texture_size.x * rock_scale
	var world_height: float = texture_size.y * rock_scale
	return {
		"center": pos + Vector2(0.0, float(data["foot_dy"]) * world_height),
		"rx": float(data["foot_rx"]) * world_width,
		"ry": float(data["foot_ry"]) * world_width,
	}


## Блокирующий эллипс без создания узла (см. blocking_ellipse_in_world).
static func blocking_ellipse_at(index: int, rock_scale: float, pos: Vector2) -> Dictionary:
	var data: Dictionary = VARIANTS[clampi(index, 0, VARIANTS.size() - 1)] as Dictionary
	var world_width: float = (data["texture"] as Texture2D).get_size().x * rock_scale
	var footprint: Dictionary = footprint_at(index, rock_scale, pos)
	var foot_ry: float = float(footprint["ry"])
	var block_ry: float = maxf(float(data["block_ry"]) * world_width, foot_ry)
	var center: Vector2 = footprint["center"] as Vector2
	center.y -= block_ry - foot_ry
	return {"center": center, "rx": float(footprint["rx"]), "ry": block_ry}


## Коллизия: один эллипс по следу скалы на земле (то, на чём скала реально стоит), а не по всему силуэту с верхушкой.
## Строится в локальных координатах узла (до масштаба), масштаб и отражение применяются самим узлом.
func _build_collision(index: int, texture: Texture2D) -> void:
	var old_shape: Node = get_node_or_null("CollisionShape2D")
	if old_shape != null:
		old_shape.queue_free()
	var old_polygon: Node = get_node_or_null("FootprintCollision")
	if old_polygon != null:
		old_polygon.free()
	var data: Dictionary = VARIANTS[clampi(index, 0, VARIANTS.size() - 1)] as Dictionary
	var texture_size: Vector2 = texture.get_size()
	var center: Vector2 = Vector2(0.0, float(data["foot_dy"]) * texture_size.y)
	var radius_x: float = float(data["foot_rx"]) * texture_size.x
	var radius_y: float = float(data["foot_ry"]) * texture_size.x
	var polygon: PackedVector2Array = PackedVector2Array()
	for point_index: int in COLLISION_POINTS:
		var angle: float = TAU * float(point_index) / float(COLLISION_POINTS)
		polygon.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	var collision: CollisionPolygon2D = CollisionPolygon2D.new()
	collision.name = "FootprintCollision"
	collision.polygon = polygon
	add_child(collision)
