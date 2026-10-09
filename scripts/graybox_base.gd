class_name GrayboxBase
extends Node2D

signal health_changed(current_health: float, maximum_health: float)
signal state_changed(state: String)
signal destroyed

@export var building_id: int = 155
@export var max_health: float = 750.0
@export var defense: float = 25.0
@export var temporary_balance_status: String = "SCREENSHOT_CONFIRMED"

var profile: Dictionary = {}
var health: float = 0.0
var building_state: String = GrayboxBuildingState.BUILT
var shield_points: float = 0.0
var invulnerability_until: float = 0.0

func _ready() -> void:
	add_to_group("graybox_base")
	profile = GameBalance.BUILDINGS.get(building_id, GameBalance.BUILDINGS[155])
	health = max_health
	_set_state(GrayboxBuildingState.ACTIVE)
	health_changed.emit(health, max_health)

func take_damage(amount: float) -> void:
	if amount <= 0.0 or health <= 0.0:
		return
	if Time.get_ticks_msec() / 1000.0 < invulnerability_until:
		return
	var mitigated_damage: float = maxf(amount - defense, 1.0)
	if shield_points > 0.0:
		var absorbed: float = minf(shield_points, mitigated_damage)
		shield_points -= absorbed
		mitigated_damage -= absorbed
	if mitigated_damage <= 0.0:
		return
	health = maxf(health - mitigated_damage, 0.0)
	health_changed.emit(health, max_health)
	if health <= 0.0:
		_set_state(GrayboxBuildingState.DESTROYED)
		destroyed.emit()
	else:
		_set_state(GrayboxBuildingState.DAMAGED)

func set_shield(amount: float) -> void:
	shield_points = maxf(amount, 0.0)

func set_invulnerable(duration: float) -> void:
	invulnerability_until = Time.get_ticks_msec() / 1000.0 + maxf(duration, 0.0)

func get_invulnerability_remaining() -> float:
	return maxf(invulnerability_until - Time.get_ticks_msec() / 1000.0, 0.0)

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
