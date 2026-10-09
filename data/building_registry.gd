class_name BuildingRegistry
extends RefCounted

const ORIGINAL_CONFIRMED: String = "ORIGINAL_CONFIRMED"
const ORIGINAL_INFERRED: String = "ORIGINAL_INFERRED"
const SCREENSHOT_CONFIRMED: String = "SCREENSHOT_CONFIRMED"
const TEMPORARY_BALANCE: String = "TEMPORARY_BALANCE"
const UNRESOLVED: String = "UNRESOLVED"
const USER_OBSERVED: String = "USER_OBSERVED"

const INITIAL_IDS: Array[int] = [163, 151]
const PLAYABLE_IDS: Array[int] = [151, 153, 163, 157, 167, 169, 159]

const BUILDINGS: Dictionary = {
	151: {
		"name": "energy_station", "display_name": "Энергостанция", "help_name": "Энергостанция",
		"max_health": 400, "cost": 1500, "prototype_cost": 1500, "defense": 15,
		"construction_time": 25.0, "unique": true,
		"footprint": Vector2i(2, 2), "base_clearance_radius": 140.0,
		"combat_status": "NON_COMBAT", "ui_stats_status": SCREENSHOT_CONFIRMED,
		"status": ORIGINAL_CONFIRMED, "scene_path": "res://scenes/graybox/graybox_energy_station.tscn"
	},
	153: {
		"name": "fire_tower", "display_name": "Огневая башня", "help_name": "Огневая башня",
		"max_health": 30000, "cost": 500, "prototype_cost": 100,
		"footprint": Vector2i(2, 2), "base_clearance_radius": 110.0,
		"combat_status": UNRESOLVED, "status": ORIGINAL_CONFIRMED,
		"scene_path": "res://scenes/graybox/graybox_tower.tscn"
	},
	155: {
		"name": "central_base", "display_name": "Центральная база", "help_name": "Центральная база",
		"max_health": 750, "defense": 25, "cost": 750,
		"static_effect_damage": 750, "combat_status": ORIGINAL_CONFIRMED,
		"status": ORIGINAL_CONFIRMED, "footprint": Vector2i(1, 1), "scene_path": "res://scenes/graybox/graybox_central_base_template.tscn"
	},
	157: {
		"name": "laser_tower", "display_name": "Лазерная башня", "help_name": "Лазерная башня",
		"max_health": 15000, "cost": 250, "prototype_cost": 600,
		"footprint": Vector2i(2, 2), "base_clearance_radius": 110.0,
		"combat_status": "SPECIAL_ZERO_HP_EFFECT", "status": ORIGINAL_CONFIRMED,
		"scene_path": "res://scenes/graybox/graybox_laser_tower.tscn"
	},
	159: {
		"name": "beacon", "display_name": "Маяк", "help_name": "Маяк",
		"max_health": 30000, "cost": 800, "prototype_cost": 600,
		"footprint": Vector2i(2, 2), "base_clearance_radius": 110.0,
		"static_effect_damage": 800, "combat_status": ORIGINAL_CONFIRMED,
		"status": ORIGINAL_CONFIRMED, "scene_path": "res://scenes/graybox/graybox_beacon.tscn"
	},
	161: {
		"name": "assault_gun", "display_name": "Штурмовое орудие", "help_name": "Штурмовое орудие",
		"max_health": 60000, "cost": 1000, "static_effect_damage": 1000,
		"combat_status": ORIGINAL_CONFIRMED, "status": ORIGINAL_CONFIRMED
	},
	163: {
		"name": "soldiers", "display_name": "Солдаты", "help_name": "Солдаты",
		"max_health": 80, "cost": 500, "prototype_cost": 500, "upgrade_cost": 600,
		"upgrade_costs": [600, 1000], "max_upgrade_level": 2,
		"construction_time": 5.0, "upgrade_time": 3.0,
		"defense": 5, "attack": 3, "radius": 2, "upgrade_health_bonus": 20,
		"upgrade_defense_bonus": 5, "upgrade_attack_bonus": 1, "footprint": Vector2i(1, 1),
		"base_clearance_radius": 110.0, "combat_status": "TEMPORARY_GRAYBOX_COMBAT",
		"ui_stats_status": USER_OBSERVED, "upgrade_status": USER_OBSERVED, "status": USER_OBSERVED,
		"scene_path": "res://scenes/graybox/graybox_soldier_defender.tscn"
	},
	165: {
		"name": "minefield", "display_name": "Минное поле", "help_name": "Минное поле",
		"max_health": 90000, "cost": 4000, "combat_status": UNRESOLVED,
		"status": ORIGINAL_CONFIRMED
	},
	167: {
		"name": "plasma_tower", "display_name": "Плазменная башня", "help_name": "Плазменная башня",
		"max_health": 80000, "cost": 2000, "prototype_cost": 800,
		"footprint": Vector2i(2, 2), "base_clearance_radius": 110.0,
		"combat_status": UNRESOLVED, "status": ORIGINAL_CONFIRMED,
		"scene_path": "res://scenes/graybox/graybox_plasma_tower.tscn"
	},
	169: {
		"name": "radar_tower", "display_name": "Радарная вышка", "help_name": "Радарная вышка",
		"max_health": 50000, "cost": 3000, "prototype_cost": 700,
		"footprint": Vector2i(2, 2), "base_clearance_radius": 110.0,
		"combat_status": UNRESOLVED, "status": ORIGINAL_CONFIRMED,
		"scene_path": "res://scenes/graybox/graybox_radar_tower.tscn"
	},
	171: {
		"name": "satellite", "display_name": "Сателлит", "help_name": "Сателлит",
		"max_health": 120000, "cost": 5000, "combat_status": UNRESOLVED,
		"status": ORIGINAL_CONFIRMED
	},
	173: {
		"name": "communication_center", "display_name": "Центр коммуникации", "help_name": "Центр коммуникации",
		"max_health": 100000, "cost": 4000, "static_effect_damage": 4000,
		"combat_status": ORIGINAL_CONFIRMED, "status": ORIGINAL_CONFIRMED
	}
}

static func profile(building_id: int) -> Dictionary:
	return BUILDINGS.get(building_id, {}) as Dictionary

static func display_name(building_id: int) -> String:
	var data: Dictionary = profile(building_id)
	return str(data.get("display_name", data.get("name", "Постройка")))

static func prototype_cost(building_id: int) -> int:
	var data: Dictionary = profile(building_id)
	return int(data.get("prototype_cost", data.get("cost", 0)))

static func footprint(building_id: int) -> Vector2i:
	var data: Dictionary = profile(building_id)
	return data.get("footprint", Vector2i(2, 2)) as Vector2i
