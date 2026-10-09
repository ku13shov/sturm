class_name BugRigWShot
extends Node2D
## Renders BugRigW at neutral pose and mid-walk into res://tmp/ (zoomed) and
## writes grounding geometry to res://tmp/bugrigw_geometry.txt.
## Run live (GPU) via run_scene so pixels are real.

const OUT_DIR: String = "res://tmp"
const RIG_POSITION: Vector2 = Vector2(300.0, 300.0)
const ZOOM: float = 5.0
const CAPTURE_SIZE: int = 240

var driver: RigCheckDriver
var rig: BugRigW
var report: PackedStringArray = PackedStringArray()

func _ready() -> void:
	var camera: Camera2D = Camera2D.new()
	camera.position = RIG_POSITION
	camera.zoom = Vector2(ZOOM, ZOOM)
	add_child(camera)
	camera.make_current()
	driver = RigCheckDriver.new()
	add_child(driver)
	rig = load("res://scenes/units/BugRigW.tscn").instantiate() as BugRigW
	rig.position = RIG_POSITION
	rig.random_initial_phase = false
	driver.add_child(rig)
	rig.set_process(false)
	await get_tree().process_frame

	driver.velocity = Vector2.ZERO
	for i: int in 12:
		rig._process(0.05)
	_print_geometry("neutral")
	await _render()
	_capture("bugrigw_neutral.png")

	driver.velocity = Vector2(12.0, 0.0)
	for i: int in 22:
		driver.position.x += 12.0 / 60.0
		rig._process(1.0 / 60.0)
	_print_geometry("midwalk")
	await _render()
	_capture("bugrigw_midwalk.png")

	# Reference: NewBugVisual shadow placement (the look to match).
	rig.visible = false
	driver.velocity = Vector2.ZERO
	var reference: Node2D = load("res://scenes/units/NewBugVisual.tscn").instantiate() as Node2D
	reference.set("bug_visual_height_px", 36.0)
	reference.set("ground_offset_px", 3.0)
	reference.position = RIG_POSITION
	add_child(reference)
	await _render()
	_capture("bugref_newbugvisual.png")
	_print_reference(reference)
	_flush_report()

func _render() -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

func _capture(file_name: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	var size: Vector2i = image.get_size()
	var origin: Vector2i = (size - Vector2i(CAPTURE_SIZE, CAPTURE_SIZE)) / 2
	var region: Image = image.get_region(Rect2i(origin, Vector2i(CAPTURE_SIZE, CAPTURE_SIZE)))
	region.save_png(ProjectSettings.globalize_path(OUT_DIR + "/" + file_name))
	print("saved ", OUT_DIR + "/" + file_name)

func _print_reference(reference: Node2D) -> void:
	var ref_body: Sprite2D = reference.get_node("Body")
	var ref_shadow: Sprite2D = reference.get_node("ContactShadow")
	var ur: Rect2i = ref_body.texture.get_image().get_used_rect()
	var body_gt: Transform2D = ref_body.get_global_transform()
	var content_br: Vector2 = body_gt * (ref_body.offset + Vector2(ur.position) + Vector2(ur.size))
	var shadow_gt: Transform2D = ref_shadow.get_global_transform()
	var st: Vector2 = ref_shadow.texture.get_size()
	var half: Vector2 = Vector2(st.x * 0.5 * ref_shadow.scale.x, st.y * 0.5 * ref_shadow.scale.y)
	var center: Vector2 = shadow_gt * Vector2.ZERO
	report.append("REF newbug body content br=%s skirt_bottom_y=%.2f" % [content_br, content_br.y])
	report.append("REF newbug shadow center=%s top=%.2f bottom=%.2f half=%s tex=%s" % [center, center.y - half.y, center.y + half.y, half, st])
	report.append("REF newbug ground_offset=%.2f shadow_width_fraction=%.2f shadow_offset=%s" % [reference.get("ground_offset_px"), reference.get("shadow_width_fraction"), reference.get("shadow_offset")])
	print("\n".join(report))

func _flush_report() -> void:
	var file: FileAccess = FileAccess.open(OUT_DIR + "/bugrigw_geometry.txt", FileAccess.WRITE)
	file.store_string("\n".join(report))
	file.flush()
	print("geometry written to ", OUT_DIR + "/bugrigw_geometry.txt")

func _print_geometry(tag: String) -> void:
	var ur: Rect2i = rig.body.texture.get_image().get_used_rect()
	var body_gt: Transform2D = rig.body.get_global_transform()
	var content_tl: Vector2 = body_gt * (rig.body.offset + Vector2(ur.position))
	var content_br: Vector2 = body_gt * (rig.body.offset + Vector2(ur.position) + Vector2(ur.size))
	report.append("%s body content tl=%s br=%s skirt_bottom_y=%.2f" % [tag, content_tl, content_br, content_br.y])
	var shadow_gt: Transform2D = rig.contact_shadow.get_global_transform()
	var st: Vector2 = rig.contact_shadow.texture.get_size()
	var half: Vector2 = Vector2(st.x * 0.5 * rig.contact_shadow.scale.x, st.y * 0.5 * rig.contact_shadow.scale.y)
	var center: Vector2 = shadow_gt * Vector2.ZERO
	report.append("%s shadow center=%s top=%.2f bottom=%.2f half=%s" % [tag, center, center.y - half.y, center.y + half.y, half])
	report.append("%s body_rest=%s neutral_length=%.3f inset=%.2f dome=%.2f" % [tag, rig.body_rest_position, rig.neutral_length, rig.leg_root_inset, rig.bug_visual_height_px])
	report.append("%s leg_root_x_near=%s leg_root_x_far=%s" % [tag, rig.leg_root_x_near, rig.leg_root_x_far])
	for index: int in 6:
		report.append("%s leg%d %s root=%s foot=%s rot=%.4f" % [tag, index, rig.legs[index].name, rig.legs[index].global_position, rig._actual_leg_foot(index), rig.legs[index].rotation])
	print("\n".join(report))
