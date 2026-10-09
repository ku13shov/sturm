class_name BugSheetVisualW
extends Node2D

const SHEET: Texture2D = preload("res://assets/sprites/units/new_base_bug/bug_sprite.png")
const GLOW_MASK: Texture2D = preload("res://assets/sprites/units/new_base_bug/bug_sprite-mask.png")
const FRAME_COUNT: int = 25
const FRAME_SIZE: Vector2i = Vector2i(345, 190)
const FPS: float = 13.3
const DOME_STUDIO_HEIGHT: float = 24.0
const GAME_DOME_HEIGHT: float = 26.0
const GAME_PX_PER_STUDIO_PX: float = GAME_DOME_HEIGHT / DOME_STUDIO_HEIGHT
const SPRITE_SCALE: float = GAME_PX_PER_STUDIO_PX / 5.0
const CYCLE_DISTANCE_STUDIO: float = 22.3077
const PIVOT_IN_FRAME: Vector2 = Vector2(172.5, 170.0)

@export var bug_visual_height_px: float = 26.0
@export var shadow_opacity: float = 0.35
@export var shadow_width_fraction: float = 1.05
## Базовая интенсивность свечения трещин и глаза в состоянии покоя (0 — выключено, 1 — максимум).
@export_range(0.0, 1.0, 0.01) var glow_base: float = 0.45
## Амплитуда заметного медленного дыхания вокруг glow_base; период дыхания около 2,5 секунды.
@export_range(0.0, 1.0, 0.01) var glow_pulse: float = 0.30
@export var glow_color: Color = Color("#ff8a1e")
## Максимальный наклон корпуса при разгоне и торможении, градусы.
@export_range(0.0, 4.0, 0.1) var max_lean_deg: float = 1.2
## Скорость сглаживания наклона (больше = резче реагирует).
@export_range(1.0, 30.0, 0.5) var lean_smoothing: float = 10.0
## Ускорение, при котором наклон достигает максимума (px/с²), около MOVEMENT_ACCELERATION жука.
@export var lean_full_accel: float = 150.0
## За сколько секунд поза доезжает до кадра 0 после остановки.
@export_range(0.05, 0.6, 0.01) var stop_ease_time: float = 0.2
## Случайные отличия между юнитами: стартовая фаза, масштаб ±3%, фаза дыхания свечения.
@export var variation_enabled: bool = true
@export_range(0.0, 0.1, 0.005) var scale_variation: float = 0.03

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var glow_sprite: AnimatedSprite2D = $GlowAnimatedSprite2D
@onready var contact_shadow: Sprite2D = $ContactShadow
var sprite_frames_resource: SpriteFrames
var glow_frames_resource: SpriteFrames
var walk_phase: float = 0.0
var glow_touchdown_remaining: float = 0.0
var glow_time: float = 0.0
var unit_scale_mult: float = 1.0
var glow_phase_offset: float = 0.0
var was_moving: bool = true
var stop_easing: bool = false
var stop_target_phase: float = 0.0
var stop_ease_rate: float = 0.0
var previous_speed: float = 0.0
var smoothed_accel: float = 0.0

func _sprite_scale() -> float:
    return SPRITE_SCALE * unit_scale_mult
const TOUCHDOWN_PHASES: Array[float] = [0.0, 0.342, 0.421, 0.5, 0.842, 0.921]
const TOUCHDOWN_BUMP_DURATION: float = 0.12

func set_visual_height_px(value: float) -> void:
    bug_visual_height_px = value
    if is_node_ready():
        var scale_factor: float = _sprite_scale()
        animated_sprite.scale = Vector2.ONE * scale_factor
        glow_sprite.scale = Vector2.ONE * scale_factor
        _apply_shadow(scale_factor)

func _ready() -> void:
    if variation_enabled:
        unit_scale_mult = 1.0 + randf_range(-scale_variation, scale_variation)
        glow_phase_offset = randf() * 2.5
        walk_phase = randf()
    sprite_frames_resource = _build_sprite_frames(SHEET)
    glow_frames_resource = _build_sprite_frames(GLOW_MASK)
    animated_sprite.sprite_frames = sprite_frames_resource
    glow_sprite.sprite_frames = glow_frames_resource
    animated_sprite.animation = &"walk"
    glow_sprite.animation = &"walk"
    animated_sprite.frame = 0
    glow_sprite.frame = 0
    animated_sprite.pause()
    glow_sprite.pause()
    var sprite_offset: Vector2 = Vector2(-PIVOT_IN_FRAME.x + FRAME_SIZE.x * 0.5, -PIVOT_IN_FRAME.y + FRAME_SIZE.y * 0.5)
    animated_sprite.offset = sprite_offset
    glow_sprite.offset = sprite_offset
    var scale_factor: float = _sprite_scale()
    animated_sprite.scale = Vector2.ONE * scale_factor
    glow_sprite.scale = Vector2.ONE * scale_factor
    glow_sprite.flip_h = animated_sprite.flip_h
    _apply_glow(0.0)
    _apply_shadow(scale_factor)

func _build_sprite_frames(sheet: Texture2D) -> SpriteFrames:
    var frames: SpriteFrames = SpriteFrames.new()
    frames.remove_animation(&"default")
    frames.add_animation(&"walk")
    frames.set_animation_speed(&"walk", FPS)
    frames.set_animation_loop(&"walk", true)
    for index: int in FRAME_COUNT:
        var atlas: AtlasTexture = AtlasTexture.new()
        atlas.atlas = sheet
        atlas.region = Rect2(index * FRAME_SIZE.x, 0, FRAME_SIZE.x, FRAME_SIZE.y)
        frames.add_frame(&"walk", atlas)
    return frames

func _process(delta: float) -> void:
    var bug: GrayboxBug = get_parent() as GrayboxBug
    if not is_instance_valid(bug):
        return
    var velocity_now: Vector2 = bug.velocity / bug.map_scale()
    var actual_speed: float = velocity_now.length()
    var cycle_distance_px: float = CYCLE_DISTANCE_STUDIO * GAME_PX_PER_STUDIO_PX * unit_scale_mult
    var moving: bool = actual_speed > 0.1
    var previous_progress: float = fposmod(walk_phase, 1.0)
    animated_sprite.pause()
    glow_sprite.pause()
    if absf(velocity_now.x) > 0.1:
        animated_sprite.flip_h = velocity_now.x > 0.0
    glow_sprite.flip_h = animated_sprite.flip_h
    if moving:
        stop_easing = false
        walk_phase += actual_speed * delta / maxf(cycle_distance_px, 0.001)
        _check_touchdowns(previous_progress, fposmod(walk_phase, 1.0))
    else:
        if was_moving:
            stop_target_phase = roundf(walk_phase)
            var remaining: float = absf(stop_target_phase - walk_phase)
            stop_easing = remaining > 0.0001
            stop_ease_rate = remaining / maxf(stop_ease_time, 0.01)
        if stop_easing:
            walk_phase = move_toward(walk_phase, stop_target_phase, stop_ease_rate * delta)
            if is_equal_approx(walk_phase, stop_target_phase):
                walk_phase = stop_target_phase
                stop_easing = false
    was_moving = moving
    var cycle_progress: float = fposmod(walk_phase, 1.0)
    animated_sprite.frame = mini(int(floor(cycle_progress * FRAME_COUNT)), FRAME_COUNT - 1)
    glow_sprite.frame = animated_sprite.frame
    _apply_lean(actual_speed, delta)
    glow_time += delta
    glow_touchdown_remaining = maxf(glow_touchdown_remaining - delta, 0.0)
    _apply_glow(glow_time + glow_phase_offset)

func _apply_lean(speed_now: float, delta: float) -> void:
    if delta <= 0.0:
        return
    var accel: float = (speed_now - previous_speed) / delta
    previous_speed = speed_now
    smoothed_accel = lerpf(smoothed_accel, accel, clampf(delta * lean_smoothing, 0.0, 1.0))
    var amount: float = clampf(smoothed_accel / maxf(lean_full_accel, 1.0), -1.0, 1.0)
    # Спрайт нарисован лицом влево (W). Разгон: нос вперёд-вниз. Влево это против часовой (минус), вправо по часовой (плюс).
    var facing_sign: float = 1.0 if animated_sprite.flip_h else -1.0
    var lean_rad: float = deg_to_rad(max_lean_deg) * amount * facing_sign
    animated_sprite.rotation = lean_rad
    glow_sprite.rotation = lean_rad

func _check_touchdowns(previous_progress: float, current_progress: float) -> void:
    for touchdown: float in TOUCHDOWN_PHASES:
        var crossed: bool = current_progress >= touchdown and previous_progress < touchdown
        if touchdown == 0.0:
            crossed = current_progress < previous_progress
        if crossed:
            glow_touchdown_remaining = TOUCHDOWN_BUMP_DURATION
            break

func _apply_glow(time_seconds: float) -> void:
    var breathing: float = sin(time_seconds * TAU / 2.5) * glow_pulse
    var touchdown_bump: float = glow_touchdown_remaining / TOUCHDOWN_BUMP_DURATION * 0.35
    var intensity: float = clampf(glow_base + breathing + touchdown_bump, 0.0, 1.0)
    glow_sprite.modulate = Color(glow_color.r, glow_color.g, glow_color.b, intensity)

func _apply_shadow(_scale_factor: float) -> void:
    var shadow_width_px: float = bug_visual_height_px * shadow_width_fraction * unit_scale_mult
    var shadow_height_px: float = shadow_width_px * 0.4
    var texture_size: Vector2 = contact_shadow.texture.get_size()
    contact_shadow.scale = Vector2(shadow_width_px / maxf(texture_size.x, 1.0), shadow_height_px / maxf(texture_size.y, 1.0))
    contact_shadow.position = Vector2(0.0, 0.0)
    var shadow_material: ShaderMaterial = contact_shadow.material as ShaderMaterial
    if shadow_material != null:
        shadow_material.set_shader_parameter("shadow_opacity", shadow_opacity)

func on_hit() -> void:
    var hit_material: ShaderMaterial = animated_sprite.material as ShaderMaterial
    if hit_material != null:
        hit_material.set_shader_parameter("hit_flash", 1.0)
        var tween: Tween = create_tween()
        tween.tween_method(_set_hit_flash.bind(hit_material), 1.0, 0.0, 0.07)

func _set_hit_flash(value: float, hit_material: ShaderMaterial) -> void:
    if is_instance_valid(hit_material):
        hit_material.set_shader_parameter("hit_flash", value)
