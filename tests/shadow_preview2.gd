extends Node2D
## Временная сцена для проверки теней: башня 2 уровня (с барьерами) крупно, на фоне цвета земли.

const TOWER := preload("res://scenes/units/SoldiersTower.tscn")

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.62, 0.36, 0.22)
	bg.size = Vector2(1200, 900)
	bg.z_index = -100
	add_child(bg)
	var tower: SoldiersTower = TOWER.instantiate()
	tower.position = Vector2(216, 330)
	tower.scale = Vector2(2.6, 2.6)
	add_child(tower)
	tower.set_upgrade_level(1, false)
