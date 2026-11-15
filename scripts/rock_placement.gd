class_name RockPlacement
extends RefCounted
## Расстановка скал (план ROCKS-1, R5). Скалы идут группами (одна большая или medium_a и 1-2 меньшие),
## плюс несколько одиночных small. Положения детерминированы сидом (ROCK_SEED).
##
## Каждая новая группа проверяется на сетке вместе с уже принятыми:
## 1. с 16 стартовых клеток по краю карты (8 направлений и четверти сторон) есть путь до базы;
## 2. длина пути (с учётом диагоналей) не больше MAX_PATH_STRETCH от длины без скал;
## 3. путь есть и на сетке, «разъеденной» на ERODE_CELLS клетки вокруг блокировок (проход не уже ~5 клеток).
## Если группа не проходит проверку, она сдвигается (до MAX_ATTEMPTS попыток), затем пропускается.
##
## Использование: RockPlacement.generate(grid, base_pos, map_half_extent) возвращает массив словарей
## {position, variant, size_jitter, flipped}, отсортированный по Y (дальние скалы рисуются раньше ближних).
## Затем для каждой созданной скалы вызвать RockPlacement.block_rock_on_grid(grid, rock.blocking_ellipse_in_world()).

const ROCK_SEED: int = 20260324
## Сколько секторов вокруг базы получают группу (из 8) и сколько одиночных small ставится дополнительно.
const GROUP_COUNT: int = 5
const SINGLE_COUNT: int = 2
const SECTOR_COUNT: int = 8

## Жёсткие правила (px).
const MIN_BASE_DISTANCE: float = 300.0
const MIN_EDGE_DISTANCE: float = 200.0
const MIN_GROUP_DISTANCE: float = 450.0
## Одиночные скалы это мелкий декор: до других групп и одиночных им достаточно меньшего расстояния.
const MIN_SINGLE_DISTANCE: float = 300.0
## Радиус центра группы от базы и сдвиг угла от прямой «край-база» (градусы).
const GROUP_RADIUS_MIN: float = 350.0
const GROUP_RADIUS_MAX: float = 650.0
const SINGLE_RADIUS_MAX: float = 800.0
const SHIFT_MIN_DEG: float = 12.0
const SHIFT_MAX_DEG: float = 20.0
const MAX_ATTEMPTS: int = 20
## Зазор между следами внутри группы и между блокирующими эллипсами разных групп (px).
const GAP_IN_GROUP: float = 32.0
const GAP_BETWEEN_GROUPS: float = 96.0
## Допустимое удлинение пути и радиус «разъедания» (клетки).
const MAX_PATH_STRETCH: float = 1.10
const ERODE_CELLS: int = 2
## Отступ точки спавна за краем карты (как SPAWN_MARGIN в graybox_vertical_slice.gd).
const SPAWN_MARGIN: float = 48.0

## Блокировка клеток скалой: ядро (нельзя ходить и строить) и буфер (нельзя ходить, строить можно).
## Минимальная доля клетки внутри блокирующего эллипса, чтобы клетка стала ядром.
const CORE_MIN_COVERAGE: float = 0.25
## Ширина буфера вокруг ядра (запас на ширину жука).
const BUFFER_WIDTH: float = 32.0
## Сетка точек n x n внутри клетки для оценки доли покрытия эллипсом.
const COVERAGE_SAMPLES: int = 4

## Направления 8 сторон (в том же порядке, что DEBUG_SPAWN_DIRECTIONS в graybox_vertical_slice.gd).
const SECTOR_DIRECTIONS: Array[Vector2] = [
	Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1),
	Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1),
]

const UNREACHED: int = 1 << 30
const STEP_STRAIGHT: int = 10
const STEP_DIAGONAL: int = 14
const NEIGHBOR_DX: Array[int] = [1, -1, 0, 0, 1, 1, -1, -1]
const NEIGHBOR_DY: Array[int] = [0, 0, 1, -1, 1, -1, 1, -1]

var _grid: MapGrid
var _base_position: Vector2 = Vector2.ZERO
var _map_half_extent: Vector2 = Vector2.ZERO
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _cell_count: int = 0
## Заблокированные клетки (ядро, буфер и то, что уже было блокировано в сетке), принятые скалы.
var _blocked: PackedByteArray = PackedByteArray()
## То же, расширенное на ERODE_CELLS клеток.
var _eroded: PackedByteArray = PackedByteArray()
var _goal: int = 0
var _starts: PackedInt32Array = PackedInt32Array()
var _baseline: PackedInt32Array = PackedInt32Array()
var _rocks: Array[Dictionary] = []
var _group_centers: Array[Vector2] = []
## Сколько раз кандидат отвергался и по какой причине (для настройки и отчёта).
var _rejections: Dictionary = {}


func _reject(reason: String) -> bool:
	_rejections[reason] = int(_rejections.get(reason, 0)) + 1
	return false


## Строит расстановку. grid нужен как источник начальной блокировки (обычно пустая сетка).
## map_half_extent: половина размера карты (центр карты в нуле). report, если передан, заполняется
## статистикой: groups (по секторам: попытки и результат), singles, rocks, ms.
static func generate(
	grid: MapGrid,
	base_pos: Vector2,
	map_half_extent: Vector2,
	seed_value: int = ROCK_SEED,
	report: Dictionary = {}
) -> Array[Dictionary]:
	var placement: RockPlacement = RockPlacement.new()
	return placement._run(grid, base_pos, map_half_extent, seed_value, report)


## Клетки, которые блокирует скала с данным блокирующим эллипсом.
## Возвращает {"core": PackedInt32Array, "buffer": PackedInt32Array} (плоские индексы клеток).
static func rock_cells(blocking_ellipse: Dictionary) -> Dictionary:
	var center: Vector2 = blocking_ellipse["center"] as Vector2
	var radius_x: float = float(blocking_ellipse["rx"])
	var radius_y: float = float(blocking_ellipse["ry"])
	var reach: Vector2 = Vector2(radius_x, radius_y) + Vector2.ONE * (BUFFER_WIDTH + MapGrid.CELL_SIZE)
	var min_cell: Vector2i = cell_from_position(center - reach)
	var max_cell: Vector2i = cell_from_position(center + reach)
	var core: PackedInt32Array = PackedInt32Array()
	var buffer: PackedInt32Array = PackedInt32Array()
	for y: int in range(maxi(min_cell.y, 0), mini(max_cell.y, MapGrid.HEIGHT - 1) + 1):
		for x: int in range(maxi(min_cell.x, 0), mini(max_cell.x, MapGrid.WIDTH - 1) + 1):
			var cell_center_position: Vector2 = cell_center(Vector2i(x, y))
			if ellipse_cell_coverage(center, radius_x, radius_y, cell_center_position) >= CORE_MIN_COVERAGE:
				core.append(y * MapGrid.WIDTH + x)
			elif ellipse_cell_coverage(center, radius_x + BUFFER_WIDTH, radius_y + BUFFER_WIDTH, cell_center_position) > 0.0:
				buffer.append(y * MapGrid.WIDTH + x)
	return {"core": core, "buffer": buffer}


## Применяет блокировку скалы к сетке игры (ядро и буфер).
static func block_rock_on_grid(target_grid: MapGrid, blocking_ellipse: Dictionary) -> void:
	var cells: Dictionary = rock_cells(blocking_ellipse)
	for index: int in cells["core"] as PackedInt32Array:
		target_grid.set_rock_core(cell_of_index(index), true)
	for index: int in cells["buffer"] as PackedInt32Array:
		target_grid.set_rock_buffer(cell_of_index(index), true)


## Доля клетки (0..1), попадающая в эллипс: по сетке точек внутри клетки.
static func ellipse_cell_coverage(center: Vector2, radius_x: float, radius_y: float, cell_center_position: Vector2) -> float:
	var inside: int = 0
	var total: int = COVERAGE_SAMPLES * COVERAGE_SAMPLES
	for sample_y: int in COVERAGE_SAMPLES:
		for sample_x: int in COVERAGE_SAMPLES:
			var offset: Vector2 = Vector2(
				(float(sample_x) + 0.5) / float(COVERAGE_SAMPLES) - 0.5,
				(float(sample_y) + 0.5) / float(COVERAGE_SAMPLES) - 0.5
			) * MapGrid.CELL_SIZE
			var delta: Vector2 = cell_center_position + offset - center
			if (delta.x * delta.x) / (radius_x * radius_x) + (delta.y * delta.y) / (radius_y * radius_y) <= 1.0:
				inside += 1
	return float(inside) / float(total)


static func cell_from_position(world_position: Vector2) -> Vector2i:
	var origin: Vector2 = Vector2(float(MapGrid.WIDTH), float(MapGrid.HEIGHT)) * MapGrid.CELL_SIZE * -0.5
	return Vector2i(
		floori((world_position.x - origin.x) / MapGrid.CELL_SIZE),
		floori((world_position.y - origin.y) / MapGrid.CELL_SIZE)
	)


static func cell_center(cell: Vector2i) -> Vector2:
	var origin: Vector2 = Vector2(float(MapGrid.WIDTH), float(MapGrid.HEIGHT)) * MapGrid.CELL_SIZE * -0.5
	return origin + Vector2(cell) * MapGrid.CELL_SIZE + Vector2.ONE * MapGrid.CELL_SIZE * 0.5


@warning_ignore("integer_division")
static func cell_of_index(index: int) -> Vector2i:
	return Vector2i(index % MapGrid.WIDTH, index / MapGrid.WIDTH)


## Клетка старта жука, как в _path_to_base: позиция за краем карты прижимается к ближайшей клетке на краю.
static func start_cell_for(world_position: Vector2) -> Vector2i:
	var cell: Vector2i = cell_from_position(world_position)
	return Vector2i(clampi(cell.x, 0, MapGrid.WIDTH - 1), clampi(cell.y, 0, MapGrid.HEIGHT - 1))


func _run(grid: MapGrid, base_pos: Vector2, map_half_extent: Vector2, seed_value: int, report: Dictionary) -> Array[Dictionary]:
	var started_ms: int = Time.get_ticks_msec()
	_grid = grid
	_base_position = base_pos
	_map_half_extent = map_half_extent
	_rng.seed = seed_value
	_setup()
	var sectors: Array[int] = []
	for sector: int in SECTOR_COUNT:
		sectors.append(sector)
	_shuffle(sectors)
	# Первые GROUP_COUNT секторов получают группы. Три подряд идущих сектора с группами не допускаются:
	# средняя группа оказалась бы зажата соседями, и 450 px до обеих недостижимы. Тогда перемешиваем заново.
	for _reshuffle: int in 50:
		if not _has_consecutive_run(sectors, GROUP_COUNT, 3):
			break
		_shuffle(sectors)
	var group_reports: Array[Dictionary] = []
	for group_index: int in GROUP_COUNT:
		group_reports.append(_place_group(sectors[group_index], false))
	var single_reports: Array[Dictionary] = []
	for single_index: int in SINGLE_COUNT:
		# Одиночные скалы идут в секторы без групп (в перемешанном порядке это следующие за группами).
		single_reports.append(_place_group(sectors[(GROUP_COUNT + single_index) % SECTOR_COUNT], true))
	_rocks.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float((a["foot"] as Dictionary)["center"].y) < float((b["foot"] as Dictionary)["center"].y)
	)
	var result: Array[Dictionary] = []
	for rock: Dictionary in _rocks:
		result.append({
			"position": rock["position"],
			"variant": rock["variant"],
			"size_jitter": rock["size_jitter"],
			"flipped": rock["flipped"],
		})
	report["groups"] = group_reports
	report["singles"] = single_reports
	report["rocks"] = result.size()
	report["rejections"] = _rejections
	report["ms"] = Time.get_ticks_msec() - started_ms
	return result


func _setup() -> void:
	_cell_count = MapGrid.WIDTH * MapGrid.HEIGHT
	_blocked.resize(_cell_count)
	_blocked.fill(0)
	_eroded.resize(_cell_count)
	_eroded.fill(0)
	var initial_blocked: PackedInt32Array = PackedInt32Array()
	for y: int in MapGrid.HEIGHT:
		for x: int in MapGrid.WIDTH:
			if not _grid.is_walkable(Vector2i(x, y)):
				_blocked[y * MapGrid.WIDTH + x] = 1
				initial_blocked.append(y * MapGrid.WIDTH + x)
	_dilate(_eroded, initial_blocked)
	var goal_cell: Vector2i = cell_from_position(_base_position) + Vector2i(-1, 0)
	_goal = goal_cell.y * MapGrid.WIDTH + goal_cell.x
	_starts = _build_start_cells()
	var baseline_costs: PackedInt32Array = _costs(_blocked)
	_baseline.resize(_starts.size())
	for index: int in _starts.size():
		_baseline[index] = baseline_costs[_starts[index]]


## 16 стартов по краю: 8 направлений (как у фиксированного спавна) и четверти каждой стороны.
func _build_start_cells() -> PackedInt32Array:
	var half: Vector2 = Vector2(float(MapGrid.WIDTH), float(MapGrid.HEIGHT)) * MapGrid.CELL_SIZE * 0.5 + Vector2.ONE * SPAWN_MARGIN
	var positions: Array[Vector2] = []
	for direction: Vector2 in SECTOR_DIRECTIONS:
		positions.append(direction * half)
	for sign_value: float in [-0.5, 0.5]:
		positions.append(Vector2(sign_value * half.x, -half.y))
		positions.append(Vector2(sign_value * half.x, half.y))
		positions.append(Vector2(-half.x, sign_value * half.y))
		positions.append(Vector2(half.x, sign_value * half.y))
	var starts: PackedInt32Array = PackedInt32Array()
	for position_value: Vector2 in positions:
		var cell: Vector2i = start_cell_for(position_value)
		starts.append(cell.y * MapGrid.WIDTH + cell.x)
	return starts


## Есть ли среди первых chosen_count секторов run_length подряд идущих (по кругу, 7 и 0 соседние).
static func _has_consecutive_run(sectors: Array[int], chosen_count: int, run_length: int) -> bool:
	var chosen: Array[bool] = []
	chosen.resize(SECTOR_COUNT)
	chosen.fill(false)
	for index: int in chosen_count:
		chosen[sectors[index]] = true
	for start: int in SECTOR_COUNT:
		var run: int = 0
		for offset: int in run_length:
			if chosen[(start + offset) % SECTOR_COUNT]:
				run += 1
		if run == run_length:
			return true
	return false


func _shuffle(values: Array[int]) -> void:
	for index: int in range(values.size() - 1, 0, -1):
		var other: int = _rng.randi_range(0, index)
		var temp: int = values[index]
		values[index] = values[other]
		values[other] = temp


## Пытается поставить группу (или одиночную small) в секторе. Возвращает {sector, attempts, placed, rocks, single}.
func _place_group(sector: int, single: bool) -> Dictionary:
	var info: Dictionary = {"sector": sector, "attempts": 0, "placed": false, "rocks": 0, "single": single}
	for attempt: int in MAX_ATTEMPTS:
		info["attempts"] = attempt + 1
		var candidate: Array[Dictionary] = _build_single_candidate(sector, attempt) if single else _build_group_candidate(sector, attempt)
		if candidate.is_empty():
			continue
		if _accept(candidate, MIN_SINGLE_DISTANCE if single else MIN_GROUP_DISTANCE):
			info["placed"] = true
			info["rocks"] = candidate.size()
			break
	return info


## Диапазон радиуса для попытки. Соседние сектора по умолчанию разводятся по радиусу: чётные сектора ближе к базе,
## нечётные дальше (иначе центры соседних групп оказываются ближе MIN_GROUP_DISTANCE: при равных радиусах
## расстояние между ними примерно 0.77 радиуса). Попытки идут по кругу: своя зона, противоположная зона, весь диапазон.
static func _radius_range(attempt: int, sector: int, radius_min: float, radius_max: float) -> Vector2:
	var band: float = (radius_max - radius_min) * 0.25
	var inner: Vector2 = Vector2(radius_min, radius_min + band)
	var outer: Vector2 = Vector2(radius_max - band, radius_max)
	var prefer_inner: bool = sector % 2 == 0
	match attempt % 3:
		0:
			return inner if prefer_inner else outer
		1:
			return outer if prefer_inner else inner
	return Vector2(radius_min, radius_max)


func _build_single_candidate(sector: int, attempt: int) -> Array[Dictionary]:
	var range_value: Vector2 = _radius_range(attempt, sector, GROUP_RADIUS_MIN, SINGLE_RADIUS_MAX)
	var center: Vector2 = _sector_point(sector, range_value.x, range_value.y)
	var rock: Dictionary = _make_rock(3, _rng.randf_range(0.92, 1.08), center, _rng.randf() > 0.5)
	if not _fits_hard_rules(rock):
		return []
	return [rock]


## Группа: главная скала (large или medium_a) и 1-2 меньшие рядом. Пустой массив, если собрать не удалось.
func _build_group_candidate(sector: int, attempt: int) -> Array[Dictionary]:
	var range_value: Vector2 = _radius_range(attempt, sector, GROUP_RADIUS_MIN, GROUP_RADIUS_MAX)
	var center: Vector2 = _sector_point(sector, range_value.x, range_value.y)
	var main_variant: int = 0 if _rng.randf() < 0.5 else 1
	var main: Dictionary = _make_rock(main_variant, _rng.randf_range(0.92, 1.08), center, _rng.randf() > 0.5)
	if not _fits_hard_rules(main):
		return []
	var group: Array[Dictionary] = [main]
	var companion_count: int = _rng.randi_range(1, 2)
	var side: float = 1.0 if _rng.randf() < 0.5 else -1.0
	for companion_index: int in companion_count:
		var placed: bool = false
		for _try: int in 12:
			var variant: int = _rng.randi_range(main_variant + 1, RockFormation.VARIANTS.size() - 1)
			var jitter: float = _rng.randf_range(0.92, 1.08)
			var angle: float = deg_to_rad(_rng.randf_range(-60.0, 60.0))
			var direction: Vector2 = Vector2(side * cos(angle), sin(angle))
			var half_sum: float = (
				RockFormation.world_width_for(main_variant, float(main["size_jitter"]))
				+ RockFormation.world_width_for(variant, jitter)
			) * 0.5
			var distance: float = _rng.randf_range(0.7, 0.9) * half_sum
			var limit: float = distance * 1.8
			var companion: Dictionary = {}
			while distance <= limit:
				companion = _make_rock(variant, jitter, center + direction * distance, _rng.randf() > 0.5)
				if _gap_to_group(companion, group) >= GAP_IN_GROUP:
					break
				companion = {}
				distance += 4.0
			if companion.is_empty() or not _fits_hard_rules(companion):
				continue
			group.append(companion)
			placed = true
			break
		# Следующая скала идёт на другую сторону от главной, чтобы группа не была «колбасой» в одну сторону.
		side = -side
		if not placed:
			continue
	if group.size() < 2:
		_reject("не нашлось места для меньшей скалы")
		return []
	return group


func _sector_point(sector: int, radius_min: float, radius_max: float) -> Vector2:
	var half: Vector2 = Vector2(float(MapGrid.WIDTH), float(MapGrid.HEIGHT)) * MapGrid.CELL_SIZE * 0.5 + Vector2.ONE * SPAWN_MARGIN
	var spawn: Vector2 = SECTOR_DIRECTIONS[sector] * half
	var edge_angle: float = (spawn - _base_position).angle()
	var shift: float = deg_to_rad(_rng.randf_range(SHIFT_MIN_DEG, SHIFT_MAX_DEG)) * (1.0 if _rng.randf() < 0.5 else -1.0)
	return _base_position + Vector2.from_angle(edge_angle + shift) * _rng.randf_range(radius_min, radius_max)


func _make_rock(variant: int, size_jitter: float, position_value: Vector2, flipped: bool) -> Dictionary:
	var rock_scale: float = RockFormation.scale_for(variant, size_jitter)
	var blocking: Dictionary = RockFormation.blocking_ellipse_at(variant, rock_scale, position_value)
	return {
		"position": position_value,
		"variant": variant,
		"size_jitter": size_jitter,
		"flipped": flipped,
		"foot": RockFormation.footprint_at(variant, rock_scale, position_value),
		"block": blocking,
	}


## Расстояние от базы и от краёв карты.
func _fits_hard_rules(rock: Dictionary) -> bool:
	var position_value: Vector2 = rock["position"] as Vector2
	if position_value.distance_to(_base_position) < MIN_BASE_DISTANCE:
		return _reject("близко к базе")
	if absf(position_value.x) > _map_half_extent.x - MIN_EDGE_DISTANCE:
		return _reject("у края карты")
	if absf(position_value.y) > _map_half_extent.y - MIN_EDGE_DISTANCE:
		return _reject("у края карты")
	return true


func _gap_to_group(rock: Dictionary, group: Array[Dictionary]) -> float:
	var smallest: float = INF
	for other: Dictionary in group:
		smallest = minf(smallest, _ellipse_gap(rock["foot"] as Dictionary, other["foot"] as Dictionary))
	return smallest


## Приближённый зазор между двумя эллипсами по линии, соединяющей центры.
static func _ellipse_gap(first: Dictionary, second: Dictionary) -> float:
	var first_center: Vector2 = first["center"] as Vector2
	var second_center: Vector2 = second["center"] as Vector2
	var delta: Vector2 = second_center - first_center
	var distance: float = delta.length()
	if distance < 0.001:
		return -1000.0
	var direction: Vector2 = delta / distance
	return distance - _radius_along(first, direction) - _radius_along(second, -direction)


static func _radius_along(ellipse: Dictionary, direction: Vector2) -> float:
	var radius_x: float = float(ellipse["rx"])
	var radius_y: float = float(ellipse["ry"])
	var term_x: float = direction.x / radius_x
	var term_y: float = direction.y / radius_y
	return 1.0 / sqrt(term_x * term_x + term_y * term_y)


## Проверка группы против уже принятых скал и против сетки. При успехе группа принимается.
func _accept(candidate: Array[Dictionary], min_center_distance: float) -> bool:
	var group_center: Vector2 = candidate[0]["position"] as Vector2
	for other_center: Vector2 in _group_centers:
		if group_center.distance_to(other_center) < min_center_distance:
			return _reject("близко к другой группе")
	for rock: Dictionary in candidate:
		for accepted: Dictionary in _rocks:
			if _ellipse_gap(rock["block"] as Dictionary, accepted["block"] as Dictionary) < GAP_BETWEEN_GROUPS:
				return _reject("зазор до чужой скалы")
	var blocked: PackedByteArray = _blocked.duplicate()
	var eroded: PackedByteArray = _eroded.duplicate()
	for rock: Dictionary in candidate:
		var cells: Dictionary = rock_cells(rock["block"] as Dictionary)
		rock["cells"] = cells
		for index: int in cells["core"] as PackedInt32Array:
			blocked[index] = 1
		for index: int in cells["buffer"] as PackedInt32Array:
			blocked[index] = 1
		_dilate(eroded, cells["core"] as PackedInt32Array)
		_dilate(eroded, cells["buffer"] as PackedInt32Array)
	if not _layout_is_valid(blocked, eroded):
		return false
	_blocked = blocked
	_eroded = eroded
	_group_centers.append(group_center)
	for rock: Dictionary in candidate:
		_rocks.append(rock)
	return true


func _layout_is_valid(blocked: PackedByteArray, eroded: PackedByteArray) -> bool:
	if blocked[_goal] != 0 or eroded[_goal] != 0:
		return _reject("проверка: цель закрыта")
	for start: int in _starts:
		if eroded[start] != 0:
			return _reject("проверка: старт закрыт")
	var costs: PackedInt32Array = _costs(blocked)
	for index: int in _starts.size():
		var base_cost: int = _baseline[index]
		if base_cost >= UNREACHED:
			continue
		var cost: int = costs[_starts[index]]
		if cost >= UNREACHED:
			return _reject("проверка: нет пути")
		if float(cost) > float(base_cost) * MAX_PATH_STRETCH:
			return _reject("проверка: путь длиннее на 10%")
	var reachable: PackedByteArray = _reachable(eroded)
	for start: int in _starts:
		if reachable[start] == 0:
			return _reject("проверка: проход уже 5 клеток")
	return true


## Расширяет блокировку: все клетки в радиусе ERODE_CELLS (по Чебышёву) от данных клеток.
@warning_ignore("integer_division")
func _dilate(target: PackedByteArray, indices: PackedInt32Array) -> void:
	for index: int in indices:
		var cell_x: int = index % MapGrid.WIDTH
		var cell_y: int = index / MapGrid.WIDTH
		for offset_y: int in range(-ERODE_CELLS, ERODE_CELLS + 1):
			var y: int = cell_y + offset_y
			if y < 0 or y >= MapGrid.HEIGHT:
				continue
			for offset_x: int in range(-ERODE_CELLS, ERODE_CELLS + 1):
				var x: int = cell_x + offset_x
				if x >= 0 and x < MapGrid.WIDTH:
					target[y * MapGrid.WIDTH + x] = 1


## Стоимость пути от каждой клетки до цели (прямой шаг 10, диагональ 14), те же правила соседей,
## что в NavigationSystem (диагональ нельзя, если один из боковых соседей закрыт). Недостижимо: UNREACHED.
@warning_ignore("integer_division")
func _costs(blocked: PackedByteArray) -> PackedInt32Array:
	var distances: PackedInt32Array = PackedInt32Array()
	distances.resize(_cell_count)
	distances.fill(UNREACHED)
	if blocked[_goal] != 0:
		return distances
	distances[_goal] = 0
	var buckets: Array[Array] = [[_goal]]
	var pending: int = 1
	var cost: int = 0
	while pending > 0 and cost < buckets.size():
		var bucket: Array = buckets[cost]
		for node_value: Variant in bucket:
			var node: int = node_value as int
			pending -= 1
			if distances[node] != cost:
				continue
			var cell_x: int = node % MapGrid.WIDTH
			var cell_y: int = node / MapGrid.WIDTH
			for direction: int in 8:
				var next_x: int = cell_x + NEIGHBOR_DX[direction]
				var next_y: int = cell_y + NEIGHBOR_DY[direction]
				if next_x < 0 or next_x >= MapGrid.WIDTH or next_y < 0 or next_y >= MapGrid.HEIGHT:
					continue
				var next_index: int = next_y * MapGrid.WIDTH + next_x
				if blocked[next_index] != 0:
					continue
				var step: int = STEP_STRAIGHT
				if direction >= 4:
					if blocked[cell_y * MapGrid.WIDTH + next_x] != 0 or blocked[next_y * MapGrid.WIDTH + cell_x] != 0:
						continue
					step = STEP_DIAGONAL
				var next_cost: int = cost + step
				if next_cost < distances[next_index]:
					distances[next_index] = next_cost
					while buckets.size() <= next_cost:
						buckets.append([])
					buckets[next_cost].append(next_index)
					pending += 1
		buckets[cost] = []
		cost += 1
	return distances


## Клетки, достижимые от цели (простая заливка, те же правила соседей).
@warning_ignore("integer_division")
func _reachable(blocked: PackedByteArray) -> PackedByteArray:
	var visited: PackedByteArray = PackedByteArray()
	visited.resize(_cell_count)
	visited.fill(0)
	if blocked[_goal] != 0:
		return visited
	var queue: PackedInt32Array = PackedInt32Array([_goal])
	visited[_goal] = 1
	var head: int = 0
	while head < queue.size():
		var node: int = queue[head]
		head += 1
		var cell_x: int = node % MapGrid.WIDTH
		var cell_y: int = node / MapGrid.WIDTH
		for direction: int in 8:
			var next_x: int = cell_x + NEIGHBOR_DX[direction]
			var next_y: int = cell_y + NEIGHBOR_DY[direction]
			if next_x < 0 or next_x >= MapGrid.WIDTH or next_y < 0 or next_y >= MapGrid.HEIGHT:
				continue
			var next_index: int = next_y * MapGrid.WIDTH + next_x
			if visited[next_index] != 0 or blocked[next_index] != 0:
				continue
			if direction >= 4:
				if blocked[cell_y * MapGrid.WIDTH + next_x] != 0 or blocked[next_y * MapGrid.WIDTH + cell_x] != 0:
					continue
			visited[next_index] = 1
			queue.append(next_index)
	return visited
