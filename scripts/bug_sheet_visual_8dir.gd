class_name BugSheetVisual8Dir
extends Node2D
## Листовой жук на все 8 направлений из одного листа студии (5 строк: S, SW, W, NW, N).
## NE, E и SE берутся зеркалом строк NW, W и SW (flip_h). Направление выбирается по скорости
## родительского GrayboxBug с гистерезисом, фаза шага привязана к дистанции (стопы не скользят).
## Если лист или маска не найдены, узел сам скрывается (available == false),
## а GrayboxBug использует прежние визуалы.

const ROW_S: int = 0
const ROW_SW: int = 1
const ROW_W: int = 2
const ROW_NW: int = 3
const ROW_N: int = 4
const ROW_COUNT: int = 5
const DEFAULT_SHEET_PATH: String = "res://assets/sprites/units/new_base_bug/bug_sheet_5dir.webp"
const DEFAULT_MASK_PATH: String = "res://assets/sprites/units/new_base_bug/bug_sheet_5dir-mask.webp"
const DEFAULT_ATTACK_SHEET_PATH: String = "res://assets/sprites/units/new_base_bug/bug_attack_5dir.webp"
const DEFAULT_ATTACK_MASK_PATH: String = "res://assets/sprites/units/new_base_bug/bug_attack_5dir-mask.webp"
const DEFAULT_DEATH_SHEET_PATH: String = "res://assets/sprites/units/new_base_bug/bug_death_5dir.webp"
const DEFAULT_DEATH_MASK_PATH: String = "res://assets/sprites/units/new_base_bug/bug_death_5dir-mask.webp"
const TOUCHDOWN_BUMP_DURATION: float = 0.12

## Жук отыграл анимацию смерти до конца (последний кадр прозрачный), можно удалять узел.
signal death_finished

enum State { WALK, ATTACK, ATTACK_HOLD, DEATH }
## Секторы строк по углу от вектора «вниз» (0° = S, 90° = бок, 180° = N).
const ROW_SECTORS: Array[Vector2] = [
	Vector2(0.0, 22.5),
	Vector2(22.5, 67.5),
	Vector2(67.5, 112.5),
	Vector2(112.5, 157.5),
	Vector2(157.5, 180.0),
]

@export var sheet: Texture2D
@export var glow_mask: Texture2D
## Листы атаки и смерти (5 строк, те же 320 px). Если не найдены, анимации просто недоступны.
@export var attack_sheet: Texture2D
@export var attack_mask: Texture2D
@export var death_sheet: Texture2D
@export var death_mask: Texture2D
@export var attack_frame_count: int = 10
@export var attack_duration: float = 0.5
@export var death_frame_count: int = 16
@export var death_duration: float = 0.9
@export var frame_count: int = 25
## Размер ячейки листа в px (frame_size из bug_params.json).
@export var frame_size: Vector2i = Vector2i(320, 320)
## Пивот в ячейке (pivot_in_frame из json): центр по X, линия земли по Y.
@export var pivot_in_frame: Vector2 = Vector2(160.0, 225.0)
## Масштаб ячейки при экспорте студии (поле «Масштаб ячейки»).
@export var export_zoom: float = 2.5
## Высота корпуса S в студийных px (bodyW 60.7 × 257/276) и желаемая высота в игре.
@export var studio_body_height: float = 56.5
@export var game_body_height: float = 26.0
## Дистанция цикла по строкам (S, SW, W, NW, N) в студийных px экрана:
## step / duty × sqrt(cos(a)² + (sin(a) × fsh)²), где step 10, duty 0.6, fsh 0.7.
@export var row_cycle_distance_studio: PackedFloat32Array = PackedFloat32Array([11.667, 14.385, 16.667, 14.385, 11.667])
## 1.0 — стопы строго не скользят. Больше 1.0 — шаги реже, но появляется скольжение.
@export_range(0.5, 8.0, 0.05) var stride_scale: float = 3.0
@export var touchdown_phases: PackedFloat32Array = PackedFloat32Array([0.0, 0.383, 0.442, 0.5, 0.883, 0.942])
## Запас гистерезиса при смене направления, градусы.
@export_range(0.0, 30.0, 0.5) var view_hysteresis_degrees: float = 10.0

@export var shadow_opacity: float = 0.2
@export var shadow_width_fraction: float = 1.05
@export_range(0.0, 1.0, 0.01) var glow_base: float = 0.43
@export_range(0.0, 1.0, 0.01) var glow_pulse: float = 0.30
@export var glow_color: Color = Color("#ff8a1e")
@export_range(0.0, 4.0, 0.1) var max_lean_deg: float = 1.2
@export_range(1.0, 30.0, 0.5) var lean_smoothing: float = 10.0
@export var lean_full_accel: float = 150.0
@export_range(0.05, 0.6, 0.01) var stop_ease_time: float = 0.2
@export var variation_enabled: bool = true
@export_range(0.0, 0.1, 0.005) var scale_variation: float = 0.03

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var glow_sprite: AnimatedSprite2D = $GlowAnimatedSprite2D
@onready var contact_shadow: Sprite2D = $ContactShadow

## Тень по силуэту: те же кадры листа, что у тела, отражённые от линии земли по ShadowLight.DIR.
var silhouette_shadow: AnimatedSprite2D
## true, когда лист и маска загружены и узел можно показывать.
var available: bool = false
var has_attack: bool = false
var has_death: bool = false
var state: State = State.WALK
var state_time: float = 0.0
var death_emitted: bool = false
var bug_visual_height_px: float = 26.0
var current_row: int = ROW_S
var current_flip: bool = false
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

func _game_px_per_studio_px() -> float:
	return game_body_height / maxf(studio_body_height, 0.001)

func _sprite_scale() -> float:
	return _game_px_per_studio_px() / maxf(export_zoom, 0.001) * unit_scale_mult

func set_visual_height_px(value: float) -> void:
	bug_visual_height_px = value
	if available and is_node_ready():
		var scale_factor: float = _sprite_scale()
		animated_sprite.scale = Vector2.ONE * scale_factor
		glow_sprite.scale = Vector2.ONE * scale_factor
		_apply_shadow()

func _ready() -> void:
	# Мягкий эллипс заменён тенью по силуэту; узел оставлен, чтобы не трогать остальные ссылки.
	contact_shadow.visible = false
	# Материал из сцены общий для всех экземпляров: без копии вспышка попадания зажигает всех жуков сразу.
	if animated_sprite != null and animated_sprite.material != null:
		animated_sprite.material = animated_sprite.material.duplicate()
	if sheet == null and ResourceLoader.exists(DEFAULT_SHEET_PATH):
		sheet = load(DEFAULT_SHEET_PATH) as Texture2D
	if glow_mask == null and ResourceLoader.exists(DEFAULT_MASK_PATH):
		glow_mask = load(DEFAULT_MASK_PATH) as Texture2D
	if sheet == null or glow_mask == null:
		push_warning("BugSheetVisual8Dir: нет bug_sheet_5dir.webp или маски, узел отключён.")
		visible = false
		return
	available = true
	if attack_sheet == null and ResourceLoader.exists(DEFAULT_ATTACK_SHEET_PATH):
		attack_sheet = load(DEFAULT_ATTACK_SHEET_PATH) as Texture2D
	if attack_mask == null and ResourceLoader.exists(DEFAULT_ATTACK_MASK_PATH):
		attack_mask = load(DEFAULT_ATTACK_MASK_PATH) as Texture2D
	if death_sheet == null and ResourceLoader.exists(DEFAULT_DEATH_SHEET_PATH):
		death_sheet = load(DEFAULT_DEATH_SHEET_PATH) as Texture2D
	if death_mask == null and ResourceLoader.exists(DEFAULT_DEATH_MASK_PATH):
		death_mask = load(DEFAULT_DEATH_MASK_PATH) as Texture2D
	has_attack = attack_sheet != null and attack_mask != null
	has_death = death_sheet != null and death_mask != null
	if variation_enabled:
		unit_scale_mult = 1.0 + randf_range(-scale_variation, scale_variation)
		glow_phase_offset = randf() * 2.5
		walk_phase = randf()
	animated_sprite.sprite_frames = _build_sprite_frames(sheet, attack_sheet if has_attack else null, death_sheet if has_death else null)
	glow_sprite.sprite_frames = _build_sprite_frames(glow_mask, attack_mask if has_attack else null, death_mask if has_death else null)
	_set_row(ROW_S, false)
	animated_sprite.pause()
	glow_sprite.pause()
	var sprite_offset: Vector2 = Vector2(-pivot_in_frame.x + frame_size.x * 0.5, -pivot_in_frame.y + frame_size.y * 0.5)
	animated_sprite.offset = sprite_offset
	glow_sprite.offset = sprite_offset
	silhouette_shadow = AnimatedSprite2D.new()
	silhouette_shadow.name = "SilhouetteShadow"
	silhouette_shadow.sprite_frames = animated_sprite.sprite_frames
	silhouette_shadow.offset = sprite_offset
	silhouette_shadow.z_index = -1
	silhouette_shadow.modulate = Color(ShadowLight.COLOR, ShadowLight.ALPHA)
	add_child(silhouette_shadow)
	move_child(silhouette_shadow, contact_shadow.get_index() + 1)
	silhouette_shadow.pause()
	var scale_factor: float = _sprite_scale()
	animated_sprite.scale = Vector2.ONE * scale_factor
	glow_sprite.scale = Vector2.ONE * scale_factor
	_apply_glow(0.0)
	_apply_shadow()

func _row_animation(row: int) -> StringName:
	match state:
		State.ATTACK, State.ATTACK_HOLD:
			return StringName("attack_%d" % row)
		State.DEATH:
			return StringName("death_%d" % row)
	return StringName("row_%d" % row)

func _add_row_animations(frames: SpriteFrames, prefix: String, source: Texture2D, count: int, loop: bool) -> void:
	for row: int in ROW_COUNT:
		var animation_name: StringName = StringName("%s_%d" % [prefix, row])
		frames.add_animation(animation_name)
		frames.set_animation_speed(animation_name, 1.0)
		frames.set_animation_loop(animation_name, loop)
		for index: int in count:
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = source
			atlas.region = Rect2(index * frame_size.x, row * frame_size.y, frame_size.x, frame_size.y)
			frames.add_frame(animation_name, atlas)

func _build_sprite_frames(source: Texture2D, attack_source: Texture2D = null, death_source: Texture2D = null) -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.remove_animation(&"default")
	_add_row_animations(frames, "row", source, frame_count, true)
	if attack_source != null:
		_add_row_animations(frames, "attack", attack_source, attack_frame_count, false)
	if death_source != null:
		_add_row_animations(frames, "death", death_source, death_frame_count, false)
	return frames

func _set_row(row: int, flip: bool) -> void:
	current_row = row
	current_flip = flip
	var animation_name: StringName = _row_animation(row)
	if animated_sprite.animation != animation_name:
		animated_sprite.animation = animation_name
		glow_sprite.animation = animation_name
	animated_sprite.flip_h = flip
	glow_sprite.flip_h = flip

## Строка листа и зеркало по вектору скорости (экранные координаты, y вниз).
func _resolve_row(velocity_now: Vector2) -> void:
	if velocity_now.length_squared() < 0.01:
		return
	var angle_from_down: float = rad_to_deg(atan2(absf(velocity_now.x), velocity_now.y))
	var margin: float = view_hysteresis_degrees
	var sector: Vector2 = ROW_SECTORS[current_row]
	var new_row: int = current_row
	if angle_from_down < sector.x - margin or angle_from_down >= sector.y + margin:
		new_row = ROW_N
		for row: int in ROW_COUNT:
			if angle_from_down >= ROW_SECTORS[row].x and angle_from_down < ROW_SECTORS[row].y:
				new_row = row
				break
	# SW, W, NW нарисованы лицом влево; движение вправо даёт SE, E, NE через зеркало. S и N симметричны.
	var mirrored_row: bool = new_row == ROW_SW or new_row == ROW_W or new_row == ROW_NW
	var flip: bool = current_flip
	if mirrored_row:
		if absf(velocity_now.x) > 0.1:
			flip = velocity_now.x > 0.0
	else:
		flip = false
	if new_row != current_row or flip != current_flip:
		_set_row(new_row, flip)

func _process(delta: float) -> void:
	_process_visual(delta)
	_sync_silhouette_shadow()

func _sync_silhouette_shadow() -> void:
	if silhouette_shadow == null:
		return
	if silhouette_shadow.animation != animated_sprite.animation:
		silhouette_shadow.animation = animated_sprite.animation
	silhouette_shadow.flip_h = animated_sprite.flip_h
	silhouette_shadow.frame = animated_sprite.frame

func _process_visual(delta: float) -> void:
	if not available:
		return
	var bug: GrayboxBug = get_parent() as GrayboxBug
	if not is_instance_valid(bug):
		return
	if state != State.WALK:
		_process_action(delta, bug)
		return
	var velocity_now: Vector2 = bug.velocity / bug.map_scale()
	var actual_speed: float = velocity_now.length()
	_resolve_row(velocity_now)
	var cycle_distance_px: float = row_cycle_distance_studio[current_row] * _game_px_per_studio_px() * unit_scale_mult * stride_scale
	var moving: bool = actual_speed > 0.1
	var previous_progress: float = fposmod(walk_phase, 1.0)
	animated_sprite.pause()
	glow_sprite.pause()
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
	animated_sprite.frame = mini(int(floor(cycle_progress * frame_count)), frame_count - 1)
	glow_sprite.frame = animated_sprite.frame
	_apply_lean(actual_speed, delta)
	glow_time += delta
	glow_touchdown_remaining = maxf(glow_touchdown_remaining - delta, 0.0)
	_apply_glow(glow_time + glow_phase_offset)

## Удар в сторону цели (вектор в экранных координатах). Анимация 0,5 с, пик удара примерно на 0,18 с.
func play_attack(direction: Vector2) -> void:
	if not available or not has_attack:
		return
	if state == State.ATTACK or state == State.DEATH:
		return
	state = State.ATTACK
	state_time = 0.0
	if direction.length_squared() > 0.0001:
		_resolve_row(direction.normalized() * 10.0)
	_set_row(current_row, current_flip)
	_show_action_frame(0, attack_frame_count)

func is_attacking() -> bool:
	return state == State.ATTACK

## Анимация смерти на месте, по окончании приходит сигнал death_finished.
func play_death() -> void:
	if not available or not has_death or state == State.DEATH:
		return
	state = State.DEATH
	state_time = 0.0
	death_emitted = false
	_set_row(current_row, current_flip)
	_show_action_frame(0, death_frame_count)

func is_dying() -> bool:
	return state == State.DEATH

func _show_action_frame(frame_index: int, total: int) -> void:
	var clamped: int = clampi(frame_index, 0, maxi(total - 1, 0))
	animated_sprite.pause()
	glow_sprite.pause()
	animated_sprite.frame = clamped
	glow_sprite.frame = clamped
	animated_sprite.rotation = 0.0
	glow_sprite.rotation = 0.0

func _process_action(delta: float, bug: GrayboxBug) -> void:
	glow_time += delta
	glow_touchdown_remaining = maxf(glow_touchdown_remaining - delta, 0.0)
	if state == State.ATTACK_HOLD:
		# Держим нейтральную позу, пока жук стоит; при движении возвращаемся к ходьбе.
		if (bug.velocity / bug.map_scale()).length() > 0.1:
			state = State.WALK
			_set_row(current_row, current_flip)
			was_moving = true
		_apply_glow(glow_time + glow_phase_offset)
		return
	state_time += delta
	var is_death: bool = state == State.DEATH
	var duration: float = maxf(death_duration if is_death else attack_duration, 0.01)
	var total: int = death_frame_count if is_death else attack_frame_count
	var progress: float = clampf(state_time / duration, 0.0, 1.0)
	_show_action_frame(int(floor(progress * total)), total)
	if is_death:
		contact_shadow.modulate.a = 1.0 - smoothstep(0.55, 1.0, progress)
		silhouette_shadow.modulate.a = ShadowLight.ALPHA * (1.0 - smoothstep(0.55, 1.0, progress))
		if progress >= 1.0 and not death_emitted:
			death_emitted = true
			death_finished.emit()
	elif progress >= 1.0:
		state = State.ATTACK_HOLD
		_set_row(current_row, current_flip)
		_show_action_frame(total - 1, total)
	_apply_glow(glow_time + glow_phase_offset)

func _apply_lean(speed_now: float, delta: float) -> void:
	if delta <= 0.0:
		return
	var accel: float = (speed_now - previous_speed) / delta
	previous_speed = speed_now
	smoothed_accel = lerpf(smoothed_accel, accel, clampf(delta * lean_smoothing, 0.0, 1.0))
	var amount: float = clampf(smoothed_accel / maxf(lean_full_accel, 1.0), -1.0, 1.0)
	var facing_sign: float = 1.0 if animated_sprite.flip_h else -1.0
	var lean_rad: float = deg_to_rad(max_lean_deg) * amount * facing_sign
	animated_sprite.rotation = lean_rad
	glow_sprite.rotation = lean_rad

func _check_touchdowns(previous_progress: float, current_progress: float) -> void:
	for touchdown: float in touchdown_phases:
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

func _apply_shadow() -> void:
	if silhouette_shadow != null:
		var ground: Transform2D = ShadowLight.ground_basis()
		var factor: float = _sprite_scale()
		silhouette_shadow.transform = Transform2D(ground.x * factor, ground.y * factor, Vector2.ZERO)
	var shadow_width_px: float = bug_visual_height_px * shadow_width_fraction * unit_scale_mult
	var shadow_height_px: float = shadow_width_px * 0.4
	var texture_size: Vector2 = contact_shadow.texture.get_size()
	contact_shadow.scale = Vector2(shadow_width_px / maxf(texture_size.x, 1.0), shadow_height_px / maxf(texture_size.y, 1.0))
	contact_shadow.position = Vector2(0.0, 0.0)
	var shadow_material: ShaderMaterial = contact_shadow.material as ShaderMaterial
	if shadow_material != null:
		shadow_material.set_shader_parameter("shadow_opacity", shadow_opacity)

var hit_tween: Tween

func on_hit() -> void:
	var hit_material: ShaderMaterial = animated_sprite.material as ShaderMaterial
	if hit_material != null:
		if hit_tween != null and hit_tween.is_valid():
			hit_tween.kill()
		hit_material.set_shader_parameter("hit_flash", 1.0)
		hit_tween = create_tween()
		hit_tween.tween_method(_set_hit_flash.bind(hit_material), 1.0, 0.0, 0.07)

func _set_hit_flash(value: float, hit_material: ShaderMaterial) -> void:
	if is_instance_valid(hit_material):
		hit_material.set_shader_parameter("hit_flash", value)
