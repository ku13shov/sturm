@tool
class_name BugRigW
extends Node2D

const BASE_VISUAL_HEIGHT_PX: float = 26.0
const DUST_MIN_INTERVAL: float = 0.15
const DUST_LIFETIME: float = 0.15
const DUST_COLOR: Color = Color(0.62, 0.50, 0.42, 0.30)

@export_group("Размер")
## Высота купола; масштабирует вручную расставленные узлы рига.
@export var bug_visual_height_px: float = BASE_VISUAL_HEIGHT_PX:
	set(value):
		bug_visual_height_px = value
		_apply_root_scale()

@export_group("Походка")
## Скорость жука, при которой walk проигрывается на скорости 1.0.
@export var walk_animation_speed: float = 42.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body: Sprite2D = $Body
@onready var legs: Array[Sprite2D] = [$LegFar1, $LegFar2, $LegFar3, $LegNear1, $LegNear2, $LegNear3]

var mirror_x: float = 1.0
var dust_cooldown: float = 0.0
var dust_cursor: int = 0
var dust_remaining: Array[float] = [0.0, 0.0, 0.0]
var hit_tween: Tween

func _ready() -> void:
	_apply_root_scale()
	if animation_player != null and not Engine.is_editor_hint():
		animation_player.play("idle")

func _process(delta: float) -> void:
	dust_cooldown = maxf(dust_cooldown - delta, 0.0)
	_update_dust(delta)
	if animation_player == null:
		return
	var bug_speed: float = 0.0
	var bug: Node2D = get_parent() as Node2D
	if is_instance_valid(bug):
		var velocity_value: Variant = bug.get("velocity")
		if velocity_value is Vector2:
			bug_speed = (velocity_value as Vector2).length()
	if Engine.is_editor_hint():
		animation_player.speed_scale = 1.0
		return
	animation_player.speed_scale = bug_speed / maxf(walk_animation_speed, 0.001)
	if bug_speed > 0.1:
		if animation_player.current_animation != "walk":
			animation_player.play("walk")
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")

func _apply_root_scale() -> void:
	if not is_node_ready():
		return
	var visual_scale: float = maxf(bug_visual_height_px, 1.0) / BASE_VISUAL_HEIGHT_PX
	scale = Vector2(visual_scale * mirror_x, visual_scale)

func set_mirror_x(value: float) -> void:
	mirror_x = -1.0 if value < 0.0 else 1.0
	_apply_root_scale()

func on_hit() -> void:
	if hit_tween != null and hit_tween.is_valid():
		hit_tween.kill()
	for node: Sprite2D in [body] + legs:
		var hit_material: ShaderMaterial = node.material as ShaderMaterial
		if hit_material != null:
			hit_material.set_shader_parameter("hit_flash", 1.0)
	hit_tween = create_tween()
	hit_tween.tween_method(_set_hit_flash, 1.0, 0.0, 0.07)

func _set_hit_flash(value: float) -> void:
	for node: Sprite2D in [body] + legs:
		var hit_material: ShaderMaterial = node.material as ShaderMaterial
		if hit_material != null:
			hit_material.set_shader_parameter("hit_flash", value)

func emit_dust() -> void:
	if dust_cooldown > 0.0:
		return
	dust_cooldown = DUST_MIN_INTERVAL
	var dust: Polygon2D = get_node_or_null("Dust" + str(dust_cursor % 3)) as Polygon2D
	dust_cursor += 1
	if dust == null:
		return
	dust.position = Vector2(0.0, 8.0)
	dust.modulate = DUST_COLOR
	dust.visible = true
	dust_remaining[(dust_cursor - 1) % 3] = DUST_LIFETIME

func _update_dust(delta: float) -> void:
	for index: int in 3:
		dust_remaining[index] = maxf(dust_remaining[index] - delta, 0.0)
		var dust: Polygon2D = get_node_or_null("Dust" + str(index)) as Polygon2D
		if dust != null:
			dust.visible = dust_remaining[index] > 0.0
