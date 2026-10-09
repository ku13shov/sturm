class_name MapRoot
extends Node2D

@export var map_width: int = 64
@export var map_height: int = 64
@export var cell_size: float = 2.0
@export var show_debug_grid: bool = false

var grid: MapGrid
var navigation: NavigationSystem

func _ready() -> void:
	grid = MapGrid.new()
	navigation = NavigationSystem.new(grid)
