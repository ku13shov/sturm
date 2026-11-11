extends Node2D
## Временная сцена: диагностика левой башни (почему нет солдат) и эффект ремонта.

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.45, 0.33, 0.25)
	bg.size = Vector2(432, 768)
	bg.z_index = -100
	add_child(bg)
	var t: Node2D = (load("res://scenes/graybox/graybox_soldier_defender.tscn") as PackedScene).instantiate()
	t.combat_enabled = false
	t.position = Vector2(200, 260)
	t.scale = Vector2(1.5, 1.5)
	add_child(t)
	print("DIAG use_new=", t.use_new_soldier_visual, " hp=", t.health, " lvl=", t.upgrade_level)
	var v: Node = t.get_node_or_null("SoldierVisual")
	print("DIAG visual=", v, " visible=", v.visible if v else "-", " soldiers=", v.get("soldiers").size() if v and v.get("soldiers") != null else "-")
	t.take_damage(100)
	print("DIAG after dmg hp=", t.health, " valid=", is_instance_valid(t))
	set_meta("t", t)

func _process(_d: float) -> void:
	var t: Node2D = get_meta("t")
	if is_instance_valid(t):
		t.call("repair_by", 0.15)
