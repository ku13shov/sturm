class_name RepairFx
extends Node2D
## Общий эффект ремонта для любого здания (башни всех уровней, база, будущие постройки).
## Подключение: в repair_by() здания одна строка `RepairFx.pulse(self)`. Узел создаётся сам,
## текстуры не нужны. Пока HP растёт и pulse() вызывается, летят зелёные «+» и мелкие искры сварки;
## через HOLD секунд после последнего вызова эффект затихает.

const HOLD := 0.5
const FADE_IN := 6.0
const FADE_OUT := 3.0
const NODE_NAME := "RepairFx"

@export var color := Color("#3dff8f")
@export var outline := Color(0.02, 0.1, 0.06, 0.9)
## Размер эффекта (1 = для клетки 32 px и тумбы около 96 px шириной).
@export var fx_scale := 1.0
## Радиус кольца на земле и разброс «+» и искр по горизонтали.
@export var ground_radius := 40.0

var _hold_t := 0.0
var _alpha := 0.0
var _time := 0.0
var _plus_cd := 0.0
var _spark_cd := 0.0
var _plus: Array[Dictionary] = []
var _sparks: Array[Dictionary] = []


## Вызывать при каждом росте HP. offset: где над землёй висит ключ (по умолчанию над центром здания).
static func pulse(host: Node2D, offset := Vector2(0.0, -64.0)) -> void:
	if not is_instance_valid(host):
		return
	var fx := host.get_node_or_null(NODE_NAME) as RepairFx
	if fx == null:
		fx = RepairFx.new()
		fx.name = NODE_NAME
		fx.position = offset
		fx.z_index = 20
		host.add_child(fx)
	fx.refresh()


func refresh() -> void:
	_hold_t = HOLD
	set_process(true)


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	_time += delta
	_hold_t = maxf(0.0, _hold_t - delta)
	var active := _hold_t > 0.0
	_alpha = move_toward(_alpha, 1.0 if active else 0.0, delta * (FADE_IN if active else FADE_OUT))
	if active:
		_plus_cd -= delta
		if _plus_cd <= 0.0:
			_plus_cd = 0.16
			_plus.append({"x": randf_range(-1.0, 1.0) * ground_radius * 0.7, "age": 0.0, "life": randf_range(0.7, 1.0), "s": randf_range(0.8, 1.2)})
		_spark_cd -= delta
		if _spark_cd <= 0.0:
			_spark_cd = 0.06
			var a := randf_range(-PI, 0.0)
			_sparks.append({"p": Vector2(randf_range(-1.0, 1.0) * ground_radius * 0.6, -position.y * 0.6 + randf_range(-6.0, 6.0)), "v": Vector2(cos(a), sin(a)) * randf_range(22.0, 50.0), "age": 0.0, "life": randf_range(0.15, 0.3)})
	for p: Dictionary in _plus:
		p["age"] = float(p["age"]) + delta
	for s: Dictionary in _sparks:
		s["age"] = float(s["age"]) + delta
		s["v"] = (s["v"] as Vector2) + Vector2(0.0, 220.0) * delta
		s["p"] = (s["p"] as Vector2) + (s["v"] as Vector2) * delta
	_plus = _plus.filter(func(p: Dictionary) -> bool: return float(p["age"]) < float(p["life"]))
	_sparks = _sparks.filter(func(s: Dictionary) -> bool: return float(s["age"]) < float(s["life"]))
	queue_redraw()
	if not active and _alpha <= 0.0 and _plus.is_empty() and _sparks.is_empty():
		set_process(false)


func _draw() -> void:
	if _alpha <= 0.0 and _plus.is_empty() and _sparks.is_empty():
		return
	var ground := Vector2(0.0, -position.y)
	# «+» летят вверх от основания.
	for p: Dictionary in _plus:
		var k := float(p["age"]) / float(p["life"])
		var pos := ground + Vector2(float(p["x"]) + sin(_time * 5.0 + float(p["x"])) * 2.0, -k * (-ground.y + 4.0) * 0.9 - 6.0)
		var a := sin(k * PI) * 0.95
		var r := 3.4 * float(p["s"]) * fx_scale
		draw_line(pos + Vector2(-r, 0.0), pos + Vector2(r, 0.0), Color(outline, a), 3.4 * fx_scale)
		draw_line(pos + Vector2(0.0, -r), pos + Vector2(0.0, r), Color(outline, a), 3.4 * fx_scale)
		draw_line(pos + Vector2(-r, 0.0), pos + Vector2(r, 0.0), Color(color, a), 1.8 * fx_scale)
		draw_line(pos + Vector2(0.0, -r), pos + Vector2(0.0, r), Color(color, a), 1.8 * fx_scale)
	# Искры сварки.
	for s: Dictionary in _sparks:
		var sp: Vector2 = s["p"]
		var sv: Vector2 = s["v"]
		var k := float(s["age"]) / float(s["life"])
		draw_line(sp - sv.normalized() * 2.0, sp, Color(1.0, 0.95, 0.6, (1.0 - k) * 0.9), 1.0)
