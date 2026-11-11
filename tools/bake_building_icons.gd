extends Node
## Одноразовый инструмент: рендерит актуальные здания в маленькие PNG для верхней инфо-панели.
## Запуск: открыть res://tools/bake_building_icons.tscn и нажать «Запустить сцену».
## Результат: res://assets/ui/icons/*.png (квадрат ICON_SIZE, прозрачный фон, здание по центру).

const ICON_SIZE: int = 96
const RENDER_SIZE: int = 320
const OUT_DIR: String = "res://assets/ui/icons"

## [имя файла, сцена, уровень апгрейда]
const JOBS: Array = [
	["soldiers_l1", "res://scenes/graybox/graybox_soldier_defender.tscn", 0],
	["soldiers_l2", "res://scenes/graybox/graybox_soldier_defender.tscn", 1],
	["soldiers_l3", "res://scenes/graybox/graybox_soldier_defender.tscn", 2],
	["fire_tower", "res://scenes/graybox/graybox_tower.tscn", 0],
	["energy_station", "res://scenes/graybox/graybox_energy_station.tscn", 0],
	["laser_tower", "res://scenes/graybox/graybox_laser_tower.tscn", 0],
	["plasma_tower", "res://scenes/graybox/graybox_plasma_tower.tscn", 0],
	["radar_tower", "res://scenes/graybox/graybox_radar_tower.tscn", 0],
	["beacon", "res://scenes/graybox/graybox_beacon.tscn", 0],
]

const BASE_TEXTURES: Array = [
	["base_l1", "res://assets/sprites/buildings/central_base_l1.webp"],
	["base_l2", "res://assets/sprites/buildings/central_base_l2.webp"],
	["base_l3", "res://assets/sprites/buildings/central_base_l3.webp"],
]

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	for job: Array in JOBS:
		await _bake_scene(str(job[0]), str(job[1]), int(job[2]))
	for entry: Array in BASE_TEXTURES:
		_bake_texture(str(entry[0]), str(entry[1]))
	print("ICON_BAKE_DONE")
	get_tree().quit()

func _bake_scene(file_name: String, scene_path: String, level: int) -> void:
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		push_warning("Нет сцены: " + scene_path)
		return
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(RENDER_SIZE, RENDER_SIZE)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var holder: Node2D = Node2D.new()
	holder.position = Vector2(RENDER_SIZE * 0.5, RENDER_SIZE * 0.62)
	viewport.add_child(holder)
	var building: Node2D = packed.instantiate() as Node2D
	holder.add_child(building)
	if level > 0 and building is GrayboxTower:
		var tower: GrayboxTower = building as GrayboxTower
		tower.combat_enabled = false
		tower.restore_saved_state(tower.max_health, level)
	elif building is GrayboxTower:
		(building as GrayboxTower).combat_enabled = false
	for _frame: int in 12:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = viewport.get_texture().get_image()
	_save_fitted(image, file_name)
	viewport.queue_free()

func _bake_texture(file_name: String, texture_path: String) -> void:
	var texture: Texture2D = load(texture_path) as Texture2D
	if texture == null:
		push_warning("Нет текстуры: " + texture_path)
		return
	_save_fitted(texture.get_image(), file_name)

## Обрезает по непрозрачной области и вписывает в квадрат ICON_SIZE с небольшим полем.
func _save_fitted(source: Image, file_name: String) -> void:
	var image: Image = source.duplicate()
	image.convert(Image.FORMAT_RGBA8)
	var used: Rect2i = image.get_used_rect()
	if used.size.x <= 0 or used.size.y <= 0:
		push_warning("Пустой рендер: " + file_name)
		return
	var cropped: Image = image.get_region(used)
	var inner: float = float(ICON_SIZE - 8)
	var factor: float = minf(inner / float(cropped.get_width()), inner / float(cropped.get_height()))
	var new_w: int = maxi(1, roundi(float(cropped.get_width()) * factor))
	var new_h: int = maxi(1, roundi(float(cropped.get_height()) * factor))
	cropped.resize(new_w, new_h, Image.INTERPOLATE_LANCZOS)
	var canvas: Image = Image.create(ICON_SIZE, ICON_SIZE, false, Image.FORMAT_RGBA8)
	canvas.blit_rect(cropped, Rect2i(0, 0, new_w, new_h), Vector2i((ICON_SIZE - new_w) / 2, (ICON_SIZE - new_h) / 2))
	var error: int = canvas.save_png("%s/%s.png" % [OUT_DIR, file_name])
	print("icon ", file_name, " -> ", error)
