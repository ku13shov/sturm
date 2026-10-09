class_name GrayboxVerticalSlice
extends Node2D

const BUG_SCENE: PackedScene = preload("res://scenes/graybox/graybox_bug.tscn")
const TOWER_SCENE: PackedScene = preload("res://scenes/graybox/graybox_tower.tscn")
const ENERGY_STATION_SCENE: PackedScene = preload("res://scenes/graybox/graybox_energy_station.tscn")
const SOLDIER_DEFENDER_SCENE: PackedScene = preload("res://scenes/graybox/graybox_soldier_defender.tscn")
const LASER_TOWER_SCENE: PackedScene = preload("res://scenes/graybox/graybox_laser_tower.tscn")
const PLASMA_TOWER_SCENE: PackedScene = preload("res://scenes/graybox/graybox_plasma_tower.tscn")
const RADAR_TOWER_SCENE: PackedScene = preload("res://scenes/graybox/graybox_radar_tower.tscn")
const BEACON_SCENE: PackedScene = preload("res://scenes/graybox/graybox_beacon.tscn")
const CENTRAL_BASE_TEMPLATE_SCENE: PackedScene = preload("res://scenes/graybox/graybox_central_base_template.tscn")
const ROCK_FORMATION_SCENE: PackedScene = preload("res://scenes/map/rock_formation.tscn")
const BUILD_PALETTE_SUPPORTED_IDS: Array[int] = BUILDING_REGISTRY.INITIAL_IDS
const BALANCE: Dictionary = preload("res://data/game_balance.gd").GRAYBOX
const BUILDING_REGISTRY: Script = preload("res://data/building_registry.gd")
const TEMPORARY_TOWER_COST: int = BALANCE["tower_cost"]
const TEMPORARY_ENEMY_REWARD: int = BALANCE["enemy_reward"]
const REPAIR_COST_PER_HP: float = 3.0
const REPAIR_RATE_HP_PER_SECOND: float = 2.0
const FIRE_TOWER_ID: int = 153
const ENERGY_STATION_ID: int = 151
const CENTRAL_BASE_ID: int = 155
const SOLDIERS_ID: int = 163
const SUPPORTED_BUILDING_IDS: Array[int] = BUILDING_REGISTRY.PLAYABLE_IDS
const GRID_ORIGIN: Vector2 = Vector2(32.0, 32.0)
const MAP_GRID_TYPE = preload("res://map/map_grid.gd")
const NAVIGATION_SYSTEM_TYPE = preload("res://map/navigation_system.gd")
const SAVE_PATH: String = "user://sturmtrupp_survival_save.json"
const SAVE_TEMP_PATH: String = "user://sturmtrupp_survival_save.tmp"
const SAVE_BACKUP_PATH: String = "user://sturmtrupp_survival_save.bak"
const SMALL_CONSTRUCTION_TEXTURE: Texture2D = preload("res://original/145.png")
const LARGE_CONSTRUCTION_TEXTURE: Texture2D = preload("res://original/146.png")
const SMALL_PAD_TEXTURE: Texture2D = preload("res://original/147.png")
const LARGE_PAD_TEXTURE: Texture2D = preload("res://original/148.png")
const SMALL_CONSTRUCTION_TIME: float = 2.0
const LARGE_CONSTRUCTION_TIME: float = 3.0

@onready var base: GrayboxBase = $Playfield/Entities/CentralBase
@onready var towers: Node2D = $Playfield/Entities/Towers
@onready var enemies: Node2D = $Playfield/Entities/Enemies
@onready var credits_label: Label = get_node_or_null("HUD/Credits")
@onready var selected_label: Label = get_node_or_null("HUD/SelectedBuilding")
@onready var tower_info_label: Label = get_node_or_null("HUD/TowerInfo")
@onready var upgrade_button: Button = get_node_or_null("HUD/UpgradeButton")
@onready var repair_button: Button = get_node_or_null("HUD/RepairButton")
@onready var sell_button: Button = get_node_or_null("HUD/SellButton")
@onready var build_button: Button = get_node_or_null("HUD/BuildButton")
@onready var cancel_build_button: Button = $PlacementCancelButton
@onready var building_151_button: Button = get_node_or_null("HUD/Building151Button")
@onready var building_153_button: Button = get_node_or_null("HUD/Building153Button")
@onready var building_155_button: Button = get_node_or_null("HUD/Building155Button")
@onready var building_picker: OptionButton = get_node_or_null("HUD/BuildingPicker")
@onready var build_preview: Polygon2D = $Playfield/Entities/BuildPreview
@onready var wave_label: Label = get_node_or_null("HUD/Wave")
@onready var next_wave_button: Button = get_node_or_null("HUD/NextWaveButton")
@onready var pause_button: Button = $PauseTouchButton
@onready var actions_button: Button = $ActionsTouchButton
@onready var progression_notice: Control = $ProgressionNotice
@onready var notice_message: Label = $ProgressionNotice/Card/Scroll/Message
@onready var notice_confirm_button: Button = $ProgressionNotice/Card/ConfirmButton
@onready var status_label: Label = get_node_or_null("HUD/Status")
@onready var save_button: Button = get_node_or_null("HUD/SaveButton")
@onready var load_button: Button = get_node_or_null("HUD/LoadButton")
@onready var wave_manager: GrayboxWaveManager = $WaveManager
@onready var base_bar: ProgressBar = get_node_or_null("HUD/BaseHealth")
@onready var selection_title: Label = $Playfield/RetroTopStrip/SelectionTitle
@onready var selection_icon: TextureRect = $Playfield/RetroTopStrip/SelectionIcon
@onready var selection_hp_bar: ProgressBar = $Playfield/RetroTopStrip/SelectionHpBar
@onready var selection_strip: Control = $Playfield/RetroTopStrip
@onready var selection_stats: Label = $Playfield/RetroTopStrip/SelectionStats
@onready var context_title: Label = $Playfield/ContextPanel/ContextTitle
@onready var context_hint: Label = $Playfield/ContextPanel/ContextHint
@onready var attack_marker: Label = $Playfield/MiniMap/AttackMarker
@onready var minimap_viewport: ColorRect = $Playfield/MiniMap/ViewportRect
@onready var minimap_base_marker: ColorRect = $Playfield/MiniMap/BaseMarker
@onready var action_picker: OptionButton = $Playfield/ContextPanel/ActionPicker
@onready var use_action_button: Button = $Playfield/ContextPanel/UseActionButton
@onready var research_picker: OptionButton = $Playfield/ContextPanel/ResearchPicker
@onready var research_button: Button = $Playfield/ContextPanel/ResearchButton
@onready var upgrade_building_button: Button = $Playfield/ContextPanel/UpgradeBuildingButton
@onready var repair_building_button: Button = $Playfield/ContextPanel/RepairBuildingButton
@onready var sell_building_button: Button = $Playfield/ContextPanel/SellBuildingButton
@onready var entities: Node2D = $Playfield/Entities
@onready var hover_debug_radii: GrayboxHoverDebug = $Playfield/Entities/HoverDebugRadii
@onready var playfield: Control = $Playfield
@onready var fog_mask: ColorRect = $Playfield/FogOfWarMask
@onready var minimap_control: Control = $Playfield/MiniMap
var fps_label: Label
var debug_button: Button
var debug_menu: Panel
var debug_money_button: Button
var debug_fog_button: Button
var debug_cell_diamond_button: Button
var debug_muzzle_points_button: Button
var debug_close_button: Button
var debug_cell_diamond_enabled: bool = false
var debug_muzzle_points_enabled: bool = false
var fog_reveal_infinite: bool = false
@onready var test_hud_panel: Control = $TestHUD

const FOG_MASK_SIZE: int = 64
const FOG_MASK_UPDATE_INTERVAL: float = 1.0
var fog_mask_image: Image
var fog_mask_texture: ImageTexture
var fog_mask_rebuild_cooldown: float = 0.0

@onready var pause_menu: Control = $PauseMenu
@onready var pause_menu_status: Label = $PauseMenu/Card/Status
@onready var pause_stats: Label = $PauseMenu/Card/Stats
@onready var commander_intro: Control = $CommanderIntro
@onready var intro_confirm_button: Button = $CommanderIntro/Dialog/ConfirmButton
@onready var build_palette_popup: Control = $BuildPalettePopup
@onready var palette_picker: OptionButton = $BuildPalettePopup/Card/BuildingPicker
@onready var palette_confirm_button: Button = $BuildPalettePopup/Card/ConfirmButton
@onready var palette_cancel_button: Button = $BuildPalettePopup/Card/CancelButton
@onready var palette_details: Label = $BuildPalettePopup/Card/Details
@onready var credits_text: Label = $Playfield/CreditsBadge/CreditsText

var grid: MapGrid
var navigation: NavigationSystem
var credits: int = BALANCE["starting_credits"]
var score: int = 0
var enemy_kills: int = 0
var survival_started_at: int = 0
var spawn_counter: int = 0
var game_over: bool = false
var selected_building_id: int = SOLDIERS_ID
var selected_tower: GrayboxTower
var base_selected: bool = false
var build_mode: bool = false
var build_cursor_position: Vector2 = Vector2.ZERO
var placement_preview_cell: Vector2i = Vector2i(-1, -1)
var placement_preview_valid: bool = false
var game_paused: bool = false
var intro_pending: bool = true
var build_picker_open: bool = false
var building_action_panel_active: bool = false
var pending_build_cell: Vector2i = Vector2i(-1, -1)
var pending_build_screen_position: Vector2 = Vector2.ZERO
var pointer_is_down: bool = false
var pointer_dragged: bool = false
var pointer_start_position: Vector2 = Vector2.ZERO
var pointer_last_position: Vector2 = Vector2.ZERO
var pointer_can_pan: bool = false
var touch_drag_started: bool = false
var map_zoom: float = 1.0
const MIN_MAP_ZOOM: float = 0.75
const MAX_MAP_ZOOM: float = 1.5
const PAN_DRAG_THRESHOLD: float = 10.0
# Keep camera, fog and minimap bounds aligned with the playable grid.
# The grid is 64 x 32 px, so its half-extent is 1024 px; the previous
# presentation multiplier let the camera travel into non-buildable space.
const MAP_PRESENTATION_SCALE: float = 1.0
const MAP_HALF_EXTENT: Vector2 = Vector2(float(MapGrid.WIDTH) * MapGrid.CELL_SIZE * 0.5 * MAP_PRESENTATION_SCALE, float(MapGrid.HEIGHT) * MapGrid.CELL_SIZE * 0.5 * MAP_PRESENTATION_SCALE)
const EDGE_INDICATOR_MARGIN: float = 18.0
const FOG_BASE_RADIUS_PIXELS: float = 340.0
const FOG_BUILDING_RADIUS_PIXELS: float = 300.0
var selected_action: String = "1"
var selected_research: String = "1"
var action_active_until: float = 0.0
var experience: int = 0
var rank: int = 0
var base_upgrade_level: int = 1
var action_charges: Dictionary = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0, 11: 0, 12: 0}
var unlocked_action_ids: Array[int] = []
var researched: Dictionary = {}
var unlocked_building_ids: Array[int] = BUILDING_REGISTRY.INITIAL_IDS.duplicate()
var notice_queue: Array[String] = []
var notice_open: bool = false
var tower_cells: Dictionary = {}
var tower_footprints: Dictionary = {}
var construction_states: Dictionary = {}
var repair_states: Dictionary = {}
var spawn_points: Array[Vector2] = []
var active_spawn_position: Vector2 = Vector2.ZERO
const SPAWN_MARGIN: float = 48.0
const BUG_TARGET_RADIUS: float = 90.0

func _update_continue_button() -> void:
	var best_data: Dictionary = _read_valid_save(SAVE_PATH)
	if best_data.is_empty():
		best_data = _read_valid_save(SAVE_BACKUP_PATH)
	var has_save: bool = not best_data.is_empty()
	load_button.disabled = not has_save
	load_button.text = "Продолжить" if has_save else "Продолжить (нет сохранения)"
	if has_save:
		var wave_state: Variant = best_data.get("wave_state", {})
		if wave_state is Dictionary and int((wave_state as Dictionary).get("wave_number", 0)) > 0:
			load_button.text = "Продолжить • атака %d" % int((wave_state as Dictionary).get("wave_number", 0))
	load_button.tooltip_text = "Загрузить последнюю сохранённую игру" if has_save else "Сначала сохраните игру"

func _read_valid_save(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parser: JSON = JSON.new()
	var parse_error: Error = parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK or not parser.data is Dictionary:
		return {}
	var data: Dictionary = parser.data as Dictionary
	return data if _validate_save_data(data).is_empty() else {}

func _capture_save_data() -> Dictionary:
	var tower_data: Array[Dictionary] = []
	for tower_node: Node in towers.get_children():
		var tower: GrayboxTower = tower_node as GrayboxTower
		if not is_instance_valid(tower):
			continue
		var cell_variant: Variant = tower_cells.get(tower, null)
		if not cell_variant is Vector2i:
			continue
		var cell: Vector2i = cell_variant as Vector2i
		tower_data.append({
			"building_id": tower.building_id,
			"cell_x": cell.x,
			"cell_y": cell.y,
			"health": tower.health,
			"upgrade_level": tower.upgrade_level
		})
	var charge_data: Dictionary = {}
	for action_id: int in action_charges.keys():
		charge_data[str(action_id)] = int(action_charges[action_id])
	var enemy_data: Array[Dictionary] = []
	for enemy_node: Node in enemies.get_children():
		var enemy: GrayboxBug = enemy_node as GrayboxBug
		if is_instance_valid(enemy):
			enemy_data.append(enemy.save_state())
	var save_data: Dictionary = {
		"version": 2,
		"credits": credits,
		"score": score,
		"enemy_kills": enemy_kills,
		"experience": experience,
		"rank": rank,
		"base_upgrade_level": base_upgrade_level,
		"base_health": base.health,
		"base_defense": base.defense,
		"base_shield": base.shield_points,
		"base_invulnerability_remaining": base.get_invulnerability_remaining(),
		"fog_reveal_remaining": maxf(action_active_until - Time.get_ticks_msec() / 1000.0, 0.0),
		"unlocked_action_ids": unlocked_action_ids,
		"action_charges": charge_data,
		"researched": researched,
		"unlocked_building_ids": unlocked_building_ids,
		"buildings": tower_data,
		"enemies": enemy_data,
		"wave_state": wave_manager.save_state()
	}
	return save_data

func _save_game() -> void:
	var save_data: Dictionary = _capture_save_data()
	var save_file: FileAccess = FileAccess.open(SAVE_TEMP_PATH, FileAccess.WRITE)
	if save_file == null:
		_update_hud("Не удалось сохранить игру")
		return
	save_file.store_string(JSON.stringify(save_data))
	save_file.flush()
	var write_error: Error = save_file.get_error()
	save_file.close()
	if write_error != OK:
		_update_hud("Ошибка записи сохранения (%d)" % write_error)
		return
	if FileAccess.file_exists(SAVE_PATH):
		if FileAccess.file_exists(SAVE_BACKUP_PATH):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_BACKUP_PATH))
		var backup_error: Error = DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_PATH), ProjectSettings.globalize_path(SAVE_BACKUP_PATH))
		if backup_error != OK:
			_update_hud("Не удалось защитить предыдущее сохранение (%d)" % backup_error)
			return
	var rename_error: Error = DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_TEMP_PATH), ProjectSettings.globalize_path(SAVE_PATH))
	if rename_error != OK:
		_update_hud("Не удалось завершить сохранение (%d)" % rename_error)
		return
	_update_hud("Игра сохранена • контрольная точка атаки %d" % wave_manager.wave_number)
	_update_continue_button()

func _load_game() -> void:
	_update_continue_button()
	if load_button.disabled:
		_update_hud("Нет сохранения для продолжения")
		return
	if not FileAccess.file_exists(SAVE_PATH):
		if _try_load_backup():
			return
		_update_hud("Сохранение не найдено")
		return
	var save_file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		_update_hud("Не удалось открыть сохранение")
		return
	var parser: JSON = JSON.new()
	var parse_error: Error = parser.parse(save_file.get_as_text())
	var parsed: Variant = parser.data if parse_error == OK else null
	save_file.close()
	if not parsed is Dictionary:
		if _try_load_backup():
			return
		_update_hud("Сохранение повреждено")
		return
	var save_data: Dictionary = parsed as Dictionary
	var validation_message: String = _validate_save_data(save_data)
	if not validation_message.is_empty():
		if _try_load_backup():
			return
		_update_hud(validation_message)
		return
	_apply_save_data(save_data)
	_update_hud("Продолжение загружено • атака %d" % wave_manager.wave_number)
	_update_continue_button()

func _validate_save_data(data: Dictionary) -> String:
	var save_version: int = int(data.get("version", 1))
	if save_version < 1 or save_version > 2:
		return "Версия сохранения не поддерживается"
	for key: String in ["credits", "score", "enemy_kills", "experience", "rank", "base_upgrade_level"]:
		if data.has(key) and not (data[key] is int or data[key] is float):
			return "Сохранение повреждено: неверное поле %s" % key
	var buildings_value: Variant = data.get("buildings", [])
	if not buildings_value is Array:
		return "Сохранение повреждено: список зданий неверен"
	for building_value: Variant in buildings_value as Array:
		if not building_value is Dictionary:
			return "Сохранение повреждено: запись здания неверна"
		var building_data: Dictionary = building_value as Dictionary
		for key: String in ["building_id", "cell_x", "cell_y"]:
			if not building_data.has(key) or not (building_data[key] is int or building_data[key] is float):
				return "Сохранение повреждено: у здания нет поля %s" % key
		var building_id: int = int(building_data["building_id"])
		if not SUPPORTED_BUILDING_IDS.has(building_id):
			return "Сохранение содержит неизвестный тип здания"
		var cell_x: int = int(building_data["cell_x"])
		var cell_y: int = int(building_data["cell_y"])
		if cell_x < 0 or cell_x >= MapGrid.WIDTH or cell_y < 0 or cell_y >= MapGrid.HEIGHT:
			return "Сохранение содержит координаты здания вне карты"
		if building_data.has("health") and not (building_data["health"] is int or building_data["health"] is float):
			return "Сохранение повреждено: здоровье здания неверно"
		if building_data.has("upgrade_level") and not (building_data["upgrade_level"] is int or building_data["upgrade_level"] is float):
			return "Сохранение повреждено: уровень здания неверен"
	if save_version >= 2:
		var enemies_value: Variant = data.get("enemies", [])
		if not enemies_value is Array:
			return "Сохранение повреждено: список врагов неверен"
		for enemy_value: Variant in enemies_value as Array:
			if not enemy_value is Dictionary:
				return "Сохранение повреждено: запись врага неверна"
			var enemy_data: Dictionary = enemy_value as Dictionary
			for key: String in ["enemy_id", "x", "y", "health"]:
				if not enemy_data.has(key) or not (enemy_data[key] is int or enemy_data[key] is float):
					return "Сохранение повреждено: у врага нет поля %s" % key
			var enemy_id: int = int(enemy_data["enemy_id"])
			if not GameBalance.ENEMY_PROFILES.has(enemy_id):
				return "Сохранение содержит неизвестный тип врага"
			if float(enemy_data["health"]) <= 0.0:
				return "Сохранение содержит уничтоженного врага"
			var saved_path_value: Variant = enemy_data.get("path", [])
			if not saved_path_value is Array:
				return "Сохранение содержит некорректный маршрут врага"
			for point_value: Variant in saved_path_value as Array:
				if not point_value is Dictionary:
					return "Сохранение содержит некорректную точку маршрута"
				var point_data: Dictionary = point_value as Dictionary
				if not (point_data.get("x", null) is int or point_data.get("x", null) is float) or not (point_data.get("y", null) is int or point_data.get("y", null) is float):
					return "Сохранение содержит координату маршрута неверного типа"
		if not data.get("wave_state", {}) is Dictionary:
			return "Сохранение повреждено: состояние волн неверно"
	return ""

func _try_load_backup() -> bool:
	if not FileAccess.file_exists(SAVE_BACKUP_PATH):
		return false
	var backup_file: FileAccess = FileAccess.open(SAVE_BACKUP_PATH, FileAccess.READ)
	if backup_file == null:
		return false
	var backup_parser: JSON = JSON.new()
	var backup_parse_error: Error = backup_parser.parse(backup_file.get_as_text())
	var backup_parsed: Variant = backup_parser.data if backup_parse_error == OK else null
	backup_file.close()
	if not backup_parsed is Dictionary:
		return false
	var backup_data: Dictionary = backup_parsed as Dictionary
	if not _validate_save_data(backup_data).is_empty():
		return false
	_apply_save_data(backup_data)
	_update_hud("Основное сохранение повреждено — загружена резервная копия")
	return true

func _apply_save_data(save_data: Dictionary) -> void:
	credits = clampi(int(save_data.get("credits", credits)), 0, 999999999)
	score = maxi(int(save_data.get("score", score)), 0)
	enemy_kills = maxi(int(save_data.get("enemy_kills", score)), 0)
	rank = clampi(int(save_data.get("rank", rank)), 0, 12)
	experience = clampi(int(save_data.get("experience", experience)), 0, maxi((rank + 1) * 5 - 1, 0))
	base_upgrade_level = clampi(int(save_data.get("base_upgrade_level", base_upgrade_level)), 1, 4)
	base.defense = maxf(float(save_data.get("base_defense", base.defense)), 0.0)
	base.health = clampf(float(save_data.get("base_health", base.health)), 1.0, base.max_health)
	base.health_changed.emit(base.health, base.max_health)
	base.shield_points = maxf(float(save_data.get("base_shield", 0.0)), 0.0)
	base.set_invulnerable(float(save_data.get("base_invulnerability_remaining", 0.0)))
	_set_fog_revealed(float(save_data.get("fog_reveal_remaining", 0.0)))
	unlocked_action_ids.clear()
	var saved_action_ids: Variant = save_data.get("unlocked_action_ids", [])
	if saved_action_ids is Array:
		for action_value: Variant in saved_action_ids as Array:
			var action_id: int = int(action_value)
			if action_id >= 1 and action_id <= 12 and not unlocked_action_ids.has(action_id):
				unlocked_action_ids.append(action_id)
	for action_id: int in range(1, 13):
		action_charges[action_id] = 0
	var saved_charges: Variant = save_data.get("action_charges", {})
	if saved_charges is Dictionary:
		for action_key: Variant in (saved_charges as Dictionary).keys():
			var charge_id: int = int(action_key)
			if charge_id >= 1 and charge_id <= 12:
				action_charges[charge_id] = clampi(int((saved_charges as Dictionary)[action_key]), 0, 999)
	var saved_research: Variant = save_data.get("researched", {})
	researched = saved_research as Dictionary if saved_research is Dictionary else {}
	unlocked_building_ids.clear()
	var saved_building_unlocks: Variant = save_data.get("unlocked_building_ids", BUILDING_REGISTRY.INITIAL_IDS)
	if saved_building_unlocks is Array:
		for building_value: Variant in saved_building_unlocks as Array:
			var building_id: int = int(building_value)
			if SUPPORTED_BUILDING_IDS.has(building_id) and not unlocked_building_ids.has(building_id):
				unlocked_building_ids.append(building_id)
	if unlocked_building_ids.is_empty():
		unlocked_building_ids = BUILDING_REGISTRY.INITIAL_IDS.duplicate()
	_clear_saved_buildings()
	var saved_buildings: Variant = save_data.get("buildings", [])
	if saved_buildings is Array:
		for building_value: Variant in saved_buildings as Array:
			if building_value is Dictionary:
				_restore_building(building_value as Dictionary)
	var restored_wave_enemy_count: int = 0
	var saved_enemies: Variant = save_data.get("enemies", [])
	if saved_enemies is Array:
		for enemy_value: Variant in saved_enemies as Array:
			if enemy_value is Dictionary:
				var enemy_data: Dictionary = enemy_value as Dictionary
				if _restore_enemy(enemy_data) and bool(enemy_data.get("registered_with_wave", false)):
					restored_wave_enemy_count += 1
	var saved_wave_state: Variant = save_data.get("wave_state", {})
	if saved_wave_state is Dictionary:
		wave_manager.restore_state(saved_wave_state as Dictionary, restored_wave_enemy_count)
	else:
		wave_manager.start()
	_update_building_picker_unlocks()
	_refresh_progression_ui()

func _clear_saved_buildings() -> void:
	for enemy_node: Node in enemies.get_children():
		enemies.remove_child(enemy_node)
		enemy_node.queue_free()
	for tower_node: Node in towers.get_children():
		var tower: GrayboxTower = tower_node as GrayboxTower
		if is_instance_valid(tower):
			towers.remove_child(tower)
			tower.queue_free()
	selected_tower = null
	base_selected = false
	tower_cells.clear()
	tower_footprints.clear()
	grid = MAP_GRID_TYPE.new()
	navigation = NAVIGATION_SYSTEM_TYPE.new(grid)
	grid.set_occupied(_cell_from_position(base.position), true)
	grid.set_occupied(_cell_from_position(Vector2(300.0, 270.0)), true)

func _restore_building(building_data: Dictionary) -> void:
	var building_id: int = int(building_data.get("building_id", FIRE_TOWER_ID))
	var cell: Vector2i = Vector2i(int(building_data.get("cell_x", 0)), int(building_data.get("cell_y", 0)))
	if not SUPPORTED_BUILDING_IDS.has(building_id) or not grid.is_walkable(cell):
		return
	var tower: GrayboxTower = _scene_for_building(building_id).instantiate() as GrayboxTower
	tower.building_id = building_id
	tower.position = _slice_world_from_cell(cell)
	tower.z_index = 5
	towers.add_child(tower)
	_apply_cell_diamond_debug(tower)
	tower.destroyed.connect(_on_tower_destroyed.bind(tower))
	tower_cells[tower] = cell
	grid.set_occupied(cell, true)
	tower.restore_saved_state(float(building_data.get("health", tower.max_health)), int(building_data.get("upgrade_level", 0)))

func _restore_enemy(enemy_data: Dictionary) -> bool:
	var enemy_id: int = int(enemy_data.get("enemy_id", 70))
	if not GameBalance.ENEMY_PROFILES.has(enemy_id):
		return false
	var enemy: GrayboxBug = BUG_SCENE.instantiate() as GrayboxBug
	enemy.enemy_id = enemy_id
	enemy.position = Vector2(float(enemy_data.get("x", 0.0)), float(enemy_data.get("y", 0.0)))
	enemy.set_target(base)
	enemy.registered_with_wave = bool(enemy_data.get("registered_with_wave", false))
	var saved_path_data: Variant = enemy_data.get("path", [])
	var saved_path: Array[Vector2] = []
	if saved_path_data is Array:
		for point_value: Variant in saved_path_data as Array:
			if point_value is Dictionary:
				var point_data: Dictionary = point_value as Dictionary
				saved_path.append(Vector2(float(point_data.get("x", 0.0)), float(point_data.get("y", 0.0))))
	if saved_path.is_empty():
		saved_path = _path_to_base(enemy.position)
	enemy.set_path(saved_path)
	enemy.died.connect(_on_bug_died.bind(bool(enemy_data.get("registered_with_wave", false))))
	enemies.add_child(enemy)
	enemy.restore_saved_state(enemy_data)
	return true

func _setup_debug_controls() -> void:
	debug_button = Button.new()
	debug_button.name = "DebugTouchButton"
	debug_button.position = Vector2(8.0, 670.0)
	debug_button.size = Vector2(104.0, 40.0)
	debug_button.text = "ДЕБАГ"
	debug_button.z_index = 2600
	debug_button.pressed.connect(_on_debug_button_pressed)
	add_child(debug_button)

	debug_menu = Panel.new()
	debug_menu.name = "DebugMenu"
	debug_menu.position = Vector2(8.0, 430.0)
	debug_menu.size = Vector2(300.0, 320.0)
	debug_menu.z_index = 2700
	debug_menu.visible = false
	add_child(debug_menu)

	var title: Label = Label.new()
	title.position = Vector2(14.0, 10.0)
	title.size = Vector2(270.0, 28.0)
	title.text = "ДЕБАГ-МЕНЮ"
	debug_menu.add_child(title)

	debug_money_button = Button.new()
	debug_money_button.position = Vector2(14.0, 48.0)
	debug_money_button.size = Vector2(270.0, 42.0)
	debug_money_button.text = "+1000 ДЕНЕГ"
	debug_money_button.pressed.connect(_on_debug_add_money_pressed)
	debug_menu.add_child(debug_money_button)

	debug_fog_button = Button.new()
	debug_fog_button.position = Vector2(14.0, 98.0)
	debug_fog_button.size = Vector2(270.0, 42.0)
	debug_fog_button.text = "РАСКРЫТЬ ТУМАН НАВСЕГДА"
	debug_fog_button.pressed.connect(_on_debug_fog_pressed)
	debug_menu.add_child(debug_fog_button)

	debug_cell_diamond_button = Button.new()
	debug_cell_diamond_button.position = Vector2(14.0, 153.0)
	debug_cell_diamond_button.size = Vector2(270.0, 42.0)
	debug_cell_diamond_button.text = "РОМБ КЛЕТКИ: ВЫКЛ"
	debug_cell_diamond_button.pressed.connect(_on_debug_cell_diamond_pressed)
	debug_menu.add_child(debug_cell_diamond_button)

	debug_muzzle_points_button = Button.new()
	debug_muzzle_points_button.position = Vector2(14.0, 198.0)
	debug_muzzle_points_button.size = Vector2(270.0, 42.0)
	debug_muzzle_points_button.text = "ТОЧКИ ДУЛА: ВЫКЛ"
	debug_muzzle_points_button.pressed.connect(_on_debug_muzzle_points_pressed)
	debug_menu.add_child(debug_muzzle_points_button)

	debug_close_button = Button.new()
	debug_close_button.position = Vector2(14.0, 253.0)
	debug_close_button.size = Vector2(270.0, 38.0)
	debug_close_button.text = "ЗАКРЫТЬ"
	debug_close_button.pressed.connect(_on_debug_button_pressed)
	debug_menu.add_child(debug_close_button)

func _on_debug_button_pressed() -> void:
	if not is_instance_valid(debug_menu):
		return
	debug_menu.visible = not debug_menu.visible

func _on_debug_add_money_pressed() -> void:
	credits += 1000
	_update_hud("Дебаг: добавлено 1000 ресурсов")

func _on_debug_fog_pressed() -> void:
	fog_reveal_infinite = true
	action_active_until = 0.0
	var fog_material: ShaderMaterial = fog_mask.material as ShaderMaterial
	if fog_material != null:
		fog_material.set_shader_parameter("enabled", 0.0)
	for fog_name: String in ["FogTop", "FogBottom", "FogLeft", "FogRight"]:
		var fog: ColorRect = get_node("Playfield/" + fog_name) as ColorRect
		fog.color.a = 0.0
	_update_hud("Дебаг: туман войны раскрыт навсегда")
	debug_fog_button.text = "ТУМАН РАСКРЫТ"
	debug_fog_button.disabled = true

func _on_debug_cell_diamond_pressed() -> void:
	debug_cell_diamond_enabled = not debug_cell_diamond_enabled
	debug_cell_diamond_button.text = "РОМБ КЛЕТКИ: ВКЛ" if debug_cell_diamond_enabled else "РОМБ КЛЕТКИ: ВЫКЛ"
	for tower_node: Node in towers.get_children():
		_apply_cell_diamond_debug(tower_node as GrayboxTower)

func _on_debug_muzzle_points_pressed() -> void:
	debug_muzzle_points_enabled = not debug_muzzle_points_enabled
	debug_muzzle_points_button.text = "ТОЧКИ ДУЛА: ВКЛ" if debug_muzzle_points_enabled else "ТОЧКИ ДУЛА: ВЫКЛ"
	for tower_node: Node in towers.get_children():
		var tower: GrayboxTower = tower_node as GrayboxTower
		if not is_instance_valid(tower):
			continue
		var soldier_visual: SoldiersTower = tower.get_node_or_null("SoldierVisual") as SoldiersTower
		if soldier_visual != null:
			soldier_visual.set_debug_muzzle_points(debug_muzzle_points_enabled)

func _apply_cell_diamond_debug(tower: GrayboxTower) -> void:
	if not is_instance_valid(tower):
		return
	var soldier_visual: SoldiersTower = tower.get_node_or_null("SoldierVisual") as SoldiersTower
	if soldier_visual != null:
		soldier_visual.debug_cell_diamond = debug_cell_diamond_enabled
		soldier_visual.queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED and is_node_ready():
		_save_game()
		_set_game_paused(true)

func _ensure_hud_label(hud_node: Panel, node_name: String) -> Label:
	var existing: Label = hud_node.get_node_or_null(node_name) as Label
	if existing != null:
		return existing
	var created: Label = Label.new()
	created.name = node_name
	hud_node.add_child(created)
	return created

func _ensure_hud_button(hud_node: Panel, node_name: String) -> Button:
	var existing: Button = hud_node.get_node_or_null(node_name) as Button
	if existing != null:
		return existing
	var created: Button = Button.new()
	created.name = node_name
	hud_node.add_child(created)
	return created

func _ensure_hud_compatibility() -> void:
	var hud_node: Panel = get_node_or_null("HUD") as Panel
	if hud_node == null:
		hud_node = Panel.new()
		hud_node.name = "HUD"
		hud_node.visible = false
		add_child(hud_node)
	credits_label = _ensure_hud_label(hud_node, "Credits")
	selected_label = _ensure_hud_label(hud_node, "SelectedBuilding")
	tower_info_label = _ensure_hud_label(hud_node, "TowerInfo")
	status_label = _ensure_hud_label(hud_node, "Status")
	wave_label = _ensure_hud_label(hud_node, "Wave")
	for label_name: String in ["Title", "Subtitle", "Instructions", "BaseLabel"]:
		_ensure_hud_label(hud_node, label_name)
	upgrade_button = _ensure_hud_button(hud_node, "UpgradeButton")
	repair_button = _ensure_hud_button(hud_node, "RepairButton")
	sell_button = _ensure_hud_button(hud_node, "SellButton")
	build_button = _ensure_hud_button(hud_node, "BuildButton")
	next_wave_button = _ensure_hud_button(hud_node, "NextWaveButton")
	building_151_button = _ensure_hud_button(hud_node, "Building151Button")
	building_153_button = _ensure_hud_button(hud_node, "Building153Button")
	building_155_button = _ensure_hud_button(hud_node, "Building155Button")
	building_picker = hud_node.get_node_or_null("BuildingPicker") as OptionButton
	if building_picker == null:
		building_picker = OptionButton.new()
		building_picker.name = "BuildingPicker"
		hud_node.add_child(building_picker)
	save_button = _ensure_hud_button(hud_node, "SaveButton")
	load_button = _ensure_hud_button(hud_node, "LoadButton")
	base_bar = hud_node.get_node_or_null("BaseHealth") as ProgressBar
	if base_bar == null:
		base_bar = ProgressBar.new()
		base_bar.name = "BaseHealth"
		hud_node.add_child(base_bar)
	# Keep legacy HUD paths used by the setup text safe when the HUD was deleted.
	_ensure_hud_button(hud_node, "CancelBuildButton")
	_ensure_hud_button(hud_node, "PauseButton")

func _ready() -> void:
	_ensure_hud_compatibility()
	_setup_debug_controls()
	randomize()
	survival_started_at = Time.get_ticks_msec()
	active_spawn_position = _random_edge_spawn()
	$HUD/Title.text = "ОБОРОНА МАРСА"
	$HUD/Subtitle.text = "Защищай центральную базу и переживи атаки"
	$HUD/Instructions.text = "Коснись постройки • Построить • выбери свободную клетку\nКоснись объекта, чтобы выбрать его • Escape отмена режима"
	$HUD/BaseLabel.text = "Целостность базы"
	$HUD/UpgradeButton.text = "Модернизировать"
	$HUD/RepairButton.text = "Ремонтировать"
	$HUD/SellButton.text = "Снести"
	$HUD/CancelBuildButton.text = "Отменить"
	$HUD/Instructions.text = "Выбери здание и нажми Построить\nНажми на свободную клетку для размещения\nВыбери объект для управления"
	$HUD/Title.text = "СТУРМТРУПП МАРС"
	$HUD/Subtitle.text = ""
	$HUD/BuildButton.text = "СТРОИТЬ"
	$HUD/CancelBuildButton.text = "ОТМЕНА"
	$HUD/NextWaveButton.text = "АТАКА"
	$HUD/PauseButton.text = "ПАУЗА"
	$HUD/UpgradeButton.text = "УЛУЧШИТЬ"
	$HUD/RepairButton.text = "РЕМОНТ"
	$HUD/SellButton.text = "ПРОДАТЬ"
	$PauseMenu/Card/SaveButton.pressed.connect(_on_pause_save_pressed)
	$PauseMenu/Card/ContinueButton.pressed.connect(_on_pause_continue_pressed)
	$PauseMenu/Card/MenuButton.pressed.connect(_on_pause_menu_pressed)
	intro_confirm_button.pressed.connect(_on_intro_confirmed)
	palette_picker.clear()
	for building_id: int in BUILD_PALETTE_SUPPORTED_IDS:
		palette_picker.add_item(BUILDING_REGISTRY.display_name(building_id), building_id)
	palette_picker.item_selected.connect(_on_palette_picker_selected)
	palette_confirm_button.pressed.connect(_on_palette_confirmed)
	palette_cancel_button.pressed.connect(_close_build_palette)
	grid = MAP_GRID_TYPE.new()
	navigation = NAVIGATION_SYSTEM_TYPE.new(grid)
	_add_contact_shadow(base, Vector2(1.35, 0.72), 0.30)
	_register_rock_formations()
	grid.set_occupied(_cell_from_position(base.position), true)
	var test_base_cell: Vector2i = _cell_from_position(Vector2(300.0, 270.0))
	if test_base_cell != _cell_from_position(base.position):
		grid.set_occupied(test_base_cell, true)
	base.health_changed.connect(_on_base_health_changed)
	base.destroyed.connect(_on_base_destroyed)
	wave_manager.spawn_requested.connect(_on_wave_spawn_requested)
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_cleared.connect(_on_wave_cleared)
	wave_manager.all_waves_complete.connect(_on_all_waves_complete)
	wave_manager.intermission_started.connect(_on_intermission_started)
	next_wave_button.pressed.connect(_on_next_wave_pressed)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	repair_button.pressed.connect(_on_repair_button_pressed)
	sell_button.pressed.connect(_on_sell_button_pressed)
	build_button.pressed.connect(_on_build_button_pressed)
	cancel_build_button.pressed.connect(_on_cancel_build_button_pressed)
	save_button.pressed.connect(_save_game)
	load_button.pressed.connect(_load_game)
	building_151_button.pressed.connect(_on_building_151_pressed)
	building_153_button.pressed.connect(_on_building_153_pressed)
	building_155_button.pressed.connect(_on_building_155_pressed)
	building_picker.clear()
	for building_id: int in BUILDING_REGISTRY.PLAYABLE_IDS:
		building_picker.add_item(BUILDING_REGISTRY.display_name(building_id), building_id)
	building_picker.item_selected.connect(_on_building_picker_selected)
	_update_building_picker_unlocks()
	_action_picker_setup()
	_research_picker_setup()
	use_action_button.pressed.connect(_on_use_action_pressed)
	research_button.pressed.connect(_on_research_pressed)
	upgrade_building_button.pressed.connect(_on_upgrade_button_pressed)
	repair_building_button.pressed.connect(_on_repair_button_pressed)
	sell_building_button.pressed.connect(_on_sell_button_pressed)
	_refresh_progression_ui()
	building_151_button.visible = false
	building_153_button.visible = false
	building_155_button.visible = false
	build_preview.visible = false
	pause_button.pressed.connect(_toggle_pause)
	actions_button.pressed.connect(_on_actions_button_pressed)
	notice_confirm_button.pressed.connect(_on_notice_confirmed)
	next_wave_button.visible = false
	_update_selected_building()
	_update_tower_info()
	_update_hud("Неподалеку обнаружены инопланетные существа")
	var continue_requested: bool = bool(get_tree().get_meta("sturmtrupp_continue_requested", false))
	if continue_requested:
		get_tree().remove_meta("sturmtrupp_continue_requested")
		intro_pending = false
		commander_intro.visible = false
		_load_game()
		wave_manager.start()
	else:
		intro_pending = true
		commander_intro.visible = true
		# Gameplay is gated by intro_pending; keep the tree running so embedded Godot playtest input cannot appear frozen.
		get_tree().paused = false
		_update_continue_button()
	_update_spawn_marker()
	_initialize_fog_mask()

func _on_intro_confirmed() -> void:
	if not intro_pending:
		return
	intro_pending = false
	commander_intro.visible = false
	get_tree().paused = false
	wave_manager.start()
	_update_hud("Атака Марса началась")

func _update_palette_details() -> void:
	var profile: Dictionary = BUILDING_REGISTRY.profile(selected_building_id)
	var details: Array[String] = []
	if profile.has("max_health"):
		details.append("ОЖ: %.0f" % float(profile["max_health"]))
	if profile.has("defense"):
		details.append("О: %.0f" % float(profile["defense"]))
	if profile.has("attack"):
		details.append("А: %.0f" % float(profile["attack"]))
	if profile.has("radius"):
		details.append("Р: %.0f" % float(profile["radius"]))
	details.append("Расходы: %d $" % _build_cost(selected_building_id))
	palette_details.text = "   ".join(details)

func _on_palette_picker_selected(index: int) -> void:
	var building_id: int = palette_picker.get_item_id(index)
	if BUILD_PALETTE_SUPPORTED_IDS.has(building_id):
		selected_building_id = building_id
		_update_palette_details()

func _on_palette_confirmed() -> void:
	if pending_build_cell.x < 0 or pending_build_cell.y < 0:
		return
	var local_world: Vector2 = entities.to_local(pending_build_screen_position)
	local_world = _slice_world_from_cell(pending_build_cell)
	build_palette_popup.visible = false
	build_picker_open = false
	build_mode = true
	cancel_build_button.visible = true
	build_cursor_position = pending_build_screen_position
	placement_preview_cell = pending_build_cell
	placement_preview_valid = _can_build_at(local_world, pending_build_cell)
	build_preview.visible = true
	build_button.text = "Разместить здесь"
	_update_hud("Перемести юнит и нажми повторно для строительства")

func _close_build_palette() -> void:
	build_palette_popup.visible = false
	build_picker_open = false
	pending_build_cell = Vector2i(-1, -1)

func _test_spawn_enemy() -> void:
	_spawn_bug(spawn_points[spawn_counter % spawn_points.size()], false)
	spawn_counter += 1
	_update_hud("Тест: создан враг")

func _test_damage_base() -> void:
	base.take_damage(50.0)
	_update_hud("Тест: база получила 50 урона")

func _test_add_credits() -> void:
	credits += 500
	_update_hud("Тест: добавлено 500 ресурсов")

func _test_repair_base() -> void:
	base.repair_full()
	_update_hud("Тест: база отремонтирована")

func _test_unlock_actions() -> void:
	for action_id: int in range(1, 13):
		if not unlocked_action_ids.has(action_id):
			unlocked_action_ids.append(action_id)
		action_charges[action_id] = 1
	_refresh_progression_ui()
	_update_hud("Тест: действия разблокированы")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag or event is InputEventMouseButton or event is InputEventMouseMotion:
		return
	if event is InputEventKey:
		var escape_event: InputEventKey = event as InputEventKey
		if escape_event.pressed and not escape_event.echo and escape_event.keycode == KEY_ESCAPE and not game_over:
			if build_mode:
				_on_cancel_build_button_pressed()
			elif game_paused:
				_set_game_paused(false)
			else:
				_set_game_paused(true)
			return
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if test_hud_panel.visible and key_event.pressed and key_event.keycode == KEY_F1:
			_spawn_bug(spawn_points[spawn_counter % spawn_points.size()], false)
			spawn_counter += 1
			_update_hud("DEBUG F1: enemy spawned")
		elif test_hud_panel.visible and key_event.pressed and key_event.keycode == KEY_F2:
			base.take_damage(50.0)
			_update_hud("DEBUG F2: base damaged by 50")
		elif test_hud_panel.visible and key_event.pressed and key_event.keycode == KEY_F3:
			credits += 500
			_update_hud("DEBUG F3: +500 credits")
		elif test_hud_panel.visible and key_event.pressed and key_event.keycode == KEY_F4:
			base.repair_full()
			_update_hud("DEBUG F4: base repaired")
		elif test_hud_panel.visible and key_event.pressed and key_event.keycode == KEY_F6:
			_save_game()
		elif test_hud_panel.visible and key_event.pressed and key_event.keycode == KEY_F7:
			_load_game()
		elif test_hud_panel.visible and key_event.pressed and key_event.keycode == KEY_F5:
			for action_id: int in range(1, 13):
				if not unlocked_action_ids.has(action_id):
					unlocked_action_ids.append(action_id)
				action_charges[action_id] = 1
			_refresh_progression_ui()
			_update_hud("DEBUG F5: all actions unlocked")
		elif not game_paused and key_event.pressed and key_event.keycode == KEY_1:
			selected_building_id = FIRE_TOWER_ID
			_update_selected_building()
			_update_hud("Selected Fire Tower ID 153")
		elif test_hud_panel.visible and key_event.pressed and key_event.keycode == KEY_D:
			_damage_first_tower()
		elif test_hud_panel.visible and key_event.pressed and key_event.keycode == KEY_U:
			_upgrade_first_tower()
	if game_paused:
		return

	if event is InputEventKey and (event as InputEventKey).pressed and (event as InputEventKey).keycode == KEY_ESCAPE and build_mode:
		_on_cancel_build_button_pressed()
		return
	if event.is_action_pressed("ui_accept") and not game_over:
		_spawn_bug(spawn_points[spawn_counter % spawn_points.size()], false)
		spawn_counter += 1

func _set_map_zoom(next_zoom: float, focus: Vector2) -> void:
	var clamped_zoom: float = clampf(next_zoom, MIN_MAP_ZOOM, MAX_MAP_ZOOM)
	if is_equal_approx(clamped_zoom, map_zoom):
		return
	var local_focus: Vector2 = entities.to_local(focus)
	map_zoom = clamped_zoom
	entities.scale = Vector2.ONE * map_zoom
	var grid_lines: Line2D = playfield.get_node_or_null("GridLines") as Line2D
	entities.position = focus - local_focus * map_zoom
	entities.position = _clamp_map_pan(entities.position)
	if grid_lines != null:
		grid_lines.scale = Vector2.ONE * map_zoom
		grid_lines.position = entities.position

func _clamp_map_pan(candidate_offset: Vector2) -> Vector2:
	# The map is centered around its local origin, not laid out from (0, 0).
	# Therefore the valid offset range must be calculated from both map edges.
	var scaled_extent: Vector2 = MAP_HALF_EXTENT * map_zoom
	var scaled_base_position: Vector2 = base.position * map_zoom
	var map_origin: Vector2 = scaled_base_position - scaled_extent
	var map_end: Vector2 = scaled_base_position + scaled_extent
	var min_offset: Vector2 = playfield.size - map_end
	var max_offset: Vector2 = -map_origin
	return Vector2(clampf(candidate_offset.x, min_offset.x, max_offset.x), clampf(candidate_offset.y, min_offset.y, max_offset.y))

func _update_map_edge_indicators() -> void:
	# Edge labels are optional presentation nodes. They may be removed from the
	# gameplay scene without breaking the map or the build controls.
	var edge_names: Array[String] = ["MapEdgeLeft", "MapEdgeRight", "MapEdgeTop", "MapEdgeBottom"]
	for edge_name: String in edge_names:
		var edge_node: CanvasItem = entities.get_node_or_null(edge_name) as CanvasItem
		if is_instance_valid(edge_node):
			edge_node.visible = false

func _pointer_start(pointer_position: Vector2, from_touch: bool) -> void:
	if intro_pending or game_paused or game_over or build_picker_open:
		pointer_is_down = false
		return
	if _screen_point_hits_ui(pointer_position):
		pointer_is_down = false
		return
	pointer_is_down = true
	pointer_dragged = false
	touch_drag_started = false
	pointer_start_position = pointer_position
	pointer_last_position = pointer_position
	pointer_can_pan = not build_mode and not _screen_point_hits_ui(pointer_position)
	if from_touch:
		touch_drag_started = false
	pointer_dragged = touch_drag_started
	build_cursor_position = pointer_position

func _pointer_move(pointer_position: Vector2) -> void:
	if not pointer_is_down:
		return
	var movement: Vector2 = pointer_position - pointer_last_position
	pointer_last_position = pointer_position
	if not pointer_dragged and pointer_position.distance_to(pointer_start_position) >= PAN_DRAG_THRESHOLD:
		pointer_dragged = true
	if pointer_dragged and pointer_can_pan:
		entities.position += movement
		entities.position = _clamp_map_pan(entities.position)
		var grid_lines: Line2D = playfield.get_node_or_null("GridLines") as Line2D
		if grid_lines != null:
			grid_lines.position = entities.position
		build_cursor_position = pointer_position

func _pointer_end(pointer_position: Vector2) -> void:
	if not pointer_is_down:
		return
	pointer_is_down = false
	build_cursor_position = pointer_position
	if not pointer_dragged and pointer_position.distance_to(pointer_start_position) >= PAN_DRAG_THRESHOLD:
		pointer_dragged = true
	if pointer_dragged:
		return
	_select_or_build(pointer_position)

func _input(event: InputEvent) -> void:
	if game_paused or intro_pending or game_over or build_picker_open:
		return
	if building_action_panel_active:
		if event is InputEventMouseButton:
			var mouse_event: InputEventMouseButton = event as InputEventMouseButton
			if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT and not _context_panel_contains_point(mouse_event.position):
				_close_building_action_panel()
			return
		if event is InputEventScreenTouch:
			var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
			if touch_event.pressed and not _context_panel_contains_point(touch_event.position):
				_close_building_action_panel()
			return
		if event is InputEventMouseMotion or event is InputEventScreenDrag:
			return
	if event is InputEventMouseButton:
		var mouse_input: InputEventMouseButton = event as InputEventMouseButton
		if _screen_point_hits_ui(mouse_input.position):
			pointer_is_down = false
			return
	if event is InputEventScreenTouch:
		var touch_input: InputEventScreenTouch = event as InputEventScreenTouch
		if _screen_point_hits_ui(touch_input.position):
			pointer_is_down = false
			return
	if event is InputEventScreenDrag:
		var drag_input: InputEventScreenDrag = event as InputEventScreenDrag
		if _screen_point_hits_ui(drag_input.position):
			pointer_is_down = false
			return
	if event is InputEventMagnifyGesture:
		var magnify_event: InputEventMagnifyGesture = event as InputEventMagnifyGesture
		_set_map_zoom(map_zoom * magnify_event.factor, magnify_event.position)
		return
	if event is InputEventMouseButton:
		var wheel_event: InputEventMouseButton = event as InputEventMouseButton
		if wheel_event.pressed and wheel_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_map_zoom(map_zoom * 1.1, wheel_event.position)
			return
		if wheel_event.pressed and wheel_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_map_zoom(map_zoom / 1.1, wheel_event.position)
			return
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			_pointer_start(touch_event.position, true)
		else:
			_pointer_end(touch_event.position)
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		if not pointer_is_down:
			_pointer_start(drag_event.position, true)
		if pointer_is_down:
			_pointer_move(drag_event.position)
	elif event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				_pointer_start(mouse_event.position, false)
			else:
				_pointer_end(mouse_event.position)
	elif event is InputEventMouseMotion:
		var motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		build_cursor_position = motion_event.position
		_update_hover_selection(motion_event.position)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if not pointer_is_down:
				_pointer_start(motion_event.position, false)
			if pointer_is_down:
				_pointer_move(motion_event.position)

func _context_panel_contains_point(pointer_position: Vector2) -> bool:
	var context_panel: Control = get_node_or_null("Playfield/ContextPanel") as Control
	return is_instance_valid(context_panel) and context_panel.visible and context_panel.get_global_rect().has_point(pointer_position)

func _close_building_action_panel() -> void:
	building_action_panel_active = false
	$Playfield/ContextPanel.visible = false
	base_selected = false
	selected_tower = null
	hover_debug_radii.hide_radii()
	_update_tower_info()

func _screen_point_hits_ui(pointer_position: Vector2) -> bool:
	var ui_roots: Array[Control] = [pause_button, actions_button, cancel_build_button, debug_button, debug_menu]
	var overlay_names: Array[String] = ["CommanderIntro", "BuildPalettePopup", "ProgressionNotice", "PauseMenu"]
	for overlay_name: String in overlay_names:
		var overlay: Control = get_node_or_null(overlay_name) as Control
		if is_instance_valid(overlay):
			ui_roots.append(overlay)
	var context_panel: Control = get_node_or_null("Playfield/ContextPanel") as Control
	if is_instance_valid(context_panel):
		ui_roots.append(context_panel)
	for ui_root: Control in ui_roots:
		if is_instance_valid(ui_root) and _control_tree_contains_point(ui_root, pointer_position):
			return true
	return false

func _control_tree_contains_point(control: Control, pointer_position: Vector2) -> bool:
	if not control.visible or control.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		return false
	if control.get_global_rect().has_point(pointer_position):
		return true
	for child: Node in control.get_children():
		var child_control: Control = child as Control
		if is_instance_valid(child_control) and _control_tree_contains_point(child_control, pointer_position):
			return true
	return false

func _screen_point_hits_fixed_hud(pointer_position: Vector2) -> bool:
	var minimap: Control = get_node("Playfield/MiniMap") as Control
	var badge: Control = get_node("Playfield/CreditsBadge") as Control
	var minimap_rect: Rect2 = Rect2(minimap.position, minimap.size)
	var badge_rect: Rect2 = Rect2(badge.position, badge.size)
	if minimap_rect.has_point(pointer_position) or badge_rect.has_point(pointer_position):
		return true
	var fixed_controls: Array[Control] = [pause_button, actions_button, cancel_build_button]
	for control: Control in fixed_controls:
		if is_instance_valid(control) and control.visible and control.get_global_rect().has_point(pointer_position):
			return true
	return false

func _update_minimap() -> void:
	var minimap_size: Vector2 = $Playfield/MiniMap.size
	var map_size: Vector2 = MAP_HALF_EXTENT * 2.0
	var map_offset: Vector2 = entities.position
	var map_origin: Vector2 = base.position - MAP_HALF_EXTENT
	var visible_origin: Vector2 = (-map_offset / map_zoom - map_origin)
	var visible_size: Vector2 = playfield.size / map_zoom
	var viewport_position: Vector2 = visible_origin / map_size * minimap_size
	var viewport_size: Vector2 = visible_size / map_size * minimap_size
	var clamped_viewport_size: Vector2 = Vector2(minf(viewport_size.x, minimap_size.x), minf(viewport_size.y, minimap_size.y))
	var max_viewport_position: Vector2 = minimap_size - clamped_viewport_size
	minimap_viewport.position = Vector2(clampf(viewport_position.x, 0.0, max_viewport_position.x), clampf(viewport_position.y, 0.0, max_viewport_position.y))
	minimap_viewport.size = clamped_viewport_size
	var base_map_position: Vector2 = ((map_offset / map_zoom) + base.position - map_origin) / map_size * minimap_size
	var marker_size: Vector2 = Vector2(4.0, 4.0)
	var marker_origin: Vector2 = base_map_position - marker_size * 0.5
	minimap_base_marker.position = Vector2(clampf(marker_origin.x, 0.0, minimap_size.x - marker_size.x), clampf(marker_origin.y, 0.0, minimap_size.y - marker_size.y))
	minimap_base_marker.size = marker_size

func _start_construction(tower: GrayboxTower, is_upgrade: bool = false) -> void:
	var large_building: bool = tower.building_id == ENERGY_STATION_ID
	tower.combat_enabled = false
	var construction_visual: Sprite2D = Sprite2D.new()
	construction_visual.texture = LARGE_CONSTRUCTION_TEXTURE if large_building else SMALL_CONSTRUCTION_TEXTURE
	construction_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	construction_visual.z_index = 4
	construction_visual.scale = Vector2(2.0, 2.0)
	tower.add_child(construction_visual)
	var pad_visual: Sprite2D = Sprite2D.new()
	pad_visual.texture = LARGE_PAD_TEXTURE if large_building else SMALL_PAD_TEXTURE
	pad_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pad_visual.z_index = 0
	pad_visual.scale = Vector2(2.0, 2.0)
	pad_visual.visible = not bool(tower.get("use_new_soldier_visual"))
	tower.add_child(pad_visual)
	var progress_bar: ProgressBar = ProgressBar.new()
	progress_bar.position = Vector2(-32.0, 38.0)
	progress_bar.size = Vector2(64.0, 7.0)
	progress_bar.max_value = 1.0
	progress_bar.value = 0.0
	progress_bar.show_percentage = false
	progress_bar.z_index = 6
	tower.add_child(progress_bar)
	var original_visibility: Dictionary = {}
	for child: Node in tower.get_children():
		if child != construction_visual and child != pad_visual and child != progress_bar:
			if child is CanvasItem:
				original_visibility[child.name] = (child as CanvasItem).visible
				(child as CanvasItem).visible = false
	var profile: Dictionary = BUILDING_REGISTRY.profile(tower.building_id)
	var default_duration: float = LARGE_CONSTRUCTION_TIME if large_building else SMALL_CONSTRUCTION_TIME
	var duration_key: String = "upgrade_time" if is_upgrade else "construction_time"
	var duration: float = float(profile.get(duration_key, default_duration))
	construction_states[tower] = {"elapsed": 0.0, "duration": duration, "visual": construction_visual, "pad": pad_visual, "progress": progress_bar, "original_visibility": original_visibility, "is_upgrade": is_upgrade}
	_update_hud("Модернизация началась" if is_upgrade else "Строительство началось")

func _process_repairs(delta: float) -> void:
	var completed: Array[Node] = []
	for target_key: Variant in repair_states.keys():
		if not is_instance_valid(target_key):
			repair_states.erase(target_key)
			continue
		var target: Node = target_key as Node
		if credits <= 0:
			completed.append(target)
			continue
		var missing_health: float = maxf(float(target.max_health) - float(target.health), 0.0)
		if missing_health <= 0.0:
			completed.append(target)
			continue
		var repair_amount: float = minf(REPAIR_RATE_HP_PER_SECOND * delta, missing_health)
		var state: Dictionary = repair_states[target]
		var requested_cost: float = float(state["cost_remainder"]) + repair_amount * REPAIR_COST_PER_HP
		var charge: int = floori(requested_cost)
		if charge > credits:
			repair_amount = float(credits) / REPAIR_COST_PER_HP
			charge = credits
			requested_cost = 0.0
		if repair_amount > 0.0 and target.has_method("repair_by"):
			target.repair_by(repair_amount)
		credits -= charge
		state["cost_remainder"] = requested_cost - float(charge)
		if float(target.health) >= float(target.max_health) or credits <= 0:
			completed.append(target)
	for target: Node in completed:
		repair_states.erase(target)
		_update_hud("Ремонт завершен" if is_instance_valid(target) and float(target.health) >= float(target.max_health) else "Ремонт остановлен: недостаточно средств")
	_update_tower_info()

func _process_construction(delta: float) -> void:
	var completed: Array[GrayboxTower] = []
	for tower_key: Variant in construction_states.keys():
		var tower: GrayboxTower = tower_key as GrayboxTower
		if not is_instance_valid(tower):
			completed.append(tower)
			continue
		var state: Dictionary = construction_states[tower]
		state["elapsed"] = float(state["elapsed"]) + delta
		var progress: float = clampf(float(state["elapsed"]) / float(state["duration"]), 0.0, 1.0)
		var progress_bar: ProgressBar = state["progress"] as ProgressBar
		progress_bar.value = progress
		if progress >= 1.0:
			var construction_visual: Node = state["visual"] as Node
			var pad_visual: Node = state["pad"] as Node
			var progress_node: Node = state["progress"] as Node
			construction_visual.queue_free()
			progress_node.queue_free()
			var original_visibility: Dictionary = state["original_visibility"] as Dictionary
			for child: Node in tower.get_children():
				if child != pad_visual and child != construction_visual and child != progress_node and child is CanvasItem:
					(child as CanvasItem).visible = bool(original_visibility.get(child.name, true))
			var is_upgrade: bool = bool(state.get("is_upgrade", false))
			if is_upgrade:
				tower.upgrade()
			tower.combat_enabled = true
			completed.append(tower)
	for tower: GrayboxTower in completed:
		var completed_state: Dictionary = construction_states.get(tower, {}) as Dictionary
		construction_states.erase(tower)
		_update_tower_info()
		_update_hud("Модернизация завершена" if bool(completed_state.get("is_upgrade", false)) else "Строительство завершено")

func _initialize_fog_mask() -> void:
	fog_mask_image = Image.create(FOG_MASK_SIZE, FOG_MASK_SIZE, false, Image.FORMAT_RGBA8)
	fog_mask_image.fill(Color.BLACK)
	fog_mask_texture = ImageTexture.create_from_image(fog_mask_image)
	var fog_material: ShaderMaterial = fog_mask.material as ShaderMaterial
	if fog_material != null:
		fog_material.set_shader_parameter("reveal_mask", fog_mask_texture)
		fog_material.set_shader_parameter("enabled", 1.0)

func _fog_reveal_sources() -> Array[Dictionary]:
	var sources: Array[Dictionary] = []
	if is_instance_valid(base) and base.health > 0.0:
		sources.append({"node": base, "radius": FOG_BASE_RADIUS_PIXELS})
	for tower_node: Node in towers.get_children():
		var tower: GrayboxTower = tower_node as GrayboxTower
		if is_instance_valid(tower) and tower.health > 0.0 and tower.combat_enabled and tower.building_state != GrayboxBuildingState.DESTROYED:
			sources.append({"node": tower, "radius": FOG_BUILDING_RADIUS_PIXELS})
	for defender_node: Node in get_tree().get_nodes_in_group("graybox_defenders"):
		var defender: Node2D = defender_node as Node2D
		if is_instance_valid(defender) and defender.visible and not defender.is_queued_for_deletion():
			sources.append({"node": defender, "radius": FOG_BUILDING_RADIUS_PIXELS * 0.75})
	return sources

func _rebuild_fog_mask() -> void:
	if fog_mask_image == null or fog_mask_texture == null:
		return
	var map_origin: Vector2 = base.position - MAP_HALF_EXTENT
	var map_size: Vector2 = MAP_HALF_EXTENT * 2.0
	var source_data: Array[Dictionary] = []
	for source: Dictionary in _fog_reveal_sources():
		var source_node: Node2D = source["node"] as Node2D
		source_data.append({"position": entities.to_local(source_node.global_position), "radius": float(source["radius"])})
	var pixel_data: PackedByteArray = PackedByteArray()
	pixel_data.resize(FOG_MASK_SIZE * FOG_MASK_SIZE * 4)
	for y: int in FOG_MASK_SIZE:
		for x: int in FOG_MASK_SIZE:
			var map_position: Vector2 = map_origin + Vector2((float(x) + 0.5) / FOG_MASK_SIZE * map_size.x, (float(y) + 0.5) / FOG_MASK_SIZE * map_size.y)
			var reveal: float = 0.0
			for source: Dictionary in source_data:
				var distance_ratio: float = (source["position"] as Vector2).distance_to(map_position) / float(source["radius"])
				reveal = maxf(reveal, 1.0 - smoothstep(0.78, 1.0, distance_ratio))
			var reveal_byte: int = roundi(reveal * 255.0)
			var pixel_index: int = (y * FOG_MASK_SIZE + x) * 4
			pixel_data[pixel_index] = reveal_byte
			pixel_data[pixel_index + 1] = reveal_byte
			pixel_data[pixel_index + 2] = reveal_byte
			pixel_data[pixel_index + 3] = 255
	fog_mask_image.set_data(FOG_MASK_SIZE, FOG_MASK_SIZE, false, Image.FORMAT_RGBA8, pixel_data)
	fog_mask_texture.update(fog_mask_image)

func _update_fog_mask_uniforms() -> void:
	if not is_instance_valid(fog_mask):
		return
	fog_mask.position = Vector2.ZERO
	fog_mask.size = playfield.size
	var fog_material: ShaderMaterial = fog_mask.material as ShaderMaterial
	if fog_material == null:
		return
	fog_material.set_shader_parameter("map_origin", base.position - MAP_HALF_EXTENT)
	fog_material.set_shader_parameter("map_size", MAP_HALF_EXTENT * 2.0)
	fog_material.set_shader_parameter("map_offset", entities.position)
	fog_material.set_shader_parameter("map_zoom", map_zoom)
	fog_material.set_shader_parameter("viewport_size", playfield.size)
	fog_mask_rebuild_cooldown -= get_process_delta_time()
	if fog_mask_rebuild_cooldown <= 0.0:
		_rebuild_fog_mask()
		fog_mask_rebuild_cooldown = FOG_MASK_UPDATE_INTERVAL

func _process(_delta: float) -> void:
	if not is_instance_valid(fps_label):
		fps_label = Label.new()
		fps_label.name = "FPSLabel"
		fps_label.position = Vector2(0.0, minimap_control.size.y + 4.0)
		fps_label.size = Vector2(minimap_control.size.x, 22.0)
		fps_label.add_theme_color_override("font_color", Color(0.75, 0.85, 0.92, 0.9))
		fps_label.add_theme_font_size_override("font_size", 12)
		minimap_control.add_child(fps_label)
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	_process_construction(_delta)
	_process_repairs(_delta)
	if is_instance_valid(fog_mask) and playfield.size.x > 0.0 and playfield.size.y > 0.0:
		_update_fog_mask_uniforms()
	if next_wave_button.visible and wave_manager.next_wave_timer > 0.0:
		next_wave_button.text = "Начать атаку %d  •  %.0f" % [wave_manager.wave_number + 1, ceilf(wave_manager.next_wave_timer)]
	elif next_wave_button.visible:
		next_wave_button.text = "Начать атаку %d" % (wave_manager.wave_number + 1)
	attack_marker.visible = fmod(float(Time.get_ticks_msec()), 700.0) < 350.0
	if not fog_reveal_infinite and action_active_until > 0.0 and Time.get_ticks_msec() / 1000.0 >= action_active_until:
		for fog_name: String in ["FogTop", "FogBottom", "FogLeft", "FogRight"]:
			var fog: ColorRect = get_node("Playfield/" + fog_name) as ColorRect
			fog.color.a = 0.72
		action_active_until = 0.0
	if Input.is_action_just_pressed("ui_cancel") and game_over:
		get_tree().paused = false
		get_tree().reload_current_scene()
	credits_label.text = "Расходы / ресурсы  %d $" % credits
	credits_text.text = "$%d" % credits
	wave_label.text = "Атака  %d / %d" % [wave_manager.wave_number, wave_manager.wave_counts.size()]
	base_bar.value = base.health
	_update_action_buttons()
	_update_building_palette()
	build_button.disabled = (not build_mode and (not SUPPORTED_BUILDING_IDS.has(selected_building_id) or credits < _build_cost(selected_building_id) or base_selected))
	_update_build_preview()
	_update_map_edge_indicators()
	_update_minimap()

func _select_building_from_palette(building_id: int) -> void:
	if not BUILD_PALETTE_SUPPORTED_IDS.has(building_id):
		return
	base_selected = false
	selected_tower = null
	selected_building_id = building_id
	_update_selected_building()
	_update_hud("Selected building ID %d" % building_id)

func _update_building_picker_unlocks() -> void:
	for index: int in range(building_picker.item_count):
		var building_id: int = building_picker.get_item_id(index)
		var unique_already_built: bool = building_id == ENERGY_STATION_ID and _has_energy_station()
		building_picker.set_item_disabled(index, not unlocked_building_ids.has(building_id) or unique_already_built)

func _has_energy_station() -> bool:
	for tower_node: Node in towers.get_children():
		var tower: GrayboxTower = tower_node as GrayboxTower
		if is_instance_valid(tower) and not tower.is_queued_for_deletion() and tower.building_id == ENERGY_STATION_ID:
			return true
	return false

func _refresh_progression_ui() -> void:
	for index: int in range(action_picker.item_count):
		var action_id: int = action_picker.get_item_id(index)
		var unlocked: bool = unlocked_action_ids.has(action_id)
		action_picker.set_item_disabled(index, not unlocked)
		var charge_count: int = int(action_charges.get(action_id, 0))
		action_picker.set_item_text(index, "%s [%d]" % [action_picker.get_item_text(index).split(" [")[0], charge_count])
	var selected_id: int = int(selected_action)
	use_action_button.disabled = not unlocked_action_ids.has(selected_id) or int(action_charges.get(selected_id, 0)) <= 0
	var research_available: bool = _has_energy_station()
	research_button.disabled = researched.has(selected_research) or not research_available
	research_button.text = ("Изучено" if researched.has(selected_research) else ("Нужна энергостанция" if not research_available else "Исследовать"))
	var research_state: String = "исследовано" if researched.has(selected_research) else ("построй энергостанцию для исследований" if not research_available else "исследование доступно")
	if not $Playfield/ContextPanel.visible:
		context_hint.text = "Ранг %d • Опыт %d/%d • Действие: %d • %s" % [rank, experience, (rank + 1) * 5, int(action_charges.get(selected_id, 0)), research_state]

func _grant_experience(amount: int) -> void:
	enemy_kills += maxi(amount, 0)
	experience = enemy_kills
	var previous_rank: int = rank
	if enemy_kills >= 43:
		rank = 3
	elif enemy_kills >= 18:
		rank = 2
	elif enemy_kills >= 10:
		rank = 1
	else:
		rank = 0
	for unlocked_id: int in range(1, rank + 1):
		if not unlocked_action_ids.has(unlocked_id):
			unlocked_action_ids.append(unlocked_id)
			action_charges[unlocked_id] = int(action_charges.get(unlocked_id, 0)) + 1
	if previous_rank != rank:
		_update_hud("Новое звание: %s" % _rank_name())
	_refresh_progression_ui()

func _rank_name() -> String:
	return "Старшина" if rank >= 2 else "Сержант"

func _action_picker_setup() -> void:
	action_picker.clear()
	action_picker.add_item("Разведывательный полёт", 1)
	action_picker.add_item("Быстрый ремонт", 2)
	action_picker.add_item("Бомба", 3)
	action_picker.add_item("Быстрая смерть", 4)
	action_picker.add_item("Парализующие лучи", 5)
	action_picker.add_item("Ядовитый газ", 6)
	action_picker.add_item("Суперщит", 7)
	action_picker.add_item("Неразрушимость", 8)
	action_picker.add_item("Бонус радиуса", 9)
	action_picker.add_item("Экстремальная сила", 10)
	action_picker.add_item("Оглушительные лучи", 11)
	action_picker.add_item("Интеллигентная бомба", 12)
	action_picker.select(0)
	action_picker.item_selected.connect(_on_action_picker_selected)

func _research_picker_setup() -> void:
	research_picker.clear()
	research_picker.add_item("Радиус поражения", 1)
	research_picker.add_item("Вооружение", 2)
	research_picker.add_item("Интенсивность атаки", 3)
	research_picker.add_item("Щитовое прикрытие", 4)
	research_picker.select(0)
	research_picker.item_selected.connect(_on_research_picker_selected)

func _on_action_picker_selected(index: int) -> void:
	selected_action = str(action_picker.get_item_id(index))

func _on_research_picker_selected(index: int) -> void:
	selected_research = str(research_picker.get_item_id(index))

func _first_enemy() -> GrayboxBug:
	for enemy_node: Node in get_tree().get_nodes_in_group("graybox_enemies"):
		var enemy: GrayboxBug = enemy_node as GrayboxBug
		if is_instance_valid(enemy):
			return enemy
	return null

func _on_use_action_pressed() -> void:
	var action_id: int = int(selected_action)
	if not unlocked_action_ids.has(action_id) or int(action_charges.get(action_id, 0)) <= 0:
		_update_hud("Действие ещё не открыто или уже использовано")
		return
	action_charges[action_id] = int(action_charges.get(action_id, 0)) - 1
	var enemy: GrayboxBug = _first_enemy()
	match selected_action:
		"1":
			_set_fog_revealed(4.0)
			_update_hud("Разведывательный полёт: поле раскрыто")
		"2":
			if base_selected:
				base.repair_full()
			elif is_instance_valid(selected_tower):
				selected_tower.repair_full()
			_update_hud("Быстрый ремонт применён")
		"3":
			if is_instance_valid(enemy):
				enemy.take_typed_damage(120.0, "fire")
			_update_hud("Бомба применена")
		"4":
			if is_instance_valid(enemy):
				enemy.take_typed_damage(999.0, "bullet")
			_update_hud("Быстрая смерть применена")
		"5":

			for enemy_node: Node in get_tree().get_nodes_in_group("graybox_enemies"):
				var target: GrayboxBug = enemy_node as GrayboxBug
				if is_instance_valid(target):
					target.paralyze(3.0)
			_update_hud("Враги парализованы")
		"6":
			for enemy_node: Node in get_tree().get_nodes_in_group("graybox_enemies"):
				var target: GrayboxBug = enemy_node as GrayboxBug
				if is_instance_valid(target):
					target.take_typed_damage(35.0, "fire")
			_update_hud("Ядовитый газ применён")
		"7":
			base.set_shield(250.0)
			_update_hud("Суперщит активирован")
		"8":
			base.set_invulnerable(4.0)
			_update_hud("Неразрушимость активирована")
		"9":
			for tower_node: Node in towers.get_children():
				var tower: GrayboxTower = tower_node as GrayboxTower
				if is_instance_valid(tower):
					tower.attack_range *= 1.25
			_update_hud("Радиус поражения увеличен")
		"10":
			for tower_node: Node in towers.get_children():
				var tower: GrayboxTower = tower_node as GrayboxTower
				if is_instance_valid(tower):
					tower.damage *= 2.0
			_update_hud("Экстремальная сила активирована")
		"12":
			for enemy_node: Node in get_tree().get_nodes_in_group("graybox_enemies"):
				var target: GrayboxBug = enemy_node as GrayboxBug
				if is_instance_valid(target):
					target.take_typed_damage(999.0, "energy")
			_update_hud("Интеллигентная бомба применена")
	_refresh_progression_ui()

func _on_research_pressed() -> void:
	if not _has_energy_station():
		_update_hud("Для исследования нужна действующая энергостанция")
		return
	if researched.has(selected_research):
		_update_hud("Это исследование уже выполнено")
		return
	if selected_research == "1":
		for tower_node: Node in towers.get_children():
			var tower: GrayboxTower = tower_node as GrayboxTower
			if is_instance_valid(tower):
				tower.attack_range *= 1.15
	elif selected_research == "2":
		base.defense += 5.0
	elif selected_research == "3":
		for tower_node: Node in towers.get_children():
			var tower: GrayboxTower = tower_node as GrayboxTower
			if is_instance_valid(tower):
				tower.damage *= 1.15
	elif selected_research == "4":
		base.set_shield(150.0)
	researched[selected_research] = true
	_refresh_progression_ui()
	_update_hud("Исследование завершено")

func _on_actions_button_pressed() -> void:
	if intro_pending or game_paused or game_over:
		return
	var context: Control = $Playfield/ContextPanel
	building_action_panel_active = false
	context.visible = not context.visible
	if context.visible:
		context.position = Vector2(8.0, get_viewport().get_visible_rect().size.y - 150.0)
		context.size = Vector2(get_viewport().get_visible_rect().size.x - 16.0, 104.0)
		context_title.text = "Дополнительные действия"
		context_hint.text = "Выберите действие и нажмите «Применить»"
		action_picker.visible = true
		use_action_button.visible = true
		research_picker.visible = false
		research_button.visible = false
	else:
		action_picker.visible = false
		use_action_button.visible = false
		research_picker.visible = false
		research_button.visible = false
	_refresh_progression_ui()

func _show_progression_notice(message: String) -> void:
	notice_queue.append(message)
	if not notice_open:
		_show_next_notice()

func _show_next_notice() -> void:
	if notice_queue.is_empty():
		notice_open = false
		progression_notice.visible = false
		return
	notice_open = true
	progression_notice.visible = true
	notice_message.text = notice_queue.pop_front()
	get_tree().paused = true

func _on_notice_confirmed() -> void:
	get_tree().paused = false
	_show_next_notice()

func _toggle_pause() -> void:
	_set_game_paused(not game_paused)

func _set_game_paused(value: bool) -> void:
	if intro_pending and value:
		return
	game_paused = value
	if test_hud_panel.visible:
		test_hud_panel.visible = false
	get_tree().paused = value
	pause_button.text = "Продолжить" if value else "Пауза"
	pause_menu.visible = value
	pause_menu.z_index = 1000
	if value:
		_save_game()
		var survived_seconds: int = maxi(int(float(Time.get_ticks_msec() - survival_started_at) / 1000.0), 0)
		pause_stats.text = "Продержался: %d сек.\nОчки: %d   Уровень игрока: %d\nЧин: %s" % [survived_seconds, score, rank + 1, _rank_name()]
		pause_menu_status.text = "Игра остановлена. Прогресс автоматически сохранён."
		_update_hud("Пауза — прогресс сохранён")
	else:
		_update_hud("Игра продолжается")

func _on_pause_save_pressed() -> void:
	_save_game()
	pause_menu_status.text = "Прогресс сохранён. Можно продолжить игру."

func _on_pause_continue_pressed() -> void:
	_set_game_paused(false)

func _on_pause_menu_pressed() -> void:
	_save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")

func _set_fog_revealed(duration: float) -> void:
	for fog_name: String in ["FogTop", "FogBottom", "FogLeft", "FogRight"]:
		var fog: ColorRect = get_node("Playfield/" + fog_name) as ColorRect
		fog.color.a = 0.0
	action_active_until = Time.get_ticks_msec() / 1000.0 + duration

func _on_building_picker_selected(index: int) -> void:
	var building_id: int = building_picker.get_item_id(index)
	_select_building_from_palette(building_id)

func _on_building_151_pressed() -> void:
	_select_building_from_palette(151)

func _on_building_153_pressed() -> void:
	_select_building_from_palette(153)

func _on_building_155_pressed() -> void:
	_select_building_from_palette(SOLDIERS_ID)

func _on_build_button_pressed() -> void:
	if intro_pending:
		return
	if build_mode and placement_preview_valid:
		_try_build_tower(entities.to_global(_slice_world_from_cell(placement_preview_cell)))
		return
	build_mode = true
	cancel_build_button.visible = true
	base_selected = false
	selected_tower = null
	placement_preview_cell = Vector2i(-1, -1)
	placement_preview_valid = false
	build_button.text = "Выбери клетку"
	_update_tower_info()
	_update_hud("Коснись свободной клетки на карте")

func _on_cancel_build_button_pressed() -> void:
	build_mode = false
	cancel_build_button.visible = false
	placement_preview_cell = Vector2i(-1, -1)
	placement_preview_valid = false
	build_preview.visible = false
	_update_selected_building()
	_update_hud("Размещение отменено")

func _update_build_preview() -> void:
	if not build_mode:
		build_preview.visible = false
		return
	var local_position: Vector2 = entities.to_local(build_cursor_position)
	var cell: Vector2i = _cell_from_position(local_position)
	var clamped_cell: Vector2i = Vector2i(clampi(cell.x, 0, MapGrid.WIDTH - 1), clampi(cell.y, 0, MapGrid.HEIGHT - 1))
	build_preview.position = _slice_world_from_cell(clamped_cell)
	var footprint: Vector2i = _building_footprint(selected_building_id)
	var half_size: Vector2 = Vector2(footprint) * MapGrid.CELL_SIZE * 0.5
	build_preview.polygon = PackedVector2Array([Vector2(-half_size.x, -half_size.y), Vector2(half_size.x, -half_size.y), Vector2(half_size.x, half_size.y), Vector2(-half_size.x, half_size.y)])
	build_preview.visible = true
	placement_preview_cell = cell
	placement_preview_valid = _can_build_at(local_position, cell)
	build_preview.color = Color(0.2, 0.9, 0.45, 0.55) if placement_preview_valid else Color(0.95, 0.2, 0.2, 0.5)
	build_button.text = "Выбери клетку" if not placement_preview_valid else "Разместить здесь"
	build_button.disabled = not SUPPORTED_BUILDING_IDS.has(selected_building_id) or credits < _build_cost(selected_building_id)

func _build_cost(building_id: int) -> int:
	var profile: Dictionary = BUILDING_REGISTRY.profile(building_id)
	if profile.is_empty():
		return TEMPORARY_TOWER_COST
	return BUILDING_REGISTRY.prototype_cost(building_id)

func _building_footprint(building_id: int) -> Vector2i:
	return BUILDING_REGISTRY.footprint(building_id)

func _footprint_cells(anchor: Vector2i, building_id: int) -> Array[Vector2i]:
	var footprint: Vector2i = _building_footprint(building_id)
	var start: Vector2i = anchor - Vector2i(floori(float(footprint.x - 1) / 2.0), floori(float(footprint.y - 1) / 2.0))
	var cells: Array[Vector2i] = []
	for y: int in footprint.y:
		for x: int in footprint.x:
			cells.append(start + Vector2i(x, y))
	return cells

func _clearance_cells(anchor: Vector2i, building_id: int) -> Array[Vector2i]:
	var blocked: Array[Vector2i] = []
	for occupied_cell: Vector2i in _footprint_cells(anchor, building_id):
		for y: int in range(-1, 2):
			for x: int in range(-1, 2):
				var clearance_cell: Vector2i = occupied_cell + Vector2i(x, y)
				if not blocked.has(clearance_cell):
					blocked.append(clearance_cell)
	return blocked

func _add_contact_shadow(parent_node: Node2D, shadow_scale: Vector2, alpha: float) -> void:
	var shadow: Polygon2D = Polygon2D.new()
	shadow.name = "ContactShadow"
	shadow.polygon = PackedVector2Array([Vector2(-70, 18), Vector2(-48, 30), Vector2(0, 38), Vector2(48, 30), Vector2(70, 18), Vector2(48, 8), Vector2(0, 4), Vector2(-48, 8)])
	shadow.scale = shadow_scale
	shadow.color = Color(0.01, 0.008, 0.006, alpha)
	shadow.z_index = -1
	parent_node.add_child(shadow)

func _register_rock_formations() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 20260324
	var rock_positions: Array[Vector2] = []
	var nearby_position: Vector2 = base.position + Vector2(235.0, -175.0)
	rock_positions.append(nearby_position)
	var attempts: int = 0
	while rock_positions.size() < 11 and attempts < 300:
		attempts += 1
		var candidate: Vector2 = Vector2(
			rng.randf_range(-MAP_HALF_EXTENT.x + 140.0, MAP_HALF_EXTENT.x - 140.0),
			rng.randf_range(-MAP_HALF_EXTENT.y + 140.0, MAP_HALF_EXTENT.y - 140.0)
		)
		if candidate.distance_to(base.position) < 300.0:
			continue
		var too_close: bool = false
		for existing_position: Vector2 in rock_positions:
			if candidate.distance_to(existing_position) < 600.0:
				too_close = true
				break
		if too_close:
			continue
		rock_positions.append(candidate)
	for index: int in rock_positions.size():
		var rock: StaticBody2D = ROCK_FORMATION_SCENE.instantiate() as StaticBody2D
		rock.position = rock_positions[index]
		var size_roll: float = rng.randf()
		var rock_scale: float = 0.34 if size_roll < 0.35 else (0.50 if size_roll < 0.92 else 0.62)
		rock.scale = Vector2.ONE * rock_scale
		_add_contact_shadow(rock, Vector2(1.9, 1.0), 0.24)
		if rng.randf() > 0.5:
			rock.scale.x *= -1.0
		entities.add_child(rock)
		# Navigation is grid-based, so reserve enough cells for the scaled rock
		# plus the bug's collision radius. This keeps pathfinding consistent with
		# the StaticBody2D collision shape instead of allowing corner clipping.
		var rock_half_width: float = 215.0 * rock_scale
		var bug_clearance: float = 18.0
		var cell_radius: int = ceili((rock_half_width + bug_clearance) / MapGrid.CELL_SIZE)
		var center_cell: Vector2i = _cell_from_position(rock.position)
		for y: int in range(-cell_radius, cell_radius + 1):
			for x: int in range(-cell_radius, cell_radius + 1):
				var blocked_cell: Vector2i = center_cell + Vector2i(x, y)
				if grid.is_valid_cell(blocked_cell):
					grid.set_walkable(blocked_cell, false)

func _can_build_at(local_position: Vector2, cell: Vector2i) -> bool:
	if not SUPPORTED_BUILDING_IDS.has(selected_building_id) or credits < _build_cost(selected_building_id):
		return false
	var selected_profile: Dictionary = BUILDING_REGISTRY.profile(selected_building_id)
	if bool(selected_profile.get("unique", false)) and _has_energy_station():
		return false
	var configured_base_clearance: float = float(selected_profile.get("base_clearance_radius", 110.0))
	var base_collision_radius: float = _collision_radius(base)
	var footprint: Vector2i = _building_footprint(selected_building_id)
	var footprint_half_extents: Vector2 = Vector2(footprint) * MapGrid.CELL_SIZE * 0.5
	var building_visual_radius: float = footprint_half_extents.length()
	if selected_building_id == SOLDIERS_ID:
		# The soldier platform is wider than its logical 1x1 footprint.
		building_visual_radius = maxf(building_visual_radius, 48.0)
	var collision_based_clearance: float = base_collision_radius + building_visual_radius + 4.0
	var base_clearance_radius: float = maxf(configured_base_clearance, collision_based_clearance)
	if local_position.distance_to(base.position) < base_clearance_radius:
		return false
	# The building itself must fit inside the map.
	for footprint_cell: Vector2i in _footprint_cells(cell, selected_building_id):
		if not grid.is_valid_cell(footprint_cell) or not grid.is_walkable(footprint_cell):
			return false
	# Clearance is an in-map gameplay buffer. Cells outside the map must not
	# make an otherwise valid edge placement fail.
	for blocked_cell: Vector2i in _clearance_cells(cell, selected_building_id):
		if grid.is_valid_cell(blocked_cell) and not grid.is_walkable(blocked_cell):
			return false
	return true

func _sell_refund(building_id: int, upgrade_level: int = 0, upgrade_cost: int = 0, current_health: float = -1.0, maximum_health: float = -1.0) -> int:
	var total_cost: int = _build_cost(building_id)
	if upgrade_level > 0:
		total_cost += upgrade_cost
	var full_refund: float = float(total_cost) * 0.5
	if maximum_health > 0.0 and current_health >= 0.0:
		full_refund *= clampf(current_health / maximum_health, 0.0, 1.0)
	return floori(full_refund)

func _repair_cost(maximum_health: float, current_health: float) -> int:
	return ceili(maxf(maximum_health - current_health, 0.0) * REPAIR_COST_PER_HP)

func _update_action_buttons() -> void:
	building_picker.disabled = build_mode
	var has_tower: bool = is_instance_valid(selected_tower)
	var has_base: bool = base_selected and is_instance_valid(base)
	var selected_sell_refund: int = _sell_refund(selected_tower.building_id, selected_tower.upgrade_level, selected_tower.upgrade_cost, selected_tower.health, selected_tower.max_health) if has_tower else 0
	var tower_constructing: bool = has_tower and construction_states.has(selected_tower)
	var tower_repair_cost: int = _repair_cost(selected_tower.max_health, selected_tower.health) if has_tower else 0
	var base_repair_cost: int = _repair_cost(base.max_health, base.health) if has_base else 0
	var selected_repair_cost: int = tower_repair_cost if has_tower else base_repair_cost
	var tower_repairing: bool = has_tower and repair_states.has(selected_tower)
	var base_repairing: bool = has_base and repair_states.has(base)
	upgrade_button.visible = has_tower or has_base
	repair_button.visible = (has_tower and selected_tower.health < selected_tower.max_health) or (has_base and base.health < base.max_health)
	sell_button.visible = has_tower
	upgrade_button.disabled = tower_constructing or (has_base and (base_upgrade_level >= 4 or credits < 1000)) or (has_tower and (selected_tower.upgrade_level >= selected_tower.max_upgrade_level or credits < selected_tower.upgrade_cost)) or (not has_tower and not has_base)
	repair_button.disabled = tower_constructing or (not has_tower and not has_base) or (has_tower and (selected_tower.health >= selected_tower.max_health or (credits <= 0 and not tower_repairing))) or (has_base and (base.health >= base.max_health or (credits <= 0 and not base_repairing)))
	sell_button.disabled = not has_tower or tower_constructing
	if has_base:
		upgrade_button.text = "Модернизировать базу (1000)"
	elif has_tower:
		upgrade_button.text = "Модернизировать (%d)" % selected_tower.upgrade_cost
	else:
		upgrade_button.text = "Модернизировать"
	repair_button.text = "Остановить ремонт" if (tower_repairing or base_repairing) else "Ремонтировать (%d)" % selected_repair_cost
	sell_button.text = "Снести (+%d)" % selected_sell_refund
	if building_action_panel_active:
		context_title.text = "Центральная база" if has_base else "Управление зданием"
		context_hint.text = "Выберите действие для объекта"
		action_picker.visible = false
		use_action_button.visible = false
		research_picker.visible = false
		research_button.visible = false
		upgrade_building_button.visible = has_tower or has_base
		repair_building_button.visible = has_tower or has_base
		sell_building_button.visible = has_tower
		upgrade_building_button.disabled = upgrade_button.disabled
		repair_building_button.disabled = repair_button.disabled
		sell_building_button.disabled = sell_button.disabled
		if has_base:
			upgrade_building_button.text = "Модернизировать базу (1000)"
		elif has_tower:
			upgrade_building_button.text = "Модернизировать (%d)" % selected_tower.upgrade_cost
		repair_building_button.text = "Остановить ремонт" if (tower_repairing or base_repairing) else "Ремонтировать (%d)" % selected_repair_cost
		sell_building_button.text = "Снести (+%d)" % selected_sell_refund
	else:
		upgrade_building_button.visible = false
		repair_building_button.visible = false
		sell_building_button.visible = false
	build_button.disabled = not SUPPORTED_BUILDING_IDS.has(selected_building_id) or credits < _build_cost(selected_building_id)

func _on_upgrade_button_pressed() -> void:
	if base_selected:
		_upgrade_base()
	else:
		_upgrade_first_tower()

func _upgrade_base() -> void:
	if base_upgrade_level >= 4 or credits < 1000:
		_update_hud("База уже улучшена или недостаточно ресурсов")
		return
	base_upgrade_level += 1
	credits -= 1000
	for building_id: int in [157, 167, 169, 159]:
		if base_upgrade_level >= 2 and not unlocked_building_ids.has(building_id):
			unlocked_building_ids.append(building_id)
	_update_building_picker_unlocks()
	_refresh_progression_ui()
	_update_hud("Центральная база улучшена до уровня %d" % base_upgrade_level)

func _on_repair_button_pressed() -> void:
	var target: Node = null
	if base_selected and is_instance_valid(base):
		target = base
	elif is_instance_valid(selected_tower):
		target = selected_tower
	if not is_instance_valid(target):
		return
	if repair_states.has(target):
		repair_states.erase(target)
		_update_hud("Ремонт остановлен")
		_update_action_buttons()
		return
	var current_health: float = float(target.health)
	var maximum_health: float = float(target.max_health)
	if current_health >= maximum_health:
		return
	if credits <= 0:
		_update_hud("Not enough credits to repair [TEMPORARY_BALANCE]")
		return
	repair_states[target] = {"cost_remainder": 0.0}
	_update_hud("Ремонт начался: 2 ОЖ/сек, 3 $/ОЖ")

func _on_sell_button_pressed() -> void:
	if not is_instance_valid(selected_tower):
		return
	var tower_to_sell: GrayboxTower = selected_tower
	var refund: int = _sell_refund(tower_to_sell.building_id, tower_to_sell.upgrade_level, tower_to_sell.upgrade_cost, tower_to_sell.health, tower_to_sell.max_health)
	var footprint_variant: Variant = tower_footprints.get(tower_to_sell, [])
	if footprint_variant is Array:
		for footprint_cell: Variant in footprint_variant:
			if footprint_cell is Vector2i:
				grid.set_occupied(footprint_cell as Vector2i, false)
	tower_footprints.erase(tower_to_sell)
	tower_cells.erase(tower_to_sell)
	selected_tower = null
	tower_to_sell.queue_free()
	credits += refund
	_update_building_picker_unlocks()
	_update_building_palette()
	_update_tower_info()
	_update_hud("Selected tower sold: +%d credits" % refund)

func _collision_radius(node: Node2D) -> float:
	var collision_node: CollisionShape2D = node.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_node == null or collision_node.shape == null:
		return 0.0
	var shape: Shape2D = collision_node.shape
	if shape is CircleShape2D:
		return (shape as CircleShape2D).radius
	if shape is RectangleShape2D:
		var rectangle: RectangleShape2D = shape as RectangleShape2D
		return rectangle.size.length() * 0.5
	return 0.0

func _update_hover_selection(screen_position: Vector2) -> void:
	if build_mode or intro_pending or game_paused or game_over or build_picker_open:
		hover_debug_radii.hide_radii()
		return
	if building_action_panel_active:
		return
	if _screen_point_hits_ui(screen_position):
		return
	var local_position: Vector2 = entities.to_local(screen_position)
	var base_selection_radius: float = _collision_radius(base)
	if local_position.distance_to(base.position) <= base_selection_radius:
		base_selected = true
		selected_tower = null
		var base_radius: float = base_selection_radius
		hover_debug_radii.show_radii(base.position, base_radius, base_radius, 0.0)
		_update_tower_info()
		return
	var hovered_tower: GrayboxTower = _find_tower_at_position(local_position)
	if is_instance_valid(hovered_tower):
		base_selected = false
		selected_tower = hovered_tower
		var physical_radius: float = _collision_radius(hovered_tower)
		if physical_radius <= 0.0:
			physical_radius = 64.0 if hovered_tower.building_id == ENERGY_STATION_ID else 48.0
		hover_debug_radii.show_radii(hovered_tower.position, physical_radius, physical_radius, hovered_tower.attack_range if hovered_tower.combat_enabled else 0.0)
		_update_tower_info()
		return
	base_selected = false
	selected_tower = null
	hover_debug_radii.hide_radii()
	_update_tower_info()

func _select_or_build(screen_position: Vector2) -> void:
	if intro_pending or game_paused or game_over or build_picker_open:
		return
	if build_mode:
		build_cursor_position = screen_position
		var placement_position: Vector2 = entities.to_local(screen_position)
		var placement_cell: Vector2i = _cell_from_position(placement_position)
		placement_preview_cell = placement_cell
		placement_preview_valid = _can_build_at(placement_position, placement_cell)
		if placement_preview_valid:
			_try_build_tower(screen_position)
		else:
			_update_hud("Клетка недоступна — выбери свободную клетку")
		return
	var local_position: Vector2 = entities.to_local(screen_position)
	var base_selection_radius: float = _collision_radius(base)
	if local_position.distance_to(base.position) <= base_selection_radius:
		base_selected = true
		selected_tower = null
		building_action_panel_active = true
		$Playfield/ContextPanel.visible = true
		_update_tower_info()
		_update_hud("Выбрана центральная база")
		return
	var tower: GrayboxTower = _find_tower_at_position(local_position)
	if is_instance_valid(tower):
		base_selected = false
		selected_tower = tower
		building_action_panel_active = true
		$Playfield/ContextPanel.visible = true
		_update_tower_info()
		_update_hud("Выбрано здание")
		return
	if screen_position.x < 20.0 or screen_position.x > playfield.size.x - 20.0 or screen_position.y < 20.0 or screen_position.y > playfield.size.y - 20.0:
		return
	building_action_panel_active = false
	$Playfield/ContextPanel.visible = false
	var candidate_cell: Vector2i = _cell_from_position(local_position)
	if not grid.is_valid_cell(candidate_cell):
		return
	if grid.is_walkable(candidate_cell) and local_position.distance_to(base.position) >= 70.0:
		pending_build_cell = candidate_cell
		pending_build_screen_position = screen_position
		palette_picker.clear()
		for building_id: int in BUILD_PALETTE_SUPPORTED_IDS:
			var profile: Dictionary = GameBalance.BUILDINGS.get(building_id, {})
			var building_name: String = _display_building_name(building_id, str(profile.get("name", "Постройка")))
			palette_picker.add_item(building_name, building_id)
			palette_picker.set_item_disabled(palette_picker.item_count - 1, credits < _build_cost(building_id))
		palette_picker.select(0)
		selected_building_id = palette_picker.get_item_id(0)
		_update_palette_details()
		build_palette_popup.visible = true
		build_picker_open = true
		return
	_try_build_tower(screen_position)

func _find_tower_at_position(local_position: Vector2) -> GrayboxTower:
	var best_tower: GrayboxTower
	var best_distance: float = INF
	for tower_node: Node in towers.get_children():
		var tower: GrayboxTower = tower_node as GrayboxTower
		if not is_instance_valid(tower):
			continue
		var distance_limit: float = _collision_radius(tower)
		if distance_limit <= 0.0:
			distance_limit = 72.0
		var distance: float = tower.position.distance_to(local_position)
		if distance <= distance_limit and distance <= best_distance:
			best_distance = distance
			best_tower = tower
	return best_tower

func _scene_for_building(building_id: int) -> PackedScene:
	var profile: Dictionary = BUILDING_REGISTRY.profile(building_id)
	var scene_path: String = str(profile.get("scene_path", ""))
	if not scene_path.is_empty():
		var scene: PackedScene = load(scene_path) as PackedScene
		if scene != null:
			return scene
	return CENTRAL_BASE_TEMPLATE_SCENE

func _try_build_tower(screen_position: Vector2) -> void:
	if intro_pending or game_paused or game_over or build_picker_open:
		return
	if build_mode and not placement_preview_valid:
		var proposed_position: Vector2 = entities.to_local(screen_position)
		var proposed_cell: Vector2i = _cell_from_position(proposed_position)
		placement_preview_cell = proposed_cell
		placement_preview_valid = _can_build_at(proposed_position, proposed_cell)
		if not placement_preview_valid:
			_update_hud("Сначала выбери свободную клетку на карте")
			return
	if not SUPPORTED_BUILDING_IDS.has(selected_building_id):
		_update_hud("Selected building has no graybox scene yet")
		return
	if credits < _build_cost(selected_building_id):
		_update_hud("Недостаточно ресурсов [TEMPORARY_BALANCE]")
		return
	var local_position: Vector2 = entities.to_local(screen_position)
	var world_cell: Vector2i = _cell_from_position(local_position)
	if not grid.is_valid_cell(world_cell):
		_update_hud("Клетка находится за пределами карты")
		return
	if local_position.distance_to(base.position) < 80.0:
		_update_hud("Держись подальше от базы")
		return
	var cell: Vector2i = world_cell
	if build_mode and (cell != placement_preview_cell or not placement_preview_valid):
		_update_hud("Выбери свободную подсвеченную клетку")
		return
	if not _can_build_at(local_position, cell):
		_update_hud("Эта клетка занята или недоступна")
		return
	var building_scene: PackedScene = _scene_for_building(selected_building_id)
	var tower: GrayboxTower = building_scene.instantiate() as GrayboxTower
	tower.building_id = selected_building_id
	tower.position = _slice_world_from_cell(cell)
	tower.z_index = 5
	towers.add_child(tower)
	_apply_cell_diamond_debug(tower)
	tower.destroyed.connect(_on_tower_destroyed.bind(tower))
	tower_cells[tower] = cell
	tower_footprints[tower] = _clearance_cells(cell, selected_building_id)
	_start_construction(tower)
	for footprint_cell: Vector2i in tower_footprints[tower] as Array[Vector2i]:
		grid.set_occupied(footprint_cell, true)
	credits -= _build_cost(selected_building_id)
	_refresh_progression_ui()
	build_mode = false
	cancel_build_button.visible = false
	placement_preview_cell = Vector2i(-1, -1)
	placement_preview_valid = false
	build_preview.visible = false
	_update_selected_building()
	var placed_profile: Dictionary = GameBalance.BUILDINGS.get(selected_building_id, {})
	_update_hud("%s built at cell %s" % [str(placed_profile.get("name", "building")).replace("_", " "), cell])

func _update_spawn_marker() -> void:
	var half_extent: float = float(MapGrid.WIDTH) * MapGrid.CELL_SIZE * 0.5
	var normalized: Vector2 = (active_spawn_position + Vector2(half_extent, half_extent)) / (half_extent * 2.0)
	var minimap: Control = $Playfield/MiniMap
	var marker_size: Vector2 = attack_marker.size
	var raw_position: Vector2 = normalized * minimap.size - marker_size * 0.5
	var max_position: Vector2 = Vector2(maxf(minimap.size.x - marker_size.x, 0.0), maxf(minimap.size.y - marker_size.y, 0.0))
	attack_marker.position = Vector2(clampf(raw_position.x, 0.0, max_position.x), clampf(raw_position.y, 0.0, max_position.y))

func _random_edge_spawn() -> Vector2:
	var half_extent: float = float(MapGrid.WIDTH) * MapGrid.CELL_SIZE * 0.5
	var side: int = randi_range(0, 3)
	var along: float = randf_range(-half_extent, half_extent)
	if side == 0:
		return Vector2(along, -half_extent - SPAWN_MARGIN)
	if side == 1:
		return Vector2(half_extent + SPAWN_MARGIN, along)
	if side == 2:
		return Vector2(along, half_extent + SPAWN_MARGIN)
	return Vector2(-half_extent - SPAWN_MARGIN, along)

func _target_for_bug(world_position: Vector2, _fallback: Node2D) -> Node2D:
	# The base has priority whenever it is inside the bug's interest radius.
	# A secondary building is considered only when the base is still outside it.
	var interest_radius: float = BUG_TARGET_RADIUS
	# Distances are measured in map units (entities-local), not screen pixels,
	# so changing the map zoom does not change what a bug notices.
	world_position = entities.to_local(world_position)
	var base_map_pos: Vector2 = entities.to_local(base.global_position)
	if world_position.distance_to(base_map_pos) <= interest_radius:
		return base
	var nearest_tower: GrayboxTower
	var nearest_distance: float = interest_radius
	for tower_node: Node in towers.get_children():
		var tower: GrayboxTower = tower_node as GrayboxTower
		if not is_instance_valid(tower) or tower.health <= 0.0:
			continue
		var tower_map_pos: Vector2 = entities.to_local(tower.global_position)
		var distance: float = world_position.distance_to(tower_map_pos)
		# Never retarget a tower that is already behind the bug. Without this
		# guard a bug can pass a turret, notice it within the radius, and turn
		# around to attack it instead of continuing toward the base.
		var bug_distance_to_base: float = world_position.distance_to(base_map_pos)
		var tower_distance_to_base: float = tower_map_pos.distance_to(base_map_pos)
		if tower_distance_to_base >= bug_distance_to_base - 4.0:
			continue
		if distance <= nearest_distance:
			nearest_distance = distance
			nearest_tower = tower
	if is_instance_valid(nearest_tower):
		return nearest_tower
	# Also intercept defensive buildings placed directly in the bug's approach corridor.
	# This prevents a bug from walking through a line of separated soldiers merely
	# because the next one is outside the temporary 150 px interest radius.
	var corridor_vector: Vector2 = base_map_pos - world_position
	var corridor_distance_total: float = corridor_vector.length()
	if corridor_distance_total > 0.1:
		var corridor_direction: Vector2 = corridor_vector / corridor_distance_total
		var corridor_target: GrayboxTower
		var corridor_distance: float = INF
		for tower_node: Node in towers.get_children():
			var tower: GrayboxTower = tower_node as GrayboxTower
			if not is_instance_valid(tower) or tower.health <= 0.0:
				continue
			var tower_map_pos: Vector2 = entities.to_local(tower.global_position)
			var projection: float = (tower_map_pos - world_position).dot(corridor_direction)
			if projection < 0.0 or projection > corridor_distance_total:
				continue
			var closest_point: Vector2 = world_position + corridor_direction * projection
			var lateral_distance: float = tower_map_pos.distance_to(closest_point)
			if lateral_distance <= 48.0 and projection < corridor_distance:
				corridor_distance = projection
				corridor_target = tower
		if is_instance_valid(corridor_target):
			return corridor_target
	return base

func _spawn_bug(spawn_position: Vector2, is_wave_enemy: bool) -> void:
	if is_wave_enemy:
		spawn_position = active_spawn_position
		var to_base: Vector2 = base.position - spawn_position
		var travel_direction: Vector2 = to_base.normalized() if to_base.length_squared() > 0.01 else Vector2.DOWN
		var lateral_direction: Vector2 = Vector2(-travel_direction.y, travel_direction.x)
		var lane_offset: float = float((wave_manager.spawn_index % 5) - 2) * 30.0
		spawn_position += lateral_direction * lane_offset
	var bug: GrayboxBug = BUG_SCENE.instantiate() as GrayboxBug
	var enemy_balance: Dictionary = GameBalance.GRAYBOX_ENEMY_BALANCE.get(bug.enemy_id, {})
	if not enemy_balance.is_empty():
		bug.max_health = float(enemy_balance.get("max_health", bug.max_health))
		bug.graybox_damage = float(enemy_balance.get("damage", bug.graybox_damage))
		bug.attack_interval = float(enemy_balance.get("attack_interval", bug.attack_interval))
		bug.speed = float(enemy_balance.get("speed", bug.speed))
		bug.target_detection_radius = float(enemy_balance.get("detection_radius", bug.target_detection_radius))
	# spawn_position is in the same grid-local space as the navigation path and
	# placed buildings. It must NOT be shifted by the presentation offset, or the
	# bug starts displaced from its path and walks back toward a path node behind
	# it (i.e. away from the base).
	bug.position = spawn_position
	if is_wave_enemy:
		var speed_variation: float = 0.94 + float(wave_manager.spawn_index % 4) * 0.04
		bug.speed *= speed_variation
	bug.registered_with_wave = is_wave_enemy
	bug.set_target(base)
	bug.set_target_provider(Callable(self, "_target_for_bug"))
	bug.set_path(_path_to_base(spawn_position))
	bug.died.connect(_on_bug_died.bind(is_wave_enemy))
	enemies.add_child(bug)
	if not enemy_balance.is_empty() and enemy_balance.has("bullet_resistance"):
		bug.resistances["bullet"] = float(enemy_balance["bullet_resistance"])
	_update_hud("Enemy spawned with grid path" if is_wave_enemy else "Manual enemy spawned")

func _on_wave_spawn_requested(_requested_spawn_index: int) -> void:
	_spawn_bug(Vector2.ZERO, true)

func _on_wave_started(started_wave: int, enemy_count: int) -> void:
	# The initial edge is chosen once per survival session; all waves use it.
	_update_spawn_marker()
	next_wave_button.visible = false
	_update_hud("Атака %d началась • противников: %d" % [started_wave, enemy_count])

func _on_wave_cleared(cleared_wave: int) -> void:
	_update_hud("Атака %d отбита — подготовь оборону" % cleared_wave)

func _on_intermission_started(next_wave_number: int) -> void:
	if next_wave_number <= wave_manager.wave_counts.size():
		next_wave_button.visible = true
		next_wave_button.disabled = false
		next_wave_button.text = "Начать атаку %d" % next_wave_number
		_update_hud("Передышка: нажми «Начать атаку», когда будешь готов")

func _on_next_wave_pressed() -> void:
	if intro_pending or game_paused:
		return
	if wave_manager.request_next_wave():
		next_wave_button.visible = false

func _on_all_waves_complete() -> void:
	next_wave_button.visible = false
	game_over = true
	_update_hud("ПОБЕДА — все атаки отражены")

func _cell_from_position(world_position: Vector2) -> Vector2i:
	var origin_x: float = -float(MapGrid.WIDTH) * MapGrid.CELL_SIZE * 0.5
	var origin_y: float = -float(MapGrid.HEIGHT) * MapGrid.CELL_SIZE * 0.5
	return Vector2i(floori((world_position.x - origin_x) / MapGrid.CELL_SIZE), floori((world_position.y - origin_y) / MapGrid.CELL_SIZE))

func _slice_world_from_cell(cell: Vector2i) -> Vector2:
	var origin_x: float = -float(MapGrid.WIDTH) * MapGrid.CELL_SIZE * 0.5
	var origin_y: float = -float(MapGrid.HEIGHT) * MapGrid.CELL_SIZE * 0.5
	return Vector2(origin_x, origin_y) + Vector2(cell) * MapGrid.CELL_SIZE + Vector2(MapGrid.CELL_SIZE * 0.5, MapGrid.CELL_SIZE * 0.5)

func _path_to_base(start_position: Vector2) -> Array[Vector2]:
	# Wave enemies spawn just outside the grid. Clamp the navigation start to
	# the nearest valid edge cell so A* can build an entry route around rocks.
	var raw_start_cell: Vector2i = _cell_from_position(start_position)
	var start_cell: Vector2i = Vector2i(
		clampi(raw_start_cell.x, 0, MapGrid.WIDTH - 1),
		clampi(raw_start_cell.y, 0, MapGrid.HEIGHT - 1)
	)
	var base_cell: Vector2i = _cell_from_position(base.position)
	var goal_cell: Vector2i = base_cell + Vector2i(-1, 0)
	var cell_path: Array[Vector2i] = navigation.find_path(start_cell, goal_cell)
	var world_path: Array[Vector2] = []
	for cell: Vector2i in cell_path:
		world_path.append(_slice_world_from_cell(cell))
	return world_path

func _damage_first_tower() -> void:
	if not is_instance_valid(selected_tower):
		_update_hud("Select a tower before using D")
		return
	selected_tower.take_damage(100.0)
	_update_tower_info()
	_update_hud("Tower damaged: %s" % selected_tower.building_state)

func _upgrade_first_tower() -> void:
	if not is_instance_valid(selected_tower):
		_update_hud("Select a tower before upgrading")
		return
	if construction_states.has(selected_tower):
		_update_hud("Модернизация уже выполняется")
		return
	if selected_tower.upgrade_level >= selected_tower.max_upgrade_level:
		_update_hud("Здание уже достигло максимального уровня")
		return
	var upgrade_price: int = selected_tower.upgrade_cost
	if credits < upgrade_price:
		_update_hud("Not enough credits for upgrade [TEMPORARY_BALANCE]")
		return
	credits -= upgrade_price
	_start_construction(selected_tower, true)
	_update_tower_info()
	_update_hud("Модернизация здания началась")

func _on_tower_destroyed(tower: GrayboxTower) -> void:
	if selected_tower == tower:
		selected_tower = null
		_update_tower_info()
	var footprint_variant: Variant = tower_footprints.get(tower, null)
	if footprint_variant is Array:
		for occupied_cell_value: Variant in footprint_variant as Array:
			if occupied_cell_value is Vector2i:
				grid.set_occupied(occupied_cell_value as Vector2i, false)
	else:
		var cell_variant: Variant = tower_cells.get(tower, null)
		if cell_variant is Vector2i:
			grid.set_occupied(cell_variant as Vector2i, false)
	tower_footprints.erase(tower)
	tower_cells.erase(tower)
	_refresh_progression_ui()
	_update_hud("Tower destroyed — cell released")

func _on_bug_died(registered_with_wave: bool) -> void:
	if registered_with_wave:
		wave_manager.notify_enemy_died()
	credits += TEMPORARY_ENEMY_REWARD
	score += 13
	_grant_experience(1)
	if enemy_kills == 15:
		_show_progression_notice("Вам присвоили новое звание и предоставляется первое дополнительное действие. Вы можете применить его, открыв меню дополнительных действий и выбрав желаемое действие. После этого вы должны будете выбрать цель и подтвердить выбор. После того, как вы применили дополнительное действие, вы можете снова активировать его в соответствующем здании за определенную сумму. В данном случае это центральная база, разведывательный полет.")
		_show_progression_notice("Дополнительное действие можно выбрать в меню дополнительных действий.")
	_update_hud("Враг уничтожен: +130 $ и +13 очков")

func _on_base_health_changed(current_health: float, maximum_health: float) -> void:
	base_bar.max_value = maximum_health
	base_bar.value = current_health
	if base_selected:
		_update_tower_info()

func _on_base_destroyed() -> void:
	game_over = true
	_set_game_paused(false)
	pause_button.visible = false
	_update_hud("ПОРАЖЕНИЕ — центральная база уничтожена. Нажми Esc для перезапуска")

func _update_tower_info() -> void:
	selection_strip.visible = base_selected or is_instance_valid(selected_tower)
	var icon_texture: Texture2D = load("res://original/100.png") as Texture2D
	if base_selected and is_instance_valid(base):
		selection_icon.texture = icon_texture
		selection_hp_bar.max_value = base.max_health
		selection_hp_bar.value = base.health
		selection_title.text = "Центральная база"
		selection_stats.text = "ОЖ: %.0f   О: %.0f" % [base.health, base.defense]
		tower_info_label.text = "Центральная база\nОЖ: %.0f / %.0f   О: %.0f" % [base.health, base.max_health, base.defense]
		return
	if not is_instance_valid(selected_tower):
		selection_title.text = "Выбор объекта"
		selection_stats.text = "Коснись здания или врага"
		tower_info_label.text = "Здание не выбрано"
		return
	var tower_name: String = _display_building_name(selected_tower.building_id, "Оборонительное сооружение")
	var profile: Dictionary = GameBalance.BUILDINGS.get(selected_tower.building_id, {})
	var icon_path: String = "res://original/103.png"
	if selected_tower.building_id == ENERGY_STATION_ID:
		icon_path = "res://original/113.png"
	elif selected_tower.building_id == SOLDIERS_ID:
		icon_path = "res://original/110.png"
	selection_icon.texture = load(icon_path) as Texture2D
	selection_hp_bar.max_value = selected_tower.max_health
	selection_hp_bar.value = selected_tower.health
	selection_title.text = tower_name
	var stats_text: String = "ОЖ: %.0f" % selected_tower.health
	if profile.has("defense"):
		stats_text += "   О: %.0f" % selected_tower.defense_value
	if profile.has("attack"):
		stats_text += "   А: %.0f" % selected_tower.damage
	if profile.has("radius"):
		stats_text += "   Р: %.0f" % selected_tower.radius_value
	selection_stats.text = stats_text
	tower_info_label.text = "%s\nУровень: %d\n%s / %.0f" % [tower_name, selected_tower.upgrade_level + 1, stats_text, selected_tower.max_health]

func _update_building_palette() -> void:
	building_151_button.text = "%s\nПостроить %d $" % [BUILDING_REGISTRY.display_name(ENERGY_STATION_ID), _build_cost(ENERGY_STATION_ID)]
	building_153_button.text = "%s\nПостроить %d $" % [BUILDING_REGISTRY.display_name(FIRE_TOWER_ID), _build_cost(FIRE_TOWER_ID)]
	building_155_button.text = "%s\nПостроить %d $" % [BUILDING_REGISTRY.display_name(SOLDIERS_ID), _build_cost(SOLDIERS_ID)]
	if build_mode:
		return
	building_151_button.disabled = _has_energy_station() or credits < _build_cost(ENERGY_STATION_ID)
	building_155_button.disabled = credits < _build_cost(SOLDIERS_ID)
	building_153_button.disabled = credits < _build_cost(FIRE_TOWER_ID)

func _update_selected_building() -> void:
	_update_building_palette()
	for index: int in range(building_picker.item_count):
		if building_picker.get_item_id(index) == selected_building_id:
			building_picker.select(index)
			break
	var profile: Dictionary = GameBalance.BUILDINGS.get(selected_building_id, {})
	var building_name: String = str(profile.get("name", "unknown"))
	var display_name: String = _display_building_name(selected_building_id, building_name)
	selected_label.text = "Выбрано: %s\nСтоимость: %d $" % [display_name, _build_cost(selected_building_id)]
	build_button.text = "Построить %s" % display_name

func _display_building_name(building_id: int, fallback_name: String) -> String:
	var display_name: String = BUILDING_REGISTRY.display_name(building_id)
	return display_name if not display_name.is_empty() else fallback_name.replace("_", " ").capitalize()

func _update_hud(message: String) -> void:
	status_label.text = message
