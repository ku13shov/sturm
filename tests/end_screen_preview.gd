extends Control
## Предпросмотр экрана итогов: запусти сцену tests/end_screen_preview.tscn.

func _ready() -> void:
	var screen: EndScreen = preload("res://scenes/ui/end_screen.tscn").instantiate() as EndScreen
	add_child(screen)
	screen.show_result(false, [
		["Время игры", "12:34"],
		["Очки", "208"],
		["Атака", "2 / 3"],
		["Убито жуков", "16"],
		["Звание", "Сержант"],
		["Опыт", "16 / 18"],
		["Башен построено", "5"],
		["Башен потеряно", "2"],
	])
