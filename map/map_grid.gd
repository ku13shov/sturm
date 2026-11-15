class_name MapGrid
extends RefCounted

const WIDTH: int = 64
const HEIGHT: int = 64
const CELL_SIZE: float = 32.0

## Счётчик изменений проходимости: растёт при каждом изменении клеток (здания, скалы).
## Жуки по нему узнают, что построенный ранее путь мог устареть.
var version: int = 0

var _walkable: Array[bool] = []
var _occupied: Array[bool] = []
## Ядро скалы: нельзя ни ходить, ни строить.
var _rock_core: Array[bool] = []
## Буфер вокруг скалы (запас на ширину жука): ходить нельзя, строить можно.
var _rock_buffer: Array[bool] = []

func _init() -> void:
	_walkable.resize(WIDTH * HEIGHT)
	_occupied.resize(WIDTH * HEIGHT)
	_rock_core.resize(WIDTH * HEIGHT)
	_rock_buffer.resize(WIDTH * HEIGHT)
	for index: int in _walkable.size():
		_walkable[index] = true
		_occupied[index] = false
		_rock_core[index] = false
		_rock_buffer[index] = false

func is_valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < WIDTH and cell.y >= 0 and cell.y < HEIGHT

## Проходима ли клетка для жуков (навигация): без зданий, ядра и буфера скал.
func is_walkable(cell: Vector2i) -> bool:
	if not is_valid_cell(cell):
		return false
	var index: int = _index(cell)
	return _walkable[index] and not _occupied[index] and not _rock_core[index] and not _rock_buffer[index]

## Можно ли строить в клетке: без зданий и ядра скал. Буфер скал строить не запрещает.
func is_buildable(cell: Vector2i) -> bool:
	if not is_valid_cell(cell):
		return false
	var index: int = _index(cell)
	return _walkable[index] and not _occupied[index] and not _rock_core[index]

func is_rock_core(cell: Vector2i) -> bool:
	return is_valid_cell(cell) and _rock_core[_index(cell)]

func is_rock_buffer(cell: Vector2i) -> bool:
	return is_valid_cell(cell) and _rock_buffer[_index(cell)]

func is_occupied(cell: Vector2i) -> bool:
	return is_valid_cell(cell) and _occupied[_index(cell)]

func set_rock_core(cell: Vector2i, value: bool) -> void:
	if is_valid_cell(cell) and _rock_core[_index(cell)] != value:
		_rock_core[_index(cell)] = value
		version += 1

func set_rock_buffer(cell: Vector2i, value: bool) -> void:
	if is_valid_cell(cell) and _rock_buffer[_index(cell)] != value:
		_rock_buffer[_index(cell)] = value
		version += 1

func set_walkable(cell: Vector2i, value: bool) -> void:
	if is_valid_cell(cell) and _walkable[_index(cell)] != value:
		_walkable[_index(cell)] = value
		version += 1

func set_occupied(cell: Vector2i, value: bool) -> void:
	if is_valid_cell(cell) and _occupied[_index(cell)] != value:
		_occupied[_index(cell)] = value
		version += 1

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
