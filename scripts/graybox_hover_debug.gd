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
	# Круги выделения и радиуса атаки убраны по дизайну: радиус показывает сама выбранная башня (GrayboxTower.set_range_visible).
	pass
