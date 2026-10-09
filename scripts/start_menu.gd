class_name StartMenu
extends Control

const GAME_SCENE: String = "res://scenes/gameplay/graybox_vertical_slice.tscn"
const HELP_SCENE: String = "res://scenes/ui/help_pages.tscn"
const SAVE_PATH: String = "user://sturmtrupp_survival_save.json"
const SAVE_BACKUP_PATH: String = "user://sturmtrupp_survival_save.bak"

@onready var continue_button: Button = $Center/Panel/Content/ContinueButton

func _ready() -> void:
	$Center/Panel/Content/NewGameButton.pressed.connect(_start_new_game)
	continue_button.pressed.connect(_continue_game)
	$Center/Panel/Content/HelpButton.pressed.connect(_open_help)
	_refresh_continue_button()

func _refresh_continue_button() -> void:
	var save_data: Dictionary = _read_save(SAVE_PATH)
	if save_data.is_empty():
		save_data = _read_save(SAVE_BACKUP_PATH)
	continue_button.disabled = save_data.is_empty()
	continue_button.text = "Продолжить"
	if not save_data.is_empty():
		var wave_value: Variant = save_data.get("wave_state", {})
		if wave_value is Dictionary:
			var wave_state: Dictionary = wave_value as Dictionary
			continue_button.text = "Продолжить • атака %d" % int(wave_state.get("wave_number", 0))

func _read_save(path: String) -> Dictionary:
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
	var version: int = int(data.get("version", 1))
	if version < 1 or version > 2 or not (data.get("credits", 0) is int or data.get("credits", 0) is float):
		return {}
	if not data.get("buildings", []) is Array:
		return {}
	if version >= 2 and not data.get("enemies", []) is Array:
		return {}
	return data

func _start_new_game() -> void:
	get_tree().set_meta("sturmtrupp_continue_requested", false)
	get_tree().change_scene_to_file(GAME_SCENE)

func _continue_game() -> void:
	if continue_button.disabled:
		return
	get_tree().set_meta("sturmtrupp_continue_requested", true)
	get_tree().change_scene_to_file(GAME_SCENE)

func _open_help() -> void:
	get_tree().change_scene_to_file(HELP_SCENE)
