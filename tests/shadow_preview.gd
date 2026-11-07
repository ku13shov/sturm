extends Node2D
## Временная сцена для проверки теней: башня солдат без апгрейда и с барьерами, крупно, на светлом фоне.

const TOWER := preload("res://scenes/units/SoldiersTower.tscn")

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.62, 0.36, 0.22)
	bg.size = Vector2(1200, 700)
	bg.z_index = -100
	add_child(bg)
	for i: int in 2:
		var tower: SoldiersTower = TOWER.instantiate()
		tower.position = Vector2(230 + i * 440, 330)
		tower.scale = Vector2(2.2, 2.2)
		add_child(tower)
		tower.set_upgrade_level(i, false)
