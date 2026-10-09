extends SceneTree

const SOURCE_PATH: String = "res://assets/sprites/units/new_base_bug/bug_sheet.png"
const OUTPUT_DIR: String = "res://assets/generated"
const VIEW_RECTS: Array[Rect2i] = [Rect2i(26, 290, 315, 353), Rect2i(361, 291, 341, 348), Rect2i(712, 316, 344, 294), Rect2i(1072, 294, 328, 308), Rect2i(1423, 292, 322, 311)]
const VIEW_NAMES: Array[String] = ["s", "sw", "w", "nw", "n"]
const TARGET_CONTENT_HEIGHT: int = 100
const W_SCALE: float = 1.05
const FLIP_SOURCE: Dictionary = {"SW": true}

func _init() -> void:
	var source: Image = Image.load_from_file(SOURCE_PATH)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	for index: int in VIEW_RECTS.size():
		_save_view(source, VIEW_RECTS[index], VIEW_NAMES[index], bool(FLIP_SOURCE.get(VIEW_NAMES[index], false)), W_SCALE if index == 2 else 1.0)
	for mirrored: Dictionary in [{"index": 5, "name": "ne", "source": 3}, {"index": 6, "name": "e", "source": 2}, {"index": 7, "name": "se", "source": 1}]:
		_save_view(source, VIEW_RECTS[int(mirrored["source"])], str(mirrored["name"]), true, W_SCALE if int(mirrored["index"]) == 6 else 1.0)
	print("Generated 8 bug views; target content height=%d px, W coefficient=%.2f" % [TARGET_CONTENT_HEIGHT, W_SCALE])
	quit()

func _save_view(source: Image, rect: Rect2i, view_name: String, mirror: bool, scale_factor: float) -> void:
	var crop: Image = source.get_region(rect)
	var target_width: int = maxi(1, roundi(float(crop.get_width()) * float(TARGET_CONTENT_HEIGHT) / float(crop.get_height()) * scale_factor))
	crop.resize(target_width, TARGET_CONTENT_HEIGHT, Image.INTERPOLATE_LANCZOS)
	if mirror:
		crop.flip_x()
	var canvas: Image = Image.create(160, 140, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0, 0, 0, 0))
	canvas.blit_rect(crop, Rect2i(Vector2i.ZERO, crop.get_size()), Vector2i((160 - crop.get_width()) / 2, 140 - crop.get_height()))
	canvas.save_png("%s/bug_%d_%s.png" % [OUTPUT_DIR, _output_index(view_name, mirror), view_name])

func _output_index(view_name: String, mirror: bool) -> int:
	if view_name == "s": return 0
	if view_name == "sw": return 1
	if view_name == "w": return 2
	if view_name == "nw": return 3
	if view_name == "n": return 4
	if view_name == "ne": return 5
	if view_name == "e": return 6
	return 7
