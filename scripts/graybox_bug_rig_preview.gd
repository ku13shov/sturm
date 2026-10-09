class_name GrayboxBugRigPreview
extends Node2D

@export var preview_velocity: Vector2 = Vector2(0.0, -42.0)
@export var animation_enabled: bool = true
@export var attack_preview_enabled: bool = true
@export_range(0.5, 5.0, 0.1) var attack_preview_interval: float = 2.2

@onready var preview_bug: GrayboxBug = $GrayboxBug

var attack_preview_timer: float = 0.0

func _process(delta: float) -> void:
	if not is_instance_valid(preview_bug):
		return
	preview_bug.velocity = preview_velocity if animation_enabled else Vector2.ZERO
	if attack_preview_enabled:
		attack_preview_timer -= delta
		if attack_preview_timer <= 0.0:
			attack_preview_timer = attack_preview_interval
			preview_bug.attack_animation_remaining = preview_bug.attack_animation_duration
