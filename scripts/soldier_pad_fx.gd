class_name SoldierPadFx
extends Node
## Анимация тумбы солдатской башни: мигающие голубые полоски в покое, «посадка» тумбы при постройке
## и общие помощники для пыли и дыма (используются и эффектом разрушения).
## Подключается из SoldiersTower; без файла маски свечения полоски просто не мигают.

const GLOW_PATH: String = "res://assets/sprites/units/soldiers/pad_soldiers-glow.webp"
## Период пульсации полосок; нарочно отличается от солдат (1,6 с), чтобы не мигали синхронно.
const GLOW_PERIOD: float = 2.0
## Нижний уровень яркости полосок в пульсации.
const GLOW_MIN: float = 0.3
## Через сколько секунд после посадки тумбы начинают загораться полоски.
const BUILD_GLOW_DELAY: float = 0.3
const BUILD_DROP_PX: float = 14.0
const BUILD_FALL_SECONDS: float = 0.26
const DUST_COLOR: Color = Color(0.64, 0.6, 0.54)
const SMOKE_COLOR: Color = Color(0.3, 0.3, 0.32)

static var _soft_texture: GradientTexture2D
static var _additive_material: CanvasItemMaterial
static var _grow_curve: Curve

var pad: Sprite2D
var glow: Sprite2D
var _clock: float = 0.0
var _phase: float = 0.0
var _build_time: float = -1.0

## Создаёт эффект и добавляет его к owner_node; pad_sprite — спрайт тумбы.
static func attach(owner_node: Node, pad_sprite: Sprite2D) -> SoldierPadFx:
	var effect: SoldierPadFx = SoldierPadFx.new()
	effect.name = "PadFx"
	effect.pad = pad_sprite
	owner_node.add_child(effect)
	return effect

## Мягкий круг для частиц и пятна копоти (радиальный градиент 64x64).
static func soft_texture() -> GradientTexture2D:
	if _soft_texture == null:
		var gradient: Gradient = Gradient.new()
		gradient.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
		gradient.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0)])
		_soft_texture = GradientTexture2D.new()
		_soft_texture.gradient = gradient
		_soft_texture.fill = GradientTexture2D.FILL_RADIAL
		_soft_texture.fill_from = Vector2(0.5, 0.5)
		_soft_texture.fill_to = Vector2(1.0, 0.5)
		_soft_texture.width = 64
		_soft_texture.height = 64
	return _soft_texture

static func _get_additive_material() -> CanvasItemMaterial:
	if _additive_material == null:
		_additive_material = CanvasItemMaterial.new()
		_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _additive_material

static func _get_grow_curve() -> Curve:
	if _grow_curve == null:
		_grow_curve = Curve.new()
		_grow_curve.add_point(Vector2(0.0, 0.45))
		_grow_curve.add_point(Vector2(1.0, 1.7))
	return _grow_curve

## Глобальный z-индекс узла с учётом z_as_relative вверх по дереву.
static func global_z(node: Node) -> int:
	var total: int = 0
	var current: Node = node
	while current is CanvasItem:
		var item: CanvasItem = current as CanvasItem
		total += item.z_index
		if not item.z_as_relative:
			break
		current = current.get_parent()
	return total

## Разовый выброс пыли (smoke = false) или лёгкого дыма (smoke = true) в мировых координатах.
## area — половина размеров прямоугольника эмиссии в px экрана. Узел сам удаляется после затухания.
static func spawn_puff(parent: Node, world_position: Vector2, area: Vector2, amount: int, lifetime: float, smoke: bool, delay: float = 0.0) -> CPUParticles2D:
	var particles: CPUParticles2D = CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.amount = amount
	particles.lifetime = lifetime
	particles.local_coords = false
	particles.texture = soft_texture()
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = area
	particles.scale_amount_curve = _get_grow_curve()
	var tint: Color = SMOKE_COLOR if smoke else DUST_COLOR
	var ramp: Gradient = Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.18, 1.0])
	ramp.colors = PackedColorArray([
		Color(tint.r, tint.g, tint.b, 0.0),
		Color(tint.r, tint.g, tint.b, 0.34 if smoke else 0.55),
		Color(tint.r, tint.g, tint.b, 0.0),
	])
	particles.color_ramp = ramp
	if smoke:
		particles.explosiveness = 0.25
		particles.direction = Vector2(0.0, -1.0)
		particles.spread = 40.0
		particles.gravity = Vector2(0.0, -10.0)
		particles.initial_velocity_min = 3.0
		particles.initial_velocity_max = 9.0
		particles.scale_amount_min = 0.7
		particles.scale_amount_max = 1.1
	else:
		particles.explosiveness = 0.85
		particles.direction = Vector2(0.0, -1.0)
		particles.spread = 180.0
		particles.gravity = Vector2(0.0, -6.0)
		particles.initial_velocity_min = 14.0
		particles.initial_velocity_max = 42.0
		particles.damping_min = 30.0
		particles.damping_max = 60.0
		particles.scale_amount_min = 0.5
		particles.scale_amount_max = 0.9
	particles.angle_min = 0.0
	particles.angle_max = 360.0
	particles.z_index = 6
	parent.add_child(particles)
	particles.global_position = world_position
	if delay > 0.0:
		particles.get_tree().create_timer(delay).timeout.connect(particles.set.bind("emitting", true), CONNECT_ONE_SHOT)
	else:
		particles.emitting = true
	particles.get_tree().create_timer(delay + lifetime + 0.6).timeout.connect(particles.queue_free, CONNECT_ONE_SHOT)
	return particles

func _ready() -> void:
	if not is_instance_valid(pad) or not ResourceLoader.exists(GLOW_PATH):
		set_process(false)
		return
	var texture: Texture2D = load(GLOW_PATH) as Texture2D
	glow = Sprite2D.new()
	glow.name = "PadGlow"
	glow.texture = texture
	glow.centered = pad.centered
	glow.offset = pad.offset
	glow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	glow.material = _get_additive_material()
	pad.add_child(glow)
	_phase = randf() * GLOW_PERIOD

func _process(delta: float) -> void:
	_clock += delta
	var gain: float = 1.0
	if _build_time >= 0.0:
		_build_time += delta
		var ramp: float = clampf((_build_time - BUILD_GLOW_DELAY) / 0.4, 0.0, 1.0)
		var flicker: float = 1.0 if ramp >= 1.0 else 0.55 + 0.45 * signf(sin(_build_time * 55.0))
		gain = ramp * flicker
		if _build_time > BUILD_GLOW_DELAY + 0.5:
			_build_time = -1.0
	var pulse: float = GLOW_MIN + (1.0 - GLOW_MIN) * (0.5 + 0.5 * sin(TAU * (_clock + _phase) / GLOW_PERIOD))
	glow.modulate = Color(1.0, 1.0, 1.0, pulse * gain)

## Тумба падает на место с лёгким сжатием, поднимает пыль, затем по очереди загораются полоски.
func play_build_in() -> void:
	if not is_instance_valid(pad):
		return
	_build_time = 0.0
	if is_instance_valid(glow):
		glow.modulate.a = 0.0
	var base_position: Vector2 = pad.position
	var base_scale: Vector2 = pad.scale
	pad.modulate.a = 0.0
	pad.position = base_position + Vector2(0.0, -BUILD_DROP_PX)
	var tween: Tween = create_tween()
	tween.tween_property(pad, "modulate:a", 1.0, 0.12)
	tween.parallel().tween_property(pad, "position", base_position, BUILD_FALL_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_on_pad_landed)
	tween.tween_property(pad, "scale", base_scale * Vector2(1.04, 0.93), 0.05)
	tween.tween_property(pad, "scale", base_scale, 0.12)

func _on_pad_landed() -> void:
	if not is_instance_valid(pad) or not is_instance_valid(pad.get_parent()):
		return
	var size: Vector2 = pad.texture.get_size() * pad.global_scale
	spawn_puff(self, pad.global_position, Vector2(size.x * 0.34, size.y * 0.2), 14, 0.8, false)
