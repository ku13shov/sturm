extends Node2D
## Временная сцена: тумба, бункер и бункер без шейдера вспышки на корпусе, для поиска причины затемнения.

const TOWER := preload("res://scenes/units/SoldiersTower.tscn")

func _add_tower(x: float, level: int) -> SoldiersTower:
	var t: SoldiersTower = TOWER.instantiate()
	t.position = Vector2(x, 250)
	t.scale = Vector2(1.1, 1.1)
	add_child(t)
	t.set_upgrade_level(level, false)
	return t

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.45, 0.33, 0.25)
	bg.size = Vector2(432, 768)
	bg.z_index = -100
	add_child(bg)
	_add_tower(70, 0)
	_add_tower(215, 2)
	var c := _add_tower(360, 2)
	c.bunker._body.material = null
	c.bunker._prev.material = null
