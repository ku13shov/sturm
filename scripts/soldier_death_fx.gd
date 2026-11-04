class_name SoldierDeathFx
extends Node2D
## Смерть солдата кодом из тех же слоёв, что в студии: руки отлетают и вращаются, голова срывается и падает,
## тело оседает к ступням с наклоном, свечение гаснет с миганием, затем растворение. Искры рисуются отдельным слоем.
## Создаётся в родителе башни через SoldierDeathFx.spawn(), после чего башню можно сразу удалять.

const LAYERS_PATH: String = "res://assets/sprites/units/soldiers/soldier_layers.webp"
const LAYERS_MASK_PATH: String = "res://assets/sprites/units/soldiers/soldier_layers-mask.webp"
const LAYER_NAMES: Array[String] = ["body", "head", "arms"]

## Значения из студии (итоговые настройки). Искры уменьшены: башня умирает сразу с четырьмя солдатами.
const DURATION: float = 0.9
const ARMS_SPREAD: float = 95.0
const ARMS_ROTATION_DEG: float = 60.0
const HEAD_FALL: float = 400.0
const BODY_SETTLE: float = 0.55
const BODY_LEAN: float = 0.04
const GLOW_FADE_FRACTION: float = 0.4
const DISSOLVE: float = 1.0
const SPARK_MULTIPLIER: float = 1.5
## Минимальная ширина искры на экране (px), иначе при масштабе солдата она пропадает.
const SPARK_MIN_WIDTH_PX: float = 0.9

static var _layer_textures: Dictionary = {}
static var _atlas_color: Texture2D
static var _atlas_glow: Texture2D
static var _additive_material: CanvasItemMaterial

class SparkLayer:
	extends Node2D
	var fx: SoldierDeathFx

	func _draw() -> void:
		if fx != null:
			fx.draw_sparks(self)

var row: int = 0
var time_alive: float = 0.0
var glow_start_level: float = 1.0
var body_pivot: Node2D
var head_pivot: Node2D
var arms_pivot: Node2D
var glow_body_pivot: Node2D
var glow_head_pivot: Node2D
var glow_arms_pivot: Node2D
var color_nodes: Array[Node2D] = []
var glow_nodes: Array[Node2D] = []
var spark_layer: SparkLayer
var sparks: Array[Dictionary] = []

## world_position: точка опоры (ступни). world_scale: px экрана на px листа (масштаб SoldierSheetVisual).
## flip: вид зеркалится (SW, W, NW). glow_level: текущая яркость свечения солдата в момент смерти.
static func spawn(parent: Node, world_position: Vector2, view_row: int, flip: bool, world_scale: float, glow_level: float) -> SoldierDeathFx:
	if not _ensure_atlas():
		return null
	var effect: SoldierDeathFx = SoldierDeathFx.new()
	effect.row = view_row
	effect.glow_start_level = glow_level
	effect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	effect.z_index = 1
	parent.add_child(effect)
	effect.global_position = world_position
	var parent_scale: float = 1.0
	var parent_item: Node2D = parent as Node2D
	if parent_item != null:
		parent_scale = maxf(absf(parent_item.global_scale.x), 0.0001)
	# Координаты слоёв считаем в px студийного холста, поэтому масштаб = экранный px на px холста.
	var canvas_scale: float = world_scale / parent_scale * SoldierSheetData.SHEET_SCALE
	effect.scale = Vector2(-canvas_scale if flip else canvas_scale, canvas_scale)
	effect._build()
	return effect

static func _ensure_atlas() -> bool:
	if _atlas_color == null and ResourceLoader.exists(LAYERS_PATH):
		_atlas_color = load(LAYERS_PATH) as Texture2D
	if _atlas_glow == null and ResourceLoader.exists(LAYERS_MASK_PATH):
		_atlas_glow = load(LAYERS_MASK_PATH) as Texture2D
	return _atlas_color != null and _atlas_glow != null

static func _layer_texture(view_row: int, layer_name: String, glow: bool) -> AtlasTexture:
	var key: String = "%d_%s_%d" % [view_row, layer_name, 1 if glow else 0]
	if _layer_textures.has(key):
		return _layer_textures[key] as AtlasTexture
	var source: Array[Dictionary] = SoldierSheetData.GLOW_LAYERS if glow else SoldierSheetData.LAYERS
	var entry: Dictionary = source[view_row]
	if not entry.has(layer_name):
		return null
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = _atlas_glow if glow else _atlas_color
	atlas.region = entry[layer_name]["rect"] as Rect2
	_layer_textures[key] = atlas
	return atlas

static func _get_additive_material() -> CanvasItemMaterial:
	if _additive_material == null:
		_additive_material = CanvasItemMaterial.new()
		_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _additive_material

## Слой как узел-ось (нужен для вращения вокруг центра) с одним спрайтом внутри.
func _make_layer(layer_name: String, glow: bool, pivot_canvas: Vector2) -> Node2D:
	var view: Dictionary = SoldierSheetData.VIEWS[row]
	var anchor: Vector2 = view["anchor"] as Vector2
	var pivot: Node2D = Node2D.new()
	pivot.position = pivot_canvas - anchor
	add_child(pivot)
	var texture: AtlasTexture = _layer_texture(row, layer_name, glow)
	if texture == null:
		return pivot
	var source: Array[Dictionary] = SoldierSheetData.GLOW_LAYERS if glow else SoldierSheetData.LAYERS
	var origin: Vector2 = source[row][layer_name]["origin"] as Vector2
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	# Лист в 1/SHEET_SCALE раз меньше холста, поэтому спрайт растягивается обратно до px холста.
	sprite.scale = Vector2.ONE / SoldierSheetData.SHEET_SCALE
	sprite.position = origin - pivot_canvas
	if glow:
		sprite.material = _get_additive_material()
	pivot.add_child(sprite)
	return pivot

func _build() -> void:
	var view: Dictionary = SoldierSheetData.VIEWS[row]
	var anchor: Vector2 = view["anchor"] as Vector2
	var head_pivot_canvas: Vector2 = (view["head_c"] as Vector2) + (view["head_shift"] as Vector2)
	var arms_pivot_canvas: Vector2 = (view["arms_c"] as Vector2) + (view["arms_shift"] as Vector2)
	# Сначала все цветные слои, затем все слои свечения (как в студии: свечение поверх всего, аддитивно).
	body_pivot = _make_layer("body", false, anchor)
	head_pivot = _make_layer("head", false, (view["head_c"] as Vector2))
	arms_pivot = _make_layer("arms", false, (view["arms_c"] as Vector2))
	glow_body_pivot = _make_layer("body", true, anchor)
	glow_head_pivot = _make_layer("head", true, (view["head_c"] as Vector2))
	glow_arms_pivot = _make_layer("arms", true, (view["arms_c"] as Vector2))
	# Сдвиги hx/hy/ax/ay запекаются в стартовые позиции осей головы и рук.
	head_pivot.position = head_pivot_canvas - anchor
	glow_head_pivot.position = head_pivot.position
	arms_pivot.position = arms_pivot_canvas - anchor
	glow_arms_pivot.position = arms_pivot.position
	color_nodes = [body_pivot, head_pivot, arms_pivot]
	glow_nodes = [glow_body_pivot, glow_head_pivot, glow_arms_pivot]
	spark_layer = SparkLayer.new()
	spark_layer.fx = self
	spark_layer.z_index = 2
	spark_layer.material = _get_additive_material()
	add_child(spark_layer)
	_spawn_sparks(view["sparks"] as Array, anchor)
	_apply(0.0)

func _spawn_sparks(sources: Array, anchor: Vector2) -> void:
	for source: Variant in sources:
		var data: Array = source as Array
		var origin: Vector2 = Vector2(float(data[0]), float(data[1])) - anchor
		var count: int = roundi(float(data[2]) * SPARK_MULTIPLIER)
		for index: int in count:
			var angle: float = randf() * TAU
			var big: bool = randf() < 0.2
			var speed: float = (60.0 if big else 80.0) + randf() * (200.0 if big else 280.0)
			sparks.append({
				"x": origin.x, "y": origin.y,
				"vx": cos(angle) * speed, "vy": sin(angle) * speed - 110.0,
				"delay": randf() * 0.35,
				"life": (0.6 if big else 0.4) + randf() * 0.7,
				"width": 1.9 if big else 1.0,
			})

func _process(delta: float) -> void:
	time_alive += delta
	if time_alive >= DURATION + 0.05:
		queue_free()
		return
	_apply(time_alive / DURATION)
	spark_layer.queue_redraw()

func _smooth(value: float) -> float:
	var clamped: float = clampf(value, 0.0, 1.0)
	return clamped * clamped * (3.0 - 2.0 * clamped)

func _apply(progress: float) -> void:
	var view: Dictionary = SoldierSheetData.VIEWS[row]
	var anchor: Vector2 = view["anchor"] as Vector2
	var arms_base: Vector2 = ((view["arms_c"] as Vector2) + (view["arms_shift"] as Vector2)) - anchor
	var head_base: Vector2 = ((view["head_c"] as Vector2) + (view["head_shift"] as Vector2)) - anchor
	# Руки
	var arms_u: float = clampf(progress / 0.9, 0.0, 1.0)
	var gravity: float = ARMS_SPREAD * 0.8 + 220.0
	var arms_offset: Vector2 = Vector2(ARMS_SPREAD * arms_u, -ARMS_SPREAD * 0.8 * arms_u + gravity * arms_u * arms_u)
	var arms_rotation: float = deg_to_rad(ARMS_ROTATION_DEG) * arms_u
	# Голова
	var head_q: float = clampf((progress - 0.12) / 0.88, 0.0, 1.0)
	var head_offset: Vector2 = Vector2(-0.12 * HEAD_FALL * head_q, HEAD_FALL * head_q * head_q)
	var head_rotation: float = -0.6 * head_q
	# Тело: сжатие вокруг ступней (начало координат) и наклон от линии ступней.
	var settle: float = _smooth(progress / 0.7)
	var lean: float = BODY_LEAN * settle
	var scale_x: float = 1.0 + 0.3 * BODY_SETTLE * settle
	var scale_y: float = 1.0 - 0.6 * BODY_SETTLE * settle
	var body_transform: Transform2D = Transform2D(Vector2(scale_x, 0.0), Vector2(-scale_x * lean, scale_y), Vector2.ZERO)
	body_pivot.transform = body_transform
	glow_body_pivot.transform = body_transform
	head_pivot.position = head_base + head_offset
	head_pivot.rotation = head_rotation
	glow_head_pivot.position = head_pivot.position
	glow_head_pivot.rotation = head_rotation
	arms_pivot.position = arms_base + arms_offset
	arms_pivot.rotation = arms_rotation
	glow_arms_pivot.position = arms_pivot.position
	glow_arms_pivot.rotation = arms_rotation
	# Растворение и свечение
	var fade: float = 1.0 - DISSOLVE * _smooth((progress - 0.7) / 0.3)
	var glow_k: float = maxf(0.0, 1.0 - progress / GLOW_FADE_FRACTION)
	if progress > 0.05 and sin(time_alive * 70.0) < -0.3:
		glow_k *= 0.25
	for node: Node2D in color_nodes:
		node.modulate.a = fade
	for node: Node2D in glow_nodes:
		node.modulate = Color(1.0, 1.0, 1.0, minf(1.0, glow_start_level) * glow_k * fade)

## Искры в координатах холста; ширина пересчитывается так, чтобы на экране была не тоньше SPARK_MIN_WIDTH_PX.
func draw_sparks(canvas: CanvasItem) -> void:
	var screen_per_canvas: float = maxf(absf(global_scale.x), 0.0001)
	for spark: Dictionary in sparks:
		var age: float = time_alive - float(spark["delay"])
		var life: float = float(spark["life"])
		if age < 0.0 or age > life:
			continue
		var fade: float = 1.0 - age / life
		var vx: float = float(spark["vx"])
		var vy: float = float(spark["vy"])
		var head: Vector2 = Vector2(float(spark["x"]) + vx * age, float(spark["y"]) + vy * age + 260.0 * age * age)
		var tail: Vector2 = head - Vector2(vx, vy + 520.0 * age) * 0.05
		var width_screen: float = maxf(SPARK_MIN_WIDTH_PX, (0.6 * fade + 0.5) * float(spark["width"]))
		canvas.draw_line(tail, head, Color(170.0 / 255.0, 230.0 / 255.0, 1.0, fade), width_screen / screen_per_canvas)
