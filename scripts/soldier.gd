@tool
class_name Soldier
extends Node2D

const DIRECTION_COUNT: int = 8
const SOLDIER_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/units/soldiers/soldier_0_s.png"), preload("res://assets/sprites/units/soldiers/soldier_1_sw.png"),
	preload("res://assets/sprites/units/soldiers/soldier_2_w.png"), preload("res://assets/sprites/units/soldiers/soldier_3_nw.png"),
	preload("res://assets/sprites/units/soldiers/soldier_4_n.png"), preload("res://assets/sprites/units/soldiers/soldier_5_ne.png"),
	preload("res://assets/sprites/units/soldiers/soldier_6_e.png"), preload("res://assets/sprites/units/soldiers/soldier_7_se.png"),
]

@export_group("Размер и направление")
## Масштаб спрайта солдата; увеличение делает солдата крупнее.
@export_range(0.01, 1.0, 0.01) var sprite_scale: float = 0.15:
	set(value):
		sprite_scale = value
		if is_node_ready(): set_visual_scale(value)
## Индекс направления 0–7; изменение выбирает соответствующий вид солдата.
@export_range(0, 7, 1) var direction_index: int = 0:
	set(value):
		direction_index = posmod(value, DIRECTION_COUNT)
		if is_node_ready(): _refresh_direction_visual()
## Точки дульных срезов в координатах спрайта, px; изменение смещает начало выстрела.
@export var muzzle_offsets: Array[Vector2] = [Vector2(12.0, -104.0), Vector2(-24.0, -103.0), Vector2(-38.0, -96.0), Vector2(-30.0, -110.0), Vector2(-10.0, -116.0), Vector2(30.0, -110.0), Vector2(38.0, -96.0), Vector2(24.0, -103.0)]:
	set(value):
		muzzle_offsets = value
		if is_node_ready(): queue_redraw()

@export_group("Трассер")
## Включает новый визуал солдата; включение заменяет старый визуал.
@export var use_new_soldier_visual: bool = false
## Оставляет старую прямую линию вместо нового трассера.
@export var use_legacy_tracer: bool = false
## Длина трассера, px; увеличение делает штрих длиннее.
@export_range(1.0, 80.0, 1.0) var tracer_length_px: float = 24.0
## Скорость трассера, px/с; увеличение ускоряет полёт.
@export_range(100.0, 3000.0, 10.0) var tracer_speed_px_per_s: float = 900.0
## Минимальная длительность трассера, секунды; увеличение продлевает короткие выстрелы.
@export_range(0.01, 0.3, 0.005) var tracer_min_duration: float = 0.06
## Максимальная длительность трассера, секунды; увеличение продлевает дальние выстрелы.
@export_range(0.01, 0.3, 0.005) var tracer_max_duration: float = 0.1
## Цвет яркой головки трассера.
@export var tracer_head_color: Color = Color("BFFFFF")
## Цвет и затухание хвоста трассера.
@export var tracer_tail_color: Color = Color(0.1686, 0.9569, 0.9725, 0.0)

@export_group("Вспышка и отдача")
## Размер вспышки у дула, px; увеличение делает вспышку крупнее.
@export_range(4.0, 32.0, 1.0) var muzzle_flash_size_px: float = 14.0
## Длительность вспышки, секунды; увеличение оставляет её дольше.
@export_range(0.01, 0.2, 0.005) var muzzle_flash_duration: float = 0.05
## Цвет центра вспышки.
@export var muzzle_flash_center_color: Color = Color("FFF4B0")
## Цвет края и затухание вспышки.
@export var muzzle_flash_edge_color: Color = Color(0.1686, 0.9569, 0.9725, 0.0)
## Длина отдачи, px; увеличение усиливает смещение спрайта.
@export_range(0.0, 10.0, 0.1) var recoil_px: float = 2.5
## Время движения в отдачу, секунды; увеличение замедляет толчок.
@export_range(0.01, 0.2, 0.005) var recoil_out_duration: float = 0.04
## Время возврата после отдачи, секунды; увеличение замедляет возврат.
@export_range(0.01, 0.2, 0.005) var recoil_return_duration: float = 0.06

@export_group("Искры и отладка")
## Число искр попадания, шт.; увеличение добавляет искры.
@export_range(1, 10, 1) var spark_count: int = 5
## Время жизни искр, секунды; увеличение оставляет их дольше.
@export_range(0.01, 0.5, 0.005) var spark_lifetime: float = 0.15
## Минимальный разлёт искр, px; увеличение отодвигает ближайшие искры.
@export_range(1.0, 40.0, 1.0) var spark_min_distance: float = 10.0
## Максимальный разлёт искр, px; увеличение расширяет облако.
@export_range(1.0, 40.0, 1.0) var spark_max_distance: float = 20.0
## Цвет искр.
@export var spark_color: Color = Color("FFF3B0")
## Показывает точки дула в игре при включении отладки.
@export var debug_muzzle_points: bool = false
## Направления, где трассер и вспышка рисуются под спрайтом.
@export var behind_directions: Array[int] = [3, 4, 5]

@onready var sprite: Sprite2D = $Sprite
@onready var shadow: Sprite2D = $Shadow
var tracer: Line2D
var muzzle_flash: Sprite2D
var sparks: Array[Polygon2D] = []
var base_sprite_position: Vector2 = Vector2.ZERO
var recoil_tween: Tween

func _ready() -> void:
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	base_sprite_position = sprite.position
	set_visual_scale(sprite_scale)
	set_direction(direction_index)
	if not Engine.is_editor_hint():
		_build_effect_pool()
	queue_redraw()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_refresh_direction_visual()
		queue_redraw()

func set_visual_scale(value: float) -> void:
	if sprite_scale != value:
		sprite_scale = value
	if is_instance_valid(sprite): sprite.scale = Vector2.ONE * sprite_scale
	if is_instance_valid(shadow):
		shadow.scale = Vector2(sprite_scale * 0.45, sprite_scale * 0.14)
		shadow.modulate = Color(0.18, 0.05, 0.025, 1.0)

func set_direction(index: int) -> void:
	direction_index = posmod(index, DIRECTION_COUNT)
	_refresh_direction_visual()

func _refresh_direction_visual() -> void:
	if not is_instance_valid(sprite):
		return
	if Engine.is_editor_hint():
		var preview_index: int = direction_index
		var mirrored: bool = preview_index >= 5
		var texture_index: int = 8 - preview_index if mirrored else preview_index
		sprite.texture = SOLDIER_TEXTURES[texture_index]
		sprite.flip_h = mirrored
	else:
		sprite.texture = SOLDIER_TEXTURES[direction_index]
		sprite.flip_h = false
	queue_redraw()

func face_screen_vector(screen_vector: Vector2) -> void:
	if screen_vector.length_squared() <= 0.0001: return
	var angle_from_screen_down: float = atan2(screen_vector.x, screen_vector.y)
	var nearest_direction: int = roundi(-angle_from_screen_down / (PI / 4.0))
	set_direction(posmod(nearest_direction, DIRECTION_COUNT))

func get_muzzle_position_local() -> Vector2:
	return base_sprite_position + muzzle_offsets[clampi(direction_index, 0, muzzle_offsets.size() - 1)] * sprite_scale

func play_shot(target_global_position: Vector2) -> void:
	if not use_new_soldier_visual or use_legacy_tracer: return
	var muzzle_local: Vector2 = get_muzzle_position_local()
	var target_local: Vector2 = to_local(target_global_position)
	_apply_shot_layers()
	_play_tracer(muzzle_local, target_local)
	_play_muzzle_flash(muzzle_local)
	_play_recoil()
	_play_impact_sparks(target_local)

func set_debug_muzzle_points(enabled: bool) -> void:
	debug_muzzle_points = enabled
	queue_redraw()

func _build_effect_pool() -> void:
	tracer = Line2D.new()
	tracer.name = "Tracer"
	tracer.z_index = 12
	tracer.width = 2.2
	tracer.antialiased = true
	var gradient: Gradient = Gradient.new()
	gradient.colors = PackedColorArray([tracer_head_color, tracer_tail_color])
	tracer.gradient = gradient
	var tracer_material: CanvasItemMaterial = CanvasItemMaterial.new()
	tracer_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	tracer.material = tracer_material
	tracer.visible = false
	add_child(tracer)
	muzzle_flash = Sprite2D.new()
	muzzle_flash.name = "MuzzleFlash"
	muzzle_flash.z_index = 13
	muzzle_flash.texture = _make_flash_texture()
	muzzle_flash.scale = Vector2.ONE * muzzle_flash_size_px / 32.0
	muzzle_flash.visible = false
	var flash_material: CanvasItemMaterial = CanvasItemMaterial.new()
	flash_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	muzzle_flash.material = flash_material
	add_child(muzzle_flash)
	for index: int in range(6):
		var spark: Polygon2D = Polygon2D.new()
		spark.name = "ImpactSpark%d" % index
		spark.polygon = PackedVector2Array([Vector2(-1.2, 0.0), Vector2(0.0, -2.5), Vector2(1.2, 0.0), Vector2(0.0, 2.5)])
		spark.color = spark_color
		spark.z_index = 13
		spark.visible = false
		var spark_material: CanvasItemMaterial = CanvasItemMaterial.new()
		spark_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		spark.material = spark_material
		add_child(spark)
		sparks.append(spark)

func _make_flash_texture() -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.colors = PackedColorArray([muzzle_flash_center_color, muzzle_flash_edge_color])
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 32
	texture.height = 32
	return texture

func _apply_shot_layers() -> void:
	if not is_instance_valid(tracer) or not is_instance_valid(muzzle_flash):
		return
	var draw_behind_soldier: bool = behind_directions.has(direction_index)
	# z=0 is above the tower pad (-2) and shadow (-3), but below Sprite (z=1).
	tracer.z_index = 0 if draw_behind_soldier else 12
	muzzle_flash.z_index = 0 if draw_behind_soldier else 13
	# Impact sparks are always a foreground effect.
	for spark: Polygon2D in sparks:
		spark.z_index = 13

func _play_tracer(muzzle_local: Vector2, target_local: Vector2) -> void:
	var travel: Vector2 = target_local - muzzle_local
	var distance: float = travel.length()
	if distance <= 0.1: return
	var direction: Vector2 = travel / distance
	var duration: float = clampf(distance / tracer_speed_px_per_s, tracer_min_duration, tracer_max_duration)
	tracer.points = PackedVector2Array([muzzle_local, muzzle_local])
	tracer.visible = true
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_method(_update_tracer.bind(muzzle_local, target_local, direction), 0.0, 1.0, duration)
	tween.tween_callback(_hide_tracer)

func _update_tracer(progress: float, muzzle_local: Vector2, target_local: Vector2, direction: Vector2) -> void:
	var head: Vector2 = muzzle_local.lerp(target_local, progress)
	tracer.points = PackedVector2Array([head - direction * tracer_length_px, head])

func _hide_tracer() -> void: tracer.visible = false

func _play_muzzle_flash(muzzle_local: Vector2) -> void:
	muzzle_flash.position = muzzle_local
	muzzle_flash.visible = true
	muzzle_flash.scale = Vector2.ONE * muzzle_flash_size_px / 32.0
	muzzle_flash.modulate = Color.WHITE
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(muzzle_flash, "scale", Vector2.ONE * muzzle_flash_size_px * 1.4 / 32.0, muzzle_flash_duration)
	tween.tween_property(muzzle_flash, "modulate:a", 0.0, muzzle_flash_duration)
	tween.chain().tween_callback(_hide_muzzle_flash)

func _hide_muzzle_flash() -> void:
	muzzle_flash.visible = false
	muzzle_flash.modulate = Color.WHITE

func _play_recoil() -> void:
	if recoil_tween != null and recoil_tween.is_running(): recoil_tween.kill()
	sprite.position = base_sprite_position
	var recoil_position: Vector2 = base_sprite_position - _direction_vector() * recoil_px
	recoil_tween = create_tween()
	recoil_tween.tween_property(sprite, "position", recoil_position, recoil_out_duration)
	recoil_tween.tween_property(sprite, "position", base_sprite_position, recoil_return_duration)

func _play_impact_sparks(target_local: Vector2) -> void:
	var count: int = mini(spark_count, sparks.size())
	for index: int in range(count):
		var spark: Polygon2D = sparks[index]
		spark.position = target_local
		spark.modulate = Color.WHITE
		spark.visible = true
		var angle: float = TAU * float(index) / float(maxi(count, 1)) + randf_range(-0.3, 0.3)
		var destination: Vector2 = target_local + Vector2.from_angle(angle) * randf_range(spark_min_distance, spark_max_distance)
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(spark, "position", destination, spark_lifetime)
		tween.tween_property(spark, "modulate:a", 0.0, spark_lifetime)
		tween.chain().tween_callback(_hide_spark.bind(spark))

func _hide_spark(spark: Polygon2D) -> void:
	spark.visible = false
	spark.modulate = Color.WHITE

func _direction_vector() -> Vector2:
	return [Vector2(0.0, 1.0), Vector2(-0.707, 0.707), Vector2(-1.0, 0.0), Vector2(-0.707, -0.707), Vector2(0.0, -1.0), Vector2(0.707, -0.707), Vector2(1.0, 0.0), Vector2(0.707, 0.707)][direction_index]

func _draw() -> void:
	if Engine.is_editor_hint() or debug_muzzle_points:
		draw_circle(get_muzzle_position_local(), 2.5, Color(1.0, 0.05, 0.05, 1.0))
