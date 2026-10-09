class_name GrayboxBugCutoutRigController
extends Node2D

@export_range(0.0, 1.0, 0.01) var walk_swing: float = 0.18
@export_range(0.1, 30.0, 0.1) var gait_angular_speed: float = 13.0
@export_range(0.0, 1.0, 0.01) var body_sway_x: float = 0.35
@export_range(0.0, 1.0, 0.01) var body_bob_y: float = 0.45
@export_range(0.0, 1.0, 0.01) var body_shadow_follow: float = 0.35
@export_range(0.0, 1.0, 0.01) var leg_shadow_fade_on_lift: float = 0.35
@export_range(0.0, 2.0, 0.01) var leg_shadow_lift_distance: float = 0.35

@onready var body_sprite: Sprite2D = $Body
@onready var body_shadow: Sprite2D = $BodyShadow
@onready var leg_front_left: Node2D = $LegFrontLeft
@onready var leg_middle_left: Node2D = $LegMiddleLeft
@onready var leg_back_left: Node2D = $LegBackLeft
@onready var leg_front_right: Node2D = $LegFrontRight
@onready var leg_middle_right: Node2D = $LegMiddleRight
@onready var leg_back_right: Node2D = $LegBackRight
@onready var leg_front_left_shadow: Sprite2D = $LegFrontLeft/Shadow
@onready var leg_middle_left_shadow: Sprite2D = $LegMiddleLeft/Shadow
@onready var leg_back_left_shadow: Sprite2D = $LegBackLeft/Shadow
@onready var leg_front_right_shadow: Sprite2D = $LegFrontRight/Shadow
@onready var leg_middle_right_shadow: Sprite2D = $LegMiddleRight/Shadow
@onready var leg_back_right_shadow: Sprite2D = $LegBackRight/Shadow

var gait_phase: float = 0.0
var body_rest_position: Vector2 = Vector2.ZERO
var body_shadow_rest_position: Vector2 = Vector2.ZERO
var body_shadow_rest_scale: Vector2 = Vector2.ONE
var body_shadow_rest_modulate: Color = Color.WHITE
var leg_pivots: Array[Node2D] = []
var leg_shadows: Array[Sprite2D] = []
var leg_shadow_rest_positions: Array[Vector2] = []
var leg_shadow_rest_scales: Array[Vector2] = []
var leg_shadow_rest_modulates: Array[Color] = []

func _ready() -> void:
	leg_pivots = [leg_front_left, leg_middle_left, leg_back_left, leg_front_right, leg_middle_right, leg_back_right]
	leg_shadows = [leg_front_left_shadow, leg_middle_left_shadow, leg_back_left_shadow, leg_front_right_shadow, leg_middle_right_shadow, leg_back_right_shadow]
	body_rest_position = body_sprite.position
	body_shadow_rest_position = body_shadow.position
	body_shadow_rest_scale = body_shadow.scale
	body_shadow_rest_modulate = body_shadow.modulate
	for shadow: Sprite2D in leg_shadows:
		leg_shadow_rest_positions.append(shadow.position)
		leg_shadow_rest_scales.append(shadow.scale)
		leg_shadow_rest_modulates.append(shadow.modulate)

func _process(delta: float) -> void:
	var bug: GrayboxBug = get_parent() as GrayboxBug
	if not is_instance_valid(bug):
		return
	var movement_ratio: float = clampf(bug.velocity.length() / maxf(bug.speed, 1.0), 0.0, 1.0)
	if movement_ratio <= 0.02:
		for index: int in leg_pivots.size():
			leg_pivots[index].rotation = move_toward(leg_pivots[index].rotation, 0.0, delta * 2.5)
			leg_shadows[index].position = leg_shadow_rest_positions[index]
			leg_shadows[index].scale = leg_shadow_rest_scales[index]
			leg_shadows[index].modulate = leg_shadow_rest_modulates[index]
		body_sprite.position = body_rest_position
		body_shadow.position = body_shadow_rest_position
		body_shadow.scale = body_shadow_rest_scale
		body_shadow.modulate = body_shadow_rest_modulate
		return
	gait_phase = fposmod(gait_phase + delta * gait_angular_speed * movement_ratio, TAU)
	for index: int in leg_pivots.size():
		var tripod_phase: float = gait_phase + (PI if index == 1 or index == 3 or index == 5 else 0.0)
		var side_sign: float = -1.0 if index < 3 else 1.0
		var position_sign: float = -1.0 if index % 3 != 1 else 1.0
		var step: float = sin(tripod_phase)
		var lift_factor: float = maxf(0.0, step)
		leg_pivots[index].rotation = step * walk_swing * side_sign * position_sign * movement_ratio
		leg_shadows[index].position = leg_shadow_rest_positions[index] + Vector2(0.0, -lift_factor * leg_shadow_lift_distance)
		leg_shadows[index].scale = leg_shadow_rest_scales[index] * Vector2(1.0 + lift_factor * 0.08, 1.0 - lift_factor * 0.12)
		var leg_shadow_modulate: Color = leg_shadow_rest_modulates[index]
		leg_shadow_modulate.a *= 1.0 - lift_factor * leg_shadow_fade_on_lift
		leg_shadows[index].modulate = leg_shadow_modulate
	body_sprite.position = body_rest_position + Vector2(cos(gait_phase) * body_sway_x, sin(gait_phase * 2.0) * body_bob_y) * movement_ratio
	var body_motion: Vector2 = body_sprite.position - body_rest_position
	body_shadow.position = body_shadow_rest_position + body_motion * body_shadow_follow
	var body_lift: float = maxf(0.0, -body_motion.y)
	body_shadow.scale = body_shadow_rest_scale * Vector2(1.0 + body_lift * 0.06, 1.0 - body_lift * 0.08)
	var body_shadow_modulate: Color = body_shadow_rest_modulate
	body_shadow_modulate.a *= 1.0 - body_lift * 0.05
	body_shadow.modulate = body_shadow_modulate
