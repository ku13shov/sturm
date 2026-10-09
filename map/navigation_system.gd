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
	var frontier: Array[Vector2i] = [start]
	var came_from: Dictionary = {start: start}
	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
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
