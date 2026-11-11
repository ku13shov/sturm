extends Node2D
## Одноразовый инструмент: снимает реальные сцены зданий в прозрачные иконки для инфо-панели.
## Запуск: открыть tools/icon_capture.tscn и запустить сцену. Результат: res://assets/ui/icons/*.png

const OUT_DIR: String = "res://assets/ui/icons/"
const CANVAS: int = 512
const ICON: int = 128
const ALPHA_CUTOFF: float = 0.2
const MARGIN: int = 6
const SETTLE_FRAMES: int = 60
const ITEMS: Array[Dictionary] = [
	{"name": "soldiers_1", "scene": "res://scenes/graybox/graybox_soldier_defender.tscn", "level": 0},
	{"name": "soldiers_2", "scene": "res://scenes/graybox/graybox_soldier_defender.tscn", "level": 1},
	{"name": "soldiers_3", "scene": "res://scenes/graybox/graybox_soldier_defender.tscn", "level": 2},
	{"name": "energy_station", "scene": "res://scenes/graybox/graybox_energy_station.tscn", "level": -1},
	{"name": "fire_tower", "scene": "res://scenes/graybox/graybox_tower.tscn", "level": -1},
	{"name": "laser_tower", "scene": "res://scenes/graybox/graybox_laser_tower.tscn", "level": -1},
	{"name": "plasma_tower", "scene": "res://scenes/graybox/graybox_plasma_tower.tscn", "level": -1},
	{"name": "radar_tower", "scene": "res://scenes/graybox/graybox_radar_tower.tscn", "level": -1},
	{"name": "beacon", "scene": "res://scenes/graybox/graybox_beacon.tscn", "level": -1},
	{"name": "central_base", "scene": "res://scenes/graybox/graybox_central_base_template.tscn", "level": -1},
]

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	for item: Dictionary in ITEMS:
		await _capture(item)
	print("ICON_CAPTURE_DONE")
	get_tree().quit()

func _capture(item: Dictionary) -> void:
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(CANVAS, CANVAS)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var packed: PackedScene = load(str(item["scene"])) as PackedScene
	if packed == null:
		push_warning("ICON_CAPTURE: нет сцены %s" % str(item["scene"]))
		viewport.queue_free()
		return
	var node: Node2D = packed.instantiate() as Node2D
	node.position = Vector2(CANVAS * 0.5, CANVAS * 0.62)
	viewport.add_child(node)
	var level: int = int(item["level"])
	if level >= 0:
		var visual: Node = node.get_node_or_null("SoldierVisual")
		if visual != null and visual.has_method("set_upgrade_level"):
			visual.call("set_upgrade_level", level, false)
	for _frame: int in SETTLE_FRAMES:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = viewport.get_texture().get_image()
	var bounds: Rect2i = _opaque_bounds(image)
	if bounds.size.x <= 0 or bounds.size.y <= 0:
		push_warning("ICON_CAPTURE: пустой кадр у %s" % str(item["name"]))
		viewport.queue_free()
		return
	var side: int = maxi(bounds.size.x, bounds.size.y) + MARGIN * 2
	var square: Image = Image.create(side, side, false, Image.FORMAT_RGBA8)
	square.fill(Color(0, 0, 0, 0))
	var offset: Vector2i = Vector2i((side - bounds.size.x) / 2, (side - bounds.size.y) / 2)
	square.blit_rect(image, bounds, offset)
	square.resize(ICON, ICON, Image.INTERPOLATE_LANCZOS)
	var path: String = "%s%s.png" % [OUT_DIR, str(item["name"])]
	var error: int = square.save_png(path)
	print("ICON_CAPTURE %s -> %s (err %d, bounds %s)" % [str(item["name"]), path, error, str(bounds)])
	viewport.queue_free()

func _opaque_bounds(image: Image) -> Rect2i:
	var min_x: int = image.get_width()
	var min_y: int = image.get_height()
	var max_x: int = -1
	var max_y: int = -1
	for y: int in image.get_height():
		for x: int in image.get_width():
			if image.get_pixel(x, y).a >= ALPHA_CUTOFF:
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
				min_y = mini(min_y, y)
				max_y = maxi(max_y, y)
	if max_x < 0:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
