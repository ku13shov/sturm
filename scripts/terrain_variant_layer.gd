class_name TerrainVariantLayer
extends Node2D

const PATCH_TEXTURES: Array[Texture2D] = [
	preload("res://assets/map/tile_variants/basic_regolith.webp"),
	preload("res://assets/map/tile_variants/compacted_soil.webp"),
	preload("res://assets/map/tile_variants/cracked.webp"),
	preload("res://assets/map/tile_variants/mineral_patch.webp"),
	preload("res://assets/map/tile_variants/rocky_soil.webp"),
	preload("res://assets/map/tile_variants/transition.webp")
]
const PATCH_COUNT: int = 10
const MAP_HALF_SIZE: float = 1024.0

func _ready() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 874231
	for index: int in PATCH_COUNT:
		var patch: Sprite2D = Sprite2D.new()
		patch.name = "TerrainPatch_%02d" % index
		patch.texture = PATCH_TEXTURES[index % PATCH_TEXTURES.size()]
		patch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		patch.position = Vector2(
			rng.randf_range(-MAP_HALF_SIZE, MAP_HALF_SIZE),
			rng.randf_range(-MAP_HALF_SIZE, MAP_HALF_SIZE)
		)
		patch.scale = Vector2.ONE * rng.randf_range(0.75, 1.15)
		patch.modulate = Color(1.0, 1.0, 1.0, 0.16)
		patch.z_index = -5
		add_child(patch)
