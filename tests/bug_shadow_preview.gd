extends Node2D
## Временная сцена: жуки в нескольких направлениях, крупно, для проверки теней по силуэту.

const BUG := preload("res://scenes/graybox/graybox_bug.tscn")

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.62, 0.36, 0.22)
	bg.size = Vector2(1200, 900)
	bg.z_index = -100
	add_child(bg)
	var dirs: Array[Vector2] = [Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(1, -0.3), Vector2(0, -1), Vector2(1, 1)]
	for i: int in dirs.size():
		var bug: Node2D = BUG.instantiate()
		bug.position = Vector2(80 + (i % 3) * 130, 160 + (i / 3) * 200)
		bug.scale = Vector2(4, 4)
		add_child(bug)
		bug.set("velocity", dirs[i].normalized() * 1.0)
