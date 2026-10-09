class_name MapDecorationLayer
extends Node2D

const DECORATION_TEXTURES: Array[Texture2D] = [
	preload("res://assets/map/decorations/metal_debris.webp"),
	preload("res://assets/map/decorations/mineral_shards.webp"),
	preload("res://assets/map/decorations/cable_conduit.webp"),
	preload("res://assets/map/decorations/broken_survey_marker.webp"),
	preload("res://assets/map/decorations/sensor_pylon.webp")
]
const DECORATION_COUNT: int = 18
const MAP_HALF_SIZE: float = 1024.0
const BASE_POSITION: Vector2 = Vector2(216.0, 235.0)

func _ready() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 492781
	var positions: Array[Vector2] = []
	var attempts: int = 0
	while positions.size() < DECORATION_COUNT and attempts < 500:
		attempts += 1
		var candidate: Vector2 = Vector2(
			rng.randf_range(-MAP_HALF_SIZE + 80.0, MAP_HALF_SIZE - 80.0),
			rng.randf_range(-MAP_HALF_SIZE + 80.0, MAP_HALF_SIZE - 80.0)
		)
		if candidate.distance_to(BASE_POSITION) < 190.0:
			continue
		var occupied: bool = false
		for existing_position: Vector2 in positions:
			if candidate.distance_to(existing_position) < 120.0:
				occupied = true
				break
		if not occupied:
			positions.append(candidate)
	for index: int in positions.size():
		var decoration: Sprite2D = Sprite2D.new()
		decoration.name = "Decoration_%02d" % index
		decoration.texture = DECORATION_TEXTURES[index % DECORATION_TEXTURES.size()]
		decoration.position = positions[index]
		var fixed_scale: bool = index % DECORATION_TEXTURES.size() == 4
		var decoration_scale: float = 0.07 if fixed_scale else rng.randf_range(0.07, 0.15)
		decoration.scale = Vector2.ONE * decoration_scale
		decoration.flip_h = rng.randf() > 0.5
		var decoration_alpha: float = rng.randf_range(0.32, 0.58)
		decoration.modulate = Color(0.90, 0.82, 0.72, decoration_alpha)
		decoration.z_index = 0
		var shadow: Polygon2D = Polygon2D.new()
		shadow.name = "ContactShadow"
		shadow.polygon = PackedVector2Array([Vector2(-42, 12), Vector2(-28, 22), Vector2(0, 27), Vector2(28, 22), Vector2(42, 12), Vector2(28, 4), Vector2(0, 0), Vector2(-28, 4)])
		shadow.color = Color(0.01, 0.008, 0.006, 0.20)
		shadow.z_index = -1
		decoration.add_child(shadow)
		add_child(decoration)
