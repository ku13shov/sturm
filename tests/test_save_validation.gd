extends Node

const GAME_SCRIPT = preload("res://scripts/graybox_vertical_slice.gd")
const GAME_SCENE: PackedScene = preload("res://scenes/gameplay/graybox_vertical_slice.tscn")

func _validate(data: Dictionary) -> String:
	var game: Node = GAME_SCRIPT.new()
	var result: String = String(game.call("_validate_save_data", data))
	game.free()
	return result

func test_accepts_legacy_v1_save() -> void:
	var data: Dictionary = {"version": 1, "credits": 2500, "buildings": []}
	assert(_validate(data).is_empty())

func test_accepts_active_wave_v2_save() -> void:
	var data: Dictionary = {
		"version": 2,
		"credits": 2500,
		"buildings": [{"building_id": 153, "cell_x": 5, "cell_y": 4, "health": 80.0, "upgrade_level": 0}],
		"enemies": [{
			"enemy_id": 70,
			"x": 120.0,
			"y": 180.0,
			"health": 30.0,
			"path": [{"x": 80.0, "y": 144.0}],
			"path_index": 0,
			"registered_with_wave": true
		}],
		"wave_state": {"wave_number": 1, "pending_spawns": 1, "active_enemies": 1}
	}
	assert(_validate(data).is_empty())

func test_rejects_unknown_version() -> void:
	var data: Dictionary = {"version": 99, "buildings": []}
	assert(not _validate(data).is_empty())

func test_rejects_invalid_building_record() -> void:
	var data: Dictionary = {"version": 1, "buildings": [{"building_id": 999, "cell_x": 0, "cell_y": 0}]}
	assert(not _validate(data).is_empty())

func test_rejects_invalid_enemy_record() -> void:
	var data: Dictionary = {
		"version": 2,
		"buildings": [],
		"enemies": [{"enemy_id": 999, "x": 0.0, "y": 0.0, "health": 10.0, "path": []}],
		"wave_state": {}
	}
	assert(not _validate(data).is_empty())

func test_rejects_malformed_enemy_path() -> void:
	var data: Dictionary = {
		"version": 2,
		"buildings": [],
		"enemies": [{"enemy_id": 70, "x": 0.0, "y": 0.0, "health": 10.0, "path": ["bad point"]}],
		"wave_state": {}
	}
	assert(not _validate(data).is_empty())

func test_full_runtime_save_restore_round_trip() -> void:
	var game: GrayboxVerticalSlice = GAME_SCENE.instantiate() as GrayboxVerticalSlice
	get_tree().root.add_child(game)
	await get_tree().process_frame
	game.wave_manager.set_process(false)
	for child: Node in game.enemies.get_children():
		game.enemies.remove_child(child)
		child.free()
	for child: Node in game.towers.get_children():
		game.towers.remove_child(child)
		child.free()
	game.tower_cells.clear()
	game.grid = MapGrid.new()
	game.grid.set_occupied(game._cell_from_position(game.base.position), true)
	game.grid.set_occupied(game._cell_from_position(Vector2(300.0, 270.0)), true)
	var tower_data: Dictionary = {"building_id": 153, "cell_x": 5, "cell_y": 4, "health": 73.0, "upgrade_level": 1}
	game._restore_building(tower_data)
	var enemy_data: Dictionary = {
		"enemy_id": 70, "x": 151.0, "y": 207.0, "health": 17.0,
		"path": [{"x": 80.0, "y": 144.0}, {"x": 112.0, "y": 144.0}],
		"path_index": 1, "attack_cooldown": 0.3, "registered_with_wave": true
	}
	assert(game._restore_enemy(enemy_data))
	game.wave_manager.restore_state({
		"wave_number": 2, "pending_spawns": 1, "spawn_index": 3,
		"spawn_timer": 0.4, "next_wave_timer": 0.0, "running": true, "finished": false
	}, 1)
	game.credits = 4321
	var captured: Dictionary = game._capture_save_data()
	game._apply_save_data(captured)
	var pending_tower: GrayboxTower = game.towers.get_child(0) as GrayboxTower
	pending_tower.combat_enabled = false
	await get_tree().process_frame
	assert(game.credits == 4321)
	assert(game.towers.get_child_count() == 1)
	var restored_tower: GrayboxTower = game.towers.get_child(0) as GrayboxTower
	restored_tower.combat_enabled = false
	assert(restored_tower.building_id == 153)
	assert(restored_tower.upgrade_level == 1)
	assert(is_equal_approx(restored_tower.health, 73.0))
	assert(game.enemies.get_child_count() == 1)
	var restored_enemy: GrayboxBug = game.enemies.get_child(0) as GrayboxBug
	assert(restored_enemy.enemy_id == 70)
	assert(is_equal_approx(restored_enemy.health, 17.0))
	assert(restored_enemy.registered_with_wave)
	assert(restored_enemy.path_index == 1)
	assert(game.wave_manager.wave_number == 2)
	assert(game.wave_manager.pending_spawns == 1)
	assert(game.wave_manager.active_enemies == 1)
	game.queue_free()
	await get_tree().process_frame

func test_sell_refund_is_half_of_prototype_cost() -> void:
	var game: Node = GAME_SCRIPT.new()
	assert(int(game.call("_sell_refund", 163)) == 250)
	assert(int(game.call("_sell_refund", 163, 1, 600)) == 550)
	assert(int(game.call("_sell_refund", 151)) == 750)
	assert(int(game.call("_sell_refund", 163, 0, 0, 40.0, 80.0)) == 125)
	assert(int(game.call("_sell_refund", 163, 0, 0, 20.0, 80.0)) == 62)
	game.free()

func test_missing_save_is_reported_as_unavailable() -> void:
	assert(_read_save("user://ziva_test_missing_save.json").is_empty())

func test_corrupt_json_is_rejected() -> void:
	var path: String = "user://ziva_test_corrupt_save.json"
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert(file != null)
	file.store_string("{ definitely not json")
	file.close()
	assert(_read_save(path).is_empty())
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _read_save(path: String) -> Dictionary:
	var game: Node = GAME_SCRIPT.new()
	var result: Dictionary = game.call("_read_valid_save", path) as Dictionary
	game.free()
	return result
