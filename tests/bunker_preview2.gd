extends Node2D
## Временная сцена: тумба 1 ур. и бункер (3 ур.) рядом, крупно, на фоне цвета земли, для сравнения яркости.

const TOWER := preload("res://scenes/units/SoldiersTower.tscn")

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.45, 0.33, 0.25)
	bg.size = Vector2(432, 768)
	bg.z_index = -100
	add_child(bg)
	var a: SoldiersTower = TOWER.instantiate()
	a.position = Vector2(100, 250)
	a.scale = Vector2(1.7, 1.7)
	add_child(a)
	a.set_upgrade_level(0, false)
	var b: SoldiersTower = TOWER.instantiate()
	b.position = Vector2(320, 250)
	b.scale = Vector2(1.7, 1.7)
	add_child(b)
	b.set_upgrade_level(2, false)
