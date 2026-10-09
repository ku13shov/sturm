class_name BuildingRegistryTests
extends Node

const REGISTRY: Script = preload("res://data/building_registry.gd")

func test_registry_contains_playable_buildings() -> void:
	for building_id: int in REGISTRY.PLAYABLE_IDS:
		var profile: Dictionary = REGISTRY.profile(building_id)
		assert(not profile.is_empty())
		assert(not str(profile.get("display_name", "")).is_empty())
		assert(int(profile.get("prototype_cost", 0)) > 0)
		assert(profile.has("scene_path"))

func test_initial_palette_contains_energy_station_and_soldiers() -> void:
	assert(REGISTRY.INITIAL_IDS == [163, 151])
	for building_id: int in REGISTRY.INITIAL_IDS:
		assert(REGISTRY.PLAYABLE_IDS.has(building_id))

func test_registry_preserves_current_prototype_costs() -> void:
	assert(REGISTRY.prototype_cost(151) == 1500)
	assert(REGISTRY.prototype_cost(153) == 100)
	assert(REGISTRY.prototype_cost(163) == 500)
	assert(REGISTRY.prototype_cost(157) == 600)

func test_registry_provides_energy_station_construction_time() -> void:
	var profile: Dictionary = REGISTRY.profile(151)
	assert(is_equal_approx(float(profile["construction_time"]), 25.0))
	assert(bool(profile["unique"]))

func test_registry_allows_unique_energy_station_rebuild_after_removal() -> void:
	assert(bool(REGISTRY.profile(151)["unique"]))

func test_registry_provides_soldier_construction_times() -> void:
	var profile: Dictionary = REGISTRY.profile(163)
	assert(is_equal_approx(float(profile["construction_time"]), 5.0))
	assert(is_equal_approx(float(profile["upgrade_time"]), 3.0))

func test_registry_provides_current_footprints() -> void:
	assert(REGISTRY.footprint(151) == Vector2i(2, 2))
	assert(REGISTRY.footprint(163) == Vector2i(1, 1))
	assert(REGISTRY.footprint(153) == Vector2i(2, 2))
