extends Node2D
## Временная сцена: тумба с солдатами и бункер рядом, для сравнения высоты.

const TOWER := preload("res://scenes/units/SoldiersTower.tscn")

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.45, 0.33, 0.25)
	bg.size = Vector2(432, 768)
	bg.z_index = -100
	add_child(bg)
	var levels: Array[int] = [0, 2]
	var xs: Array[float] = [105.0, 320.0]
	for i: int in 2:
		var t: SoldiersTower = TOWER.instantiate()
		t.position = Vector2(xs[i], 250)
		t.scale = Vector2(1.7, 1.7)
		add_child(t)
		t.set_upgrade_level(levels[i], false)
