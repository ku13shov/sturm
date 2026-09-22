class_name BasicBugWalker
extends CharacterBody3D

@export var speed: float = 1.8
@export var arena_half_size: float = 4.5

var direction: Vector3 = Vector3(1.0, 0.0, 0.35).normalized()
var animation_player: AnimationPlayer

func _ready() -> void:
	animation_player = get_node("BugModel/AnimationPlayer") as AnimationPlayer
	var walk_animation: Animation = animation_player.get_animation("walk")
	if walk_animation != null:
		walk_animation.loop_mode = Animation.LOOP_LINEAR
	animation_player.play("walk")
	_update_facing()

func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()
	if global_position.x <= -arena_half_size or global_position.x >= arena_half_size:
		direction.x = -direction.x
		global_position.x = clampf(global_position.x, -arena_half_size, arena_half_size)
	if global_position.z <= -arena_half_size or global_position.z >= arena_half_size:
		direction.z = -direction.z
		global_position.z = clampf(global_position.z, -arena_half_size, arena_half_size)
	_update_facing()

func _update_facing() -> void:
	rotation.y = atan2(-direction.x, -direction.z)
