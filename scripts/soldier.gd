@tool
class_name Soldier
extends Node2D

const DIRECTION_COUNT: int = 8

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

@export_group("Листовой солдат")
## Включает солдата из листов студии (покой, выстрел, смерть кодом). Если листов нет в
## res://assets/sprites/units/soldiers/, солдат не рисуется.
@export var use_sheet_soldier: bool = true:
	set(value):
		use_sheet_soldier = value
		if is_node_ready() and not Engine.is_editor_hint():
			_apply_sheet_flag()

@export_group("Трассер")
## Включает новый визуал солдата (трассер, вспышка, отдача из листов).
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

@onready var shadow: Sprite2D = $Shadow
var tracer: Line2D
var sparks: Array[Polygon2D] = []
## Листовой солдат; null, пока не создан или если листов нет.
var sheet_visual: SoldierSheetVisual
## Листы не найдены: больше не пытаемся создавать визуал и не спамим предупреждениями.
static var sheet_assets_missing: bool = false

func _ready() -> void:
	set_visual_scale(sprite_scale)
	_apply_sheet_flag()
	set_direction(direction_index)
	if not Engine.is_editor_hint():
		_build_effect_pool()
	queue_redraw()

func is_sheet_active() -> bool:
	return use_sheet_soldier and is_instance_valid(sheet_visual) and sheet_visual.available and sheet_visual.visible

## Создаёт листовой визуал при включённом флаге; без листов солдат не рисуется.
func _apply_sheet_flag() -> void:
	if use_sheet_soldier and not is_instance_valid(sheet_visual) and not sheet_assets_missing:
		var created: SoldierSheetVisual = SoldierSheetVisual.new()
		created.name = "SheetVisual"
		add_child(created)
		if created.available:
			sheet_visual = created
		else:
			sheet_assets_missing = true
			created.queue_free()
	if is_instance_valid(sheet_visual):
		var enabled: bool = use_sheet_soldier and sheet_visual.available
		sheet_visual.visible = enabled
		sheet_visual.set_process(enabled)
		if enabled:
			sheet_visual.set_unit_scale(sprite_scale)
			sheet_visual.set_direction(direction_index)
	queue_redraw()

## Вспышка попадания по солдату (только листовой визуал).
func on_hit() -> void:
	if is_sheet_active():
		sheet_visual.on_hit()

## Смерть кодом: эффект создаётся в parent (обычно в родителе башни), после чего башню можно удалять.
func spawn_death_fx(parent: Node) -> void:
	if is_sheet_active():
		sheet_visual.spawn_death_fx(parent)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_refresh_direction_visual()
		queue_redraw()

func set_visual_scale(value: float) -> void:
	if sprite_scale != value:
		sprite_scale = value
	if is_instance_valid(sheet_visual): sheet_visual.set_unit_scale(sprite_scale)
	if is_instance_valid(shadow):
		shadow.scale = Vector2(sprite_scale * 0.45, sprite_scale * 0.14)
		shadow.modulate = Color(0.18, 0.05, 0.025, 1.0)

func set_direction(index: int) -> void:
	direction_index = posmod(index, DIRECTION_COUNT)
	_refresh_direction_visual()

func _refresh_direction_visual() -> void:
	if is_sheet_active():
		sheet_visual.set_direction(direction_index)
	queue_redraw()

func face_screen_vector(screen_vector: Vector2) -> void:
	if screen_vector.length_squared() <= 0.0001: return
	var angle_from_screen_down: float = atan2(screen_vector.x, screen_vector.y)
	var nearest_direction: int = roundi(-angle_from_screen_down / (PI / 4.0))
	set_direction(posmod(nearest_direction, DIRECTION_COUNT))

func get_muzzle_position_local() -> Vector2:
	if is_sheet_active():
		return sheet_visual.get_muzzle_local()
	return Vector2.ZERO

func play_shot(target_global_position: Vector2) -> void:
	if not use_new_soldier_visual or use_legacy_tracer: return
	var muzzle_local: Vector2 = get_muzzle_position_local()
	var target_local: Vector2 = to_local(target_global_position)
	_apply_shot_layers()
	_play_tracer(muzzle_local, target_local)
	if is_sheet_active():
		# Отдача запечена в кадрах выстрела, вспышку рисует листовой визуал по формулам студии.
		sheet_visual.play_shot()
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

func _apply_shot_layers() -> void:
	if not is_instance_valid(tracer):
		return
	var draw_behind_soldier: bool = is_sheet_active() and sheet_visual.is_behind()
	# z=0 is above the tower pad (-2) and shadow (-3), but below the soldier body (z=1).
	tracer.z_index = 0 if draw_behind_soldier else 12
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

func _draw() -> void:
	if Engine.is_editor_hint() or debug_muzzle_points:
		draw_circle(get_muzzle_position_local(), 2.5, Color(1.0, 0.05, 0.05, 1.0))
