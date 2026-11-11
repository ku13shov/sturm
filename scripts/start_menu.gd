class_name StartMenu
extends Control

const GAME_SCENE: String = "res://scenes/gameplay/graybox_vertical_slice.tscn"
const HELP_SCENE: String = "res://scenes/ui/help_pages.tscn"
const SAVE_PATH: String = "user://sturmtrupp_survival_save.json"
const SAVE_BACKUP_PATH: String = "user://sturmtrupp_survival_save.bak"

const DESIGN_SIZE: Vector2 = Vector2(432.0, 768.0)
const BUG_DIR: String = "res://assets/sprites/units/new_base_bug/"
## Дорожки жуков по земле неба: y линии земли, масштаб, скорость px/с, задержка выхода, яркость (дальние темнее).
const BUG_LANES: Array[Dictionary] = [
	{"y": 466.0, "scale": 0.19, "speed": 13.0, "x": 130.0, "tint": 0.5},
	{"y": 492.0, "scale": 0.23, "speed": 17.0, "x": 340.0, "tint": 0.56},
	{"y": 520.0, "scale": 0.27, "speed": 21.0, "x": 220.0, "tint": 0.62},
	{"y": 551.0, "scale": 0.32, "speed": 26.0, "x": 450.0, "tint": 0.7},
]
## Оттенок жуков: земля неба тёмная и красная, поэтому спрайты затемняются и теплеют.
const BUG_TINT: Color = Color(1.0, 0.72, 0.62)

@onready var world: Control = $World
@onready var ui: Control = $Ui
@onready var diorama: Node2D = $World/Diorama
@onready var continue_button: Button = $Ui/ContinueButton
@onready var continue_labels: Control = $Ui/ContinueButton/Labels
@onready var continue_sub: Label = $Ui/ContinueButton/Labels/Sub
@onready var version_label: Label = $Ui/VersionLabel


func _ready() -> void:
	$Ui/NewGameButton.pressed.connect(_start_new_game)
	continue_button.pressed.connect(_continue_game)
	$Ui/HelpButton.pressed.connect(_open_help)
	version_label.text = _version_text()
	resized.connect(_layout)
	_layout()
	_build_bugs()
	_refresh_continue_button()
	ui.modulate.a = 0.0
	var intro: Tween = create_tween()
	intro.tween_interval(0.15)
	intro.tween_property(ui, "modulate:a", 1.0, 0.7)

## Экран может быть выше или шире 432x768 (stretch aspect = expand): макет остаётся в центре,
## небо, грунт и затемнение продолжаются за его границами.
func _layout() -> void:
	var fit: float = minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	var origin: Vector2 = (size - DESIGN_SIZE * fit) * 0.5
	for stage: Control in [world, ui]:
		stage.scale = Vector2(fit, fit)
		stage.position = origin

func _build_bugs() -> void:
	var walk: Texture2D = load(BUG_DIR + "bug_sheet_5dir.webp") as Texture2D
	var walk_mask: Texture2D = load(BUG_DIR + "bug_sheet_5dir-mask.webp") as Texture2D
	if walk == null or walk_mask == null:
		return
	for lane: Dictionary in BUG_LANES:
		var bug: MenuBug = MenuBug.new()
		bug.walk_tex = walk
		bug.walk_mask = walk_mask
		bug.visual_scale = float(lane["scale"])
		bug.walk_speed = float(lane["speed"])
		bug.ground_y = float(lane["y"])
		bug.initial_x = float(lane["x"])
		var tint: float = float(lane["tint"])
		bug.body_tint = Color(BUG_TINT.r * tint, BUG_TINT.g * tint, BUG_TINT.b * tint, 1.0)
		diorama.add_child(bug)

func _version_text() -> String:
	var version: String = str(ProjectSettings.get_setting("application/config/version", ""))
	if version.is_empty():
		return "версия разработки"
	return "v%s" % version

func _bugs_text(count: int) -> String:
	var last_two: int = count % 100
	var last_one: int = count % 10
	var word: String = "жуков"
	if last_two < 11 or last_two > 14:
		if last_one == 1:
			word = "жук"
		elif last_one >= 2 and last_one <= 4:
			word = "жука"
	return "%d %s" % [count, word]

func _format_duration(seconds: float) -> String:
	var total: int = int(maxf(seconds, 0.0))
	var hours: int = floori(total / 3600.0)
	var minutes: int = floori((total % 3600) / 60.0)
	var secs: int = total % 60
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, secs]
	return "%d:%02d" % [minutes, secs]

func _refresh_continue_button() -> void:
	var save_data: Dictionary = _read_save(SAVE_PATH)
	if save_data.is_empty():
		save_data = _read_save(SAVE_BACKUP_PATH)
	continue_button.disabled = save_data.is_empty()
	if save_data.is_empty():
		continue_sub.text = "нет сохранения"
		continue_labels.modulate = Color(1.0, 1.0, 1.0, 0.4)
		return
	continue_labels.modulate = Color.WHITE
	var parts: PackedStringArray = PackedStringArray()
	var wave_value: Variant = save_data.get("wave_state", {})
	if wave_value is Dictionary:
		var wave_state: Dictionary = wave_value as Dictionary
		parts.append("атака %d" % int(wave_state.get("wave_number", 0)))
	var enemies_value: Variant = save_data.get("enemies", [])
	if enemies_value is Array:
		parts.append(_bugs_text((enemies_value as Array).size()))
	var time_value: Variant = save_data.get("play_time", 0.0)
	if (time_value is int or time_value is float) and float(time_value) >= 1.0:
		parts.append(_format_duration(float(time_value)))
	continue_sub.text = " • ".join(parts)

func _read_save(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parser: JSON = JSON.new()
	var parse_error: Error = parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK or not parser.data is Dictionary:
		return {}
	var data: Dictionary = parser.data as Dictionary
	var version: int = int(data.get("version", 1))
	if version < 1 or version > 2 or not (data.get("credits", 0) is int or data.get("credits", 0) is float):
		return {}
	if not data.get("buildings", []) is Array:
		return {}
	if version >= 2 and not data.get("enemies", []) is Array:
		return {}
	return data

func _start_new_game() -> void:
	get_tree().set_meta("sturmtrupp_continue_requested", false)
	get_tree().change_scene_to_file(GAME_SCENE)

func _continue_game() -> void:
	if continue_button.disabled:
		return
	get_tree().set_meta("sturmtrupp_continue_requested", true)
	get_tree().change_scene_to_file(GAME_SCENE)

func _open_help() -> void:
	get_tree().change_scene_to_file(HELP_SCENE)

## Жук для заставки: идёт справа к базе, бункер дает по нему залп, жук играет анимацию смерти и появляется снова.
## Листы и маски свечения те же, что в игре (320 px ячейка, строка W = идёт влево).
class MenuBug extends Node2D:
	enum State { WAIT, WALK }

	const ROW_W: int = 2
	const ROWS: int = 5
	const WALK_FRAMES: int = 25
	const FRAME_SIZE: float = 320.0
	const PIVOT_Y: float = 225.0
	const START_X: float = 490.0
	const END_X: float = -70.0
	const GLOW_COLOR: Color = Color(1.0, 0.541, 0.118)
	## Тень в меню: солнце низко над горизонтом справа и позади жуков, поэтому тень длинная, падает к зрителю (вниз)
	## и уходит от солнца: у жуков левее солнца клонится влево, у жуков под ним идёт почти вертикально.
	## SHADOW_LENGTH: длина тени вниз на единицу высоты жука (больше = длиннее, низкое солнце).
	## SUN_X: x солнца в координатах макета 432x768. SHADOW_LEAN_PER_PX: наклон на пиксель удаления от солнца по x.
	## SHADOW_LEAN_MIN/MAX: пределы наклона (минус = влево).
	const SHADOW_LENGTH: float = 0.6
	const SUN_X: float = 315.0
	const SHADOW_LEAN_PER_PX: float = 0.0012
	const SHADOW_LEAN_MIN: float = -0.3
	const SHADOW_LEAN_MAX: float = 0.06
	## Мягкость тени: у ног она чёткая и плотная, к вершине размывается и бледнеет.
	## SHADOW_ALPHA: плотность у ног. SHADOW_BLUR_NEAR/FAR: радиус размытия (px листа) у ног и на вершине.
	## SHADOW_FADE_HEIGHT: высота (px листа), на которой тень становится самой мягкой и бледной.
	const SHADOW_ALPHA: float = 0.5
	const SHADOW_BLUR_NEAR: float = 2.0
	const SHADOW_BLUR_FAR: float = 12.0
	const SHADOW_FADE_HEIGHT: float = 150.0
	const SHADOW_FADE_AMOUNT: float = 0.75
	const SHADOW_SHADER: String = """
shader_type canvas_item;
uniform vec4 shadow_color : source_color = vec4(0.05, 0.02, 0.012, 1.0);
uniform float opacity = 0.5;
uniform float fade_height = 150.0;
uniform float fade_amount = 0.75;
uniform float blur_near = 2.0;
uniform float blur_far = 12.0;
varying float height;
void vertex() {
	height = -VERTEX.y;
}
void fragment() {
	float t = clamp(height / fade_height, 0.0, 1.0);
	float r = mix(blur_near, blur_far, t);
	vec2 px = r / vec2(textureSize(TEXTURE, 0));
	float a = texture(TEXTURE, UV).a * 0.2;
	for (int i = 0; i < 8; i++) {
		float ang = float(i) * 0.785398;
		vec2 d = vec2(cos(ang), sin(ang));
		a += texture(TEXTURE, UV + d * px * 0.5).a * 0.05;
		a += texture(TEXTURE, UV + d * px).a * 0.05;
	}
	a *= opacity * (1.0 - fade_amount * t);
	COLOR = vec4(shadow_color.rgb, a);
}
"""
	## Длина шага: сколько пикселей листа жук проходит за один цикл из 25 кадров.
	## Если ноги всё ещё «скользят» по земле, подберите это значение (больше - жук идёт быстрее при той же анимации).
	const STRIDE_PX: float = 125.0
	## Неравномерность скорости внутри шага (0 = ровное скольжение, 0.35 = заметные толчки).
	const STEP_PULSE: float = 0.35
	## Сдвиг толчков относительно кадров анимации (доля цикла), подстройка под момент касания лап.
	const STEP_PULSE_OFFSET: float = 0.0
	## Покачивание корпуса: подскок в пикселях листа и наклон в градусах (дважды за цикл).
	const BOB_PX: float = 4.0
	const SWAY_DEG: float = 1.6
	## Остановки: как резко жук тормозит/разгоняется, длительность паузы и интервал между ними.
	const PACE_CHANGE: float = 2.2
	const PAUSE_TIME: Vector2 = Vector2(0.5, 1.3)
	const PAUSE_GAP: Vector2 = Vector2(3.0, 8.0)

	var walk_tex: Texture2D
	var walk_mask: Texture2D
	var visual_scale: float = 0.28
	var walk_speed: float = 24.0
	var ground_y: float = 540.0
	var initial_x: float = START_X
	var body_tint: Color = Color.WHITE

	var body: Sprite2D
	var shadow: Sprite2D
	var glow: Sprite2D
	var state: State = State.WAIT
	var timer: float = 0.0
	var walk_phase: float = 0.0
	var clock: float = 0.0
	var pace: float = 1.0
	var pause_left: float = 0.0
	var next_pause: float = 4.0

	func _ready() -> void:
		scale = Vector2.ONE * visual_scale
		position = Vector2(START_X, ground_y)
		clock = randf() * 3.0
		timer = 0.0
		# Тень по силуэту, как в игре: те же кадры листа, отражённые от линии земли по ShadowLight.
		shadow = _make_sprite()
		shadow.modulate = Color.WHITE
		var shadow_shader: Shader = Shader.new()
		shadow_shader.code = SHADOW_SHADER
		var shadow_material: ShaderMaterial = ShaderMaterial.new()
		shadow_material.shader = shadow_shader
		shadow_material.set_shader_parameter("shadow_color", ShadowLight.COLOR)
		shadow_material.set_shader_parameter("opacity", SHADOW_ALPHA)
		shadow_material.set_shader_parameter("fade_height", SHADOW_FADE_HEIGHT)
		shadow_material.set_shader_parameter("fade_amount", SHADOW_FADE_AMOUNT)
		shadow_material.set_shader_parameter("blur_near", SHADOW_BLUR_NEAR)
		shadow_material.set_shader_parameter("blur_far", SHADOW_BLUR_FAR)
		shadow.material = shadow_material
		_update_shadow()
		body = _make_sprite()
		glow = _make_sprite()
		var glow_material: CanvasItemMaterial = CanvasItemMaterial.new()
		glow_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		glow.material = glow_material
		body.modulate = body_tint
		_use_sheet()
		visible = false

	func _make_sprite() -> Sprite2D:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		sprite.offset = Vector2(0.0, FRAME_SIZE * 0.5 - PIVOT_Y)
		add_child(sprite)
		return sprite

	func _use_sheet() -> void:
		body.texture = walk_tex
		glow.texture = walk_mask
		shadow.texture = walk_tex
		for sprite: Sprite2D in [body, glow, shadow]:
			sprite.hframes = WALK_FRAMES
			sprite.vframes = ROWS
		_set_column(0)

	func _set_column(column: int) -> void:
		body.frame = ROW_W * body.hframes + column
		glow.frame = ROW_W * glow.hframes + column
		shadow.frame = ROW_W * shadow.hframes + column

	## Тень по силуэту: зеркало кадра от линии земли. Наклон зависит от положения жука относительно солнца.
	func _update_shadow() -> void:
		var lean: float = clampf((position.x - SUN_X) * SHADOW_LEAN_PER_PX, SHADOW_LEAN_MIN, SHADOW_LEAN_MAX)
		shadow.transform = Transform2D(Vector2.RIGHT, Vector2(-lean, -SHADOW_LENGTH), Vector2.ZERO)

	func _begin_walk() -> void:
		state = State.WALK
		position.x = initial_x
		initial_x = START_X
		walk_phase = randf()
		pace = 1.0
		pause_left = 0.0
		next_pause = randf_range(PAUSE_GAP.x * 0.4, PAUSE_GAP.y)
		visible = true

	func _process(delta: float) -> void:
		clock += delta
		if state == State.WAIT:
			timer -= delta
			if timer <= 0.0:
				_begin_walk()
			return
		_update_pace(delta)
		# Движение привязано к фазе шага: анимация и смещение идут от одной величины, поэтому лапы не скользят.
		var stride_screen: float = STRIDE_PX * visual_scale
		var cycles_per_second: float = walk_speed / stride_screen
		var phase_step: float = cycles_per_second * pace * delta
		var step_wave: float = TAU * 2.0 * (walk_phase + STEP_PULSE_OFFSET)
		var pulse: float = 1.0 + STEP_PULSE * sin(step_wave)
		position.x -= phase_step * stride_screen * pulse
		walk_phase = fposmod(walk_phase + phase_step, 1.0)
		_set_column(mini(int(walk_phase * WALK_FRAMES), WALK_FRAMES - 1))
		_update_shadow()
		# Корпус слегка подпрыгивает и покачивается в такт шагам (две опоры за цикл).
		var bob_wave: float = TAU * 2.0 * (walk_phase + STEP_PULSE_OFFSET)
		var bob_y: float = -absf(sin(bob_wave * 0.5)) * BOB_PX * pace
		var sway: float = sin(bob_wave) * deg_to_rad(SWAY_DEG) * pace
		for sprite: Sprite2D in [body, glow]:
			sprite.position.y = bob_y
			sprite.rotation = sway
		# Свечение приглушено: на тёмной земле неба яркие точки выглядят инородно.
		var glow_level: float = clampf(0.3 + sin(clock * TAU / 2.5) * 0.18, 0.0, 1.0)
		glow.modulate = Color(GLOW_COLOR.r, GLOW_COLOR.g, GLOW_COLOR.b, glow_level)
		if position.x <= END_X:
			state = State.WAIT
			timer = randf_range(2.0, 7.0)
			visible = false

	## Время от времени жук замедляется, замирает на секунду и снова идёт: живее, чем ровный ход.
	func _update_pace(delta: float) -> void:
		next_pause -= delta
		if next_pause <= 0.0 and pause_left <= 0.0:
			pause_left = randf_range(PAUSE_TIME.x, PAUSE_TIME.y)
			next_pause = randf_range(PAUSE_GAP.x, PAUSE_GAP.y) + pause_left
		var target: float = 1.0
		if pause_left > 0.0:
			target = 0.0
			pause_left = maxf(pause_left - delta, 0.0)
		pace = move_toward(pace, target, PACE_CHANGE * delta)
