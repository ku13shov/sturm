class_name GrayboxBugCutoutRig
extends Node2D

const BUG_SCALE: float = 0.027
const BODY_TEXTURE: Texture2D = preload("res://assets/generated/bug/body_with_head.png")
const LEG_TEXTURES: Array[Texture2D] = [
	preload("res://assets/generated/bug/leg_front_left.png"),
	preload("res://assets/generated/bug/leg_middle_left.png"),
	preload("res://assets/generated/bug/leg_back_left.png"),
	preload("res://assets/generated/bug/leg_front_right.png"),
	preload("res://assets/generated/bug/leg_middle_right.png"),
	preload("res://assets/generated/bug/leg_back_right.png")
]
const LEG_NAMES: Array[String] = ["LegFrontLeft", "LegMiddleLeft", "LegBackLeft", "LegFrontRight", "LegMiddleRight", "LegBackRight"]
const LEG_PIVOTS: Array[Vector2] = [
	Vector2(-5.0, -5.0), Vector2(-7.0, -0.2), Vector2(-5.0, 6.0),
	Vector2(5.0, -5.0), Vector2(7.0, -0.2), Vector2(5.0, 6.0)
]
# Pixel coordinates of each cutout's visible hip joint, measured from its image top-left.
const LEG_HIPS: Array[Vector2] = [
	Vector2(246.0, 72.0), Vector2(183.0, 47.0), Vector2(177.0, 38.0),
	Vector2(31.0, 58.0), Vector2(28.0, 43.0), Vector2(24.0, 34.0)
]
const LEG_SWING: float = 0.18
const GAIT_ANGULAR_SPEED: float = 13.0

var leg_pivots: Array[Node2D] = []
var gait_phase: float = 0.0
var body_sprite: Sprite2D
var body_rest_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_build_rig()

func _build_rig() -> void:
	for index: int in LEG_TEXTURES.size():
		var pivot: Node2D = Node2D.new()
		pivot.name = LEG_NAMES[index]
		pivot.position = LEG_PIVOTS[index]
		pivot.z_index = 0
		add_child(pivot)
		var leg_sprite: Sprite2D = Sprite2D.new()
		leg_sprite.name = "Sprite"
		leg_sprite.texture = LEG_TEXTURES[index]
		leg_sprite.position = (LEG_TEXTURES[index].get_size() * 0.5 - LEG_HIPS[index]) * BUG_SCALE
		leg_sprite.scale = Vector2.ONE * BUG_SCALE
		pivot.add_child(leg_sprite)
		leg_pivots.append(pivot)
	body_sprite = Sprite2D.new()
	body_sprite.name = "Body"
	body_sprite.texture = BODY_TEXTURE
	body_sprite.scale = Vector2.ONE * BUG_SCALE
	body_sprite.z_index = 2
	add_child(body_sprite)
	body_rest_position = body_sprite.position

func _process(delta: float) -> void:
	var bug: GrayboxBug = get_parent() as GrayboxBug
	if not is_instance_valid(bug):
		return
	var movement_ratio: float = clampf(bug.velocity.length() / maxf(bug.speed, 1.0), 0.0, 1.0)
	if movement_ratio <= 0.02:
		for pivot: Node2D in leg_pivots:
			pivot.rotation = move_toward(pivot.rotation, 0.0, delta * 2.5)
		body_sprite.position = body_rest_position
		return
	gait_phase = fposmod(gait_phase + delta * GAIT_ANGULAR_SPEED * movement_ratio, TAU)
	for index: int in leg_pivots.size():
		var tripod_phase: float = gait_phase + (PI if index == 1 or index == 3 or index == 5 else 0.0)
		var side_sign: float = -1.0 if index < 3 else 1.0
		var position_sign: float = -1.0 if index % 3 != 1 else 1.0
		leg_pivots[index].rotation = sin(tripod_phase) * LEG_SWING * side_sign * position_sign * movement_ratio
	body_sprite.position = body_rest_position + Vector2(cos(gait_phase) * 0.35, sin(gait_phase * 2.0) * 0.45) * movement_ratio
