class_name GrayboxBug
extends CharacterBody2D

const MOVEMENT_ACCELERATION: float = 150.0
const MOVEMENT_DECELERATION: float = 220.0
## За сколько секунд до удара запускается анимация атаки, чтобы кадр удара совпал с уроном.
const ATTACK_VISUAL_LEAD: float = 0.18

signal health_changed(current_health: float, maximum_health: float)
signal died

@export var enemy_id: int = 70
@export var max_health: float = 30.0
@export var speed: float = 42.0
@export var attack_interval: float = 1.0
@export_range(0.05, 1.0, 0.01) var attack_animation_duration: float = 0.30
@export var temporary_balance_status: String = "TEMPORARY_BALANCE"
@export var use_new_bug_visual: bool = true
## Единый листовой жук на 8 направлений (BugSheetVisual8Dir). Если лист не найден, узел отключается сам и показывается NewBugVisual.
@export var use_sheet_bug_8dir: bool = true
@export var bug_visual_height_px: float = 36.0

@onready var health_bar: ProgressBar = $HealthBar
@onready var new_bug_visual: Node2D = get_node_or_null("NewBugVisual") as Node2D
@onready var sheet_bug_8dir: Node2D = get_node_or_null("BugSheetVisual8Dir") as Node2D
@onready var legacy_bug_visual: Node2D = get_node_or_null("BugAnimatedSprite") as Node2D

var profile: Dictionary = {}
var health: float = 0.0
var source_damage: float = 0.0
var source_attack_range: float = 0.0
var resistances: Dictionary = {}
var target: Node2D
var target_provider: Callable
@export var target_detection_radius: float = 150.0
@export var damage_scale: float = 0.1
@export var graybox_damage: float = 3.0
var attack_cooldown: float = 0.0
var attack_animation_remaining: float = 0.0
var hit_flash_tween: Tween
var paralyzed_until: float = 0.0
var path_points: Array[Vector2] = []
var path_index: int = 0
var registered_with_wave: bool = false
var base_engaged: bool = false
var secondary_target_engaged: bool = false

func _ready() -> void:
	if is_instance_valid(new_bug_visual):
		new_bug_visual.visible = use_new_bug_visual
		var visual_script: Node = new_bug_visual
		visual_script.set("bug_visual_height_px", bug_visual_height_px)
	if is_instance_valid(legacy_bug_visual):
		legacy_bug_visual.visible = not use_new_bug_visual
	if is_instance_valid(sheet_bug_8dir):
		sheet_bug_8dir.call("set_visual_height_px", 26.0)
	_update_visual_direction()
	# Navigation already routes around rocks. Do not let CharacterBody2D physics
	# re-collide with those rocks, otherwise a corner on one map side can trap
	# or slide a bug away from its route and create a side-dependent delay.
	collision_mask = 0
	safe_margin = 0.0
	add_to_group("graybox_enemies")
	profile = GameBalance.ENEMY_PROFILES.get(enemy_id, GameBalance.ENEMY_PROFILES[70])
	source_damage = graybox_damage if graybox_damage > 0.0 else float(profile["damage"]) * damage_scale
	source_attack_range = float(profile["attack_range"])
	resistances = {
		"bullet": float(profile["bullet_resistance"]),
		"energy": float(profile["energy_resistance"]),
		"fire": float(profile["fire_resistance"])
	}
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.visible = false
	health_changed.emit(health, max_health)

## Масштаб карты (зум): родитель жука масштабируется, а CharacterBody2D двигается
## в глобальных пикселях. Все скорости и дистанции считаем в единицах карты и
## умножаем на этот коэффициент только при записи velocity.
func map_scale() -> float:
	var parent_node: Node2D = get_parent() as Node2D
	if not is_instance_valid(parent_node):
		return 1.0
	return maxf(absf(parent_node.global_scale.x), 0.01)

func _update_visual_direction() -> void:
	# Направление и анимацию внутри BugSheetVisual8Dir выбирает сам узел по фактической скорости.
	var sheet_active: bool = _sheet_8dir_active()
	if is_instance_valid(sheet_bug_8dir):
		sheet_bug_8dir.visible = sheet_active
	if is_instance_valid(new_bug_visual):
		new_bug_visual.visible = use_new_bug_visual and not sheet_active

func _sheet_8dir_active() -> bool:
	if not use_sheet_bug_8dir or not is_instance_valid(sheet_bug_8dir):
		return false
	return bool(sheet_bug_8dir.get("available"))

func set_target(base: GrayboxBase) -> void:
	target = base

func set_target_provider(provider: Callable) -> void:
	target_provider = provider

func set_path(points: Array[Vector2]) -> void:
	path_points = points.duplicate()
	path_index = 0

func _path_point_to_global(index: int) -> Vector2:
	# path_points live in the grid-local frame of Playfield/Entities (the same
	# frame as the placed base and towers). The bug is a child of that frame, so
	# the point must be converted to global before steering. Comparing a global
	# position against a raw local point rotates the heading by the entities
	# offset, which makes the bug walk away from the base after spawning.
	if index < 0 or index >= path_points.size():
		return global_position
	var frame: Node2D = get_parent() as Node2D
	if frame == null:
		return path_points[index]
	return frame.to_global(path_points[index])

func save_state() -> Dictionary:
	var path_data: Array[Dictionary] = []
	for point: Vector2 in path_points:
		path_data.append({"x": point.x, "y": point.y})
	return {
		"enemy_id": enemy_id,
		"x": global_position.x,
		"y": global_position.y,
		"health": health,
		"path": path_data,
		"path_index": path_index,
		"attack_cooldown": attack_cooldown,
		"paralyze_remaining": maxf(paralyzed_until - Time.get_ticks_msec() / 1000.0, 0.0),
		"registered_with_wave": registered_with_wave
	}

func restore_saved_state(data: Dictionary) -> void:
	health = clampf(float(data.get("health", max_health)), 0.1, max_health)
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.visible = health < max_health
	attack_cooldown = clampf(float(data.get("attack_cooldown", 0.0)), 0.0, attack_interval)
	paralyze(float(data.get("paralyze_remaining", 0.0)))
	var saved_path: Variant = data.get("path", [])
	var restored_path: Array[Vector2] = []
	if saved_path is Array:
		for point_value: Variant in saved_path as Array:
			if point_value is Dictionary:
				var point_data: Dictionary = point_value as Dictionary
				restored_path.append(Vector2(float(point_data.get("x", 0.0)), float(point_data.get("y", 0.0))))
	path_points = restored_path
	path_index = clampi(int(data.get("path_index", 0)), 0, path_points.size())
	registered_with_wave = bool(data.get("registered_with_wave", false))

func paralyze(duration: float) -> void:
	paralyzed_until = maxf(paralyzed_until, Time.get_ticks_msec() / 1000.0 + duration)
	velocity = Vector2.ZERO

func _target_is_alive() -> bool:
	if not is_instance_valid(target):
		return false
	return float(target.get("health")) > 0.0

func _physics_process(delta: float) -> void:
	attack_animation_remaining = maxf(attack_animation_remaining - delta, 0.0)
	if secondary_target_engaged and not _target_is_alive():
		# A destroyed diversion must never leave the bug idle.
		secondary_target_engaged = false
		base_engaged = false
		target = null
		path_points.clear()
		path_index = 0
	if Time.get_ticks_msec() / 1000.0 < paralyzed_until:
		velocity = Vector2.ZERO
		return
	if target_provider.is_valid() and not base_engaged and not secondary_target_engaged:
		var fallback_target: Node2D = target if is_instance_valid(target) else null
		var nearby_target: Variant = target_provider.call(global_position, fallback_target)
		if nearby_target is Node2D:
			target = nearby_target as Node2D
	if not is_instance_valid(target) or not _target_is_alive():
		velocity = Vector2.ZERO
		return
	var map_zoom_scale: float = map_scale()
	var distance_to_target: float = global_position.distance_to(target.global_position) / map_zoom_scale
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	if distance_to_target > 34.0:
		var destination: Vector2 = target.global_position
		# Once a building is selected, pursue that building directly. The old
		# base path must not make the bug walk past a valid defensive target.
		var pursuing_secondary_target: bool = target is GrayboxTower
		if not pursuing_secondary_target and path_index < path_points.size():
			destination = _path_point_to_global(path_index)
			if global_position.distance_to(destination) / map_zoom_scale < 8.0:
				path_index += 1
				if path_index < path_points.size():
					destination = _path_point_to_global(path_index)
		var controlled_speed: float = minf(speed, 50.0)
		var separation: Vector2 = Vector2.ZERO
		for other_node: Node in get_tree().get_nodes_in_group("graybox_enemies"):
			var other_bug: GrayboxBug = other_node as GrayboxBug
			if not is_instance_valid(other_bug) or other_bug == self:
				continue
			var offset: Vector2 = global_position - other_bug.global_position
			var distance: float = offset.length() / map_zoom_scale
			if distance > 0.01 and distance < 34.0:
				separation += offset.normalized() * (34.0 - distance) / 34.0
		var desired_direction: Vector2 = global_position.direction_to(destination)
		if separation.length_squared() > 0.01:
			# Use a gentle, damped avoidance vector to prevent left/right oscillation.
			desired_direction = (desired_direction + separation.normalized() * 0.32).normalized()
		# velocity is in global pixels; speeds above are in map units.
		var target_velocity: Vector2 = desired_direction * controlled_speed * map_zoom_scale
		var acceleration: float = (MOVEMENT_ACCELERATION if velocity.dot(target_velocity) >= 0.0 else MOVEMENT_DECELERATION) * map_zoom_scale
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		var bug_sprite: Node2D = get_node_or_null("BugAnimatedSprite") as Node2D
		if not use_new_bug_visual and is_instance_valid(bug_sprite) and velocity.length_squared() > 0.01:
			# The modular beetle faces up; rotate it smoothly to match travel direction.
			bug_sprite.rotation = lerp_angle(bug_sprite.rotation, velocity.angle() + PI / 2.0, clampf(delta * 8.0, 0.0, 1.0))
		_update_visual_direction()
		move_and_slide()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, MOVEMENT_DECELERATION * map_zoom_scale * delta)
		_update_visual_direction()
		if target is GrayboxBase:
			base_engaged = true
		elif target is GrayboxTower:
			secondary_target_engaged = true
		if _sheet_8dir_active() and attack_cooldown <= ATTACK_VISUAL_LEAD:
			sheet_bug_8dir.call("play_attack", target.global_position - global_position)
		if attack_cooldown <= 0.0:
			target.call("take_damage", source_damage)
			attack_cooldown = attack_interval
			attack_animation_remaining = attack_animation_duration

func take_typed_damage(raw_amount: float, channel: String) -> void:
	if raw_amount <= 0.0 or health <= 0.0:
		return
	var resistance_percent: float = float(resistances.get(channel, 0.0))
	var effective_amount: float = raw_amount * maxf(0.0, 1.0 - resistance_percent / 100.0)
	health = maxf(health - effective_amount, 0.0)
	health_bar.value = health
	if use_new_bug_visual and is_instance_valid(new_bug_visual) and new_bug_visual.visible:
		new_bug_visual.call("on_hit")
	if _sheet_8dir_active() and sheet_bug_8dir.visible:
		sheet_bug_8dir.call("on_hit")
	var animated_bug: Sprite2D = get_node_or_null("BugAnimatedSprite/Body") as Sprite2D
	if not use_new_bug_visual and is_instance_valid(animated_bug):
		if hit_flash_tween != null and hit_flash_tween.is_valid():
			hit_flash_tween.kill()
		animated_bug.modulate = Color(1.0, 0.35, 0.25, 1.0)
		hit_flash_tween = create_tween()
		hit_flash_tween.tween_property(animated_bug, "modulate", Color.WHITE, 0.10)
	health_bar.visible = true
	health_changed.emit(health, max_health)
	if health <= 0.0:
		died.emit()
		_begin_death()

## Жук уже мёртв для игры (не цель, не сохраняется), но ещё доигрывает анимацию.
var is_dying: bool = false

func _begin_death() -> void:
	if is_dying:
		return
	if not (_sheet_8dir_active() and bool(sheet_bug_8dir.get("has_death"))):
		queue_free()
		return
	is_dying = true
	set_physics_process(false)
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	remove_from_group("graybox_enemies")
	health_bar.visible = false
	sheet_bug_8dir.visible = true
	sheet_bug_8dir.connect("death_finished", queue_free, CONNECT_ONE_SHOT)
	sheet_bug_8dir.call("play_death")
