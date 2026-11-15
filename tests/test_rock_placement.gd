extends Node

const BASE_POSITION: Vector2 = Vector2(216.0, 235.0)
const HALF_EXTENT: Vector2 = Vector2(1024.0, 1024.0)


func _generate(grid: MapGrid, seed_value: int = RockPlacement.ROCK_SEED, report: Dictionary = {}) -> Array[Dictionary]:
	return RockPlacement.generate(grid, BASE_POSITION, HALF_EXTENT, seed_value, report)


func test_same_seed_gives_same_layout() -> void:
	var first: Array[Dictionary] = _generate(MapGrid.new())
	var second: Array[Dictionary] = _generate(MapGrid.new())
	assert(first.size() == second.size())
	for index: int in first.size():
		assert((first[index]["position"] as Vector2).is_equal_approx(second[index]["position"] as Vector2))
		assert(int(first[index]["variant"]) == int(second[index]["variant"]))
		assert(bool(first[index]["flipped"]) == bool(second[index]["flipped"]))


func test_default_seed_places_groups() -> void:
	var report: Dictionary = {}
	var rocks: Array[Dictionary] = _generate(MapGrid.new(), RockPlacement.ROCK_SEED, report)
	var placed_groups: int = 0
	for info: Dictionary in report["groups"]:
		if bool(info["placed"]):
			placed_groups += 1
	assert(placed_groups >= 4)
	assert(rocks.size() >= 8)
	assert(int(report["ms"]) < 1500)


func test_hard_rules_hold_for_several_seeds() -> void:
	for seed_value: int in [RockPlacement.ROCK_SEED, 1, 2, 3, 4, 5]:
		for rock: Dictionary in _generate(MapGrid.new(), seed_value):
			var position_value: Vector2 = rock["position"] as Vector2
			assert(position_value.distance_to(BASE_POSITION) >= RockPlacement.MIN_BASE_DISTANCE)
			assert(absf(position_value.x) <= HALF_EXTENT.x - RockPlacement.MIN_EDGE_DISTANCE)
			assert(absf(position_value.y) <= HALF_EXTENT.y - RockPlacement.MIN_EDGE_DISTANCE)
			assert(int(rock["variant"]) >= 0 and int(rock["variant"]) < RockFormation.VARIANTS.size())


## Независимая проверка тем же NavigationSystem, которым ходят жуки: с каждого из 12 стартов путь до базы есть,
## и он не длиннее чем на 10% (диагональ 1.414) пути на пустой карте.
func test_paths_to_base_stay_open_and_short() -> void:
	for seed_value: int in [RockPlacement.ROCK_SEED, 7, 11]:
		var empty_grid: MapGrid = MapGrid.new()
		var rocky_grid: MapGrid = MapGrid.new()
		for rock: Dictionary in _generate(MapGrid.new(), seed_value):
			var variant: int = int(rock["variant"])
			var rock_scale: float = RockFormation.scale_for(variant, float(rock["size_jitter"]))
			RockPlacement.block_rock_on_grid(rocky_grid, RockFormation.blocking_ellipse_at(variant, rock_scale, rock["position"] as Vector2))
		var empty_navigation: NavigationSystem = NavigationSystem.new(empty_grid)
		var rocky_navigation: NavigationSystem = NavigationSystem.new(rocky_grid)
		var goal: Vector2i = RockPlacement.cell_from_position(BASE_POSITION) + Vector2i(-1, 0)
		var margin: float = 1024.0 + RockPlacement.SPAWN_MARGIN
		var starts: Array[Vector2] = []
		for direction: Vector2 in RockPlacement.SECTOR_DIRECTIONS:
			starts.append(direction * margin)
		starts.append(Vector2(-0.5 * margin, -margin))
		starts.append(Vector2(0.5 * margin, margin))
		starts.append(Vector2(-margin, 0.5 * margin))
		starts.append(Vector2(margin, -0.5 * margin))
		for start_position: Vector2 in starts:
			var start: Vector2i = RockPlacement.start_cell_for(start_position)
			var baseline: Array[Vector2i] = empty_navigation.find_path(start, goal)
			var actual: Array[Vector2i] = rocky_navigation.find_path(start, goal)
			assert(not baseline.is_empty())
			assert(not actual.is_empty())
			assert(_octile_length(actual) <= _octile_length(baseline) * 1.10 + 1.0)


## Если начальная сетка уже оставляет проход уже 5 клеток, ни одна группа не должна быть принята:
## проверка «разъеденной» сетки отвергает кандидатов, а не молча ставит скалы.
func test_rejects_layouts_when_only_a_narrow_passage_exists() -> void:
	var grid: MapGrid = MapGrid.new()
	for x: int in MapGrid.WIDTH:
		if x < 10 or x > 12:
			grid.set_walkable(Vector2i(x, 20), false)
	var rocks: Array[Dictionary] = _generate(grid)
	assert(rocks.is_empty())


func _octile_length(path: Array[Vector2i]) -> float:
	var total: float = 0.0
	for index: int in range(1, path.size()):
		var step: Vector2i = path[index] - path[index - 1]
		total += 1.41421356 if (step.x != 0 and step.y != 0) else 1.0
	return total
