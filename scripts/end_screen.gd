class_name EndScreen
extends Control
## Экран итогов забега: одинаково показывается и при победе, и при поражении.
## Сам ничего не считает — получает готовые пары «название / значение» от игры.

signal restart_requested
signal menu_requested

const VICTORY_COLOR: Color = Color(0.55, 0.92, 0.62)
const DEFEAT_COLOR: Color = Color(0.95, 0.38, 0.34)
const LABEL_COLOR: Color = Color(0.82, 0.62, 0.45)
const VALUE_COLOR: Color = Color(1.0, 0.92, 0.78)
const FADE_TIME: float = 0.35

@onready var title_label: Label = $Center/Card/Box/Title
@onready var subtitle_label: Label = $Center/Card/Box/Subtitle
@onready var rows: GridContainer = $Center/Card/Box/Rows
@onready var restart_button: Button = $Center/Card/Box/RestartButton
@onready var menu_button: Button = $Center/Card/Box/MenuButton

func _ready() -> void:
	restart_button.pressed.connect(func() -> void: restart_requested.emit())
	menu_button.pressed.connect(func() -> void: menu_requested.emit())

func _unhandled_input(event: InputEvent) -> void:
	# Esc перезапускает забег, как раньше на экране поражения.
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		restart_requested.emit()

## stats — массив пар ["Название", "Значение"] в порядке показа.
func show_result(victory: bool, stats: Array) -> void:
	title_label.text = "ПОБЕДА" if victory else "ПОРАЖЕНИЕ"
	title_label.add_theme_color_override("font_color", VICTORY_COLOR if victory else DEFEAT_COLOR)
	subtitle_label.text = "Все атаки отражены" if victory else "Центральная база уничтожена"
	for child: Node in rows.get_children():
		rows.remove_child(child)
		child.queue_free()
	for entry: Variant in stats:
		var pair: Array = entry as Array
		if pair.size() < 2:
			continue
		_add_row(str(pair[0]), str(pair[1]))
	modulate.a = 0.0
	visible = true
	create_tween().tween_property(self, "modulate:a", 1.0, FADE_TIME)
	restart_button.grab_focus()

func _add_row(caption: String, value: String) -> void:
	var caption_label: Label = Label.new()
	caption_label.text = caption
	caption_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caption_label.add_theme_font_size_override("font_size", 16)
	caption_label.add_theme_color_override("font_color", LABEL_COLOR)
	rows.add_child(caption_label)
	var value_label: Label = Label.new()
	value_label.text = value
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", 17)
	value_label.add_theme_color_override("font_color", VALUE_COLOR)
	rows.add_child(value_label)
