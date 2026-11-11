extends Node2D
## Временная сцена: эффект ремонта на башне 1 ур., бункере 3 ур. и базе.

var _fixed: Array[Node2D] = []

func _spawn(path: String, x: float, upgrades: int, dmg: float) -> void:
	var t: Node2D = (load(path) as PackedScene).instantiate()
	if "combat_enabled" in t:
		t.combat_enabled = false
	t.position = Vector2(x, 260)
	t.scale = Vector2(1.5, 1.5)
	add_child(t)
	for i: int in upgrades:
		t.call("upgrade")
	t.call("take_damage", dmg)
	_fixed.append(t)

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.45, 0.33, 0.25)
	bg.size = Vector2(432, 768)
	bg.z_index = -100
	add_child(bg)
	_spawn("res://scenes/graybox/graybox_soldier_defender.tscn", 80, 0, 40)
	_spawn("res://scenes/graybox/graybox_soldier_defender.tscn", 220, 2, 100)
	_spawn("res://scenes/graybox/graybox_modern_central_base.tscn", 355, 0, 300)

func _process(_d: float) -> void:
	for t: Node2D in _fixed:
		if is_instance_valid(t):
			t.call("repair_by", 0.15)
