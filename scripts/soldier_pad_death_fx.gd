class_name SoldierPadDeathFx
extends Node2D
## Разрушение тумбы солдатской башни из готовой картинки: тумба режется кодом на осколки по линиям
## излома (диаграмма Вороного), осколки разлетаются дугой, падают, темнеют и остаются обломками на
## несколько секунд. Сверху пыль и лёгкий дым, на земле пятно копоти. Исходник по слоям не нужен.

const SHARD_COUNT: int = 9
const MIN_SEED_DISTANCE_PX: float = 58.0
## Форма тумбы в px текстуры (ромб верхней грани и боковые грани снизу), чтобы зёрна попадали внутрь.
const SHAPE_CENTER: Vector2 = Vector2(192.0, 100.0)
const SHAPE_HALF_WIDTH: float = 180.0
const SHAPE_HALF_HEIGHT: float = 90.0
const SHAPE_SIDE_THICKNESS: float = 38.0
const FLY_SECONDS_MIN: float = 0.5
const FLY_SECONDS_MAX: float = 0.8
const HOLD_SECONDS: float = 4.0
const FADE_SECONDS: float = 1.5
const RUBBLE_COLOR: Color = Color(0.6, 0.56, 0.53, 1.0)

var shard_root: Node2D

## Создаёт эффект на месте pad в parent (обычно в родителе башни); башню можно удалять сразу после.
static func spawn(parent: Node, pad: Sprite2D) -> SoldierPadDeathFx:
	if not is_instance_valid(pad) or pad.texture == null or not is_instance_valid(parent):
		return null
	var effect: SoldierPadDeathFx = SoldierPadDeathFx.new()
	parent.add_child(effect)
	effect.global_position = pad.global_position
	effect.z_index = SoldierPadFx.global_z(pad) - SoldierPadFx.global_z(parent)
	effect._build(pad, parent)
	return effect

func _build(pad: Sprite2D, parent: Node) -> void:
	var texture: Texture2D = pad.texture
	var size: Vector2 = texture.get_size()
	var parent_scale: Vector2 = Vector2.ONE
	var parent_item: Node2D = parent as Node2D
	if parent_item != null:
		parent_scale = parent_item.global_scale
	var pad_scale: Vector2 = pad.global_scale / parent_scale
	var origin_px: Vector2 = pad.offset - (size * 0.5 if pad.centered else Vector2.ZERO)
	var screen_size: Vector2 = size * pad_scale
	# Копоть на земле под обломками.
	var scorch: Sprite2D = Sprite2D.new()
	scorch.texture = SoldierPadFx.soft_texture()
	scorch.scale = Vector2(screen_size.x * 0.9, screen_size.y * 0.5) / 64.0
	scorch.position = Vector2(0.0, screen_size.y * 0.04)
	scorch.z_index = -1
	scorch.modulate = Color(0.0, 0.0, 0.0, 0.0)
	add_child(scorch)
	create_tween().tween_property(scorch, "modulate:a", 0.4, 0.3)
	# Осколки.
	shard_root = Node2D.new()
	shard_root.scale = pad_scale
	add_child(shard_root)
	var seeds: Array[Vector2] = _pick_seeds()
	var rect: PackedVector2Array = PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0.0), size, Vector2(0.0, size.y)])
	var longest_flight: float = 0.0
	for index: int in seeds.size():
		var polygon: PackedVector2Array = rect
		for other: int in seeds.size():
			if other == index:
				continue
			polygon = _clip(polygon, _pair_mid(seeds, index, other), seeds[other] - seeds[index])
			if polygon.size() < 3:
				break
		if polygon.size() < 3:
			continue
		var centroid: Vector2 = Vector2.ZERO
		for point: Vector2 in polygon:
			centroid += point
		centroid /= float(polygon.size())
		var shard: Node2D = Node2D.new()
		shard.position = centroid + origin_px
		shard.z_index = 4
		var piece: Polygon2D = Polygon2D.new()
		var local_polygon: PackedVector2Array = PackedVector2Array()
		for point: Vector2 in polygon:
			local_polygon.append(point - centroid)
		piece.polygon = local_polygon
		piece.uv = polygon
		piece.texture = texture
		piece.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		shard.add_child(piece)
		shard_root.add_child(shard)
		var outward: Vector2 = centroid - SHAPE_CENTER
		if outward.length() < 8.0:
			outward = Vector2.from_angle(randf() * TAU)
		outward = outward.normalized()
		outward.y *= 0.6
		var flight: float = randf_range(FLY_SECONDS_MIN, FLY_SECONDS_MAX)
		longest_flight = maxf(longest_flight, flight)
		_launch(shard, shard.position, outward * randf_range(45.0, 120.0), randf_range(30.0, 70.0), randf_range(-1.6, 1.6), flight, randf() * 0.1)
	# Пыль и дым.
	SoldierPadFx.spawn_puff(self, global_position, Vector2(screen_size.x * 0.34, screen_size.y * 0.2), 26, 1.0, false)
	SoldierPadFx.spawn_puff(self, global_position, Vector2(screen_size.x * 0.22, screen_size.y * 0.12), 11, 1.8, true, 0.12)
	# Обломки лежат HOLD_SECONDS и растворяются.
	var life: Tween = create_tween()
	life.tween_interval(longest_flight + 0.4 + HOLD_SECONDS)
	life.tween_property(self, "modulate:a", 0.0, FADE_SECONDS)
	life.tween_callback(queue_free)

## Зёрна диаграммы Вороного внутри формы тумбы, с минимальным расстоянием друг от друга.
func _pick_seeds() -> Array[Vector2]:
	var seeds: Array[Vector2] = []
	var attempts: int = 0
	while seeds.size() < SHARD_COUNT and attempts < 600:
		attempts += 1
		var point: Vector2 = Vector2(
			SHAPE_CENTER.x + randf_range(-SHAPE_HALF_WIDTH, SHAPE_HALF_WIDTH),
			SHAPE_CENTER.y + randf_range(-SHAPE_HALF_HEIGHT, SHAPE_HALF_HEIGHT + SHAPE_SIDE_THICKNESS)
		)
		var edge: float = 1.0 - absf(point.x - SHAPE_CENTER.x) / SHAPE_HALF_WIDTH
		var top: float = SHAPE_CENTER.y - SHAPE_HALF_HEIGHT * edge + 12.0
		var bottom: float = SHAPE_CENTER.y + SHAPE_HALF_HEIGHT * edge + SHAPE_SIDE_THICKNESS - 12.0
		if point.y < top or point.y > bottom:
			continue
		var far_enough: bool = true
		for seed_point: Vector2 in seeds:
			if seed_point.distance_to(point) < MIN_SEED_DISTANCE_PX:
				far_enough = false
				break
		if far_enough:
			seeds.append(point)
	return seeds

## Середина между зёрнами с небольшим одинаковым для обеих клеток сдвигом, чтобы линии излома были неровными.
func _pair_mid(seeds: Array[Vector2], first: int, second: int) -> Vector2:
	var low: int = mini(first, second)
	var high: int = maxi(first, second)
	var jitter: float = sin(float(low) * 12.9898 + float(high) * 78.233) * 7.0
	var direction: Vector2 = (seeds[high] - seeds[low]).normalized()
	return (seeds[low] + seeds[high]) * 0.5 + direction * jitter

## Отсекает многоугольник полуплоскостью: остаются точки, где dot(p - mid, normal) <= 0.
func _clip(polygon: PackedVector2Array, mid: Vector2, normal: Vector2) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	var count: int = polygon.size()
	for index: int in count:
		var current: Vector2 = polygon[index]
		var next: Vector2 = polygon[(index + 1) % count]
		var current_side: float = (current - mid).dot(normal)
		var next_side: float = (next - mid).dot(normal)
		if current_side <= 0.0:
			result.append(current)
		if (current_side < 0.0 and next_side > 0.0) or (current_side > 0.0 and next_side < 0.0):
			result.append(current.lerp(next, current_side / (current_side - next_side)))
	return result

func _launch(shard: Node2D, start: Vector2, travel: Vector2, height: float, spin: float, duration: float, delay: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_interval(delay)
	tween.tween_method(_move_shard.bind(shard, start, travel, height, spin), 0.0, 1.0, duration)
	tween.tween_callback(_land_shard.bind(shard))

func _move_shard(progress: float, shard: Node2D, start: Vector2, travel: Vector2, height: float, spin: float) -> void:
	if not is_instance_valid(shard):
		return
	var eased: float = 1.0 - pow(1.0 - progress, 2.0)
	shard.position = start + travel * eased + Vector2(0.0, -height * 4.0 * progress * (1.0 - progress))
	shard.rotation = spin * eased

func _land_shard(shard: Node2D) -> void:
	if not is_instance_valid(shard):
		return
	shard.z_index = 0
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(shard, "modulate", RUBBLE_COLOR, 0.3)
	tween.tween_property(shard, "scale", Vector2.ONE * 0.85, 0.3)
