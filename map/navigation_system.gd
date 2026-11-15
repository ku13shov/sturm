class_name NavigationSystem
extends RefCounted

const MapGridType = preload("res://map/map_grid.gd")

const DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
]

var grid: RefCounted

func _init(map_grid: RefCounted) -> void:
	grid = map_grid

func get_neighbours(cell: Vector2i) -> Array[Vector2i]:
	var neighbours: Array[Vector2i] = []
	for direction: Vector2i in DIRECTIONS:
		var candidate: Vector2i = cell + direction
		if not grid.is_walkable(candidate):
			continue
		if direction.x != 0 and direction.y != 0:
			if not grid.is_walkable(cell + Vector2i(direction.x, 0)) or not grid.is_walkable(cell + Vector2i(0, direction.y)):
				continue
		neighbours.append(candidate)
	return neighbours

func is_walkable(cell: Vector2i) -> bool:
	return grid.is_walkable(cell)

func find_path(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	if not grid.is_valid_cell(start) or not grid.is_valid_cell(goal):
		return path
	if start == goal:
		path.append(start)
		return path
	# Очередь с указателем вместо pop_front: pop_front у массива O(n), а поиск запускается для каждого жука.
	var frontier: Array[Vector2i] = [start]
	var head: int = 0
	var came_from: Dictionary = {start: start}
	while head < frontier.size():
		var current: Vector2i = frontier[head]
		head += 1
		if current == goal:
			break
		for next_cell: Vector2i in get_neighbours(current):
			if not came_from.has(next_cell):
				came_from[next_cell] = current
				frontier.append(next_cell)
	if not came_from.has(goal):
		return path
	var cursor: Vector2i = goal
	while cursor != start:
		path.push_front(cursor)
		cursor = came_from[cursor] as Vector2i
	path.push_front(start)
	return path

## Есть ли прямая видимость между клетками: все клетки линии Брезенхема проходимы (стартовая не проверяется).
## Диагональный шаг между двумя заблокированными клетками считается преградой (угол срезать нельзя),
## так же, как в get_neighbours.
func has_line_of_sight(from_cell: Vector2i, to_cell: Vector2i) -> bool:
	var x: int = from_cell.x
	var y: int = from_cell.y
	var delta_x: int = absi(to_cell.x - x)
	var delta_y: int = absi(to_cell.y - y)
	var step_x: int = 1 if x < to_cell.x else -1
	var step_y: int = 1 if y < to_cell.y else -1
	var error: int = delta_x - delta_y
	while x != to_cell.x or y != to_cell.y:
		var previous: Vector2i = Vector2i(x, y)
		var doubled: int = 2 * error
		var moved_x: bool = false
		var moved_y: bool = false
		if doubled > -delta_y:
			error -= delta_y
			x += step_x
			moved_x = true
		if doubled < delta_x:
			error += delta_x
			y += step_y
			moved_y = true
		if moved_x and moved_y:
			if not grid.is_walkable(previous + Vector2i(step_x, 0)) or not grid.is_walkable(previous + Vector2i(0, step_y)):
				return false
		if not grid.is_walkable(Vector2i(x, y)):
			return false
	return true

## Ближайшая проходимая клетка к заданной (поиск кольцами до max_radius клеток).
## На найденном кольце выбирается клетка, ближайшая к prefer (обычно клетка жука), то есть с его стороны.
## Если проходимых клеток рядом нет, возвращает Vector2i(-1, -1).
func nearest_walkable_cell(cell: Vector2i, max_radius: int, prefer: Vector2i) -> Vector2i:
	if grid.is_walkable(cell):
		return cell
	for radius: int in range(1, max_radius + 1):
		var best: Vector2i = Vector2i(-1, -1)
		var best_distance: float = INF
		for offset_y: int in range(-radius, radius + 1):
			for offset_x: int in range(-radius, radius + 1):
				if maxi(absi(offset_x), absi(offset_y)) != radius:
					continue
				var candidate: Vector2i = cell + Vector2i(offset_x, offset_y)
				if not grid.is_walkable(candidate):
					continue
				var distance: float = Vector2(candidate - prefer).length_squared()
				if distance < best_distance:
					best_distance = distance
					best = candidate
		if best != Vector2i(-1, -1):
			return best
	return Vector2i(-1, -1)
