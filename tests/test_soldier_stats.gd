class_name SoldierStatsTests
extends Node

const SOLDIER_SCENE: PackedScene = preload("res://scenes/graybox/graybox_soldier_defender.tscn")

func test_level_one_soldier_observed_stats() -> void:
	var soldier: GrayboxTower = SOLDIER_SCENE.instantiate() as GrayboxTower
	get_tree().root.add_child(soldier)
	await get_tree().process_frame
	soldier.combat_enabled = false
	assert(is_equal_approx(soldier.max_health, 80.0))
	assert(is_equal_approx(soldier.defense_value, 5.0))
	assert(is_equal_approx(soldier.damage, 3.0))
	assert(is_equal_approx(soldier.radius_value, 2.0))
	assert(soldier.upgrade_cost == 600)
	soldier.queue_free()
	await get_tree().process_frame

func test_level_two_soldier_applies_observed_bonuses() -> void:
	var soldier: GrayboxTower = SOLDIER_SCENE.instantiate() as GrayboxTower
	get_tree().root.add_child(soldier)
	await get_tree().process_frame
	soldier.combat_enabled = false
	assert(soldier.upgrade())
	assert(soldier.upgrade_level == 1)
	assert(is_equal_approx(soldier.max_health, 100.0))
	assert(is_equal_approx(soldier.health, 100.0))
	assert(is_equal_approx(soldier.defense_value, 10.0))
	assert(is_equal_approx(soldier.damage, 4.0))
	assert(is_equal_approx(soldier.radius_value, 2.0))
	assert(soldier.upgrade())
	assert(soldier.upgrade_level == 2)
	assert(is_equal_approx(soldier.max_health, 120.0))
	assert(is_equal_approx(soldier.health, 120.0))
	assert(is_equal_approx(soldier.defense_value, 15.0))
	assert(is_equal_approx(soldier.damage, 5.0))
	assert(soldier.upgrade_cost == 1000)
	assert(not soldier.upgrade())
	soldier.queue_free()
	await get_tree().process_frame
