@tool
class_name SoldierSheetVisual
extends Node2D
## Листовой солдат нового образца. Покой (дыхание, 12 кадров) и выстрел (отдача, 8 кадров) берутся
## из листов студии, 5 видов (S, SE, E, NE, N); SW, W и NW получаются зеркалом SE, E и NE.
## Свечение лежит в отдельных листах-масках и рисуется аддитивно: яркость и пульсация считаются здесь,
## а не запекаются. Вспышка у дула рисуется кодом по формулам студии.
## Если листов нет, available == false, и Soldier остаётся со старым визуалом.

const FOLDER: String = "res://assets/sprites/units/soldiers/"
const IDLE_SHEET_PATH: String = FOLDER + "soldier_idle_5dir.webp"
const IDLE_MASK_PATH: String = FOLDER + "soldier_idle_5dir-mask.webp"
const SHOT_SHEET_PATH: String = FOLDER + "soldier_shot_5dir.webp"
const SHOT_MASK_PATH: String = FOLDER + "soldier_shot_5dir-mask.webp"

const GLOW_PULSE_PERIOD: float = 1.6
## Отдача руки в студийных px (поле «Отдача» студии), нужна, чтобы вспышка следовала за дулом.
const RECOIL_CANVAS_PX: float = SoldierSheetData.RECOIL_PX
const FLASH_DURATION: float = 0.1
const HIT_DURATION: float = 0.25
const HIT_SHAKE_CANVAS_PX: float = 3.5
const HIT_STRENGTH: float = 0.55
const HIT_SHADER: Shader = preload("res://shaders/soldier_hit_flash.gdshader")

## Яркость свечения (gi в студии).
@export_range(0.0, 2.0, 0.05) var glow_intensity: float = 1.15
## Глубина пульсации свечения (gp в студии).
@export_range(0.0, 1.0, 0.05) var glow_pulse: float = 0.75
## Высота старого солдата в px, к которой привязан масштаб башни (soldier_visual_height_px / 150).
@export var reference_height_px: float = 150.0
## Множитель размера вспышки у дула; 1.0 соответствует студии.
@export_range(0.5, 4.0, 0.1) var flash_size_multiplier: float = 1.0

static var _additive_material: CanvasItemMaterial
static var _flash_texture: GradientTexture2D

var available: bool = false
var body_sprite: Sprite2D
var glow_sprite: Sprite2D
var shadow_sprite: Sprite2D
var flash_layer: FlashLayer
var direction_index: int = 0
var row: int = 0
var flip: bool = false
var shot_time: float = -1.0
var glow_level: float = 0.0

var _idle_sheet: Texture2D
var _idle_mask: Texture2D
var _shot_sheet: Texture2D
var _shot_mask: Texture2D
var _shot_mode: bool = false
var _clock: float = 0.0
var _idle_phase: float = 0.0
var _glow_phase: float = 0.0
var _frame: int = -1
var _applied_row: int = -1
var _hit_time: float = -1.0
var _hit_material: ShaderMaterial
const GLOW_TINT_SHADER: Shader = preload("res://shaders/soldier_glow_tint.gdshader")
var _accent_on: bool = false
var _accent_color: Color = Color.WHITE
var _base_flash_multiplier: float = -1.0
var _accent_flash_texture: GradientTexture2D
var _tint_material: ShaderMaterial


## Перекрашивает свечение деталей и вспышку выстрела в accent и меняет размер вспышки.
## enabled = false возвращает цвета студии.
func set_accent(enabled: bool, color: Color = Color.WHITE, flash_multiplier: float = 1.0) -> void:
	if _base_flash_multiplier < 0.0:
		_base_flash_multiplier = flash_size_multiplier
	_accent_on = enabled
	_accent_color = color
	flash_size_multiplier = _base_flash_multiplier * (flash_multiplier if enabled else 1.0)
	if enabled:
		_accent_flash_texture = _make_flash_texture(color)
		if _tint_material == null:
			_tint_material = ShaderMaterial.new()
			_tint_material.shader = GLOW_TINT_SHADER
		_tint_material.set_shader_parameter("tint", color)
	if is_instance_valid(glow_sprite):
		var accent_material: Material = _tint_material
		var base_material: Material = _get_additive_material()
		glow_sprite.material = accent_material if enabled else base_material
	if is_instance_valid(flash_layer):
		flash_layer.queue_redraw()


static func _make_flash_texture(color: Color) -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.25, 0.6, 1.0])
	gradient.colors = PackedColorArray([
		Color(1.0, 1.0, 1.0, 1.0),
		color.lerp(Color.WHITE, 0.7),
		Color(color.r, color.g, color.b, 0.7),
		Color(color.r, color.g, color.b, 0.0),
	])
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 64
	texture.height = 64
	return texture

## Слой для вспышки: рисует её через draw_flash, чтобы z-порядок (позади N) задавался отдельно от спрайта.
class FlashLayer:
	extends Node2D
	var visual: SoldierSheetVisual

	func _draw() -> void:
		if visual != null:
			visual.draw_flash(self)

static func _get_additive_material() -> CanvasItemMaterial:
	if _additive_material == null:
		_additive_material = CanvasItemMaterial.new()
		_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _additive_material

static func _get_flash_texture() -> GradientTexture2D:
	if _flash_texture == null:
		# Цвета и позиции остановок как в студии (радиальный градиент вспышки при f = 1).
		var gradient: Gradient = Gradient.new()
		gradient.offsets = PackedFloat32Array([0.0, 0.25, 0.6, 1.0])
		gradient.colors = PackedColorArray([
			Color(1.0, 1.0, 1.0, 1.0),
			Color(200.0 / 255.0, 245.0 / 255.0, 1.0, 1.0),
			Color(90.0 / 255.0, 200.0 / 255.0, 1.0, 0.7),
			Color(90.0 / 255.0, 200.0 / 255.0, 1.0, 0.0),
		])
		_flash_texture = GradientTexture2D.new()
		_flash_texture.gradient = gradient
		_flash_texture.fill = GradientTexture2D.FILL_RADIAL
		_flash_texture.fill_from = Vector2(0.5, 0.5)
		_flash_texture.fill_to = Vector2(1.0, 0.5)
		_flash_texture.width = 64
		_flash_texture.height = 64
	return _flash_texture

static func _env(time_value: float, duration: float) -> float:
	var rise: float = 0.04
	if time_value < 0.0 or time_value > duration:
		return 0.0
	if time_value < rise:
		return time_value / rise
	return pow(1.0 - (time_value - rise) / (duration - rise), 2.0)

func _try_load(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_idle_sheet = _try_load(IDLE_SHEET_PATH)
	_idle_mask = _try_load(IDLE_MASK_PATH)
	_shot_sheet = _try_load(SHOT_SHEET_PATH)
	_shot_mask = _try_load(SHOT_MASK_PATH)
	if _idle_sheet == null or _idle_mask == null or _shot_sheet == null or _shot_mask == null:
		push_warning("SoldierSheetVisual: нет листов в %s, используется старый солдат." % FOLDER)
		available = false
		set_process(false)
		return
	available = true
	body_sprite = Sprite2D.new()
	body_sprite.name = "SheetBody"
	body_sprite.centered = false
	body_sprite.offset = -SoldierSheetData.PIVOT
	body_sprite.z_index = 1
	body_sprite.vframes = 5
	add_child(body_sprite)
	# Тень по силуэту: тот же кадр, зеркало от ступней со сдвигом по ShadowLight.DIR.
	# z -1: над плитой и задними барьерами, под телом солдата и передними барьерами.
	shadow_sprite = Sprite2D.new()
	shadow_sprite.name = "SheetShadow"
	shadow_sprite.centered = false
	shadow_sprite.offset = -SoldierSheetData.PIVOT
	shadow_sprite.z_index = -1
	shadow_sprite.vframes = 5
	shadow_sprite.transform = ShadowLight.ground_basis()
	shadow_sprite.modulate = Color(ShadowLight.COLOR, ShadowLight.ALPHA)
	add_child(shadow_sprite)
	glow_sprite = Sprite2D.new()
	glow_sprite.name = "SheetGlow"
	glow_sprite.centered = false
	glow_sprite.offset = -SoldierSheetData.PIVOT
	glow_sprite.z_index = 1
	glow_sprite.vframes = 5
	glow_sprite.material = _get_additive_material()
	add_child(glow_sprite)
	if _accent_on:
		set_accent(true, _accent_color, flash_size_multiplier / maxf(_base_flash_multiplier, 0.01))
	flash_layer = FlashLayer.new()
	flash_layer.name = "SheetFlash"
	flash_layer.visual = self
	flash_layer.material = _get_additive_material()
	add_child(flash_layer)
	_idle_phase = randf() * SoldierSheetData.IDLE_PERIOD
	_glow_phase = randf() * GLOW_PULSE_PERIOD
	_set_mode(false)
	set_direction(direction_index)
	_update_frame()
	_update_glow()

## Масштаб привязан к старому интерфейсу: value = sprite_scale солдата (soldier_visual_height_px / 150).
func set_unit_scale(value: float) -> void:
	var factor: float = value * reference_height_px / SoldierSheetData.VISIBLE_HEIGHT_PX
	scale = Vector2.ONE * factor

func set_direction(index: int) -> void:
	direction_index = posmod(index, SoldierSheetData.ROW_OF_DIRECTION.size())
	row = SoldierSheetData.ROW_OF_DIRECTION[direction_index]
	flip = SoldierSheetData.FLIP_OF_DIRECTION[direction_index]
	if not available:
		return
	body_sprite.flip_h = flip
	glow_sprite.flip_h = flip
	shadow_sprite.flip_h = flip
	# Вспышка позади корпуса только у вида N (флаг behind в данных студии), иначе поверх.
	flash_layer.z_index = 0 if is_behind() else 13
	_update_frame()

func is_behind() -> bool:
	return bool(SoldierSheetData.VIEWS[row]["behind"])

func _set_mode(shooting: bool) -> void:
	_shot_mode = shooting
	body_sprite.texture = _shot_sheet if shooting else _idle_sheet
	glow_sprite.texture = _shot_mask if shooting else _idle_mask
	var columns: int = SoldierSheetData.SHOT_FRAMES if shooting else SoldierSheetData.IDLE_FRAMES
	body_sprite.hframes = columns
	glow_sprite.hframes = columns
	shadow_sprite.texture = body_sprite.texture
	shadow_sprite.hframes = columns
	_frame = -1

## Запускает кадры отдачи; вспышка у дула рисуется параллельно.
func play_shot() -> void:
	if not available:
		return
	shot_time = 0.0
	if not _shot_mode:
		_set_mode(true)
	_frame = -1
	flash_layer.queue_redraw()

func on_hit() -> void:
	if not available:
		return
	if _hit_material == null:
		_hit_material = ShaderMaterial.new()
		_hit_material.shader = HIT_SHADER
	_hit_time = 0.0
	body_sprite.material = _hit_material

func _process(delta: float) -> void:
	_clock += delta
	if shot_time >= 0.0:
		shot_time += delta
		if shot_time >= SoldierSheetData.SHOT_DURATION:
			shot_time = -1.0
			_set_mode(false)
			flash_layer.queue_redraw()
		elif shot_time <= FLASH_DURATION + 0.05:
			flash_layer.queue_redraw()
	_update_frame()
	_update_glow()
	_update_hit(delta)

func _update_frame() -> void:
	if not available:
		return
	var frame_value: int
	if shot_time >= 0.0:
		var last: int = SoldierSheetData.SHOT_FRAMES - 1
		frame_value = clampi(roundi(shot_time / SoldierSheetData.SHOT_DURATION * float(last)), 0, last)
	else:
		var progress: float = fposmod(_clock + _idle_phase, SoldierSheetData.IDLE_PERIOD) / SoldierSheetData.IDLE_PERIOD
		frame_value = mini(int(progress * float(SoldierSheetData.IDLE_FRAMES)), SoldierSheetData.IDLE_FRAMES - 1)
	if frame_value == _frame and row == _applied_row:
		return
	_frame = frame_value
	_applied_row = row
	var coords: Vector2i = Vector2i(frame_value, row)
	body_sprite.frame_coords = coords
	glow_sprite.frame_coords = coords
	shadow_sprite.frame_coords = coords

func _update_glow() -> void:
	var pulse: float = 1.0 - glow_pulse + glow_pulse * (0.5 + 0.5 * sin(TAU * (_clock + _glow_phase) / GLOW_PULSE_PERIOD))
	var shot_boost: float = _env(shot_time, SoldierSheetData.SHOT_DURATION) if shot_time >= 0.0 else 0.0
	glow_level = minf(1.0, glow_intensity * (pulse * 0.6 + shot_boost * 0.5))
	glow_sprite.modulate = Color(1.0, 1.0, 1.0, glow_level)

func _update_hit(delta: float) -> void:
	if _hit_time < 0.0:
		return
	_hit_time += delta
	var envelope: float = _env(_hit_time, HIT_DURATION)
	if _hit_time >= HIT_DURATION:
		_hit_time = -1.0
		body_sprite.material = null
		body_sprite.position.x = 0.0
		glow_sprite.position.x = 0.0
		return
	_hit_material.set_shader_parameter("hit_flash", clampf(HIT_STRENGTH * envelope, 0.0, 1.0))
	var shake: float = HIT_SHAKE_CANVAS_PX * envelope * sin(_hit_time * 90.0) * SoldierSheetData.SHEET_SCALE
	body_sprite.position.x = shake
	glow_sprite.position.x = shake

## Точка дула в px листа относительно точки опоры (ступни), с учётом зеркала и текущей отдачи.
func _muzzle_sheet_px() -> Vector2:
	var view: Dictionary = SoldierSheetData.VIEWS[row]
	var angle: float = deg_to_rad(float(view["an"]))
	var recoil: float = _env(shot_time, SoldierSheetData.SHOT_DURATION) if shot_time >= 0.0 else 0.0
	var recoil_offset: Vector2 = Vector2(-cos(angle), -sin(angle)) * RECOIL_CANVAS_PX * recoil
	var relative: Vector2 = (view["muzzle"] as Vector2) + (view["arms_shift"] as Vector2) + recoil_offset - (view["anchor"] as Vector2)
	relative *= SoldierSheetData.SHEET_SCALE
	if flip:
		relative.x = -relative.x
	return relative

## Точка дула в локальных координатах родителя (Soldier).
func get_muzzle_local() -> Vector2:
	return position + _muzzle_sheet_px() * scale.x

func draw_flash(canvas: CanvasItem) -> void:
	if shot_time < 0.0:
		return
	var intensity: float = _env(shot_time, FLASH_DURATION)
	if intensity <= 0.0:
		return
	var view: Dictionary = SoldierSheetData.VIEWS[row]
	var unit: float = SoldierSheetData.SHEET_SCALE * flash_size_multiplier
	var center: Vector2 = _muzzle_sheet_px()
	var radius: float = (44.0 * intensity + 10.0) * unit
	canvas.draw_texture_rect(_accent_flash_texture if _accent_on else _get_flash_texture(), Rect2(center - Vector2(radius, radius), Vector2(radius, radius) * 2.0), false, Color(1.0, 1.0, 1.0, intensity))
	var angle: float = deg_to_rad(float(view["an"]))
	if flip:
		angle = PI - angle
	var ray_length: float = 70.0 * intensity * unit
	var half_width: float = (4.0 * intensity + 1.0) * unit
	canvas.draw_set_transform(center, angle, Vector2.ONE)
	var head_color: Color = Color(1.0, 1.0, 1.0, intensity)
	var tail_color: Color = Color(_accent_color.r, _accent_color.g, _accent_color.b, 0.0) if _accent_on else Color(120.0 / 255.0, 220.0 / 255.0, 1.0, 0.0)
	canvas.draw_polygon(
		PackedVector2Array([Vector2(0.0, -half_width), Vector2(ray_length, -half_width), Vector2(ray_length, half_width), Vector2(0.0, half_width)]),
		PackedColorArray([head_color, tail_color, tail_color, head_color])
	)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

## Смерть кодом: слои разлетаются в родителе башни (башню можно сразу удалять).
func spawn_death_fx(parent: Node) -> void:
	if not available or not is_instance_valid(parent):
		return
	SoldierDeathFx.spawn(parent, global_position, row, flip, absf(global_scale.x), glow_level)
