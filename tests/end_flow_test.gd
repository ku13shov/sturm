extends Node
## Проверка цепочки конца забега: разрушаем базу и смотрим, что через 2 с появится экран итогов.

func _ready() -> void:
	var game: GrayboxVerticalSlice = preload("res://scenes/gameplay/graybox_vertical_slice.tscn").instantiate() as GrayboxVerticalSlice
	add_child(game)
	await get_tree().create_timer(0.5).timeout
	game._on_intro_confirmed()
	game.towers_built = 4
	game.towers_lost = 1
	game.enemy_kills = 12
	game.score = 156
	await get_tree().create_timer(0.5).timeout
	game.base.take_damage(999999.0)
	print("base destroyed, game_over=", game.game_over, " end_screen=", game.end_screen)
	await get_tree().create_timer(1.0).timeout
	print("after 1s, end_screen=", game.end_screen)
	await get_tree().create_timer(1.5).timeout
	print("after 2.5s, end_screen visible=", game.end_screen != null and game.end_screen.visible, " paused=", get_tree().paused)
