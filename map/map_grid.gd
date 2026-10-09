class_name MapGrid
extends RefCounted

const WIDTH: int = 64
const HEIGHT: int = 64
const CELL_SIZE: float = 32.0

var _walkable: Array[bool] = []
var _occupied: Array[bool] = []

func _init() -> void:
	_walkable.resize(WIDTH * HEIGHT)
	_occupied.resize(WIDTH * HEIGHT)
	for index: int in _walkable.size():
		_walkable[index] = true
		_occupied[index] = false

func is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < WIDTH and cell.y >= 0 and cell.y < HEIGHT

func is_walkable(cell: Vector2i) -> bool:
	if not is_valid_cell(cell):
		return false
	return _walkable[_index(cell)] and not _occupied[_index(cell)]

func set_walkable(cell: Vector2i, value: bool) -> void:
	if is_valid_cell(cell):
		_walkable[_index(cell)] = value

func set_occupied(cell: Vector2i, value: bool) -> void:
	if is_valid_cell(cell):
		_occupied[_index(cell)] = value

func grid_to_world(cell: Vector2i) -> Vector2:
	var origin_x: float = -float(WIDTH) * CELL_SIZE * 0.5 + CELL_SIZE * 0.5
	var origin_y: float = -float(HEIGHT) * CELL_SIZE * 0.5 + CELL_SIZE * 0.5
	return Vector2(origin_x + float(cell.x) * CELL_SIZE, origin_y + float(cell.y) * CELL_SIZE)

func world_to_grid(position: Vector2) -> Vector2i:
	var origin_x: float = -float(WIDTH) * CELL_SIZE * 0.5
	var origin_y: float = -float(HEIGHT) * CELL_SIZE * 0.5
	return Vector2i(floori((position.x - origin_x) / CELL_SIZE), floori((position.y - origin_y) / CELL_SIZE))

func _index(cell: Vector2i) -> int:
	return cell.y * WIDTH + cell.x
