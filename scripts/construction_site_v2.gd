class_name ConstructionSiteV2
extends Node2D
## Площадка стройки и модернизации (порт «Студия_площадки_v2.html»).
## Один ассет (короб со стенами, столбами и краном внутри) на время работ заменяет здание.
## Координаты внутри = px спрайта базы 1254x1254; масштаб узла = ширина здания / 1010.
## Настройки: res://data/construction_site_config.json, арт: res://assets/fx/site/*.webp.
## Если чего-то нет, is_available() = false и игра рисует стройку по-старому.
##
## setup(footprint, duration, is_upgrade, chevrons); каждый кадр set_progress(0..1) возвращает
## «видимость здания» 0..1 (вызывающий код проявляет настоящее здание этим числом); finish() убирает площадку.

const CONFIG_PATH: String = "res://data/construction_site_config.json"
const ART_DIR: String = "res://assets/fx/site/"
const ART_KEYS: Array[String] = ["base", "front", "floor", "turret", "boom", "hook", "tank", "crate1", "crate2"]
const RD: float = PI / 180.0
const KIND_MAIN: int = 0
const KIND_ADD: int = 1

static var _loaded: bool = false
static var _ok: bool = false
static var _cfg: Dictionary = {}
static var _tex: Dictionary = {}
static var _soft: Texture2D = null
static var _glow_tex: Texture2D = null

class _Layer extends Node2D:
	var site: ConstructionSiteV2
	var kind: int = 0
	func _draw() -> void:
		if site != null:
			site._draw_layer(self, kind)

# --- настройки (из конфига) ---
var _is_upgrade: bool = false
var _chevrons: int = 2
var _dur: float = 5.0
var _t_intro: float = 0.5
var _t_level: float = 0.0
var _t_fin: float = 0.5
var _g: float = 10.5
var _col: Color = Color("#ff8a1f")
var _foot: Vector2 = Vector2(630.0, 790.0)
var _foot_r: Vector2 = Vector2(505.0, 250.0)
var _floor_c: Vector2 = Vector2(630.0, 765.0)
var _lamps: Array[Vector2] = []
var _lamp_r: float = 150.0
var _lamp_dome: float = 34.0
var _ps: float = 0.8
var _tl: Dictionary = {}
var _pin_off: Vector2 = Vector2(95.0, 52.0)
var _pivot: Vector2 = Vector2(37.0, 42.0)
var _tip_nat: Vector2 = Vector2(357.0, 223.0)
var _tip_pt: Vector2 = Vector2(608.0, 444.0)
var _welds: Array[Vector2] = []
var _hook_s: float = 0.54
var _hook_attach: Vector2 = Vector2(0.0, 22.0)
var _cab: float = 108.0
var _luff: float = 7.5
var _hoist: float = 41.0
var _sparks: float = 60.0
var _spark_size: float = 0.7
var _steam: float = 10.0
var _glow_k: float = 1.1
var _pulse_hz: float = 4.0
var _shadow_a: float = 0.38
var _show_bar: bool = true
var _bar_y: float = 1110.0
var _bar_w: float = 640.0
var _arcs: bool = true
var _beam: bool = false
var _chase: bool = false
var _chev_poly: PackedVector2Array = PackedVector2Array()
var _chev_y: float = 215.0
var _chev_step: float = 72.0
var _pop_from: float = 0.92

# --- состояние ---
var _p: float = 0.0
var _t: float = 0.0
var _flash: float = 0.0
var _wt: float = 0.0
var _a: float = 0.0
var _pop: float = 1.0
var _intro: float = 0.0
var _fin: float = 0.0
var _lev: float = 0.0
var _bld: float = 0.0
var _finished: bool = false
var _dust: Array[Dictionary] = []
var _spk: Array[Dictionary] = []
var _glows: Array[Dictionary] = []
var _main: _Layer
var _add: _Layer

static func is_available() -> bool:
	if _loaded:
		return _ok
	_loaded = true
	_ok = false
	if not FileAccess.file_exists(CONFIG_PATH):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not (parsed is Dictionary):
		return false
	_cfg = parsed
	var assets: Dictionary = _cfg.get("assets", {})
	for key: String in ART_KEYS:
		var entry: Dictionary = assets.get(key, {})
		var fname: String = String(entry.get("file", ""))
		if fname.is_empty():
			return false
		var path: String = ART_DIR + fname
		if not ResourceLoader.exists(path):
			return false
		var tex: Texture2D = load(path) as Texture2D
		if tex == null:
			return false
		_tex[key] = _with_mipmaps(tex)
	_soft = _make_radial([0.0, 1.0], [1.0, 0.0])
	_glow_tex = _make_radial([0.0, 0.35, 1.0], [1.0, 0.45, 0.0])
	_ok = true
	return true

static func _with_mipmaps(tex: Texture2D) -> Texture2D:
	var img: Image = tex.get_image()
	if img == null or img.is_compressed():
		return tex
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)

static func _make_radial(offsets: Array, alphas: Array) -> Texture2D:
	var gr: Gradient = Gradient.new()
	gr.offsets = PackedFloat32Array(offsets)
	var cols: PackedColorArray = PackedColorArray()
	for al: float in alphas:
		cols.append(Color(1.0, 1.0, 1.0, al))
	gr.colors = cols
	var t: GradientTexture2D = GradientTexture2D.new()
	t.gradient = gr
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 128
	t.height = 128
	return t

static func _v(a: Variant, fallback: Vector2) -> Vector2:
	if a is Array and (a as Array).size() >= 2:
		return Vector2(float((a as Array)[0]), float((a as Array)[1]))
	return fallback

static func _vs(a: Variant) -> Array[Vector2]:
	var out: Array[Vector2] = []
	if a is Array:
		for item: Variant in (a as Array):
			out.append(_v(item, Vector2.ZERO))
	return out

static func _num(d: Dictionary, key: String, fallback: float) -> float:
	return float(d.get(key, fallback))

static func _seg(v: float, a: float, b: float) -> float:
	if b <= a:
		return 1.0 if v >= b else 0.0
	return clampf((v - a) / (b - a), 0.0, 1.0)

static func _ease(x: float) -> float:
	return 1.0 - pow(1.0 - x, 3.0)

static func _xf_move(pos: Vector2) -> Transform2D:
	return Transform2D(0.0, pos)

static func _xf_rot(angle: float) -> Transform2D:
	return Transform2D(angle, Vector2.ZERO)

static func _xf_scale(sx: float, sy: float) -> Transform2D:
	return Transform2D(Vector2(sx, 0.0), Vector2(0.0, sy), Vector2.ZERO)

func setup(footprint: int, duration: float, is_upgrade: bool = false, chevrons: int = 2) -> void:
	name = "ConstructionSite"
	_is_upgrade = is_upgrade
	_chevrons = clampi(chevrons, 1, 4)
	var site: Dictionary = _cfg.get("site", {})
	var widths: Dictionary = site.get("building_width_by_footprint", {})
	var bw: float = float(widths.get(str(clampi(footprint, 1, 3)), 96.0))
	var fp_w: float = _num(site, "footprint_width_px", 1010.0)
	var k: float = bw / fp_w
	scale = Vector2(k, k)
	_g = fp_w / bw
	_foot = _v(site.get("footprint_center"), _foot)
	# Совмещаем центр основания площадки с началом координат здания (иначе арт сдвинут на _foot * k).
	# Ручная подстройка в игровых px по размеру footprint: site.offset_game_px {"1": [x, y], "2": [x, y]}.
	var fp_key: String = str(clampi(footprint, 1, 3))
	var offsets: Dictionary = site.get("offset_game_px", {})
	position = -_foot * k + _v(offsets.get(fp_key), Vector2.ZERO)
	_foot_r = _v(site.get("footprint_rx_ry"), _foot_r)
	var lay: Dictionary = _cfg.get("layout", {})
	var fd: Dictionary = lay.get("floor_diamond", {})
	_floor_c = Vector2(_num(fd, "x", 630.0), _num(fd, "y", 765.0))
	_lamps = _vs(lay.get("lamp_domes", []))
	_lamp_r = _num(lay, "lamp_glow_radius", 150.0)
	_lamp_dome = _num(lay, "lamp_dome_px", 34.0)
	_ps = _num(lay, "prop_scale", 0.8)
	_tl = {
		"tur": _v(lay.get("turret_topleft"), Vector2(353.0, 544.0)),
		"tank": _v(lay.get("tank_topleft"), Vector2(720.0, 440.0)),
		"c1": _v(lay.get("crate1_topleft"), Vector2(719.0, 594.0)),
		"c2": _v(lay.get("crate2_topleft"), Vector2(636.0, 517.0)),
	}
	_pin_off = _v(lay.get("turret_pin_px"), _pin_off)
	_pivot = _v(lay.get("boom_pivot_px"), _pivot)
	_tip_nat = _v(lay.get("boom_tip_px"), _tip_nat)
	_tip_pt = _v(lay.get("tip_point"), _tip_nat)
	_welds = _vs(lay.get("weld_spots", []))
	_hook_s = _num(lay, "hook_scale", 0.54)
	_hook_attach = _v(lay.get("hook_cable_attach_offset"), _hook_attach)
	_cab = _num(lay, "cable_base_px", 108.0)
	_shadow_a = _num(lay, "shadow_alpha", 0.38)
	_bar_y = _num(lay, "bar_y", 1110.0)
	_bar_w = _num(lay, "bar_width", 640.0)
	var pop: Dictionary = lay.get("pop", {})
	_pop_from = _num(pop, "from", 0.92)
	var fx: Dictionary = _cfg.get("fx", {})
	_luff = _num(fx, "luff_deg", 7.5)
	_hoist = _num(fx, "hoist_px", 41.0)
	_sparks = _num(fx, "sparks_count", 60.0)
	_spark_size = _num(fx, "spark_size", 0.7)
	_steam = _num(fx, "steam_per_s", 10.0)
	_glow_k = _num(fx, "glow", 1.1)
	_pulse_hz = _num(fx, "lamp_pulse_hz", 4.0)
	_show_bar = bool(fx.get("show_bar", true))
	var mode: Dictionary = _cfg.get("upgrade" if is_upgrade else "build", {})
	_col = Color(String(mode.get("color", "#2bd3ee" if is_upgrade else "#ff8a1f")))
	var fixed: Dictionary = mode.get("fixed_s", {})
	var ti: float = _num(fixed, "intro", 0.4 if is_upgrade else 0.5)
	var tl: float = _num(fixed, "level", 0.65) if is_upgrade else 0.0
	var tf: float = _num(fixed, "finale", 0.4 if is_upgrade else 0.5)
	_dur = maxf(duration, 0.5)
	var sum: float = ti + tl + tf
	var sc: float = 1.0
	if _dur - sum < 0.3:
		sc = maxf(0.2, (_dur - 0.3) / sum)
	_t_intro = ti * sc
	_t_level = tl * sc
	_t_fin = tf * sc
	if is_upgrade:
		var eff: Dictionary = mode.get("effects", {})
		_arcs = bool(eff.get("arcs", true))
		_beam = bool(eff.get("beam", false))
		_chase = bool(eff.get("chase_lamps", false))
		_chev_poly = PackedVector2Array(_vs(mode.get("chevron_polygon", [[-150, 0], [0, -62], [150, 0], [150, 42], [0, -20], [-150, 42]])))
		_chev_y = _num(mode, "chevron_base_y", 215.0)
		_chev_step = _num(mode, "chevron_step_y", 72.0)
	_main = _make_layer(KIND_MAIN, 13, false)
	_add = _make_layer(KIND_ADD, 14, true)
	_pose()
	set_process(true)

func _make_layer(kind: int, z: int, additive: bool) -> _Layer:
	var l: _Layer = _Layer.new()
	l.site = self
	l.kind = kind
	l.z_index = z
	l.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if additive:
		var m: CanvasItemMaterial = CanvasItemMaterial.new()
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		l.material = m
	add_child(l)
	return l

## Прогресс 0..1. Возвращает видимость настоящего здания 0..1.
func set_progress(p: float) -> float:
	var np: float = clampf(p, 0.0, 1.0)
	if not _finished:
		_events(_p, np)
	_p = np
	_pose()
	return _bld

## true, когда начался финал площадки (здание ещё почти невидимо, сейчас начнёт проявляться).
func in_finale() -> bool:
	return _fin > 0.0

func finish() -> void:
	if _finished:
		return
	_finished = true
	queue_free()

func _pose() -> void:
	var t: float = _p * _dur
	_intro = clampf(t / _t_intro, 0.0, 1.0)
	_fin = clampf((t - (_dur - _t_fin)) / _t_fin, 0.0, 1.0)
	_lev = 0.0
	if _is_upgrade and _t_level > 0.0:
		_lev = clampf((t - (_dur - _t_fin - _t_level)) / _t_level, 0.0, 1.0)
	_a = _ease(_intro) * (1.0 - clampf(_fin * 2.5, 0.0, 1.0))
	_pop = _pop_from + (1.0 - _pop_from) * _ease(_intro) + 0.05 * _fin
	_bld = _ease(clampf(_fin * 2.5, 0.0, 1.0))
	if _is_upgrade:
		_bld = maxf(_bld, 1.0 - _ease(clampf(_intro * 2.5, 0.0, 1.0)))

func _events(a: float, b: float) -> void:
	var t0: float = a * _dur
	var t1: float = b * _dur
	if t0 < 0.01 and t1 >= 0.01:
		_dust_ring(34)
	if t0 < _t_intro and t1 >= _t_intro:
		_dust_ring(24)
	if t0 < _dur - _t_fin and t1 >= _dur - _t_fin:
		_dust_ring(50)
		_flash = 1.0

func _dust_ring(n: int) -> void:
	for i: int in n:
		var ang: float = randf() * TAU
		var c: float = cos(ang)
		var s: float = sin(ang)
		_dust.append({
			"k": 0, "x": _foot.x + c * _foot_r.x * 0.95, "y": _foot.y + s * _foot_r.y * 0.95,
			"vx": c * (10.0 + randf() * 18.0) * _g, "vy": s * (5.0 + randf() * 9.0) * _g - 3.0 * _g,
			"r": (3.0 + randf() * 5.0) * _g, "gr": 3.0 * _g, "l": 1.0 + randf(), "L": 2.0, "a": 0.38,
		})

func _emit(dt: float) -> void:
	var act: float = _ease(_intro) * (1.0 - _fin)
	if act <= 0.05:
		return
	_wt -= dt
	if _wt <= 0.0 and not _welds.is_empty():
		_wt = 0.22 + randf() * 0.7
		var w: Vector2 = _welds[randi() % _welds.size()]
		_glows.append({"x": w.x, "y": w.y, "r": 26.0 * _g, "l": 0.14, "L": 0.14})
		var n: int = 6 + int(_sparks / 10.0)
		for i: int in n:
			var life: float = 0.3 + randf() * 0.3
			_spk.append({
				"x": w.x + (randf() - 0.5) * 8.0, "y": w.y,
				"vx": (randf() - 0.5) * 50.0 * _g, "vy": (-8.0 - randf() * 30.0) * _g, "l": life, "L": 0.5,
			})
	if not _is_upgrade and randf() < dt * _steam * act:
		_dust.append({
			"k": 1, "x": _floor_c.x + (randf() - 0.5) * 440.0, "y": _floor_c.y - 120.0 + randf() * 80.0,
			"vx": (randf() - 0.5) * 8.0 * _g, "vy": -26.0 * _g, "r": (4.0 + randf() * 3.0) * _g, "gr": 4.5 * _g,
			"l": 1.6 + randf() * 1.2, "L": 2.8, "a": 0.2,
		})

func _step(dt: float) -> void:
	for i: int in range(_dust.size() - 1, -1, -1):
		var d: Dictionary = _dust[i]
		d["l"] = float(d["l"]) - dt
		if float(d["l"]) <= 0.0:
			_dust.remove_at(i)
			continue
		d["x"] = float(d["x"]) + float(d["vx"]) * dt
		d["y"] = float(d["y"]) + float(d["vy"]) * dt
		d["r"] = float(d["r"]) + float(d["gr"]) * dt
	for i: int in range(_spk.size() - 1, -1, -1):
		var s: Dictionary = _spk[i]
		s["l"] = float(s["l"]) - dt
		if float(s["l"]) <= 0.0:
			_spk.remove_at(i)
			continue
		s["vy"] = float(s["vy"]) + 140.0 * _g * dt
		s["x"] = float(s["x"]) + float(s["vx"]) * dt
		s["y"] = float(s["y"]) + float(s["vy"]) * dt
	for i: int in range(_glows.size() - 1, -1, -1):
		var gl: Dictionary = _glows[i]
		gl["l"] = float(gl["l"]) - dt
		if float(gl["l"]) <= 0.0:
			_glows.remove_at(i)

func _process(delta: float) -> void:
	if _finished:
		return
	var dt: float = minf(delta, 0.05)
	_t += dt
	_emit(dt)
	_step(dt)
	_flash = maxf(0.0, _flash - dt * 3.0)
	_main.queue_redraw()
	_add.queue_redraw()

# ---------------------------------------------------------------- геометрия крана

func _crane_geo() -> Dictionary:
	var pin: Vector2 = _tl["tur"] + _pin_off * _ps
	var nat: Vector2 = _tip_nat - _pivot
	var a0: float = nat.angle()
	var b: Vector2 = _tip_pt - pin
	var sc: float = b.length() / maxf(nat.length(), 1.0)
	var rot: float = b.angle() - a0 + _luff * RD * sin(_t * 0.9)
	var tip: Vector2 = pin + Vector2.from_angle(a0 + rot) * nat.length() * sc
	return {"pin": pin, "tip": tip, "rot": rot, "sc": sc}

func _cable_len() -> float:
	return _cab + _hoist * (0.5 + 0.5 * sin(_t * 1.1))

# ---------------------------------------------------------------- рисование

func _draw_layer(l: _Layer, kind: int) -> void:
	if _tex.is_empty() or _finished:
		return
	if kind == KIND_MAIN:
		_draw_main(l)
	else:
		_draw_additive(l)

func _topleft(key: String) -> Vector2:
	var assets: Dictionary = _cfg.get("assets", {})
	var entry: Dictionary = assets.get(key, {})
	return _v(entry.get("topleft"), Vector2.ZERO)

func _shadow(l: _Layer, x: float, y: float, w: float) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in 24:
		var an: float = float(i) / 24.0 * TAU
		pts.append(Vector2(x + cos(an) * w * 0.5, y + sin(an) * w * 0.17))
	l.draw_colored_polygon(pts, Color(0.0, 0.0, 0.0, _shadow_a))

func _draw_main(l: _Layer) -> void:
	var a: float = _a
	if a > 0.003:
		var mp: Transform2D = _xf_move(_foot) * _xf_scale(_pop, _pop) * _xf_move(-_foot)
		var white: Color = Color(1.0, 1.0, 1.0, a)
		l.draw_set_transform_matrix(mp)
		l.draw_texture(_tex["base"], _topleft("base"), white)
		l.draw_texture(_tex["floor"], _topleft("floor"), white)
		# свет из шахты (обычным смешиванием: пол тёмный)
		var f: float = 0.16 * (0.8 + 0.2 * sin(_t * 9.0)) if not _is_upgrade else 0.2 * (0.75 + 0.25 * sin(_t * _pulse_hz))
		var gc: Color = Color(_col.r, _col.g, _col.b, minf(1.0, f * _glow_k * 1.6 * _ease(_intro) * a))
		l.draw_set_transform_matrix(mp * _xf_move(_floor_c + Vector2(0.0, -20.0)) * _xf_scale(1.0, 0.5))
		l.draw_texture_rect(_glow_tex, Rect2(-400.0, -400.0, 800.0, 800.0), false, gc)
		l.draw_set_transform_matrix(mp)
		var tank: Texture2D = _tex["tank"]
		var c1: Texture2D = _tex["crate1"]
		var c2: Texture2D = _tex["crate2"]
		var tur: Texture2D = _tex["turret"]
		var items: Array[Dictionary] = [
			{"n": "tank", "y": (_tl["tank"] as Vector2).y + tank.get_height() * _ps},
			{"n": "c1", "y": (_tl["c1"] as Vector2).y + c1.get_height() * _ps},
			{"n": "c2", "y": (_tl["c2"] as Vector2).y + c2.get_height() * _ps},
			{"n": "tur", "y": (_tl["tur"] as Vector2).y + tur.get_height() * _ps},
		]
		items.sort_custom(func(u: Dictionary, v: Dictionary) -> bool: return float(u["y"]) < float(v["y"]))
		for it: Dictionary in items:
			var key: String = String(it["n"])
			var tl: Vector2 = _tl[key]
			var tex: Texture2D = tur if key == "tur" else (tank if key == "tank" else (c1 if key == "c1" else c2))
			var w: float = tex.get_width() * _ps
			var h: float = tex.get_height() * _ps
			_shadow(l, tl.x + w * 0.5, tl.y + h - (8.0 if key == "tank" else 13.0), w * 1.02)
			l.draw_texture_rect(tex, Rect2(tl, Vector2(w, h)), false, white)
		_draw_hook(l, mp, white)
		_draw_boom(l, mp, white)
		l.draw_set_transform_matrix(mp)
		l.draw_texture(_tex["front"], _topleft("front"), white)
	l.draw_set_transform_matrix(Transform2D.IDENTITY)
	for d: Dictionary in _dust:
		var life: float = float(d["l"]) / float(d["L"])
		var r: float = float(d["r"])
		var steam: bool = int(d["k"]) == 1
		var c: Color = Color(0.78, 0.8, 0.82, float(d["a"]) * life) if steam else Color(0.77, 0.59, 0.45, float(d["a"]) * life)
		l.draw_texture_rect(_soft, Rect2(float(d["x"]) - r, float(d["y"]) - r, r * 2.0, r * 2.0), false, c)
	if _is_upgrade and _lev > 0.0:
		var lv: float = _ease(_lev) * (1.0 - _fin)
		for i: int in _chevrons:
			var off: Vector2 = Vector2(630.0, _chev_y - i * _chev_step - (1.0 - _ease(_lev)) * 50.0 + sin(_t * 3.0) * 4.0)
			var poly: PackedVector2Array = PackedVector2Array()
			for pt: Vector2 in _chev_poly:
				poly.append(pt + off)
			l.draw_colored_polygon(poly, Color(1.0, 0.82, 0.24, lv))
			var outline: PackedVector2Array = poly.duplicate()
			outline.append(poly[0])
			l.draw_polyline(outline, Color(0.1, 0.07, 0.0, lv), 7.0)
	if _show_bar and _p > 0.0 and _p < 1.0:
		var ba: float = minf(1.0, _a * 3.0) * 0.9
		l.draw_rect(Rect2(630.0 - _bar_w * 0.5, _bar_y, _bar_w, 22.0), Color(0.0, 0.0, 0.0, 0.55 * ba))
		l.draw_rect(Rect2(630.0 - _bar_w * 0.5, _bar_y, _bar_w * _p, 22.0), Color(_col.r, _col.g, _col.b, ba))

func _draw_hook(l: _Layer, mp: Transform2D, white: Color) -> void:
	var gm: Dictionary = _crane_geo()
	var tex: Texture2D = _tex["hook"]
	var length: float = _cable_len()
	var sw: float = 0.05 * sin(_t * 1.7)
	var tip: Vector2 = gm["tip"]
	l.draw_set_transform_matrix(mp * _xf_move(tip + Vector2(_hook_attach.x, _hook_attach.y * _ps)) * _xf_rot(sw) * _xf_scale(_hook_s, _hook_s) * _xf_move(Vector2(-48.0, 0.0)))
	var y: float = 0.0
	while y < length:
		var hh: float = minf(52.0, length - y)
		l.draw_texture_rect_region(tex, Rect2(0.0, y, 97.0, hh), Rect2(0.0, 8.0, 97.0, hh), white)
		y += 52.0
	l.draw_texture_rect_region(tex, Rect2(0.0, length, 97.0, 198.0), Rect2(0.0, 118.0, 97.0, 198.0), white)

func _draw_boom(l: _Layer, mp: Transform2D, white: Color) -> void:
	var gm: Dictionary = _crane_geo()
	var pin: Vector2 = gm["pin"]
	var sc: float = float(gm["sc"])
	l.draw_set_transform_matrix(mp * _xf_move(pin) * _xf_rot(float(gm["rot"])) * _xf_scale(sc, sc) * _xf_move(-_pivot))
	l.draw_texture(_tex["boom"], Vector2.ZERO, white)

func _draw_additive(l: _Layer) -> void:
	var a: float = _a
	var pulse: float = 0.7 + 0.3 * sin(_t * _pulse_hz)
	if a > 0.01:
		var order: Array[int] = [0, 3, 1, 2]
		for i: int in _lamps.size():
			var pu: float = pulse
			if _is_upgrade and _chase:
				pu = 0.3 + 0.7 * pow(maxf(0.0, sin(_t * 5.0 - order[i % 4] * 1.57)), 2.0)
			var lp: Vector2 = _lamps[i]
			var r: float = _lamp_r * _glow_k
			l.draw_texture_rect(_glow_tex, Rect2(lp.x - r, lp.y - r, r * 2.0, r * 2.0), false, Color(_col.r, _col.g, _col.b, minf(1.0, 0.75 * pu * a)))
			l.draw_circle(lp, _lamp_dome, Color(_col.r, _col.g, _col.b, 0.5 * pu * a))
	if _is_upgrade and _arcs and a > 0.01 and _lamps.size() >= 4:
		var pairs: Array[Vector2i] = [Vector2i(0, 2), Vector2i(2, 3), Vector2i(3, 1), Vector2i(1, 0)]
		for pr: Vector2i in pairs:
			if randf() < 0.35:
				continue
			var p0: Vector2 = _lamps[pr.x]
			var q0: Vector2 = _lamps[pr.y]
			var pts: PackedVector2Array = PackedVector2Array()
			pts.append(p0)
			for s: int in range(1, 8):
				var f: float = float(s) / 8.0
				pts.append(p0.lerp(q0, f) + Vector2((randf() - 0.5) * 26.0, (randf() - 0.5) * 26.0 + sin(f * PI) * 26.0))
			pts.append(q0)
			l.draw_polyline(pts, Color(_col.r, _col.g, _col.b, 0.8 * a), 1.3 * _g)
	for gl: Dictionary in _glows:
		var v: float = float(gl["l"]) / float(gl["L"])
		var rr: float = float(gl["r"]) * (0.4 + 0.6 * v)
		l.draw_texture_rect(_glow_tex, Rect2(float(gl["x"]) - rr, float(gl["y"]) - rr, rr * 2.0, rr * 2.0), false, Color(_col.r, _col.g, _col.b, minf(1.0, 0.9 * v)))
	var spark_col: Color = Color(1.0, 0.82, 0.35) if not _is_upgrade else Color(0.68, 0.96, 1.0)
	for s: Dictionary in _spk:
		var life: float = float(s["l"]) / float(s["L"])
		var p0: Vector2 = Vector2(float(s["x"]), float(s["y"]))
		var vel: Vector2 = Vector2(float(s["vx"]), float(s["vy"])) * 0.05
		l.draw_line(p0, p0 - vel, Color(spark_col.r, spark_col.g, spark_col.b, life), _spark_size * 1.2 * _g)
	if _flash > 0.0:
		var fr: float = 520.0
		l.draw_set_transform_matrix(_xf_move(_foot + Vector2(0.0, -60.0)) * _xf_scale(1.0, 0.55))
		l.draw_texture_rect(_glow_tex, Rect2(-fr, -fr, fr * 2.0, fr * 2.0), false, Color(1.0, 1.0, 1.0, _flash * 0.9))
		l.draw_set_transform_matrix(Transform2D.IDENTITY)
