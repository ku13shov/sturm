class_name GrayboxWaveManagerTests
extends Node

const WAVE_MANAGER_SCRIPT: Script = preload("res://scripts/graybox_wave_manager.gd")

func test_start_initializes_first_wave() -> void:
	var manager: GrayboxWaveManager = WAVE_MANAGER_SCRIPT.new() as GrayboxWaveManager
	manager.wave_counts = [2, 1]
	manager.opening_delay = 0.0
	var started: Array[Dictionary] = []
	manager.wave_started.connect(func(wave_number: int, enemy_count: int) -> void:
		started.append({"wave_number": wave_number, "enemy_count": enemy_count})
	)
	manager.start()
	assert(manager.running)
	assert(not manager.finished)
	assert(manager.wave_number == 1)
	assert(manager.pending_spawns == 2)
	assert(started.size() == 1)
	assert(started[0]["wave_number"] == 1)
	assert(started[0]["enemy_count"] == 2)
	manager.free()

func test_spawn_and_final_wave_completion() -> void:
	var manager: GrayboxWaveManager = WAVE_MANAGER_SCRIPT.new() as GrayboxWaveManager
	manager.wave_counts = [1]
	manager.opening_delay = 0.0
	manager.spawn_interval = 0.0
	var spawned: Array[int] = []
	var completed: Array[bool] = [false]
	manager.spawn_requested.connect(func(spawn_index: int) -> void:
		spawned.append(spawn_index)
	)
	manager.all_waves_complete.connect(func() -> void:
		completed[0] = true
	)
	manager.start()
	manager._process(0.1)
	assert(spawned == [0])
	assert(manager.pending_spawns == 0)
	assert(manager.active_enemies == 1)
	manager.notify_enemy_died()
	assert(manager.finished)
	assert(not manager.running)
	assert(completed[0])
	manager.free()

func test_request_next_wave_rejects_active_wave_and_starts_intermission_wave() -> void:
	var manager: GrayboxWaveManager = WAVE_MANAGER_SCRIPT.new() as GrayboxWaveManager
	manager.wave_counts = [1, 1]
	manager.opening_delay = 0.0
	manager.spawn_interval = 0.0
	manager.inter_wave_delay = 5.0
	manager.start()
	manager._process(0.1)
	assert(not manager.request_next_wave())
	manager.notify_enemy_died()
	assert(manager.next_wave_timer == 5.0)
	assert(manager.request_next_wave())
	assert(manager.wave_number == 2)
	assert(manager.pending_spawns == 1)
	assert(manager.next_wave_timer == 0.0)
	manager.free()

func test_restore_state_clamps_runtime_values() -> void:
	var manager: GrayboxWaveManager = WAVE_MANAGER_SCRIPT.new() as GrayboxWaveManager
	manager.wave_counts = [2, 3]
	manager.spawn_interval = 0.8
	manager.inter_wave_delay = 2.5
	manager.restore_state({
		"wave_number": 99,
		"pending_spawns": 5000,
		"spawn_index": -4,
		"spawn_timer": 12.0,
		"next_wave_timer": -1.0,
		"running": true,
		"finished": false
	}, 3)
	assert(manager.wave_number == 2)
	assert(manager.pending_spawns == 1000)
	assert(manager.active_enemies == 3)
	assert(manager.spawn_index == 0)
	assert(manager.spawn_timer == 0.8)
	assert(manager.next_wave_timer == 0.0)
	assert(manager.running)
	assert(not manager.finished)
	manager.free()
