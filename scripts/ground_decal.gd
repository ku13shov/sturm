class_name GroundDecal
extends Sprite2D
## Тёмное «вытоптанное» пятно земли под зданием. Берёт один из 4 вариантов с листа
## res://assets/fx/ground_decals 1.webp (сетка 2x2), вариант и отражение выбираются по позиции здания,
## поэтому после загрузки сохранения пятно выглядит так же.

const SHEET_PATH := "res://assets/fx/ground_decals 1.webp"
const SHADER_PATH := "res://shaders/ground_decal.gdshader"
const GRID := Vector2i(2, 2)
## Какую долю ширины ячейки листа занимает само пятно (остальное пустое поле вокруг).
const PATCH_FILL_OF_CELL := 0.78

@export_group("Пятно")
## Ширина видимого пятна, px мира.
@export var width_px: float = 130.0
## Непрозрачность пятна, 0–1.
@export_range(0.0, 1.0, 0.01) var opacity: float = 0.72
## Цветовой множитель: меньше 1 затемняет пятно.
@export var tint: Color = Color(0.9, 0.82, 0.78)
## Размытие рваного края: 0 = резкий, 4 = очень мягкий.
@export_range(0.0, 5.0, 0.1) var edge_softness: float = 3.0
## Номер варианта 0–3; −1 = выбрать автоматически по позиции здания.
@export_range(-1, 3) var variant: int = -1

static var _sheet: Texture2D
static var _cells: Array[AtlasTexture] = []

var _final_scale: Vector2 = Vector2.ONE
var _tween: Tween


static func _ensure_cells() -> void:
	if not _cells.is_empty():
		return
	_sheet = load(SHEET_PATH) as Texture2D
	if _sheet == null:
		return
	var size: Vector2 = _sheet.get_size()
	var cell_size: Vector2 = Vector2(size.x / GRID.x, size.y / GRID.y)
	for row: int in GRID.y:
		for col: int in GRID.x:
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = _sheet
			atlas.region = Rect2(Vector2(col, row) * cell_size, cell_size)
			_cells.append(atlas)


func _ready() -> void:
	name = "GroundDecal"
	show_behind_parent = true
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_ensure_cells()
	if _cells.is_empty():
		queue_free()
		return
	var host: Node2D = get_parent() as Node2D
	var seed_value: int = 0
	if host != null:
		seed_value = int(absf(host.position.x) * 7.0 + absf(host.position.y) * 13.0)
	var index: int = variant if variant >= 0 else seed_value % _cells.size()
	texture = _cells[index]
	flip_h = (seed_value >> 2) % 2 == 1
	apply_width()
	_setup_material(texture as AtlasTexture)


func _setup_material(atlas: AtlasTexture) -> void:
	var shader_material: ShaderMaterial = ShaderMaterial.new()
	shader_material.shader = load(SHADER_PATH) as Shader
	shader_material.set_shader_parameter("cell_size", atlas.region.size)
	shader_material.set_shader_parameter("tint_color", Vector3(tint.r, tint.g, tint.b))
	shader_material.set_shader_parameter("blur_lod", edge_softness)
	shader_material.set_shader_parameter("opacity", opacity)
	material = shader_material


## Подгоняет масштаб так, чтобы видимое пятно было шириной width_px.
func apply_width() -> void:
	if texture == null:
		return
	var patch_px: float = texture.get_size().x * PATCH_FILL_OF_CELL
	_final_scale = Vector2.ONE * (width_px / patch_px)
	scale = _final_scale


## Пятно «проявляется» за время стройки: растёт и темнеет от прозрачного.
func appear(duration: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var shader_material: ShaderMaterial = material as ShaderMaterial
	if shader_material != null:
		shader_material.set_shader_parameter("opacity", 0.0)
	scale = _final_scale * 0.75
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "material:shader_parameter/opacity", opacity, maxf(duration, 0.1))
	_tween.tween_property(self, "scale", _final_scale, maxf(duration, 0.1)).set_ease(Tween.EASE_OUT)
