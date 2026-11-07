extends Node2D
## Временная сцена: бункер (3 ур.) и тумба 1 ур. рядом, крупно, на тёмном фоне, для сравнения яркости.

const TOWER := preload("res://scenes/units/SoldiersTower.tscn")

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.45, 0.33, 0.25)
	bg.size = Vector2(1000, 700)
	bg.z_index = -100
	add_child(bg)
	var a: SoldiersTower = TOWER.instantiate()
	a.position = Vector2(260, 330)
	a.scale = Vector2(2.4, 2.4)
	add_child(a)
	a.set_upgrade_level(0, false)
	var b: SoldiersTower = TOWER.instantiate()
	b.position = Vector2(740, 330)
	b.scale = Vector2(2.4, 2.4)
	add_child(b)
	b.set_upgrade_level(2, false)
