extends Node2D
## Временная сцена: бункеры стреляют в четыре диагонали, видно яркость корпуса и откуда идут трассеры.

const TOWER := preload("res://scenes/units/SoldiersTower.tscn")

var _towers: Array[SoldiersTower] = []
var _dirs: Array[Vector2] = [Vector2(-1, -0.5), Vector2(1, -0.5), Vector2(-1, 0.5), Vector2(1, 0.5)]
var _acc := 0.0

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.45, 0.33, 0.25)
	bg.size = Vector2(432, 768)
	bg.z_index = -100
	add_child(bg)
	var spots: Array[Vector2] = [Vector2(110, 180), Vector2(320, 180), Vector2(110, 440), Vector2(320, 440)]
	for p: Vector2 in spots:
		var t: SoldiersTower = TOWER.instantiate()
		t.position = p
		t.scale = Vector2(1.7, 1.7)
		add_child(t)
		t.set_upgrade_level(2, false)
		_towers.append(t)

func _process(delta: float) -> void:
	_acc += delta
	if _acc < 0.12:
		return
	_acc = 0.0
	for i: int in _towers.size():
		_towers[i].play_shot(_towers[i].global_position + _dirs[i] * 130.0)
