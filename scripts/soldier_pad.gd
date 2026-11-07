@tool
class_name SoldierPad
extends Node2D
## Тумба солдата: мигающие полоски по HP, короткое замыкание, разваливание, пыль и дым.
## Начало координат узла = центр верхней плоскости тумбы (сюда ставь ноги солдата).

signal short_circuit_started
signal destroyed

enum State { ALIVE, SHORT, COLLAPSE, DEAD }

@export_dir var art_dir := "res://assets/sprites/units/soldiers/pad/"
@export var idle_color := Color("#00e5ff")
@export var warn_color := Color("#ffbb00")
@export var crit_color := Color("#ff0000")
@export var pulse_speed := 1.0
@export var glow_strength := 2.0
## Множитель яркости полосок (и свечения) в состояниях «ранен» и «критично». 1 = как в покое.
@export_range(0.0, 1.0) var damaged_brightness := 0.55
@export var short_time := 2.2
@export var scatter := 1.6
@export var dust_count := 55
@export var smoke_time := 3.0
@export_range(0, 4) var fragments_left := 3
@export var keep_center := false
## Удалять узел тумбы после разрушения (true для тумбы, оторванной от башни).
@export var free_when_done := false
## Сколько секунд после разрушения лежат обломки, потом плавно исчезают. 0 = лежат вечно.
@export var debris_seconds := 8.0
## Слой оторванной тумбы относительно нового родителя. Эффект смерти солдат лежит на 1, тумба должна быть ниже.
@export var detached_z_index := 0
@export_range(0.0, 1.0) var health_ratio := 1.0: set = set_health_ratio
@export_group("Барьеры 2-го уровня")
## Бетонные барьеры вокруг тумбы (только второй уровень башни). Текстуры лежат в art_dir/fort/.
@export var barriers_enabled := false: set = set_barriers
## Сколько кусков барьеров остаётся обломками после разрушения.
@export_range(0, 12) var barrier_fragments_left := 4
## Слой передних барьеров относительно тумбы (тумба лежит на -2, тело солдат на +1 от башни).
## Задние барьеры лежат на слое тумбы, под солдатами. 4 = башня+2: передние выше солдат, ниже жуков и вспышек.
@export var front_barrier_z := 4

const ORIGIN := Vector2(192, 109)
const GRAVITY := 380.0
# Обломки разрушенного куска барьера: цвета граней как в студии (верх/лево/право), затемнены на 20%.
const RUBBLE_TOP := Color8(142, 142, 138)
const RUBBLE_LEFT := Color8(108, 108, 105)
const RUBBLE_RIGHT := Color8(80, 80, 82)
## Смещение обломков вниз от центра куска, к его основанию (подбирается глазами).
const RUBBLE_BASE_Y := 25.0
# Появление барьеров при апгрейде (секунды / единицы узла тумбы).
const APPEAR_DELAY_STEP := 0.07
const APPEAR_DROP_TIME := 0.3
const APPEAR_DROP_HEIGHT := 90.0
const APPEAR_LAMP_START := 0.5
const APPEAR_LAMP_TIME := 0.3
# [имя файла, позиция левого верхнего угла в полном кадре 384x244], порядок = порядок отрисовки
const PARTS := [
	["pad_center", Vector2(39, 19)], ["pad_rail_bl", Vector2(27, 12)], ["pad_rail_br", Vector2(209, 13)],
	["pad_top", Vector2(163, 0)], ["pad_corner_l", Vector2(0, 93)], ["pad_corner_r", Vector2(343, 93)],
	["pad_face_l", Vector2(24, 119)], ["pad_face_r", Vector2(211, 120)], ["pad_front", Vector2(162, 197)],
]
const FACES := {"pad_face_l": ["pad_strip_l", "pad_glow_l"], "pad_face_r": ["pad_strip_r", "pad_glow_r"]}
const FRAGS := ["pad_front", "pad_rail_br", "pad_corner_l", "pad_rail_bl"]  # какие части остаются обломками

var _state := State.ALIVE
var _t := 0.0
var _pt := 0.0
var _flash := 0.0
var _shake := 0.0
var _sprites := {}
var _rest := {}
var _fx := {}
var _strips: Array[Sprite2D] = []
var _glows: Array[Sprite2D] = []
var _spark_list: Array[Dictionary] = []
var _spark_layer: Node2D
var _dust: CPUParticles2D
var _smoke: CPUParticles2D
var _add_mat: CanvasItemMaterial
var _back_layer: Node2D
var _front_layer: Node2D
var _barriers_built := false
var _barrier_pieces: Array[Dictionary] = []
var _barrier_tex := {}
var _appear_t := -1.0
var _appear_off := {}
var _shadow_layer: CanvasGroup
var _barrier_shadows := {}
var _shadow_ry := -1.0

# Линия основания куска в пикселях его текстуры: v = b0 + m * u (x = b0, y = m).
# Сняты по нижней кромке непрозрачных пикселей текстур fort_*; у столба (cap_r) основание горизонтальное.
const SHADOW_BASE := {
	"cap_r": Vector2(46.0, 0.0),
	"sec_l": Vector2(36.5, 0.63),
	"sec_r": Vector2(34.5, 0.65),
}


func _ready() -> void:
	var add_mat := CanvasItemMaterial.new()
	add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	for entry in PARTS:
		var n: String = entry[0]
		var s := _make_sprite(n)
		add_child(s)
		s.position = (entry[1] as Vector2) - ORIGIN + s.texture.get_size() / 2.0
		_sprites[n] = s
		_rest[n] = s.position
		if FACES.has(n):
			var ids: Array = FACES[n]
			var st := _make_sprite(ids[0])
			s.add_child(st)
			_strips.append(st)
			var gl := _make_sprite(ids[1])
			gl.material = add_mat
			s.add_child(gl)
			_glows.append(gl)
	_add_mat = add_mat
	# Тени барьеров по силуэту. CanvasGroup склеивает их в один слой и красит целиком,
	# поэтому там, где тени соседних кусков перекрываются, нет тёмных пятен.
	_shadow_layer = CanvasGroup.new()
	_shadow_layer.name = "BarrierShadows"
	_shadow_layer.modulate = Color(1.0, 1.0, 1.0, ShadowLight.ALPHA)
	_shadow_layer.visible = false
	add_child(_shadow_layer)
	_back_layer = Node2D.new()
	add_child(_back_layer)
	_front_layer = Node2D.new()
	_front_layer.z_index = front_barrier_z
	add_child(_front_layer)
	_dust = _make_puffs(false)
	_smoke = _make_puffs(true)
	_spark_layer = Node2D.new()
	_spark_layer.material = add_mat
	_spark_layer.draw.connect(_draw_sparks)
	add_child(_spark_layer)
	_apply_barriers()


func _make_sprite(n: String) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(art_dir + n + ".webp")
	return s


func _diamond_points(count: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	while pts.size() < count:
		var x := randf_range(-190.0, 190.0)
		var y := randf_range(-105.0, 105.0)
		if absf(x) / 190.0 + absf(y) / 105.0 < 1.0:
			pts.append(Vector2(x, y + 26.0))
	return pts


func _soft_tex() -> GradientTexture2D:
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 64
	t.height = 64
	return t


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
	p.scale_amount_min = 0.2 if smoke else 0.3
	p.scale_amount_max = 0.35 if smoke else 0.6
	p.direction = Vector2(0, -1)
	p.spread = 25.0 if smoke else 180.0
	p.initial_velocity_min = 8.0 if smoke else 4.0
	p.initial_velocity_max = 26.0 if smoke else 22.0
	p.gravity = Vector2.ZERO
	p.lifetime = 2.0
	p.lifetime_randomness = 0.5
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINTS
	p.emission_points = _diamond_points(90)
	p.local_coords = true
	p.emitting = false
	if not smoke:
		p.one_shot = true
		p.explosiveness = 0.9
	add_child(p)
	return p


## Искры замыкания, как в студии: стартуют на полосках, летят вверх с разбросом,
## падают под гравитацией, живут 0.25-0.55 с, сначала белые, потом жёлтые.
func _update_sparks(delta: float, emit: bool) -> void:
	if emit:
		var want := delta * 90.0
		var count := int(want) + (1 if randf() < fmod(want, 1.0) else 0)
		for i in count:
			var t := randf()
			var from := Vector2(58, 150).lerp(Vector2(105, 172), t) if randf() < 0.5 else Vector2(283, 172).lerp(Vector2(335, 148), t)
			_spark_list.append({
				"p": from - ORIGIN,
				"v": Vector2(randf_range(-45.0, 45.0), -30.0 - randf() * 90.0),
				"l": 0.25 + randf() * 0.3,
				"a": 0.0,
			})
	for i in range(_spark_list.size() - 1, -1, -1):
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
	var w: float = 1.0 / maxf(absf(global_scale.x), 0.01)  # толщина = 1 экранный пиксель
	for s in _spark_list:
		var p: Vector2 = s["p"]
		var v: Vector2 = s["v"]
		var col := Color.WHITE if float(s["a"]) < 0.12 else Color("#ffd25a")
		col.a = clampf((float(s["l"]) - float(s["a"])) / 0.1, 0.0, 1.0)
		_spark_layer.draw_line(p, p - v * 0.05, col, w)


# ---------------- публичный API ----------------

func set_health_ratio(v: float) -> void:
	health_ratio = clampf(v, 0.0, 1.0)
	_refresh_barrier_state()


## Включить/выключить барьеры второго уровня (при первом включении они создаются).
func set_barriers(on: bool) -> void:
	barriers_enabled = on
	if is_node_ready():
		_apply_barriers()


func _apply_barriers() -> void:
	if barriers_enabled and not _barriers_built:
		_build_barriers()
	_back_layer.visible = barriers_enabled
	_front_layer.visible = barriers_enabled
	_shadow_layer.visible = barriers_enabled and _state < State.COLLAPSE


## Анимация появления барьеров при апгрейде: куски по очереди опускаются сверху,
## потом по очереди загораются голубые полоски. Вызывать после включения барьеров.
func play_barrier_appear() -> void:
	if Engine.is_editor_hint() or not _barriers_built or _state != State.ALIVE:
		return
	_appear_t = 0.0
	for info: Dictionary in _barrier_pieces:
		info["landed"] = false
	_animate_barrier_appear(0.0)


func _reset_barrier_appear() -> void:
	_appear_t = -1.0
	_appear_off.clear()
	for info: Dictionary in _barrier_pieces:
		(_sprites[info["id"]] as Node2D).modulate = Color.WHITE
		(_barrier_shadows[info["id"]] as Node2D).modulate = Color.WHITE


## Вызывать после _apply_lamp: меняет смещение и прозрачность кусков и яркость их полосок.
func _animate_barrier_appear(delta: float) -> void:
	_appear_t += delta
	var total := APPEAR_DELAY_STEP * _barrier_pieces.size() + APPEAR_DROP_TIME + APPEAR_LAMP_START + APPEAR_LAMP_TIME
	if _appear_t > total:
		_reset_barrier_appear()
		return
	for i in _barrier_pieces.size():
		var info: Dictionary = _barrier_pieces[i]
		var id: String = info["id"]
		var holder: Node2D = _sprites[id]
		var u := clampf((_appear_t - i * APPEAR_DELAY_STEP) / APPEAR_DROP_TIME, 0.0, 1.0)
		var inv := 1.0 - u
		_appear_off[id] = Vector2(0.0, -APPEAR_DROP_HEIGHT * inv * inv)
		holder.modulate = Color(1, 1, 1, clampf(u * 3.0, 0.0, 1.0))
		if _barrier_shadows.has(id):
			(_barrier_shadows[id] as Node2D).modulate.a = clampf(u * 3.0, 0.0, 1.0)
		if u >= 1.0 and not info.get("landed", false):
			info["landed"] = true
			_shake = maxf(_shake, 1.5)
		var lamp_k := clampf((_appear_t - APPEAR_LAMP_START - i * APPEAR_DELAY_STEP) / APPEAR_LAMP_TIME, 0.0, 1.0)
		for k in ["strip", "glow"]:
			var s: Sprite2D = info[k]
			if s != null:
				s.modulate.a *= lamp_k


func _build_barriers() -> void:
	var dir := art_dir + SoldierPadBarrierData.ART_SUBDIR
	var tex := {}
	for kind in ["cap_r", "sec_l", "sec_r"]:
		for st in ["w", "d"]:
			var p := "%sfort_%s_%s.webp" % [dir, kind, st]
			if not ResourceLoader.exists(p):
				push_warning("SoldierPad: нет текстуры барьера " + p)
				return
			tex[kind + st] = load(p)
			var mp := "%sfort_%s_%s_m.webp" % [dir, kind, st]
			tex[kind + st + "m"] = load(mp) if ResourceLoader.exists(mp) else null
	_barrier_tex = tex
	_barriers_built = true
	for entry in SoldierPadBarrierData.PIECES:
		var id: String = entry[0]
		var kind: String = entry[1]
		var holder := Node2D.new()
		(_back_layer if entry[2] else _front_layer).add_child(holder)
		holder.position = entry[3]
		var body := Sprite2D.new()
		body.centered = false
		holder.add_child(body)
		var strip: Sprite2D = null
		var glow: Sprite2D = null
		if tex[kind + "wm"] != null:
			strip = Sprite2D.new()
			strip.centered = false
			body.add_child(strip)
			_strips.append(strip)
			glow = Sprite2D.new()
			glow.centered = false
			glow.material = _add_mat
			body.add_child(glow)
			_glows.append(glow)
		var rubble := _make_rubble()
		holder.add_child(rubble)
		var shadow_anchor := Node2D.new()
		shadow_anchor.name = "Shadow_" + id
		shadow_anchor.position = holder.position
		_shadow_layer.add_child(shadow_anchor)
		var shadow := Sprite2D.new()
		shadow.centered = false
		shadow.modulate = Color(ShadowLight.COLOR, 1.0)
		shadow_anchor.add_child(shadow)
		_barrier_shadows[id] = shadow_anchor
		_sprites[id] = holder
		_rest[id] = holder.position
		_barrier_pieces.append({"id": id, "kind": kind, "body": body, "strip": strip, "glow": glow, "rubble": rubble, "shadow": shadow, "entry": entry, "rank": randf(), "state": -1})
	_refresh_barrier_state(true)


## Три низких обломка на месте разрушенного куска (в студии: боксы 3-9 px высотой, тёмные).
func _make_rubble() -> Node2D:
	var root := Node2D.new()
	root.visible = false
	root.position = Vector2(0.0, RUBBLE_BASE_Y)
	for i in 3:
		var c := Node2D.new()
		c.position = Vector2(randf_range(-17.0, 17.0), randf_range(-8.0, 8.0))
		root.add_child(c)
		var w := randf_range(6.0, 13.0)
		var h := randf_range(3.0, 9.0)
		var half := w * 0.5
		var left := PackedVector2Array([Vector2(-half, 0), Vector2(0, half * 0.5), Vector2(0, half * 0.5 - h), Vector2(-half, -h)])
		var right := PackedVector2Array([Vector2(0, half * 0.5), Vector2(half, 0), Vector2(half, -h), Vector2(0, half * 0.5 - h)])
		var top := PackedVector2Array([Vector2(0, -h - half * 0.5), Vector2(half, -h), Vector2(0, -h + half * 0.5), Vector2(-half, -h)])
		for face in [[left, RUBBLE_LEFT], [right, RUBBLE_RIGHT], [top, RUBBLE_TOP]]:
			var poly := Polygon2D.new()
			poly.polygon = face[0]
			poly.color = face[1]
			c.add_child(poly)
	return root


## Этапы повреждения: при HP <= 60% часть кусков заменяется битыми вариантами, при <= 25% их больше.
func _refresh_barrier_state(initial := false) -> void:
	if not _barriers_built:
		return
	# Как в студии: <=60% часть кусков битая (rank < 0.4); <=25% куски с rank < 0.28 разрушены
	# (остаются низкие обломки), с rank < 0.75 битые, остальные целые. Ранги случайные у каждой тумбы.
	var stage := 0
	if health_ratio <= 0.25:
		stage = 2
	elif health_ratio <= 0.6:
		stage = 1
	var changed := false
	for info: Dictionary in _barrier_pieces:
		var r := float(info["rank"])
		var st := 0
		if stage == 1:
			st = 1 if r < 0.4 else 0
		elif stage == 2:
			st = 2 if r < 0.28 else (1 if r < 0.75 else 0)
		if st == int(info["state"]):
			continue
		info["state"] = st
		changed = true
		var e: Array = info["entry"]
		var key: String = String(info["kind"]) + ("d" if st == 1 else "w")
		var body: Sprite2D = info["body"]
		body.visible = st != 2
		(info["rubble"] as Node2D).visible = st == 2
		body.texture = _barrier_tex[key]
		body.transform = Transform2D(e[4], e[5], e[7] if st == 1 else e[6])
		_update_piece_shadow(info)
		var mask: Texture2D = _barrier_tex[key + "m"]
		for k in ["strip", "glow"]:
			var s: Sprite2D = info[k]
			if s != null:
				s.texture = mask
	if changed and not initial and _state == State.ALIVE:
		_shake = maxf(_shake, 3.0)


func _pad_ry() -> float:
	return scale.y / scale.x if absf(scale.x) > 0.0001 else 1.0


## Тень куска по силуэту: его же текстура, отражённая от линии основания на землю и сдвинутая
## по ShadowLight.DIR. Работает в координатах текстуры, поэтому не зависит от наклона куска и зеркала.
## Точка на высоте h над основанием (по вертикали экрана) уходит на землю в (u, v_основания) + c * h.
func _update_piece_shadow(info: Dictionary) -> void:
	var shadow: Sprite2D = info.get("shadow")
	if shadow == null:
		return
	var body: Sprite2D = info["body"]
	shadow.texture = body.texture
	shadow.visible = body.visible
	var ry := _pad_ry()
	_shadow_ry = ry
	var bx: Transform2D = body.transform
	var base: Vector2 = SHADOW_BASE[info["kind"]]
	# Экранная матрица куска без общего масштаба узла (он сокращается): x, y оси со сжатием плиты по Y.
	var screen_from_local := Transform2D(Vector2(bx.x.x, bx.x.y * ry), Vector2(bx.y.x, bx.y.y * ry), Vector2.ZERO)
	var screen_height_per_v := absf(bx.y.y * ry)
	var c: Vector2 = screen_from_local.affine_inverse().basis_xform(ShadowLight.DIR * screen_height_per_v)
	var m: float = base.y
	var b0: float = base.x
	var ground := Transform2D(
		Vector2(1.0 + c.x * m, m + c.y * m),
		Vector2(-c.x, -c.y),
		Vector2(c.x * b0, b0 + c.y * b0))
	shadow.transform = bx * ground


## Только визуал попадания (вспышка и дрожь), здоровье не трогает: им управляет башня.
func flash_hit() -> void:
	if _state != State.ALIVE:
		return
	_flash = 1.0
	_shake = 3.0


## Попадание со своим здоровьем: вспышка, дрожь, минус урон; при 0 запускается разрушение.
func hit(damage_ratio := 0.15) -> void:
	if _state != State.ALIVE:
		return
	_flash = 1.0
	_shake = 3.0
	if health_ratio - damage_ratio <= 0.0:
		health_ratio = 0.0
		destroy()
	else:
		health_ratio -= damage_ratio


## Запустить короткое замыкание, затем разваливание.
func destroy() -> void:
	if _state != State.ALIVE:
		return
	_state = State.SHORT
	_pt = 0.0
	_reset_barrier_appear()
	short_circuit_started.emit()


## Для башни: переносит тумбу в new_parent (башню можно сразу удалять), запускает
## разрушение, обломки потом сами исчезают.
func detach_and_destroy(new_parent: Node) -> void:
	if _state != State.ALIVE or not is_instance_valid(new_parent) or get_parent() == null:
		return
	var keep_transform: Transform2D = global_transform
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_transform = keep_transform
	z_as_relative = true
	z_index = detached_z_index
	_front_layer.z_index = 0
	free_when_done = true
	destroy()


func _global_z(node: Node) -> int:
	var total := 0
	var current: Node = node
	while current is CanvasItem:
		var item := current as CanvasItem
		total += item.z_index
		if not item.z_as_relative:
			break
		current = current.get_parent()
	return total


func reset() -> void:
	_state = State.ALIVE
	_pt = 0.0
	health_ratio = 1.0
	for n in _sprites:
		var s: Node2D = _sprites[n]
		s.position = _rest[n]
		s.rotation = 0.0
		s.modulate = Color.WHITE
		s.visible = true
	_spark_list.clear()
	_smoke.emitting = false
	_shadow_layer.visible = barriers_enabled


## Тумба получает финальный масштаб от башни уже после своего _ready, поэтому тени пересчитываются при смене сжатия по Y.
func _sync_shadow_scale() -> void:
	if not _barriers_built or is_equal_approx(_pad_ry(), _shadow_ry):
		return
	for info: Dictionary in _barrier_pieces:
		_update_piece_shadow(info)


# ---------------- внутренности ----------------

func _process(delta: float) -> void:
	_t += delta
	_sync_shadow_scale()
	if Engine.is_editor_hint():
		_apply_lamp(_lamp_alive())
		return
	_flash = maxf(0.0, _flash - delta * 3.0)
	_shake = maxf(0.0, _shake - delta * 14.0)
	_update_sparks(delta, _state == State.SHORT)
	match _state:
		State.ALIVE:
			_apply_lamp(_lamp_alive())
			if _appear_t >= 0.0:
				_animate_barrier_appear(delta)
			_apply_shake()
		State.SHORT:
			_pt += delta
			_shake = 0.6
			_apply_lamp([crit_color, randf_range(0.4, 1.0) if randf() < 0.55 else 0.0])
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
	var i: float = l[1]
	for s in _strips:
		s.visible = i > 0.0
		s.modulate = Color(c, i)
	for g in _glows:
		g.visible = i > 0.0
		g.modulate = Color(c, minf(1.0, i * glow_strength * 0.8))


func _apply_shake() -> void:
	var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake
	for n in _sprites:
		(_sprites[n] as Node2D).position = (_rest[n] as Vector2) + off + (_appear_off.get(n, Vector2.ZERO) as Vector2)
	for n in _barrier_shadows:
		(_barrier_shadows[n] as Node2D).position = (_rest[n] as Vector2) + off


func _collapse() -> void:
	_state = State.COLLAPSE
	_pt = 0.0
	_shake = 0.0
	_shadow_layer.visible = false
	for s in _strips:
		s.visible = false
	for g in _glows:
		g.visible = false
	var keep: Array = FRAGS.slice(0, fragments_left)
	if _barriers_built and barriers_enabled:
		var order: Array = _barrier_pieces.duplicate()
		order.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			var ad := int(a["state"]) == 2
			var bd := int(b["state"]) == 2
			if ad != bd:
				return bd
			return float(a["rank"]) < float(b["rank"]))
		for i in mini(barrier_fragments_left, order.size()):
			keep.append(order[i]["id"])
	for n in _sprites:
		var r: Vector2 = _rest[n]
		var dx := r.x / 190.0
		var dy := r.y / 110.0
		_fx[n] = {
			"keep": keep.has(n) or (n == "pad_center" and keep_center),
			"d": randf() * 0.18,
			"vx": dx * 60.0 * scatter + randf_range(-15.0, 15.0),
			"vy": -70.0 * scatter * (0.5 + randf()) + dy * 25.0,
			"w": (randf() - 0.5) * 5.0 * scatter,
			"ang": (randf() - 0.5) * 0.45,
			"dy": 2.0 + randf() * 3.0,
			"dark": 0.5 + randf() * 0.15,
		}
		(_sprites[n] as Node2D).position = r
	var pk: float = maxf(absf(global_scale.x), 0.01)
	_dust.scale_amount_min = 0.3 / pk
	_dust.scale_amount_max = 0.6 / pk
	_smoke.scale_amount_min = 0.2 / pk
	_smoke.scale_amount_max = 0.35 / pk
	_dust.amount = dust_count
	_dust.restart()
	_dust.emitting = dust_count > 0
	if smoke_time > 0.0:
		_smoke.amount = maxi(1, int(smoke_time * 7.0))
		_smoke.emitting = true
		get_tree().create_timer(smoke_time).timeout.connect(func(): _smoke.emitting = false)
	destroyed.emit()


func _ease(x: float) -> float:
	return 1.0 - pow(1.0 - clampf(x, 0.0, 1.0), 3.0)


func _animate_collapse() -> void:
	for n in _sprites:
		var s: Node2D = _sprites[n]
		var f: Dictionary = _fx[n]
		var rest: Vector2 = _rest[n]
		var u := maxf(0.0, _pt - float(f["d"]))
		if f["keep"]:
			var e := _ease(u / 0.5)
			var k := 1.0 - float(f["dark"]) * e
			s.position = rest + Vector2(0, float(f["dy"]) * e)
			s.rotation = 0.0 if n == "pad_center" else float(f["ang"]) * e
			s.modulate = Color(k, k, k, 1.0)
		else:
			var al := 1.0 - clampf((u - 0.5) / 0.8, 0.0, 1.0)
			s.position = rest + Vector2(float(f["vx"]) * u, float(f["vy"]) * u + 0.5 * GRAVITY * u * u)
			s.rotation = float(f["w"]) * u
			s.modulate = Color(1, 1, 1, al)
			s.visible = al > 0.0
