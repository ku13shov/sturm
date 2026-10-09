extends SceneTree

const FRAME_COUNT: int = 8
const CELL_SIZE: Vector2i = Vector2i(120, 140)

func _init() -> void:
	var viewport: SubViewport = SubViewport.new()
	viewport.size = CELL_SIZE * FRAME_COUNT
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var driver: RigCheckDriver = RigCheckDriver.new()
	driver.position = Vector2(45.0, 100.0)
	viewport.add_child(driver)
	var rig: BugRigW = load("res://scenes/units/BugRigW.tscn").instantiate() as BugRigW
	rig.random_initial_phase = false
	rig.record_foot_coordinates = false
	driver.add_child(rig)
	await process_frame
	rig.set_process(false)
	var strip: Image = Image.create(CELL_SIZE.x * FRAME_COUNT, CELL_SIZE.y, false, Image.FORMAT_RGBA8)
	strip.fill(Color(0.035, 0.025, 0.02, 1.0))
	for index: int in FRAME_COUNT:
		driver.position.x = 45.0 + float(index) * CELL_SIZE.x
		if index == 0:
			driver.velocity = Vector2.ZERO
		else:
			driver.velocity = Vector2(12.0, 0.0)
			driver.position.x += float(index) * 1.5
		rig._process(1.0 / 12.0)
		await process_frame
		var frame_image: Image = viewport.get_texture().get_image()
		var source_rect: Rect2i = Rect2i(index * CELL_SIZE.x, 0, CELL_SIZE.x, CELL_SIZE.y)
		var frame_cell: Image = frame_image.get_region(source_rect)
		strip.blit_rect(frame_cell, Rect2i(0, 0, CELL_SIZE.x, CELL_SIZE.y), Vector2i(index * CELL_SIZE.x, 0))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp"))
	strip.save_png(ProjectSettings.globalize_path("res://tmp/rig_frames.png"))
	print("saved res://tmp/rig_frames.png (8 frames, 960x140)")
	quit()
