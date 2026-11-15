class_name MapDustLayer
extends Node2D
## Фоновая пыль карты: медленные мягкие полосы дымки, которые дрейфуют по ветру,
## и редкий пылевой вихрь. Лежит над землёй, но под юнитами и зданиями. Без частиц на юнитах.

@export_group("Карта")
## Полуразмеры карты в мире, px. Дымка зацикливается в этих границах.
@export var half_extent: Vector2 = Vector2(1024.0, 1024.0)

@export_group("Дымка")
@export var haze_enabled: bool = true
@export_range(1, 20) var haze_count: int = 12
## Направление ветра (длина не важна).
@export var wind_direction: Vector2 = Vector2(1.0, 0.18)
## Скорость дрейфа полос, px/с.
@export var haze_speed_range: Vector2 = Vector2(18.0, 28.0)
## Размер полосы по ширине, px.
@export var haze_width_range: Vector2 = Vector2(700.0, 1100.0)
## Серо-бежевый, без оранжевого, чтобы не мешать читаемости жуков.
@export var haze_color: Color = Color(0.64, 0.44, 0.36)
## Прозрачность полос (мин, макс).
@export var haze_alpha_range: Vector2 = Vector2(0.24, 0.34)

@export_group("Пылинки")
@export var motes_enabled: bool = true
## Сколько пылинок на всю карту. Экран видит небольшую часть, поэтому число большое.
@export_range(50, 2000) var motes_amount: int = 600
## Скорость пылинок по ветру, px/с (мин, макс). Близка к скорости дымки, чтобы всё плыло вместе.
@export var motes_speed_range: Vector2 = Vector2(10.0, 22.0)
## Размер пылинки в px (мин, макс).
@export var motes_size_range: Vector2 = Vector2(2.0, 5.0)
@export var motes_color: Color = Color(0.72, 0.52, 0.42)
@export_range(0.0, 1.0, 0.01) var motes_alpha: float = 0.45

@export_group("Пылевой вихрь")
@export var devil_enabled: bool = true
## Пауза между вихрями, секунды (мин, макс).
@export var devil_interval_range: Vector2 = Vector2(35.0, 70.0)
@export var devil_speed: float = 65.0
@export var devil_travel_range: Vector2 = Vector2(600.0, 900.0)
@export var devil_color: Color = Color(0.60, 0.40, 0.33)
@export_range(0.0, 1.0, 0.01) var devil_alpha: float = 0.28

const SOFT_TEXTURE_SIZE: int = 128
const DEVIL_PUFFS: int = 18
## Туман войны лежит на z 10, поэтому дымка и вихрь строго ниже.
const HAZE_Z_INDEX: int = 9

var _haze_root: Node2D

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _soft_texture: Texture2D
var _time: float = 0.0

var _haze: Array[Sprite2D] = []
var _haze_speed: PackedFloat32Array = PackedFloat32Array()
var _haze_alpha: PackedFloat32Array = PackedFloat32Array()
var _haze_phase: PackedFloat32Array = PackedFloat32Array()

var _devil_puffs: Array[Sprite2D] = []
var _devil_active: bool = false
var _devil_wait: float = 0.0
var _devil_age: float = 0.0
var _devil_life: float = 1.0
var _devil_start: Vector2 = Vector2.ZERO
var _devil_dir: Vector2 = Vector2.RIGHT


func _ready() -> void:
	name = "DustLayer"
	z_index = 19
	_rng.randomize()
	_soft_texture = _make_soft_texture()
	# Дымка и вихрь лежат ниже тумана войны (он на z 10), пылинки остаются выше.
	_haze_root = Node2D.new()
	_haze_root.name = "HazeRoot"
	_haze_root.z_as_relative = false
	_haze_root.z_index = HAZE_Z_INDEX
	add_child(_haze_root)
	if haze_enabled:
		_spawn_haze()
	if motes_enabled:
		_spawn_motes()
	if devil_enabled:
		_spawn_devil_puffs()
		_devil_wait = _rng.randf_range(10.0, 25.0)


func _process(delta: float) -> void:
	_time += delta
	_update_haze(delta)
	_update_devil(delta)


func _make_soft_texture() -> Texture2D:
	var gradient: Gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	gradient.colors = PackedColorArray([
		Color(1.0, 1.0, 1.0, 1.0),
		Color(1.0, 1.0, 1.0, 0.35),
		Color(1.0, 1.0, 1.0, 0.0),
	])
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = SOFT_TEXTURE_SIZE
	texture.height = SOFT_TEXTURE_SIZE
	return texture


func _spawn_motes() -> void:
	var motes: CPUParticles2D = CPUParticles2D.new()
	motes.name = "Motes"
	motes.texture = _soft_texture
	motes.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	motes.amount = motes_amount
	motes.lifetime = 12.0
	motes.preprocess = 12.0
	motes.local_coords = true
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = half_extent
	motes.direction = wind_direction.normalized()
	motes.spread = 6.0
	motes.gravity = Vector2.ZERO
	motes.initial_velocity_min = motes_speed_range.x
	motes.initial_velocity_max = motes_speed_range.y
	# Лёгкое покачивание, чтобы пылинки не летели по линейке.
	motes.tangential_accel_min = -6.0
	motes.tangential_accel_max = 6.0
	motes.scale_amount_min = motes_size_range.x / float(SOFT_TEXTURE_SIZE)
	motes.scale_amount_max = motes_size_range.y / float(SOFT_TEXTURE_SIZE)
	var ramp: Gradient = Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
	ramp.colors = PackedColorArray([
		Color(motes_color.r, motes_color.g, motes_color.b, 0.0),
		Color(motes_color.r, motes_color.g, motes_color.b, motes_alpha),
		Color(motes_color.r, motes_color.g, motes_color.b, motes_alpha),
		Color(motes_color.r, motes_color.g, motes_color.b, 0.0),
	])
	motes.color_ramp = ramp
	add_child(motes)


func _spawn_haze() -> void:
	for index: int in haze_count:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = _soft_texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		var width: float = _rng.randf_range(haze_width_range.x, haze_width_range.y)
		var height: float = width * _rng.randf_range(0.28, 0.42)
		sprite.scale = Vector2(width / float(SOFT_TEXTURE_SIZE), height / float(SOFT_TEXTURE_SIZE))
		sprite.rotation = wind_direction.angle() + _rng.randf_range(-0.12, 0.12)
		sprite.position = Vector2(
			_rng.randf_range(-half_extent.x, half_extent.x),
			_rng.randf_range(-half_extent.y, half_extent.y)
		)
		sprite.self_modulate = Color(haze_color.r, haze_color.g, haze_color.b, 0.0)
		_haze_root.add_child(sprite)
		_haze.append(sprite)
		_haze_speed.append(_rng.randf_range(haze_speed_range.x, haze_speed_range.y))
		_haze_alpha.append(_rng.randf_range(haze_alpha_range.x, haze_alpha_range.y))
		_haze_phase.append(_rng.randf_range(0.0, TAU))


func _update_haze(delta: float) -> void:
	if _haze.is_empty():
		return
	var direction: Vector2 = wind_direction.normalized()
	for index: int in _haze.size():
		var sprite: Sprite2D = _haze[index]
		sprite.position += direction * _haze_speed[index] * delta
		var margin: float = sprite.scale.x * float(SOFT_TEXTURE_SIZE) * 0.5
		if sprite.position.x > half_extent.x + margin:
			sprite.position.x = -half_extent.x - margin
			sprite.position.y = _rng.randf_range(-half_extent.y, half_extent.y)
		elif sprite.position.y > half_extent.y + margin:
			sprite.position.y = -half_extent.y - margin
			sprite.position.x = _rng.randf_range(-half_extent.x, half_extent.x)
		# Лёгкое «дыхание» прозрачности, чтобы полосы не выглядели статичной накладкой.
		var pulse: float = 0.75 + 0.25 * sin(_time * 0.25 + _haze_phase[index])
		sprite.self_modulate.a = _haze_alpha[index] * pulse


func _spawn_devil_puffs() -> void:
	for index: int in DEVIL_PUFFS:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = _soft_texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sprite.visible = false
		sprite.self_modulate = devil_color
		_haze_root.add_child(sprite)
		_devil_puffs.append(sprite)


func _start_devil() -> void:
	_devil_dir = wind_direction.normalized().rotated(_rng.randf_range(-0.6, 0.6))
	var travel: float = _rng.randf_range(devil_travel_range.x, devil_travel_range.y)
	_devil_life = travel / maxf(devil_speed, 1.0)
	var midpoint: Vector2 = Vector2(
		_rng.randf_range(-half_extent.x * 0.7, half_extent.x * 0.7),
		_rng.randf_range(-half_extent.y * 0.7, half_extent.y * 0.7)
	)
	_devil_start = midpoint - _devil_dir * travel * 0.5
	_devil_age = 0.0
	_devil_active = true
	for puff: Sprite2D in _devil_puffs:
		puff.visible = true


func _stop_devil() -> void:
	_devil_active = false
	_devil_wait = _rng.randf_range(devil_interval_range.x, devil_interval_range.y)
	for puff: Sprite2D in _devil_puffs:
		puff.visible = false


func _update_devil(delta: float) -> void:
	if not devil_enabled or _devil_puffs.is_empty():
		return
	if not _devil_active:
		_devil_wait -= delta
		if _devil_wait <= 0.0:
			_start_devil()
		return
	_devil_age += delta
	if _devil_age >= _devil_life:
		_stop_devil()
		return
	var progress: float = _devil_age / _devil_life
	var envelope: float = smoothstep(0.0, 0.15, progress) * (1.0 - smoothstep(0.75, 1.0, progress))
	# Центр вихря покачивается, чтобы путь не был по линейке.
	var sway: Vector2 = Vector2(-_devil_dir.y, _devil_dir.x) * sin(_devil_age * 0.7) * 26.0
	var center: Vector2 = _devil_start + _devil_dir * devil_speed * _devil_age + sway
	for index: int in _devil_puffs.size():
		var puff: Sprite2D = _devil_puffs[index]
		var cycle: float = fposmod(_devil_age * 0.35 + float(index) / float(DEVIL_PUFFS), 1.0)
		var angle: float = _devil_age * 3.0 + float(index) * 0.9 + cycle * 4.0
		var radius: float = 8.0 + cycle * 26.0
		var height: float = cycle * 80.0
		# Сжатие по вертикали под изометрию, как у остальных объектов.
		puff.position = center + Vector2(cos(angle) * radius, sin(angle) * radius * 0.45 - height)
		var puff_scale: float = (0.2 + cycle * 0.4)
		puff.scale = Vector2.ONE * puff_scale
		puff.self_modulate.a = devil_alpha * envelope * sin(cycle * PI)
