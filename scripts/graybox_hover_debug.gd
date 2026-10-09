class_name GrayboxHoverDebug
extends Node2D

var center: Vector2 = Vector2.ZERO
var selection_radius: float = 0.0
var occupation_radius: float = 0.0
var attack_radius: float = 0.0
var active: bool = false

func show_radii(next_center: Vector2, next_selection: float, next_occupation: float, next_attack: float) -> void:
	center = next_center
	selection_radius = next_selection
	occupation_radius = next_occupation
	attack_radius = next_attack
	active = true
	queue_redraw()

func hide_radii() -> void:
	active = false
	queue_redraw()

func _draw() -> void:
	if not active:
		return
	var physical_radius: float = occupation_radius if occupation_radius > 0.0 else selection_radius
	_draw_circle(physical_radius, Color(1.0, 0.55, 0.15, 0.95), 3.0)
	if attack_radius > 0.0:
		_draw_circle(attack_radius, Color(0.2, 0.75, 1.0, 0.65), 2.0)

func _draw_circle(radius: float, color: Color, width: float) -> void:
	if radius <= 0.0:
		return
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(64):
		var angle: float = TAU * float(index) / 64.0
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	points.append(points[0])
	draw_polyline(points, color, width, true)
