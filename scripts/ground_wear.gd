class_name GroundWear
extends Node2D
## Потёртости земли вокруг здания: короткие тёмные борозды и пара камешков.
## Живёт дочерним узлом здания, поэтому исчезает вместе с ним.

@export var radius: float = 52.0
@export var scuff_count: int = 8
@export var scuff_color: Color = Color(0.12, 0.07, 0.06, 0.26)
@export var pebble_color: Color = Color(0.26, 0.16, 0.13, 0.55)

const VERTICAL_SQUASH: float = 0.58


func _ready() -> void:
	# Ниже самого здания, но выше земли и пятна под ним.
	z_index = -4
	queue_redraw()


func _draw() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	# Seed от позиции, чтобы у каждого здания был свой, но стабильный рисунок.
	rng.seed = hash(Vector2i(int(global_position.x), int(global_position.y)))
	for _index: int in scuff_count:
		var angle: float = rng.randf_range(0.0, TAU)
		var distance: float = radius * rng.randf_range(0.8, 1.25)
		var direction: Vector2 = Vector2(cos(angle), sin(angle) * VERTICAL_SQUASH)
		var start: Vector2 = direction * distance
		var tangent: Vector2 = Vector2(-sin(angle), cos(angle) * VERTICAL_SQUASH).normalized()
		var length: float = rng.randf_range(10.0, 26.0)
		var points: PackedVector2Array = PackedVector2Array()
		for step: int in 4:
			var t: float = float(step) / 3.0
			points.append(start + tangent * length * (t - 0.5) + direction.normalized() * rng.randf_range(-1.5, 1.5))
		draw_polyline(points, scuff_color, rng.randf_range(1.6, 2.8), true)
	for _stone: int in 3:
		var stone_angle: float = rng.randf_range(0.0, TAU)
		var stone_center: Vector2 = Vector2(cos(stone_angle), sin(stone_angle) * VERTICAL_SQUASH) * radius * rng.randf_range(0.9, 1.35)
		var stone_radius: float = rng.randf_range(1.8, 3.6)
		draw_circle(stone_center + Vector2(0.8, 1.2), stone_radius, Color(0.03, 0.02, 0.02, 0.28))
		draw_circle(stone_center, stone_radius, pebble_color)
