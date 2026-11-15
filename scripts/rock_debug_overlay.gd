class_name RockDebugOverlay
extends Node2D
## Отладочная отрисовка скал для подбора следа и блокировок. Включается кнопкой в дебаг-меню.
## Рисует: блокирующий эллипс скалы (оранжевый контур), эллипс следа на земле (голубой), центр картинки скалы (жёлтая точка),
## центр следа (голубая точка) и клетки сетки: ядро скалы (красные, нельзя строить и ходить), буфер скалы (оранжевые,
## ходить нельзя, строить можно) и клетки зданий (фиолетовые). Должен быть дочерним узлом entities,
## тогда координаты совпадают с позициями скал и клетками сетки.

const REDRAW_INTERVAL: float = 0.25
const ELLIPSE_POINTS: int = 48
const CORE_CELL_COLOR: Color = Color(1.0, 0.15, 0.1, 0.30)
const BUFFER_CELL_COLOR: Color = Color(1.0, 0.6, 0.1, 0.18)
const OCCUPIED_CELL_COLOR: Color = Color(0.7, 0.2, 1.0, 0.22)
const BLOCK_LINE: Color = Color(1.0, 0.5, 0.1, 0.95)
const FOOTPRINT_FILL: Color = Color(0.2, 0.85, 1.0, 0.18)
const FOOTPRINT_LINE: Color = Color(0.2, 0.85, 1.0, 0.95)
const IMAGE_CENTER_COLOR: Color = Color(1.0, 0.9, 0.2, 0.95)

var _grid: MapGrid
var _entities: Node
var _time_left: float = 0.0


func setup(map_grid: MapGrid, entities_node: Node) -> void:
	_grid = map_grid
	_entities = entities_node
	name = "RockDebugOverlay"
	z_index = 60
	visible = false
	set_process(false)
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	set_process(visible)
	if visible:
		_time_left = 0.0
		queue_redraw()


func _process(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		_time_left = REDRAW_INTERVAL
		queue_redraw()


func _draw() -> void:
	if _grid == null or _entities == null:
		return
	_draw_blocked_cells()
	for node: Node in _entities.get_children():
		var rock: RockFormation = node as RockFormation
		if rock != null:
			_draw_rock(rock)


func _draw_blocked_cells() -> void:
	var origin: Vector2 = Vector2(-float(MapGrid.WIDTH), -float(MapGrid.HEIGHT)) * MapGrid.CELL_SIZE * 0.5
	var cell_size: Vector2 = Vector2.ONE * MapGrid.CELL_SIZE
	for y: int in MapGrid.HEIGHT:
		for x: int in MapGrid.WIDTH:
			var cell: Vector2i = Vector2i(x, y)
			var color: Color
			if _grid.is_rock_core(cell):
				color = CORE_CELL_COLOR
			elif _grid.is_rock_buffer(cell):
				color = BUFFER_CELL_COLOR
			elif not _grid.is_walkable(cell):
				color = OCCUPIED_CELL_COLOR
			else:
				continue
			draw_rect(Rect2(origin + Vector2(float(x), float(y)) * MapGrid.CELL_SIZE, cell_size), color, true)


func _ellipse_points(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in ELLIPSE_POINTS:
		var angle: float = TAU * float(index) / float(ELLIPSE_POINTS)
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points


func _draw_rock(rock: RockFormation) -> void:
	# Блокирующий эллипс (запрет строить и ходить), оранжевый.
	var block: Dictionary = rock.blocking_ellipse_in_world()
	var block_points: PackedVector2Array = _ellipse_points(block["center"] as Vector2, float(block["rx"]), float(block["ry"]))
	var block_outline: PackedVector2Array = block_points.duplicate()
	block_outline.append(block_points[0])
	draw_polyline(block_outline, BLOCK_LINE, 2.0)
	# След на земле (где скала стоит), голубой.
	var footprint: Dictionary = rock.footprint_in_world()
	var center: Vector2 = footprint["center"] as Vector2
	var points: PackedVector2Array = _ellipse_points(center, float(footprint["rx"]), float(footprint["ry"]))
	draw_colored_polygon(points, FOOTPRINT_FILL)
	var outline: PackedVector2Array = points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, FOOTPRINT_LINE, 1.5)
	draw_circle(center, 3.0, FOOTPRINT_LINE)
	draw_circle(rock.position, 4.0, IMAGE_CENTER_COLOR)
