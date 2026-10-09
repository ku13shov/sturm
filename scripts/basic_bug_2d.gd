class_name BasicBug2D
extends CharacterBody2D

@export var speed: float = 70.0
@export var arena_rect: Rect2 = Rect2(48.0, 48.0, 640.0, 360.0)

var direction: Vector2 = Vector2.RIGHT

func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()
	if global_position.x <= arena_rect.position.x or global_position.x >= arena_rect.end.x:
		direction.x = -direction.x
		global_position.x = clampf(global_position.x, arena_rect.position.x, arena_rect.end.x)
	if global_position.y <= arena_rect.position.y or global_position.y >= arena_rect.end.y:
		direction.y = -direction.y
		global_position.y = clampf(global_position.y, arena_rect.position.y, arena_rect.end.y)
	_update_facing()

func _update_facing() -> void:
	$AnimatedSprite2D.flip_h = direction.x < 0.0
