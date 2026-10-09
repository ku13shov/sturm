class_name GrayboxWaveManager
extends Node

signal wave_started(wave_number: int, enemy_count: int)
signal wave_cleared(wave_number: int)
signal all_waves_complete
signal spawn_requested(spawn_index: int)
signal intermission_started(wave_number: int)
signal wave_start_requested

@export var wave_counts: Array[int] = [2, 3, 4]
@export var spawn_interval: float = 0.8
@export var inter_wave_delay: float = 2.5
@export var opening_delay: float = 12.0
@export var temporary_balance_status: String = "TEMPORARY_BALANCE"

var wave_number: int = 0
var pending_spawns: int = 0
var active_enemies: int = 0
var spawn_index: int = 0
var spawn_timer: float = 0.0
var next_wave_timer: float = 0.0
var opening_timer: float = 0.0
var running: bool = false
var finished: bool = false

func start() -> void:
	wave_number = 0
	pending_spawns = 0
	active_enemies = 0
	spawn_index = 0
	spawn_timer = 0.0
	next_wave_timer = 0.0
	opening_timer = opening_delay
	running = true
	finished = false
	_start_next_wave()

func _process(delta: float) -> void:
	if not running or finished:
		return
	if opening_timer > 0.0:
		opening_timer = maxf(opening_timer - delta, 0.0)
		return
	if pending_spawns > 0:
		spawn_timer = maxf(spawn_timer - delta, 0.0)
		if spawn_timer <= 0.0:
			pending_spawns -= 1
			active_enemies += 1
			spawn_requested.emit(spawn_index)
			spawn_index += 1
			spawn_timer = spawn_interval
		return
	if active_enemies > 0:
		return
	if next_wave_timer > 0.0:
		next_wave_timer = maxf(next_wave_timer - delta, 0.0)
		if next_wave_timer <= 0.0:
			_start_next_wave()
		return
	_start_next_wave()

func save_state() -> Dictionary:
	return {
		"wave_number": wave_number,
		"pending_spawns": pending_spawns,
		"active_enemies": active_enemies,
		"spawn_index": spawn_index,
		"spawn_timer": spawn_timer,
		"next_wave_timer": next_wave_timer,
		"running": running,
		"finished": finished
	}

func restore_state(data: Dictionary, restored_enemy_count: int) -> void:
	wave_number = clampi(int(data.get("wave_number", 0)), 0, wave_counts.size())
	pending_spawns = clampi(int(data.get("pending_spawns", 0)), 0, 1000)
	active_enemies = maxi(restored_enemy_count, 0)
	spawn_index = maxi(int(data.get("spawn_index", 0)), 0)
	spawn_timer = clampf(float(data.get("spawn_timer", 0.0)), 0.0, spawn_interval)
	next_wave_timer = clampf(float(data.get("next_wave_timer", 0.0)), 0.0, inter_wave_delay)
	finished = bool(data.get("finished", false))
	running = bool(data.get("running", true)) and not finished
	if pending_spawns == 0 and active_enemies == 0 and wave_number > 0 and not finished and wave_number < wave_counts.size():
		next_wave_timer = maxf(next_wave_timer, 0.25)
		intermission_started.emit(wave_number + 1)

func notify_enemy_died() -> void:
	active_enemies = maxi(active_enemies - 1, 0)
	if pending_spawns == 0 and active_enemies == 0:
		wave_cleared.emit(wave_number)
		if wave_number >= wave_counts.size():
			finished = true
			running = false
			all_waves_complete.emit()
			return
		next_wave_timer = inter_wave_delay
		intermission_started.emit(wave_number + 1)

func request_next_wave() -> bool:
	if not running or finished or pending_spawns > 0 or active_enemies > 0 or wave_number >= wave_counts.size():
		return false
	if next_wave_timer > 0.0:
		next_wave_timer = 0.0
	wave_start_requested.emit()
	_start_next_wave()
	return true

func _start_next_wave() -> void:
	if wave_number >= wave_counts.size():
		return
	next_wave_timer = 0.0
	wave_number += 1
	pending_spawns = wave_counts[wave_number - 1]
	spawn_timer = 0.0
	wave_started.emit(wave_number, pending_spawns)
