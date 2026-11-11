extends Node2D
## Временная сцена: зелёные полоски при ремонте на уровнях 1, 2 (барьеры) и 3 (бункер).

var _towers: Array[Node2D] = []

func _spawn(x: float, upgrades: int) -> void:
	var t: Node2D = (load("res://scenes/graybox/graybox_soldier_defender.tscn") as PackedScene).instantiate()
	t.combat_enabled = false
	t.position = Vector2(x, 260)
	t.scale = Vector2(1.5, 1.5)
	add_child(t)
	for i: int in upgrades:
		t.call("upgrade")
	t.call("take_damage", 20.0)
	_towers.append(t)

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.45, 0.33, 0.25)
	bg.size = Vector2(432, 768)
	bg.z_index = -100
	add_child(bg)
	_spawn(70, 0)
	_spawn(215, 1)
	_spawn(360, 2)

func _process(_d: float) -> void:
	for t: Node2D in _towers:
		if is_instance_valid(t):
			t.call("repair_by", 0.05)
