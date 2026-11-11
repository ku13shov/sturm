@tool
class_name SoldiersTower
extends Node2D

const SCALE_VARIATIONS: Array[float] = [0.97, 1.0, 1.03, 0.985]
const GRID_CELL_SIZE: float = preload("res://map/map_grid.gd").CELL_SIZE
const PAD_TOP_FACE_WIDTH_PX: float = 382.0
const PAD_PIVOT: Vector2 = Vector2(192.0, 109.0)
const PAD_MARKS: Array[Vector2] = [Vector2(192.0, 46.0), Vector2(288.0, 104.0), Vector2(94.0, 105.0), Vector2(192.0, 166.0)]

# The playable 1x1 tower cell is rendered as this screen-space diamond.
@export var cell_diamond_width_px: float = GRID_CELL_SIZE * 3.0
@export var cell_diamond_height_px: float = GRID_CELL_SIZE * 1.5
@export_range(0.8, 1.2, 0.01) var pad_top_width_fraction_of_cell: float = 1.0
@export_range(0.5, 1.0, 0.01) var pad_y_scale_ratio: float = 0.88
@export var soldier_visual_height_px: float = 40.0
## Сдвиг всех солдат вниз (к зрителю) относительно кружков на плите, в px мира. 0 = ровно по центру кружков.
@export_range(-6.0, 6.0, 0.25) var soldier_foot_offset_px: float = 2.0
@export_range(0.5, 1.5, 0.01) var ground_shadow_width_fraction_of_pad: float = 1.15
@export var use_new_soldier_visual: bool = true
## Включает листового солдата нового образца (покой, выстрел, смерть кодом). Без листов в
## res://assets/sprites/units/soldiers/ автоматически остаётся старый солдат.
@export var use_sheet_soldier: bool = true
## Анимации тумбы: мигающие полоски, посадка при постройке, разрушение на осколки с пылью.
@export var use_pad_fx: bool = true
## На каком уровне апгрейда (upgrade_level башни) показываются барьеры: 1 = второй уровень. На 0 и 2 их нет.
@export_range(0, 2) var barrier_upgrade_level: int = 1
## С какого уровня апгрейда солдаты получают акцентный цвет (1 = второй уровень и выше).
@export_range(0, 2) var upgrade_style_min_level: int = 1
## Цвет свечения деталей, вспышки, трассера и искр на улучшенной башне (на базовой голубой).
@export var upgrade_accent_color: Color = Color(1.0, 0.6, 0.12)
## Во сколько раз вспышка выстрела крупнее базовой на улучшенной башне.
@export_range(1.0, 2.0, 0.05) var upgrade_flash_multiplier: float = 1.25
## С какого уровня апгрейда вместо тумбы с солдатами стоит бункер: 2 = третий уровень.
@export_range(0, 4) var bunker_upgrade_level: int = 2
@export var debug_cell_diamond: bool = false
@export var debug_muzzle_points: bool = false
@export_range(0.0, 0.08, 0.005) var soldier_shot_delay_max: float = 0.08

var soldiers: Array[Soldier] = []
var pad_fx: SoldierPadFx
var bunker: BunkerTower
var _health_ratio: float = 1.0
@onready var pad: SoldierPad = $Pad
@onready var ground_shadow: GroundShadow = $GroundShadow

func _ready() -> void:
	var pad_scale_x: float = cell_diamond_width_px * pad_top_width_fraction_of_cell / PAD_TOP_FACE_WIDTH_PX
	if not Engine.is_editor_hint():
		pad.scale = Vector2(pad_scale_x, pad_scale_x * pad_y_scale_ratio)
	pad.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if not Engine.is_editor_hint():
		ground_shadow.visible = use_new_soldier_visual
		ground_shadow.set_shadow_width(cell_diamond_width_px * pad_top_width_fraction_of_cell * ground_shadow_width_fraction_of_pad)
		ground_shadow.position.y += ground_shadow.base_drop_px * pad_y_scale_ratio
	y_sort_enabled = true
	for child: Node in get_children():
		if child is Soldier:
			soldiers.append(child as Soldier)
	var pad_scale: Vector2 = pad.scale
	var offsets: Array[Vector2] = []
	for mark: Vector2 in PAD_MARKS:
		offsets.append((mark - PAD_PIVOT) * pad_scale + Vector2(0.0, soldier_foot_offset_px))
	var base_sprite_scale: float = soldier_visual_height_px / 150.0
	for index: int in soldiers.size():
		var soldier: Soldier = soldiers[index]
		if not Engine.is_editor_hint():
			soldier.position = offsets[index]
		if not Engine.is_editor_hint():
			soldier.set_visual_scale(base_sprite_scale * SCALE_VARIATIONS[index])
			soldier.use_new_soldier_visual = use_new_soldier_visual
			soldier.use_sheet_soldier = use_sheet_soldier
			soldier.set_debug_muzzle_points(debug_muzzle_points)
	if not Engine.is_editor_hint():
		call_deferred("_ready_screen_report")
	queue_redraw()

func _bunker_active() -> bool:
	return is_instance_valid(bunker) and bunker.visible and bunker.available

func set_target(world_pos: Vector2) -> void:
	if _bunker_active():
		bunker.set_target(world_pos)
		return
	var screen_vector: Vector2 = world_pos - global_position
	for soldier: Soldier in soldiers:
		if is_instance_valid(soldier):
			soldier.face_screen_vector(screen_vector)

func play_shot(target_global_position: Vector2) -> void:
	if _bunker_active():
		bunker.play_shot(target_global_position)
		return
	if not use_new_soldier_visual:
		return
	for soldier: Soldier in soldiers:
		if is_instance_valid(soldier):
			var delay: float = randf_range(0.0, soldier_shot_delay_max)
			get_tree().create_timer(delay).timeout.connect(soldier.play_shot.bind(target_global_position), CONNECT_ONE_SHOT)

## Ремонт: общие «+» и искры рисует RepairFx на самой башне, а полоски (тумбы, барьеров или бункера) переключаются на зелёный.
func on_repair() -> void:
	if _bunker_active():
		bunker.on_repair()
		return
	pad.on_repair()

## Вспышка попадания по всем солдатам башни (листовой визуал).
func on_hit() -> void:
	if _bunker_active():
		bunker.on_hit()
		return
	pad.flash_hit()
	for soldier: Soldier in soldiers:
		if is_instance_valid(soldier):
			soldier.on_hit()

## Здоровье башни для цвета полосок тумбы: голубой, жёлтый, красный.
func set_health(current_health: float, maximum_health: float) -> void:
	if maximum_health > 0.0:
		_health_ratio = current_health / maximum_health
	if is_instance_valid(pad) and maximum_health > 0.0:
		pad.health_ratio = _health_ratio
	if is_instance_valid(bunker):
		bunker.health_ratio = _health_ratio

## Уровень апгрейда башни (0 = базовая). Барьеры тумбы показываются только на barrier_upgrade_level.
## Улучшенный вид солдат (со второго уровня апгрейда): другой оттенок свечения деталей, вспышки,
## трассера и искр, вспышка чуть крупнее. На базовом уровне остаются цвета студии.
func _apply_upgrade_style(level: int) -> void:
	var on: bool = use_new_soldier_visual and level >= upgrade_style_min_level
	for soldier: Soldier in soldiers:
		if is_instance_valid(soldier):
			soldier.set_accent(on, upgrade_accent_color, upgrade_flash_multiplier)


func set_upgrade_level(level: int, animate := true) -> void:
	if use_new_soldier_visual and level >= bunker_upgrade_level and _ensure_bunker():
		_show_bunker(animate)
		return
	_apply_upgrade_style(level)
	if is_instance_valid(pad):
		var was: bool = pad.barriers_enabled
		pad.barriers_enabled = use_new_soldier_visual and level == barrier_upgrade_level
		if animate and use_pad_fx and pad.barriers_enabled and not was:
			pad.play_barrier_appear()

## Создаёт бункер при первой необходимости. false = текстур нет, остаётся тумба с солдатами.
func _ensure_bunker() -> bool:
	if is_instance_valid(bunker):
		return bunker.available
	if not BunkerTower.assets_available():
		push_warning("SoldiersTower: нет текстур бункера, остаётся тумба с солдатами")
		return false
	bunker = BunkerTower.new()
	bunker.name = "Bunker"
	bunker.visible = false
	add_child(bunker)
	bunker.set_art_scale(pad.scale)
	bunker.set_accent(upgrade_accent_color)
	bunker.health_ratio = _health_ratio
	return bunker.available

## Тумба и солдаты уходят, бункер появляется (с анимацией падения сверху, как барьеры).
func _show_bunker(animate: bool) -> void:
	if is_instance_valid(pad):
		pad.barriers_enabled = false
		pad.visible = false
	for soldier: Soldier in soldiers:
		if is_instance_valid(soldier):
			soldier.visible = false
	var was_visible: bool = bunker.visible
	bunker.visible = true
	if animate and use_pad_fx and not was_visible:
		bunker.play_appear()

## Смерть башни: эффекты солдат создаются в parent, после чего башню можно сразу удалять.
func spawn_death_fx(parent: Node) -> void:
	if _bunker_active():
		bunker.detach_and_destroy(parent)
		return
	pad.detach_and_destroy(parent)
	for soldier: Soldier in soldiers:
		if is_instance_valid(soldier):
			soldier.spawn_death_fx(parent)

func set_debug_muzzle_points(enabled: bool) -> void:
	debug_muzzle_points = enabled
	for soldier: Soldier in soldiers:
		if is_instance_valid(soldier):
			soldier.set_debug_muzzle_points(enabled)

func _ready_screen_report() -> void:
	var canvas_transform: Transform2D = get_global_transform_with_canvas()
	var corners: Array[Vector2] = [
		canvas_transform * Vector2(-cell_diamond_width_px * 0.5, 0.0),
		canvas_transform * Vector2(0.0, -cell_diamond_height_px * 0.5),
		canvas_transform * Vector2(cell_diamond_width_px * 0.5, 0.0),
		canvas_transform * Vector2(0.0, cell_diamond_height_px * 0.5),
	]
	var screen_bounds: Rect2 = Rect2(corners[0], Vector2.ZERO)
	for corner: Vector2 in corners:
		screen_bounds = screen_bounds.expand(corner)
	print("SoldiersTower W_cell=%.2f H_cell=%.2f screen_px" % [screen_bounds.size.x, screen_bounds.size.y])

func _draw() -> void:
	if not debug_cell_diamond:
		return
	var half_width: float = cell_diamond_width_px * 0.5
	var half_height: float = cell_diamond_height_px * 0.5
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(-half_width, 0.0), Vector2(0.0, -half_height),
		Vector2(half_width, 0.0), Vector2(0.0, half_height),
		Vector2(-half_width, 0.0)
	])
	draw_polyline(points, Color(0.2, 0.95, 1.0, 0.9), 2.0, true)

func toggle_debug_cell_diamond() -> void:
	debug_cell_diamond = not debug_cell_diamond
	queue_redraw()
