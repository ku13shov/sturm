extends SceneTree

const FPS: float = 60.0
const DT: float = 1.0 / FPS
const DUR: int = 300

func _init() -> void:
	print("BugRigW automatic foot-slip check (5 s, 60 FPS)")
	print("speed\tslip_mean\tslip_max\tbody_jerk\tstretch_max_%\tasymmetry\tlimp_frames\tPASS")
	for speed: float in [12.0, 30.0, 60.0]:
		_run_case(speed)
	quit()

func _run_case(speed: float) -> void:
	var driver: RigCheckDriver = RigCheckDriver.new()
	var rig: BugRigW = load("res://scenes/units/BugRigW.tscn").instantiate() as BugRigW
	driver.add_child(rig)
	driver.velocity = Vector2(speed, 0.0)
	rig.record_foot_coordinates = true
	rig.random_initial_phase = false
	root.add_child(driver)
	await process_frame
	for frame: int in DUR:
		driver.position.x += speed * DT
		rig._process(DT)
	var feet: Array = rig.recorded_feet
	var bodies: Array[Vector2] = rig.recorded_body
	var stance: Array[int] = rig.recorded_stance_counts
	var states: Array = rig.recorded_states
	var lengths: Array[float] = rig.recorded_lengths
	var slip_sum: float = 0.0
	var slip_max: float = 0.0
	var slip_n: int = 0
	for frame: int in range(1, feet.size()):
		for index: int in 6:
			if states[frame][index] and states[frame - 1][index]:
				var d: float = (feet[frame][index] as Vector2).distance_to(feet[frame - 1][index] as Vector2)
				slip_sum += d
				slip_max = maxf(slip_max, d)
				slip_n += 1
	var jerk_max: float = 0.0
	for frame: int in range(2, bodies.size()):
		jerk_max = maxf(jerk_max, (bodies[frame] - bodies[frame - 1] * 2.0 + bodies[frame - 2]).length())
	var neutral: float = lengths[0] if not lengths.is_empty() else 1.0
	var stretch: float = 0.0
	for length: float in lengths: stretch = maxf(stretch, absf(length - neutral) / maxf(neutral, 0.001) * 100.0)
	var height_a: float = 0.0
	var height_b: float = 0.0
	var count_a: int = 0
	var count_b: int = 0
	for frame: int in bodies.size():
		if stance[frame] >= 6:
			height_a += bodies[frame].y
			count_a += 1
		else:
			height_b += bodies[frame].y
			count_b += 1
	var asymmetry: float = absf(height_a / maxf(count_a, 1) - height_b / maxf(count_b, 1))
	var limp: int = 0
	for count: int in stance:
		if count < 3: limp += 1
	var slip_mean: float = slip_sum / maxf(slip_n, 1)
	var passed: bool = slip_mean <= 0.3 and slip_max < 0.5 and stretch <= 15.0 and limp == 0
	print("%.0f\t%.4f\t%.4f\t%.4f\t%.2f\t%.4f\t%d\t%s" % [speed, slip_mean, slip_max, jerk_max, stretch, asymmetry, limp, "PASS" if passed else "FAIL"])
	driver.queue_free()
