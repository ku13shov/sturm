class_name GrayboxSoldier
extends Node2D

@export_range(1, 3, 1) var soldier_level: int = 1
@export var source_asset_status: String = "USER_REPORTED"

func _ready() -> void:
	add_to_group("graybox_defenders")
