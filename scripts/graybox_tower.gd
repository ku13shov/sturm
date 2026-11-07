class_name GrayboxTower
extends Node2D

signal health_changed(current_health: float, maximum_health: float)
signal state_changed(state: String)
signal destroyed

@export var building_id: int = 153
@export var max_health: float = 300.0
@export var upgrade_cost: int = 150
@export var upgrade_level: int = 0
@export var max_upgrade_level: int = 2
@export var attack_range: float = 260.0
@export var damage: float = 8.0
@export_enum("bullet", "energy", "fire") var damage_channel: String = "energy"
@export var fire_interval: float = 0.75
@export var combat_enabled: bool = true
@export var use_new_soldier_visual: bool = false
@export var use_legacy_tracer: bool = false
@export var temporary_balance_status: String = "TEMPORARY_BALANCE"

var profile: Dictionary = {}
var upgrade_costs: Array[int] = []
var defense_value: float = 0.0
var radius_value: float = 0.0
var health: float = 0.0
var building_state: String = GrayboxBuildingState.BUILT
var cooldown: float = 0.0
var shot_timer: float = 0.0

@onready var shot_line: Line2D = $ShotLine
@onready var range_indicator: Polygon2D = $RangeIndicator
@onready var upgrade_accent: Polygon2D = $UpgradeAccent
@onready var new_soldier_visual: Node = get_node_or_null("SoldierVisual")
@onready var legacy_soldier_sprite: CanvasItem = get_node_or_null("SoldierSprite") as CanvasItem

func _ready() -> void:
	if use_new_soldier_visual and is_instance_valid(legacy_soldier_sprite):
		legacy_soldier_sprite.visible = false
	if is_instance_valid(new_soldier_visual):
		new_soldier_visual.visible = use_new_soldier_visual
	if use_new_soldier_visual and not use_legacy_tracer:
		shot_line.visible = false
	if use_new_soldier_visual and is_instance_valid(new_soldier_visual):
		new_soldier_visual.call("set_target", global_position + Vector2.DOWN)
	profile = GameBalance.BUILDINGS.get(building_id, GameBalance.BUILDINGS[153])
	max_upgrade_level = int(profile.get("max_upgrade_level", max_upgrade_level))
	var configured_upgrade_costs: Variant = profile.get("upgrade_costs", [])
	if configured_upgrade_costs is Array:
		for cost_value: Variant in configured_upgrade_costs as Array:
			upgrade_costs.append(int(cost_value))
	if not upgrade_costs.is_empty():
		upgrade_cost = upgrade_costs[0]
	defense_value = float(profile.get("defense", 0.0))
	radius_value = float(profile.get("radius", attack_range))
	var circle_points: PackedVector2Array = PackedVector2Array()
	for index: int in range(32):
		var angle: float = TAU * float(index) / 32.0
		circle_points.append(Vector2(cos(angle), sin(angle)) * attack_range)
	range_indicator.polygon = circle_points
	range_indicator.visible = combat_enabled
	health = max_health
	health_changed.connect(_forward_health_to_visual)
	_set_state(GrayboxBuildingState.ACTIVE)
	health_changed.emit(health, max_health)

func _forward_health_to_visual(current_health: float, maximum_health: float) -> void:
	if use_new_soldier_visual and is_instance_valid(new_soldier_visual) and new_soldier_visual.has_method("set_health"):
		new_soldier_visual.call("set_health", current_health, maximum_health)

func _hide_legacy_runtime_sprites() -> void:
	for child: Node in get_children():
		if child is Sprite2D and child.name.begins_with("Sprite2D"):
			(child as Sprite2D).visible = false

func _process(delta: float) -> void:
	if use_new_soldier_visual:
		_hide_legacy_runtime_sprites()
	if not combat_enabled:
		return
	if use_new_soldier_visual and is_instance_valid(new_soldier_visual):
		var visual_target: GrayboxBug = _find_target()
		new_soldier_visual.call("set_target", visual_target.global_position if is_instance_valid(visual_target) else global_position + Vector2.DOWN)
	cooldown = maxf(cooldown - delta, 0.0)
	shot_timer = maxf(shot_timer - delta, 0.0)
	if shot_timer <= 0.0:
		shot_line.visible = false
	if cooldown > 0.0:
		return
	var target: GrayboxBug = _find_target()
	if not is_instance_valid(target):
		if use_new_soldier_visual and is_instance_valid(new_soldier_visual):
			new_soldier_visual.call("set_target", global_position + Vector2.DOWN)
		return
	if use_new_soldier_visual and is_instance_valid(new_soldier_visual):
		new_soldier_visual.call("set_target", target.global_position)
	target.take_typed_damage(damage, damage_channel)
	cooldown = fire_interval
	shot_timer = 0.08
	if use_new_soldier_visual and not use_legacy_tracer and is_instance_valid(new_soldier_visual):
		new_soldier_visual.call("play_shot", target.global_position)
	if not use_new_soldier_visual or use_legacy_tracer:
		shot_line.points = PackedVector2Array([Vector2.ZERO, to_local(target.global_position)])
		shot_line.visible = true

func take_damage(amount: float) -> void:
	if amount <= 0.0 or health <= 0.0:
		return
	health = maxf(health - amount, 0.0)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		_set_state(GrayboxBuildingState.DESTROYED)
		if use_new_soldier_visual and is_instance_valid(new_soldier_visual) and new_soldier_visual.has_method("spawn_death_fx") and is_instance_valid(get_parent()):
			new_soldier_visual.call("spawn_death_fx", get_parent())
		destroyed.emit()
		queue_free()
	else:
		_set_state(GrayboxBuildingState.DAMAGED)
		if use_new_soldier_visual and is_instance_valid(new_soldier_visual) and new_soldier_visual.has_method("on_hit"):
			new_soldier_visual.call("on_hit")

var _restoring := false

func restore_saved_state(saved_health: float, saved_upgrade_level: int) -> void:
	_restoring = true
	while upgrade_level < clampi(saved_upgrade_level, 0, max_upgrade_level):
		if not upgrade():
			break
	_restoring = false
	health = clampf(saved_health, 0.0, max_health)
	health_changed.emit(health, max_health)
	if health < max_health and health > 0.0:
		_set_state(GrayboxBuildingState.DAMAGED)

func repair_by(amount: float) -> void:
	if amount <= 0.0 or health <= 0.0:
		return
	health = minf(health + amount, max_health)
	if health >= max_health:
		_set_state(GrayboxBuildingState.ACTIVE)
	health_changed.emit(health, max_health)

func repair_full() -> void:
	if health <= 0.0:
		return
	repair_by(max_health - health)

func _set_state(next_state: String) -> void:
	if building_state == next_state:
		return
	building_state = next_state
	state_changed.emit(building_state)
	if next_state == GrayboxBuildingState.DAMAGED:
		modulate = Color.WHITE if use_new_soldier_visual else Color(1.0, 0.55, 0.55, 1.0)
	elif next_state == GrayboxBuildingState.ACTIVE:
		modulate = Color.WHITE
	elif next_state == GrayboxBuildingState.UPGRADED:
		modulate = Color.WHITE if use_new_soldier_visual else Color(0.65, 0.9, 1.0, 1.0)

func upgrade() -> bool:
	if health <= 0.0 or upgrade_level >= max_upgrade_level:
		return false
	upgrade_level += 1
	var health_bonus: float = float(profile.get("upgrade_health_bonus", 0.0))
	var defense_bonus: float = float(profile.get("upgrade_defense_bonus", 0.0))
	var attack_bonus: float = float(profile.get("upgrade_attack_bonus", 0.0))
	if health_bonus > 0.0:
		max_health += health_bonus
		health += health_bonus
	if defense_bonus > 0.0:
		defense_value += defense_bonus
	if attack_bonus > 0.0:
		damage += attack_bonus
	else:
		damage *= 1.5
	fire_interval *= 0.8
	if upgrade_level < upgrade_costs.size():
		upgrade_cost = upgrade_costs[upgrade_level]
	range_indicator.modulate = Color(0.25, 0.85, 1.0, 0.12)
	upgrade_accent.visible = not use_new_soldier_visual
	_set_state(GrayboxBuildingState.UPGRADED)
	if use_new_soldier_visual and is_instance_valid(new_soldier_visual) and new_soldier_visual.has_method("set_upgrade_level"):
		new_soldier_visual.call("set_upgrade_level", upgrade_level, not _restoring)
	return true

func _find_target() -> GrayboxBug:
	var best_target: GrayboxBug
	var best_distance: float = attack_range
	var parent_node: Node2D = get_parent() as Node2D
	var map_scale: float = maxf(absf(parent_node.global_scale.x), 0.01) if is_instance_valid(parent_node) else 1.0
	for candidate_node: Node in get_tree().get_nodes_in_group("graybox_enemies"):
		var candidate: GrayboxBug = candidate_node as GrayboxBug
		if not is_instance_valid(candidate):
			continue
		var distance: float = global_position.distance_to(candidate.global_position) / map_scale
		if distance <= best_distance:
			best_distance = distance
			best_target = candidate
	return best_target
