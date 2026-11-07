class_name BunkerTower
extends Node2D
## Бункер (дот) 3 уровня башни солдат: три состояния корпуса по HP, четыре ствола в бойницах,
## стрельба со стороны жуков, мигающие полоски, замыкание, разрушение на заранее нарезанные осколки.
## Всё рисуется в кадре 384x244 (как тумба), узел _art масштабируется под клетку башни.

signal destroyed

enum State { ALIVE, SHORT, COLLAPSE, DEAD }

const DEFAULT_ART_DIR := "res://assets/sprites/units/soldiers/bunker/"
const ORIGIN := Vector2(192.0, 119.5)
const MUZZLE := Vector2(20.0, 12.0)
const FORWARD := Vector2(0.83, 0.56)
const GRAVITY := 380.0
## Точки стволов в кадре 384x244: [позиция дульного среза, сторона (-1 левая, 1 правая), глубина (1 ближняя стенка, -1 дальняя)].
## Первые четыре видны (ближние стенки). Дальние четыре стоят в бойницах задних стенок: те же точки,
## отражённые по Y относительно линии боковых углов бункера (BACK_MIRROR_Y). Их стволы закрыты корпусом,
## но вспышка и трассер идут оттуда. Если трассер дальнего ствола выходит не из края корпуса, поправь точки здесь.
const BACK_MIRROR_Y := 112.5
const GUNS: Array = [
	[Vector2(71.8, 136.0), -1, 1], [Vector2(108.1, 154.0), -1, 1],
	[Vector2(313.2, 135.7), 1, 1], [Vector2(277.3, 154.3), 1, 1],
	[Vector2(71.8, 2.0 * BACK_MIRROR_Y - 136.0), -1, -1], [Vector2(108.1, 2.0 * BACK_MIRROR_Y - 154.0), -1, -1],
	[Vector2(313.2, 2.0 * BACK_MIRROR_Y - 135.7), 1, -1], [Vector2(277.3, 2.0 * BACK_MIRROR_Y - 154.3), 1, -1],
]
## Стволы, которые ломаются на критическом состоянии (по два на сторону, ближний и дальний ряд).
const BROKEN_AT_CRIT: Array[int] = [0, 3, 4, 7]
const LIGHT_SPOTS: Array[Vector2] = [
	Vector2(34, 133), Vector2(152, 194), Vector2(232, 194), Vector2(349, 135),
	Vector2(101, 70), Vector2(193, 110), Vector2(283, 70),
]
## Дым из трещин: первые две точки с повреждённого состояния, остальные с критического.
const SMOKE_POINTS: Array[Vector2] = [
	Vector2(249, 115), Vector2(168, 156), Vector2(229, 56), Vector2(215, 83), Vector2(269, 105),
]
const APPEAR_DROP_TIME := 0.45
const APPEAR_DROP_HEIGHT := 160.0
const APPEAR_LAMP_START := 0.55
const APPEAR_LAMP_TIME := 0.4

@export_dir var art_dir := DEFAULT_ART_DIR
@export var idle_color := Color("#00e5ff")
@export var warn_color := Color("#ffbb00")
@export var crit_color := Color("#ff0000")
@export var pulse_speed := 1.0
@export var glow_strength := 2.0
## Множитель яркости полосок на повреждённом и критическом состоянии.
@export_range(0.0, 1.0) var damaged_brightness := 0.55
@export var short_time := 2.2
@export var scatter := 1.6
@export var dust_count := 70
@export var smoke_time := 4.0
## Сколько осколков остаётся лежать обломками.
@export_range(0, 20) var fragments_left := 8
@export var debris_seconds := 8.0
@export var detached_z_index := 0
## Растяжение бункера по высоте (1 = как у тумбы). Растягивает весь рисунок по вертикали вокруг центра.
@export_range(0.8, 1.6, 0.01) var height_stretch := 1.15: set = set_height_stretch
@export_group("Стволы")
## Откат ствола при выстреле, px кадра (4 px кадра = 1 px игры).
@export var recoil_px := 3.9
@export_range(0.0, 1.0) var flash_strength := 1.0
## Насколько ствол доворачивается к цели, радианы.
@export_range(0.0, 0.5) var gun_aim_limit := 0.15
## Жук ближе к оси, чем эта доля (по вертикали или горизонтали): стреляют стволы обеих соседних граней.
@export_range(0.0, 1.0) var both_sides_threshold := 0.25
@export_range(0.0, 0.3) var shot_delay_max := 0.08
@export var accent_color := Color(1.0, 0.6, 0.12)
@export_group("Трассер")
@export_range(1.0, 80.0) var tracer_length_px := 24.0
@export_range(100.0, 3000.0) var tracer_speed_px_per_s := 900.0
@export_range(0.01, 0.3) var tracer_min_duration := 0.06
@export_range(0.01, 0.3) var tracer_max_duration := 0.1
@export var debug_muzzle_points := false
@export_range(0.0, 1.0) var health_ratio := 1.0: set = set_health_ratio

class Gun extends RefCounted:
	var holder: Node2D
	var sprite: Sprite2D
	var flash: Sprite2D
	var tracer: Line2D
	var rest: Vector2
	var side: int = 1
	var depth: int = 1
	var fwd: Vector2 = Vector2.RIGHT
	var recoil: float = 0.0
	var fire: float = 0.0
	var phase: float = 0.0
	var aim: float = 0.0
	var tween: Tween

static var _soft: GradientTexture2D

var available := false
var free_when_done := false
var _state := State.ALIVE
var _stage := 0
var _t := 0.0
var _pt := 0.0
var _flash := 0.0
var _shake := 0.0
var _prev_a := 0.0
var _appear_t := -1.0
var _appear_off := Vector2.ZERO
var _lamp_k := 1.0
var _landed := false
var _has_target := false
var _aim_dir := Vector2.DOWN
var _active: Array[int] = [0, 1, 2, 3]
var _tex: Array[Texture2D] = []
var _mask: Array[Texture2D] = []
var _art: Node2D
var _back_layer: Node2D
var _base_scale := Vector2.ONE
var _body: Sprite2D
var _prev: Sprite2D
var _strip: Sprite2D
var _glow: Sprite2D
var _guns: Array[Gun] = []
var _smokers: Array[CPUParticles2D] = []
var _dust: CPUParticles2D
var _smoke: CPUParticles2D
var _spark_layer: Node2D
var _spark_list: Array[Dictionary] = []
var _hit_sparks: Array[Polygon2D] = []
var _hit_spark_index := 0
var _flash_mat: ShaderMaterial
var _add_mat: CanvasItemMaterial
var _shards: Array[Dictionary] = []


static func assets_available(dir: String = DEFAULT_ART_DIR) -> bool:
	for n: String in ["bunker_0", "bunker_0_m", "bunker_1", "bunker_1_m", "bunker_2", "bunker_2_m", "bunker_gun"]:
		if not ResourceLoader.exists(dir + n + ".webp"):
			return false
	return true


func _ready() -> void:
	available = assets_available(art_dir)
	if not available:
		push_warning("BunkerTower: нет текстур бункера в " + art_dir)
		return
	for i: int in 3:
		_tex.append(load("%sbunker_%d.webp" % [art_dir, i]) as Texture2D)
		_mask.append(load("%sbunker_%d_m.webp" % [art_dir, i]) as Texture2D)
	_add_mat = CanvasItemMaterial.new()
	_add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_flash_mat = ShaderMaterial.new()
	_flash_mat.shader = load("res://shaders/bunker_hit_flash.gdshader") as Shader
	_art = Node2D.new()
	_art.name = "Art"
	_art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	add_child(_art)
	_back_layer = Node2D.new()
	_back_layer.name = "BackGuns"
	_back_layer.z_index = -1
	_art.add_child(_back_layer)
	_body = _make_layer(_tex[0])
	_body.material = _flash_mat
	_prev = _make_layer(_tex[0])
	_prev.material = _flash_mat
	_prev.visible = false
	_strip = _make_layer(_mask[0])
	_glow = _make_layer(_mask[0])
	_glow.material = _add_mat
	for p: Vector2 in SMOKE_POINTS:
		var s: CPUParticles2D = _make_crack_smoke()
		s.position = p - ORIGIN
		_smokers.append(s)
	_dust = _make_puffs(false)
	_smoke = _make_puffs(true)
	_build_guns()
	_spark_layer = Node2D.new()
	_spark_layer.material = _add_mat
	_spark_layer.draw.connect(_draw_sparks)
	_art.add_child(_spark_layer)
	for i: int in 12:
		var sp: Polygon2D = Polygon2D.new()
		sp.polygon = PackedVector2Array([Vector2(-1.2, 0.0), Vector2(0.0, -2.5), Vector2(1.2, 0.0), Vector2(0.0, 2.5)])
		sp.z_index = 13
		sp.material = _add_mat
		sp.visible = false
		add_child(sp)
		_hit_sparks.append(sp)
	set_accent(accent_color)
	_apply_stage(true)


func _make_layer(t: Texture2D) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = t
	s.centered = false
	s.position = -ORIGIN
	_art.add_child(s)
	return s


func _build_guns() -> void:
	var gun_tex: Texture2D = load(art_dir + "bunker_gun.webp") as Texture2D
	for i: int in GUNS.size():
		var g := Gun.new()
		var side: int = GUNS[i][1]
		var depth: int = GUNS[i][2]
		g.side = side
		g.depth = depth
		g.fwd = Vector2(FORWARD.x * side, FORWARD.y * depth)
		g.rest = (GUNS[i][0] as Vector2) - ORIGIN
		g.phase = i * 1.7
		g.holder = Node2D.new()
		g.holder.position = g.rest
		g.holder.scale = Vector2(float(side), float(depth))
		if depth > 0:
			_art.add_child(g.holder)
		else:
			_back_layer.add_child(g.holder)
		g.sprite = Sprite2D.new()
		g.sprite.texture = gun_tex
		g.sprite.centered = false
		g.sprite.position = -MUZZLE
		g.sprite.material = _flash_mat
		g.holder.add_child(g.sprite)
		g.flash = Sprite2D.new()
		g.flash.texture = _soft_tex()
		g.flash.material = _add_mat
		g.flash.position = FORWARD * 3.0
		g.flash.scale = Vector2(0.55, 0.55)
		g.flash.visible = false
		g.holder.add_child(g.flash)
		g.tracer = Line2D.new()
		g.tracer.z_index = 12 if depth > 0 else -1
		g.tracer.width = 2.2
		g.tracer.antialiased = true
		g.tracer.material = _add_mat
		g.tracer.visible = false
		add_child(g.tracer)
		_guns.append(g)


static func _soft_tex() -> GradientTexture2D:
	if _soft == null:
		var gr := Gradient.new()
		gr.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
		_soft = GradientTexture2D.new()
		_soft.gradient = gr
		_soft.fill = GradientTexture2D.FILL_RADIAL
		_soft.fill_from = Vector2(0.5, 0.5)
		_soft.fill_to = Vector2(1.0, 0.5)
		_soft.width = 64
		_soft.height = 64
	return _soft


func _pk() -> float:
	return maxf(absf(_art.global_scale.x), 0.01)


func _make_puffs(smoke: bool) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	var c := Color(0.27, 0.27, 0.28) if smoke else Color(0.59, 0.59, 0.57)
	var a := 0.28 if smoke else 0.5
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 1.0])
	ramp.colors = PackedColorArray([Color(c, 0.0), Color(c, a), Color(c, 0.0)])
	var curve := Curve.new()
	curve.add_point(Vector2(0, 0.6))
	curve.add_point(Vector2(1, 1.7))
	p.texture = _soft_tex()
	p.color_ramp = ramp
	p.scale_amount_curve = curve
	p.direction = Vector2(0, -1)
	p.spread = 25.0 if smoke else 180.0
	p.initial_velocity_min = 8.0 if smoke else 4.0
	p.initial_velocity_max = 26.0 if smoke else 22.0
	p.gravity = Vector2.ZERO
	p.lifetime = 2.0
	p.lifetime_randomness = 0.5
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINTS
	var pts := PackedVector2Array()
	while pts.size() < 90:
		var x := randf_range(-190.0, 190.0)
		var y := randf_range(-105.0, 105.0)
		if absf(x) / 190.0 + absf(y) / 105.0 < 1.0:
			pts.append(Vector2(x, y + 10.0))
	p.emission_points = pts
	p.local_coords = true
	p.emitting = false
	if not smoke:
		p.one_shot = true
		p.explosiveness = 0.9
	_art.add_child(p)
	return p


func _make_crack_smoke() -> CPUParticles2D:
	var p := _make_puffs(true)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 6.0
	p.amount = 5
	return p


func _refresh_smoke() -> void:
	var pk := _pk()
	for i: int in _smokers.size():
		var need := 1 if i < 2 else 2
		var s: CPUParticles2D = _smokers[i]
		s.scale_amount_min = 0.12 / pk
		s.scale_amount_max = 0.22 / pk
		s.emitting = _stage >= need and _state == State.ALIVE


## Акцентный цвет вспышки выстрела и трассера (на улучшенной башне оранжевый).
func set_accent(color: Color) -> void:
	accent_color = color
	if _guns.is_empty():
		return
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([color.lerp(Color.WHITE, 0.75), Color(color.r, color.g, color.b, 0.0)])
	for g: Gun in _guns:
		g.tracer.gradient = gradient
		g.flash.modulate = Color(color.lerp(Color.WHITE, 0.4), 1.0)
	for sp: Polygon2D in _hit_sparks:
		sp.color = color.lerp(Color.WHITE, 0.6)


func set_art_scale(s: Vector2) -> void:
	_base_scale = s
	_apply_art_scale()


func set_height_stretch(v: float) -> void:
	height_stretch = maxf(v, 0.5)
	_apply_art_scale()


func _apply_art_scale() -> void:
	if is_instance_valid(_art):
		_art.scale = Vector2(_base_scale.x, _base_scale.y * height_stretch)


# ---------------- публичный API (как у SoldiersTower) ----------------

func set_health_ratio(v: float) -> void:
	health_ratio = clampf(v, 0.0, 1.0)
	if is_node_ready() and available:
		_apply_stage()


func set_health(current_health: float, maximum_health: float) -> void:
	if maximum_health > 0.0:
		health_ratio = current_health / maximum_health


## Бункер отвечает за грань, с которой идут жуки. Направление приводится к виду «сверху» (изометрическое
## сжатие по Y убирается), тогда четыре грани бункера это четыре экранные диагонали. Жук внизу слева: левые
## ближние стволы; вверху слева: левые дальние (их не видно, но трассер идёт оттуда); так же справа.
## Почти по оси (в пределах both_sides_threshold) стреляют стволы обеих соседних граней.
func set_target(world_pos: Vector2) -> void:
	var v := world_pos - global_position
	var l := v.length()
	if l < 1.0:
		return
	_has_target = true
	_aim_dir = v / l
	_active = _guns_for(Vector2(v.x, v.y * 2.0).normalized())


func _guns_for(u: Vector2) -> Array[int]:
	var t := both_sides_threshold
	var left := u.x < t
	var right := u.x > -t
	var front := u.y > -t
	var back := u.y < t
	var res: Array[int] = []
	for i: int in GUNS.size():
		var side: int = GUNS[i][1]
		var depth: int = GUNS[i][2]
		if (left if side < 0 else right) and (front if depth > 0 else back):
			res.append(i)
	return res


func play_shot(target_global_position: Vector2) -> void:
	if not available or _state != State.ALIVE or _appear_t >= 0.0:
		return
	set_target(target_global_position)
	var n := 0
	for idx: int in _active:
		if _is_broken(idx):
			continue
		var delay := randf_range(0.0, shot_delay_max) + n * 0.04
		n += 1
		get_tree().create_timer(delay).timeout.connect(_fire_gun.bind(idx, target_global_position), CONNECT_ONE_SHOT)


func on_hit() -> void:
	if _state != State.ALIVE:
		return
	_flash = 1.0
	_shake = 3.0


## Появление при апгрейде: бункер опускается сверху, потом выезжают стволы и загораются полоски.
func play_appear() -> void:
	if not available or _state != State.ALIVE:
		return
	_appear_t = 0.0
	_landed = false
	_animate_appear(0.0)


func destroy() -> void:
	if _state != State.ALIVE:
		return
	_state = State.SHORT
	_pt = 0.0
	_appear_t = -1.0
	_refresh_smoke()


## Переносит бункер в new_parent (башню можно сразу удалять) и запускает разрушение.
func detach_and_destroy(new_parent: Node) -> void:
	if not available or _state != State.ALIVE or not is_instance_valid(new_parent) or get_parent() == null:
		return
	var keep_transform: Transform2D = global_transform
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_transform = keep_transform
	z_as_relative = true
	z_index = detached_z_index
	free_when_done = true
	destroy()


# ---------------- внутренности ----------------

func _is_broken(i: int) -> bool:
	return _stage == 2 and BROKEN_AT_CRIT.has(i)


func _apply_stage(initial := false) -> void:
	var s := 0
	if health_ratio <= 0.25:
		s = 2
	elif health_ratio <= 0.6:
		s = 1
	if s == _stage and not initial:
		return
	var worse := s > _stage
	if not initial:
		_prev.texture = _body.texture
		_prev_a = 1.0
	_stage = s
	_body.texture = _tex[s]
	_strip.texture = _mask[s]
	_glow.texture = _mask[s]
	_refresh_smoke()
	if not initial and worse and _state == State.ALIVE:
		_shake = maxf(_shake, 3.0)
		_burst_dust(0.15)


func _burst_dust(k: float) -> void:
	var pk := _pk()
	_dust.scale_amount_min = 0.3 / pk
	_dust.scale_amount_max = 0.6 / pk
	_dust.amount = maxi(1, int(dust_count * k))
	_dust.restart()
	_dust.emitting = true


func _fire_gun(idx: int, target_global: Vector2) -> void:
	if _state != State.ALIVE or _is_broken(idx):
		return
	var g: Gun = _guns[idx]
	g.recoil = 1.0
	g.fire = 1.0
	var muzzle_local: Vector2 = to_local(g.holder.to_global(FORWARD * 3.0))
	var target_local: Vector2 = to_local(target_global)
	var travel := target_local - muzzle_local
	var distance := travel.length()
	if distance > 0.1:
		var dir := travel / distance
		var duration := clampf(distance / tracer_speed_px_per_s, tracer_min_duration, tracer_max_duration)
		if g.tween != null and g.tween.is_valid():
			g.tween.kill()
		g.tracer.points = PackedVector2Array([muzzle_local, muzzle_local])
		g.tracer.visible = true
		g.tween = create_tween()
		g.tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		g.tween.tween_method(_update_tracer.bind(g, muzzle_local, target_local, dir), 0.0, 1.0, duration)
		g.tween.tween_callback(func() -> void: g.tracer.visible = false)
	for k: int in 3:
		var sp: Polygon2D = _hit_sparks[_hit_spark_index]
		_hit_spark_index = (_hit_spark_index + 1) % _hit_sparks.size()
		sp.position = target_local
		sp.modulate = Color.WHITE
		sp.visible = true
		var dest := target_local + Vector2.from_angle(randf() * TAU) * randf_range(10.0, 20.0)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(sp, "position", dest, 0.15)
		tw.tween_property(sp, "modulate:a", 0.0, 0.15)
		tw.chain().tween_callback(func() -> void: sp.visible = false)


func _update_tracer(progress: float, g: Gun, from: Vector2, to: Vector2, dir: Vector2) -> void:
	var head := from.lerp(to, progress)
	g.tracer.points = PackedVector2Array([head - dir * tracer_length_px, head])


func _process(delta: float) -> void:
	if not available:
		return
	_t += delta
	_flash = maxf(0.0, _flash - delta * 3.0)
	_shake = maxf(0.0, _shake - delta * 14.0)
	_prev_a = maxf(0.0, _prev_a - delta * 3.0)
	_prev.visible = _prev_a > 0.0
	_prev.modulate.a = _prev_a
	_flash_mat.set_shader_parameter("hit_flash", clampf(_flash, 0.0, 1.0) * 0.55)
	_update_sparks(delta, _state == State.SHORT)
	match _state:
		State.ALIVE:
			_apply_lamp(_lamp_alive())
			if _appear_t >= 0.0:
				_animate_appear(delta)
			_update_guns(delta)
			_apply_shake()
		State.SHORT:
			_pt += delta
			_shake = 0.6
			_apply_lamp([crit_color, randf_range(0.4, 1.0) if randf() < 0.55 else 0.0])
			_update_guns(delta)
			_apply_shake()
			if _pt > short_time:
				_collapse()
		State.COLLAPSE:
			_pt += delta
			_animate_collapse()
			if _pt > 2.4:
				_state = State.DEAD
		State.DEAD:
			_pt += delta
			if debris_seconds > 0.0 and _pt > debris_seconds:
				modulate.a = clampf(1.0 - (_pt - debris_seconds) / 1.5, 0.0, 1.0)
				if _pt > debris_seconds + 1.5 and free_when_done:
					queue_free()
	if debug_muzzle_points:
		queue_redraw()


func _lamp_alive() -> Array:
	var sp := pulse_speed
	var c: Color
	var i: float
	if health_ratio > 0.6:
		c = idle_color
		i = 0.72 + 0.28 * sin(_t * 2.0 * sp)
	elif health_ratio > 0.25:
		c = warn_color
		i = 0.6 + 0.4 * sin(_t * 3.5 * sp)
	else:
		c = crit_color
		i = (0.2 if randf() < 0.12 else 1.0) if sin(_t * 8.0 * sp) > -0.2 else 0.15
	var level := minf(1.0, i + _flash)
	if health_ratio <= 0.6:
		level *= damaged_brightness
	return [c, level]


func _apply_lamp(l: Array) -> void:
	var c: Color = l[0]
	var i: float = float(l[1]) * _lamp_k
	_strip.visible = i > 0.0
	_glow.visible = i > 0.0
	_strip.modulate = Color(c, i)
	_glow.modulate = Color(c, minf(1.0, i * glow_strength * 0.8))


func _apply_shake() -> void:
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake + _appear_off
	_art.position = Vector2(off.x * _art.scale.x, off.y * _art.scale.y)


func _animate_appear(delta: float) -> void:
	_appear_t += delta
	var total := APPEAR_LAMP_START + APPEAR_LAMP_TIME
	if _appear_t > total:
		_appear_t = -1.0
		_appear_off = Vector2.ZERO
		_lamp_k = 1.0
		_art.modulate.a = 1.0
		return
	var u := clampf(_appear_t / APPEAR_DROP_TIME, 0.0, 1.0)
	var inv := 1.0 - u
	_appear_off = Vector2(0.0, -APPEAR_DROP_HEIGHT * inv * inv)
	_art.modulate.a = clampf(u * 3.0, 0.0, 1.0)
	if u >= 1.0 and not _landed:
		_landed = true
		_shake = maxf(_shake, 3.0)
		_burst_dust(0.5)
	_lamp_k = clampf((_appear_t - APPEAR_LAMP_START) / APPEAR_LAMP_TIME, 0.0, 1.0)


func _update_guns(delta: float) -> void:
	var lift := 1.0 - _lamp_k
	for i: int in _guns.size():
		var g: Gun = _guns[i]
		g.recoil = maxf(0.0, g.recoil - delta * 7.0)
		g.fire = maxf(0.0, g.fire - delta * 10.0)
		var broken := _is_broken(i)
		var sway := 0.0
		if not broken and _state == State.ALIVE:
			sway = sin(_t * 0.9 + g.phase) * 0.75
		g.holder.position = g.rest + g.fwd * (sway - g.recoil * recoil_px - lift * 6.0)
		var want := 0.0
		if broken:
			want = 0.12 * g.side
		elif _has_target and _active.has(i) and _state == State.ALIVE:
			want = clampf(angle_difference(g.fwd.angle(), _aim_dir.angle()), -gun_aim_limit, gun_aim_limit)
		g.aim = lerp_angle(g.aim, want, minf(1.0, delta * 6.0))
		g.holder.rotation = g.aim
		g.holder.modulate = Color(0.55, 0.55, 0.55, _lamp_k) if broken else Color(1.0, 1.0, 1.0, _lamp_k)
		g.flash.visible = g.fire > 0.0 and flash_strength > 0.0
		if g.flash.visible:
			g.flash.modulate.a = clampf(g.fire * flash_strength, 0.0, 1.0)


## Искры замыкания: стартуют на светящихся деталях, падают под гравитацией, белые, потом жёлтые.
func _update_sparks(delta: float, emit: bool) -> void:
	if emit:
		var want := delta * 90.0
		var count := int(want) + (1 if randf() < fmod(want, 1.0) else 0)
		for i: int in count:
			var from: Vector2 = LIGHT_SPOTS[randi() % LIGHT_SPOTS.size()] - ORIGIN + Vector2(randf_range(-6.0, 6.0), randf_range(-4.0, 4.0))
			_spark_list.append({
				"p": from,
				"v": Vector2(randf_range(-45.0, 45.0), -30.0 - randf() * 90.0),
				"l": 0.25 + randf() * 0.3,
				"a": 0.0,
			})
	for i: int in range(_spark_list.size() - 1, -1, -1):
		var s: Dictionary = _spark_list[i]
		s["a"] = float(s["a"]) + delta
		if float(s["a"]) > float(s["l"]):
			_spark_list.remove_at(i)
			continue
		var v: Vector2 = s["v"]
		s["p"] = (s["p"] as Vector2) + v * delta
		v.y += GRAVITY * delta
		s["v"] = v
	_spark_layer.queue_redraw()


func _draw_sparks() -> void:
	var w: float = 1.0 / _pk()
	for s: Dictionary in _spark_list:
		var p: Vector2 = s["p"]
		var v: Vector2 = s["v"]
		var col := Color.WHITE if float(s["a"]) < 0.12 else Color("#ffd25a")
		col.a = clampf((float(s["l"]) - float(s["a"])) / 0.1, 0.0, 1.0)
		_spark_layer.draw_line(p, p - v * 0.05, col, w)


func _collapse() -> void:
	_state = State.COLLAPSE
	_pt = 0.0
	_shake = 0.0
	_art.position = Vector2.ZERO
	_art.modulate.a = 1.0
	_body.visible = false
	_prev.visible = false
	_strip.visible = false
	_glow.visible = false
	for s: CPUParticles2D in _smokers:
		s.emitting = false
	_build_shards()
	for g: Gun in _guns:
		g.flash.visible = false
		g.holder.modulate = Color(0.8, 0.8, 0.8, 1.0)
		g.holder.rotation = 0.0
		g.holder.position = g.rest
	var pk := _pk()
	_burst_dust(1.0)
	_smoke.scale_amount_min = 0.2 / pk
	_smoke.scale_amount_max = 0.35 / pk
	if smoke_time > 0.0:
		_smoke.amount = maxi(1, int(smoke_time * 7.0))
		_smoke.emitting = true
		get_tree().create_timer(smoke_time).timeout.connect(func() -> void:
			if is_instance_valid(_smoke):
				_smoke.emitting = false)
	destroyed.emit()


func _build_shards() -> void:
	var order: Array[Dictionary] = []
	for entry: Array in BunkerShardData.SHARDS:
		var path: String = art_dir + BunkerShardData.SUBDIR + String(entry[0]) + ".webp"
		if not ResourceLoader.exists(path):
			continue
		var tex: Texture2D = load(path) as Texture2D
		var sp := Sprite2D.new()
		sp.texture = tex
		var rest: Vector2 = (entry[1] as Vector2) - ORIGIN + tex.get_size() * 0.5
		sp.position = rest
		_art.add_child(sp)
		_art.move_child(sp, _glow.get_index() + 1)
		order.append({"sp": sp, "rest": rest, "sort": rest.y + randf() * 54.0})
	order.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["sort"]) > float(b["sort"]))
	for i: int in order.size():
		var rest: Vector2 = order[i]["rest"]
		var dx := rest.x / 192.0
		var dy := rest.y / 117.0
		_shards.append({
			"sp": order[i]["sp"],
			"rest": rest,
			"keep": i < fragments_left,
			"d": randf() * 0.2,
			"vx": dx * 60.0 * scatter + randf_range(-30.0, 30.0),
			"vy": -70.0 * scatter * (0.5 + randf()) + dy * 25.0,
			"w": (randf() - 0.5) * 5.0 * scatter,
			"ang": (randf() - 0.5) * 0.3,
			"dy": 3.0 + randf() * 3.5,
			"dark": 0.5 + randf() * 0.15,
		})
	for g: Gun in _guns:
		g.recoil = 0.0
		g.holder.set_meta("fx", {
			"vx": g.rest.x / 192.0 * 80.0 * scatter + randf_range(-30.0, 30.0),
			"vy": -90.0 * scatter * (0.4 + randf()),
			"w": (randf() - 0.5) * 8.0,
			"d": randf() * 0.1,
		})


func _ease(x: float) -> float:
	return 1.0 - pow(1.0 - clampf(x, 0.0, 1.0), 3.0)


func _animate_collapse() -> void:
	for f: Dictionary in _shards:
		var sp: Sprite2D = f["sp"]
		var rest: Vector2 = f["rest"]
		var u := maxf(0.0, _pt - float(f["d"]))
		if f["keep"]:
			var e := _ease(u / 0.5)
			var k := 1.0 - float(f["dark"]) * e
			sp.position = rest + Vector2(0.0, float(f["dy"]) * e)
			sp.rotation = float(f["ang"]) * e
			sp.modulate = Color(k, k, k, 1.0)
		else:
			var al := 1.0 - clampf((u - 0.5) / 0.8, 0.0, 1.0)
			sp.position = rest + Vector2(float(f["vx"]) * u, float(f["vy"]) * u + 0.5 * GRAVITY * u * u)
			sp.rotation = float(f["w"]) * u
			sp.modulate = Color(1, 1, 1, al)
			sp.visible = al > 0.0
	for g: Gun in _guns:
		var f: Dictionary = g.holder.get_meta("fx", {})
		if f.is_empty():
			continue
		var u := maxf(0.0, _pt - float(f["d"]))
		var al := 1.0 - clampf((u - 0.6) / 0.9, 0.0, 1.0)
		g.holder.position = g.rest + Vector2(float(f["vx"]) * u, float(f["vy"]) * u + 0.5 * GRAVITY * u * u)
		g.holder.rotation = float(f["w"]) * u
		g.holder.modulate = Color(0.8, 0.8, 0.8, al)
		g.holder.visible = al > 0.0


func _draw() -> void:
	if not debug_muzzle_points or _guns.is_empty():
		return
	for g: Gun in _guns:
		draw_circle(to_local(g.holder.global_position), 2.5, Color(1.0, 0.05, 0.05, 1.0))
