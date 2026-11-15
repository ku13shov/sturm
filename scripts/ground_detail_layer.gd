class_name GroundDetailLayer
extends Node2D
## Статичные детали земли: мелкие камешки.
## Рисуется кодом один раз (детерминированный seed), без новых текстур.

@export_group("Карта")
@export var half_extent: float = 1024.0
## Центр базы. Вокруг неё детали не рисуются.
@export var base_position: Vector2 = Vector2(216.0, 235.0)
@export var base_clear_radius: float = 120.0
@export var seed_value: int = 771204

@export_group("Камешки")
@export var pebbles_enabled: bool = true
@export_range(0, 400) var pebble_clusters: int = 110
@export var pebble_color: Color = Color(0.26, 0.16, 0.13, 0.55)
@export var pebble_highlight: Color = Color(0.62, 0.42, 0.34, 0.35)

## Вертикальное сжатие под изометрию, как у пятна под зданиями.
const VERTICAL_SQUASH: float = 0.7

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	z_index = 0
	queue_redraw()


func _draw() -> void:
	_rng.seed = seed_value
	if pebbles_enabled:
		_draw_pebbles()


func _is_free(point: Vector2) -> bool:
	return point.distance_to(base_position) > base_clear_radius


func _random_point() -> Vector2:
	return Vector2(
		_rng.randf_range(-half_extent + 40.0, half_extent - 40.0),
		_rng.randf_range(-half_extent + 40.0, half_extent - 40.0)
	)


func _draw_pebbles() -> void:
	var placed: int = 0
	var attempts: int = 0
	while placed < pebble_clusters and attempts < pebble_clusters * 6:
		attempts += 1
		var center: Vector2 = _random_point()
		if not _is_free(center):
			continue
		placed += 1
		var stones: int = _rng.randi_range(1, 4)
		for _stone: int in stones:
			var offset: Vector2 = Vector2(_rng.randf_range(-14.0, 14.0), _rng.randf_range(-8.0, 8.0))
			_draw_pebble(center + offset, _rng.randf_range(2.0, 6.0))


func _draw_pebble(center: Vector2, radius: float) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var sides: int = _rng.randi_range(5, 7)
	var start_angle: float = _rng.randf_range(0.0, TAU)
	for side: int in sides:
		var angle: float = start_angle + TAU * float(side) / float(sides)
		var wobble: float = _rng.randf_range(0.7, 1.15)
		points.append(center + Vector2(cos(angle), sin(angle) * VERTICAL_SQUASH) * radius * wobble)
	# Контактная тень под камнем, затем сам камень и светлая грань сверху.
	var shadow: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in points:
		shadow.append(point + Vector2(1.2, 1.6))
	draw_colored_polygon(shadow, Color(0.03, 0.02, 0.02, 0.28))
	draw_colored_polygon(points, pebble_color)
	var top: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in points:
		top.append(center + (point - center) * 0.55 + Vector2(-0.4, -radius * 0.18))
	draw_colored_polygon(top, pebble_highlight)
