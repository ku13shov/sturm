class_name GameBalance
extends RefCounted

const ORIGINAL_CONFIRMED: String = "ORIGINAL_CONFIRMED"
const ORIGINAL_INFERRED: String = "ORIGINAL_INFERRED"
const TEMPORARY_BALANCE: String = "TEMPORARY_BALANCE"

const GRAYBOX: Dictionary = {
	"status": TEMPORARY_BALANCE,
	"starting_credits": 2500,
	"tower_cost": 100,
	"enemy_reward": 130,
	"enemy_reward_status": ORIGINAL_INFERRED,
	"score_per_basic_bug": 13,
	"score_status": ORIGINAL_INFERRED,
	"wave_counts": [10, 10, 12, 13, 14],
	"wave_spawn_interval": 0.4,
	"inter_wave_delay": 2.5
}

const ENEMIES: Dictionary = {
	70: {"name": "basic_bug", "status": ORIGINAL_CONFIRMED, "scene": "res://scenes/units/basic_bug_2d.tscn"},
	71: {"name": "heavy_bug", "status": ORIGINAL_CONFIRMED},
	72: {"name": "eye_shooter", "status": ORIGINAL_CONFIRMED},
	73: {"name": "acid_ram", "status": ORIGINAL_CONFIRMED},
	74: {"name": "flying_shooter", "status": ORIGINAL_CONFIRMED},
	75: {"name": "queen", "status": ORIGINAL_CONFIRMED},
	76: {"name": "venom_bug", "status": ORIGINAL_CONFIRMED},
	77: {"name": "hidden_bug", "status": ORIGINAL_CONFIRMED},
	78: {"name": "sand_worm", "status": ORIGINAL_CONFIRMED}
}

const GRAYBOX_ENEMY_BALANCE: Dictionary = {
	70: {"max_health": 25.0, "damage": 3.0, "attack_interval": 1.5, "speed": 48.0, "detection_radius": 150.0, "bullet_resistance": 0.0, "status": TEMPORARY_BALANCE}
}

const ENEMY_PROFILES: Dictionary = {
	70: {"name": "basic_bug", "damage": 200, "attack_range": 2600, "bullet_resistance": 50, "energy_resistance": 0, "fire_resistance": 25, "reward": 95, "source_speed": 1300, "status": ORIGINAL_CONFIRMED},
	71: {"name": "heavy_bug", "damage": 150, "attack_range": 2400, "bullet_resistance": 0, "energy_resistance": 50, "fire_resistance": 25, "reward": 65, "source_speed": 1000, "status": ORIGINAL_CONFIRMED},
	72: {"name": "eye_shooter", "damage": 45, "attack_range": 8600, "bullet_resistance": 45, "energy_resistance": 25, "fire_resistance": 50, "reward": 35, "source_speed": 1200, "status": ORIGINAL_CONFIRMED},
	73: {"name": "acid_ram", "damage": 120, "attack_range": 2700, "bullet_resistance": 120, "energy_resistance": 0, "fire_resistance": 50, "reward": 45, "source_speed": 1500, "status": ORIGINAL_CONFIRMED},
	74: {"name": "flying_shooter", "damage": 25, "attack_range": 3500, "bullet_resistance": 25, "energy_resistance": 0, "fire_resistance": 25, "reward": 25, "source_speed": 900, "status": ORIGINAL_CONFIRMED},
	75: {"name": "queen", "damage": 5, "attack_range": 2400, "bullet_resistance": 5, "energy_resistance": 25, "fire_resistance": 0, "reward": 13, "source_speed": 700, "status": ORIGINAL_CONFIRMED},
	76: {"name": "venom_bug", "damage": 125, "attack_range": 2600, "bullet_resistance": 125, "energy_resistance": 25, "fire_resistance": 0, "reward": 65, "source_speed": 1200, "status": ORIGINAL_CONFIRMED},
	77: {"name": "hidden_bug", "damage": 80, "attack_range": 1900, "bullet_resistance": 80, "energy_resistance": 50, "fire_resistance": 25, "reward": 55, "source_speed": 1300, "status": ORIGINAL_CONFIRMED},
	78: {"name": "sand_worm", "damage": 250, "attack_range": 2300, "bullet_resistance": 25, "energy_resistance": 50, "fire_resistance": 0, "reward": 125, "source_speed": 1200, "status": ORIGINAL_CONFIRMED}
}

const SCREENSHOT_CONFIRMED_UI: Dictionary = {
	"central_base_level_1": {"display_name": "Центральная база", "hp": 750, "defense": 25, "status": ORIGINAL_CONFIRMED},
	"laser_tower_level_1": {"display_name": "Лазерная башня", "cost": 600, "hp": 125, "defense": 10, "attack": 6, "radius": 3, "status": ORIGINAL_CONFIRMED},
	"soldiers_display": {"display_name": "Солдаты", "hp": 76, "defense": 10, "attack": 4, "radius": 2, "status": ORIGINAL_CONFIRMED}
}

const BUILDING_REGISTRY: Script = preload("res://data/building_registry.gd")
const BUILDINGS: Dictionary = BUILDING_REGISTRY.BUILDINGS
