class_name BaseBugModularRig
extends Node2D

@export_range(0.0, 1.2, 0.01) var leg_swing: float = 0.34
@export_range(0.0, 1.5, 0.01) var tip_bend: float = 0.48
@export_range(0.1, 24.0, 0.1) var gait_speed: float = 7.2
@export_range(0.0, 30.0, 0.1) var idle_rate: float = 1.1
@export_range(0.0, 0.08, 0.001) var body_breath_scale: float = 0.012
@export_range(0.0, 0.12, 0.001) var idle_head_bob: float = 0.035
@export_range(0.0, 0.5, 0.01) var mandible_twitch: float = 0.045
@export_range(0.0, 40.0, 0.5) var foot_shadow_lift_pixels: float = 14.0
@export_range(0.0, 1.0, 0.01) var foot_shadow_fade: float = 0.48
@export_range(0.0, 1.0, 0.01) var body_shadow_follow: float = 0.28
@export_range(0.0, 120.0, 1.0) var attack_head_lunge: float = 18.0
@export_range(0.0, 0.8, 0.01) var attack_mandible_open: float = 0.22
@export_range(0.0, 0.3, 0.01) var attack_head_tilt: float = 0.06

@onready var body_sprite: Sprite2D = $Body
@onready var body_shadow: Sprite2D = $BodyShadow
@onready var head_pivot: Node2D = $HeadPivot
@onready var mandible_left_pivot: Node2D = $MandibleLeftPivot
@onready var mandible_right_pivot: Node2D = $MandibleRightPivot
@onready var leg_bases: Array[Node2D] = [
	$LegsBehindBody/LeftFrontBase,
	$LegsBehindBody/LeftMiddleBase,
	$LegsBehindBody/LeftBackBase,
	$LegsBehindBody/RightFrontBase,
	$LegsBehindBody/RightMiddleBase,
	$LegsBehindBody/RightBackBase,
]
@onready var leg_tips: Array[Node2D] = [
	$LegsBehindBody/LeftFrontBase/TipPivot,
	$LegsBehindBody/LeftMiddleBase/TipPivot,
	$LegsBehindBody/LeftBackBase/TipPivot,
	$LegsBehindBody/RightFrontBase/TipPivot,
	$LegsBehindBody/RightMiddleBase/TipPivot,
	$LegsBehindBody/RightBackBase/TipPivot,
]
@onready var leg_tip_shadows: Array[Sprite2D] = [
	$LegsBehindBody/LeftFrontBase/TipPivot/Shadow,
	$LegsBehindBody/LeftMiddleBase/TipPivot/Shadow,
	$LegsBehindBody/LeftBackBase/TipPivot/Shadow,
	$LegsBehindBody/RightFrontBase/TipPivot/Shadow,
	$LegsBehindBody/RightMiddleBase/TipPivot/Shadow,
	$LegsBehindBody/RightBackBase/TipPivot/Shadow,
]

var gait_phase: float = 0.0
var idle_phase: float = 0.0
var body_rest_position: Vector2 = Vector2.ZERO
var body_rest_scale: Vector2 = Vector2.ONE
var body_shadow_rest_position: Vector2 = Vector2.ZERO
var base_rest_rotations: Array[float] = []
var tip_rest_rotations: Array[float] = []
var tip_shadow_rest_positions: Array[Vector2] = []
var tip_shadow_rest_modulates: Array[Color] = []
var left_mandible_rest_rotation: float = 0.0
var right_mandible_rest_rotation: float = 0.0
var head_rest_rotation: float = 0.0
var head_rest_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	body_rest_position = body_sprite.position
	body_rest_scale = body_sprite.scale
	body_shadow_rest_position = body_shadow.position
	head_rest_rotation = head_pivot.rotation
	head_rest_position = head_pivot.position
	left_mandible_rest_rotation = mandible_left_pivot.rotation
	right_mandible_rest_rotation = mandible_right_pivot.rotation
	for index: int in leg_bases.size():
		base_rest_rotations.append(leg_bases[index].rotation)
		tip_rest_rotations.append(leg_tips[index].rotation)
		tip_shadow_rest_positions.append(leg_tip_shadows[index].position)
		tip_shadow_rest_modulates.append(leg_tip_shadows[index].modulate)

func _process(delta: float) -> void:
	var bug: GrayboxBug = get_parent() as GrayboxBug
	if not is_instance_valid(bug):
		return
	var movement_ratio: float = clampf(bug.velocity.length() / maxf(bug.speed, 1.0), 0.0, 1.35)
	if movement_ratio > 0.025:
		gait_phase = fposmod(gait_phase + delta * gait_speed * maxf(movement_ratio, 0.2), TAU)
	else:
		idle_phase = fposmod(idle_phase + delta * idle_rate, TAU)
	var walking: bool = movement_ratio > 0.025
	var phase: float = gait_phase if walking else idle_phase
	var attack_amount: float = 0.0
	if bug.attack_animation_duration > 0.0:
		var attack_progress: float = 1.0 - bug.attack_animation_remaining / bug.attack_animation_duration
		attack_amount = sin(clampf(attack_progress, 0.0, 1.0) * PI)
	_animate_body(phase, movement_ratio, walking, attack_amount)
	_animate_head_and_mandibles(phase, movement_ratio, walking, attack_amount)
	_animate_legs(phase, movement_ratio, walking)

func _animate_body(phase: float, movement_ratio: float, walking: bool, attack_amount: float) -> void:
	var bob: float = sin(phase * (2.0 if walking else 1.0))
	var breath: float = sin(phase * 2.0 + 0.6)
	body_sprite.position = body_rest_position + Vector2(cos(phase) * 2.0, bob * (2.5 if walking else 1.4)) * (movement_ratio if walking else 1.0)
	body_sprite.position.y += attack_amount * 2.0
	var breath_scale: float = breath * body_breath_scale
	body_sprite.scale = body_rest_scale * Vector2(1.0 + breath_scale, 1.0 - breath_scale)
	var body_delta: Vector2 = body_sprite.position - body_rest_position
	body_shadow.position = body_shadow_rest_position + body_delta * body_shadow_follow

func _animate_head_and_mandibles(phase: float, movement_ratio: float, walking: bool, attack_amount: float) -> void:
	var motion_amount: float = movement_ratio if walking else 0.32
	head_pivot.rotation = head_rest_rotation + sin(phase * 1.4) * (0.018 if walking else 0.012) * motion_amount
	head_pivot.rotation += attack_amount * attack_head_tilt
	head_pivot.position = head_rest_position + Vector2(0.0, sin(phase * 2.0) * (2.2 if walking else idle_head_bob * 32.0))
	head_pivot.position.y -= attack_amount * attack_head_lunge
	var twitch: float = sin(phase * (3.0 if walking else 2.3)) * mandible_twitch * motion_amount
	mandible_left_pivot.rotation = left_mandible_rest_rotation + twitch + attack_amount * attack_mandible_open
	mandible_right_pivot.rotation = right_mandible_rest_rotation - twitch - attack_amount * attack_mandible_open

func _animate_legs(phase: float, movement_ratio: float, walking: bool) -> void:
	for index: int in leg_bases.size():
		var tripod_phase: float = phase + (PI if index == 1 or index == 3 or index == 5 else 0.0)
		var step: float = sin(tripod_phase)
		var lift: float = maxf(step, 0.0) if walking else sin(phase * 2.0 + float(index) * 0.85) * 0.08
		var side_sign: float = -1.0 if index < 3 else 1.0
		var reach_sign: float = -1.0 if index % 3 == 0 else 1.0
		var swing_amount: float = movement_ratio if walking else 0.28
		leg_bases[index].rotation = base_rest_rotations[index] + step * leg_swing * side_sign * reach_sign * swing_amount
		leg_tips[index].rotation = tip_rest_rotations[index] - lift * tip_bend * side_sign * swing_amount
		var shadow: Sprite2D = leg_tip_shadows[index]
		shadow.position = tip_shadow_rest_positions[index] + Vector2(0.0, -lift * foot_shadow_lift_pixels)
		var shadow_modulate: Color = tip_shadow_rest_modulates[index]
		shadow_modulate.a *= 1.0 - lift * foot_shadow_fade
		shadow.modulate = shadow_modulate
