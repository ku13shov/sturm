class_name PortraitSurvivalLayout
extends Node

const DESIGN_SIZE: Vector2 = Vector2(432.0, 768.0)
const BOTTOM_BAR_HEIGHT: float = 0.0
const TOP_BAR_HEIGHT: float = 0.0

@onready var background: ColorRect = get_parent().get_node("Background") as ColorRect
@onready var playfield: Control = get_parent().get_node("Playfield") as Control
@onready var mars_ground: TextureRect = playfield.get_node("Entities/MarsGround") as TextureRect
const MAP_GROUND_SIZE: float = 8192.0
@onready var hud: Control = get_parent().get_node_or_null("HUD") as Control
@onready var test_hud_button: Button = get_parent().get_node("TestHUDButton") as Button
@onready var test_hud: Control = get_parent().get_node("TestHUD") as Control

func _ready() -> void:
	for debug_child: Node in test_hud.get_children():
		if debug_child is Control:
			(debug_child as Control).visible = false
	test_hud.visible = false
	test_hud_button.mouse_filter = Control.MOUSE_FILTER_STOP
	get_viewport().size_changed.connect(_apply_layout)
	test_hud_button.pressed.connect(_toggle_test_hud)
	call_deferred("_apply_layout")

func _apply_layout() -> void:
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	if screen_size.x > screen_size.y:
		screen_size = DESIGN_SIZE
	elif screen_size.x < 360.0:
		screen_size = DESIGN_SIZE * (screen_size.x / DESIGN_SIZE.x)
	var _ui_scale: float = screen_size.x / DESIGN_SIZE.x
	if screen_size.x > DESIGN_SIZE.x:
		_ui_scale = 1.0
	background.position = Vector2.ZERO
	background.size = screen_size
	playfield.position = Vector2.ZERO
	playfield.size = screen_size
	mars_ground.position = Vector2(-MAP_GROUND_SIZE * 0.5, -MAP_GROUND_SIZE * 0.5)
	mars_ground.size = Vector2(MAP_GROUND_SIZE, MAP_GROUND_SIZE)
	if is_instance_valid(hud):
		hud.position = Vector2.ZERO
		hud.size = screen_size
		hud.scale = Vector2.ONE
	_layout_playfield_children(screen_size.x, playfield.size.y)
	if is_instance_valid(hud):
		_layout_primary_hud(screen_size.x)
		hud.visible = false
	test_hud.visible = false
	test_hud_button.visible = false

func _layout_playfield_children(width: float, height: float) -> void:
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	var mini_map: Control = playfield.get_node("MiniMap") as Control
	mini_map.position = Vector2(6.0, 6.0)
	mini_map.size = Vector2(64.0, 54.0)
	var mini_caption: Control = mini_map.get_node("MiniMapCaption") as Control
	mini_caption.visible = false
	var attack_marker_node: Control = mini_map.get_node("AttackMarker") as Control
	attack_marker_node.position = Vector2(48.0, 2.0)
	attack_marker_node.size = Vector2(16.0, 18.0)
	var context: Control = playfield.get_node("ContextPanel") as Control
	context.visible = false
	context.color = Color(0.04, 0.02, 0.016, 0.94)
	var context_height: float = 132.0
	context.position = Vector2(8.0, height - 108.0 - context_height)
	context.size = Vector2(width - 16.0, context_height)
	var context_inner: float = context.size.x - 16.0
	var context_title: Control = context.get_node("ContextTitle") as Control
	context_title.position = Vector2(8.0, 6.0)
	context_title.size = Vector2(context_inner, 22.0)
	var context_hint: Control = context.get_node("ContextHint") as Control
	context_hint.position = Vector2(8.0, 28.0)
	context_hint.size = Vector2(context_inner, 20.0)
	var action_picker: Control = context.get_node("ActionPicker") as Control
	action_picker.position = Vector2(8.0, 54.0)
	action_picker.size = Vector2(context_inner, 34.0)
	var use_action: Control = context.get_node("UseActionButton") as Control
	use_action.position = Vector2(8.0, 92.0)
	use_action.size = Vector2(context_inner, 34.0)
	var research_picker: Control = context.get_node("ResearchPicker") as Control
	research_picker.position = Vector2(8.0, 54.0)
	research_picker.size = Vector2(context_inner, 34.0)
	var research_button: Control = context.get_node("ResearchButton") as Control
	research_button.position = Vector2(8.0, 92.0)
	research_button.size = Vector2(context_inner, 34.0)
	var upgrade_building: Control = context.get_node("UpgradeBuildingButton") as Control
	upgrade_building.position = Vector2(8.0, 54.0)
	upgrade_building.size = Vector2(context_inner, 34.0)
	var half_width: float = (context_inner - 8.0) * 0.5
	var repair_building: Control = context.get_node("RepairBuildingButton") as Control
	repair_building.position = Vector2(8.0, 92.0)
	repair_building.size = Vector2(half_width, 34.0)
	var sell_building: Control = context.get_node("SellBuildingButton") as Control
	sell_building.position = Vector2(16.0 + half_width, 92.0)
	sell_building.size = Vector2(half_width, 34.0)
	for contextual_node: Node in context.get_children():
		if contextual_node is Control:
			(contextual_node as Control).z_index = 1
	action_picker.z_index = 2
	use_action.z_index = 2
	research_picker.z_index = 2
	research_button.z_index = 2
	var entities: Node2D = playfield.get_node("Entities") as Node2D
	if not get_parent().has_meta("portrait_entities_position_initialized"):
		entities.position = Vector2.ZERO
		get_parent().set_meta("portrait_entities_position_initialized", true)
	var base: Node2D = entities.get_node("CentralBase") as Node2D
	var target_base_screen_position: Vector2 = Vector2(width * 0.5, height * 0.5)
	var previous_base_screen_position: Vector2 = entities.position + base.position * entities.scale
	var base_screen_offset: Vector2 = target_base_screen_position - previous_base_screen_position
	var apply_base_layout: bool = not get_parent().has_meta("portrait_base_offset_applied")
	if apply_base_layout:
		get_parent().set_meta("portrait_base_offset", base_screen_offset)
		get_parent().set_meta("portrait_base_offset_applied", true)
		entities.position += base_screen_offset
		var local_offset: Vector2 = base_screen_offset / maxf(entities.scale.x, 0.001)
		var towers: Node2D = entities.get_node("Towers") as Node2D
		for tower_node: Node in towers.get_children():
			var tower: Node2D = tower_node as Node2D
			tower.position += local_offset
		var enemies: Node2D = entities.get_node("Enemies") as Node2D
		for enemy_node: Node in enemies.get_children():
			var enemy: Node2D = enemy_node as Node2D
			enemy.position += local_offset
	var credits_badge: Control = playfield.get_node_or_null("CreditsBadge") as Control
	var strip: Control = playfield.get_node_or_null("RetroTopStrip") as Control
	var minimap_node: Control = playfield.get_node_or_null("MiniMap") as Control
	for hud_plate: Control in [credits_badge, strip, minimap_node]:
		if hud_plate != null:
			hud_plate.z_index = 1800
	if strip != null:
		var strip_width: float = width - 82.0
		strip.position = Vector2(76.0, 50.0)
		strip.size = Vector2(strip_width, 64.0)
		var strip_icon: Control = strip.get_node("SelectionIcon") as Control
		strip_icon.position = Vector2(6.0, 4.0)
		strip_icon.size = Vector2(52.0, 48.0)
		var strip_bar: Control = strip.get_node("SelectionHpBar") as Control
		strip_bar.position = Vector2(6.0, 54.0)
		strip_bar.size = Vector2(52.0, 6.0)
		var strip_title: Control = strip.get_node("SelectionTitle") as Control
		strip_title.position = Vector2(66.0, 6.0)
		strip_title.size = Vector2(strip_width - 72.0, 24.0)
		var strip_stats: Control = strip.get_node("SelectionStats") as Control
		strip_stats.position = Vector2(66.0, 32.0)
		strip_stats.size = Vector2(strip_width - 72.0, 22.0)
	if credits_badge != null:
		credits_badge.position = Vector2(width - 100.0, 6.0)
		credits_badge.size = Vector2(94.0, 38.0)
		var credits_text: Control = credits_badge.get_node("CreditsText") as Control
		credits_text.position = Vector2(4.0, 4.0)
		credits_text.size = Vector2(86.0, 30.0)
	var fog_top: ColorRect = playfield.get_node("FogTop") as ColorRect
	fog_top.position = Vector2.ZERO
	fog_top.size = Vector2(width, 20.0)
	var fog_bottom: ColorRect = playfield.get_node("FogBottom") as ColorRect
	fog_bottom.position = Vector2(0.0, height - 20.0)
	fog_bottom.size = Vector2(width, 20.0)
	var fog_left: ColorRect = playfield.get_node("FogLeft") as ColorRect
	fog_left.position = Vector2(0.0, 20.0)
	fog_left.size = Vector2(20.0, height - 40.0)
	var fog_right: ColorRect = playfield.get_node("FogRight") as ColorRect
	fog_right.position = Vector2(width - 20.0, 20.0)
	fog_right.size = Vector2(20.0, height - 40.0)
	var commander_intro: Control = get_parent().get_node("CommanderIntro") as Control
	commander_intro.position = Vector2.ZERO
	commander_intro.size = screen_size
	commander_intro.z_index = 2000
	var intro_dialog: Control = commander_intro.get_node("Dialog") as Control
	intro_dialog.position = Vector2(maxf(0.0, (width - 400.0) * 0.5), height * 0.45)
	intro_dialog.size = Vector2(minf(width, 400.0), 256.0)

func _layout_primary_hud(width: float) -> void:
	var title: Control = hud.get_node("Title") as Control
	title.visible = false
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.035, 0.05, 0.98)
	hud.add_theme_stylebox_override("panel", panel_style)
	var subtitle: Control = hud.get_node("Subtitle") as Control
	subtitle.visible = false
	var save_button: Control = hud.get_node("SaveButton") as Control
	save_button.visible = false
	var load_button: Control = hud.get_node("LoadButton") as Control
	load_button.visible = false
	var credits: Control = hud.get_node("Credits") as Control
	credits.visible = false
	credits.position = Vector2(12.0, 36.0)
	credits.size = Vector2(width - 24.0, 24.0)
	var selected: Control = hud.get_node("SelectedBuilding") as Control
	selected.visible = false
	var tower_info: Control = hud.get_node("TowerInfo") as Control
	tower_info.visible = false
	var picker: Control = hud.get_node("BuildingPicker") as Control
	picker.visible = false
	var shortcut151: Control = hud.get_node("Building151Button") as Control
	shortcut151.visible = false
	var shortcut153: Control = hud.get_node("Building153Button") as Control
	shortcut153.visible = false
	var shortcut155: Control = hud.get_node("Building155Button") as Control
	shortcut155.visible = false
	var wave: Control = hud.get_node("Wave") as Control
	wave.visible = false
	wave.size = Vector2(width - 24.0, 24.0)
	var next_wave: Control = hud.get_node("NextWaveButton") as Control
	next_wave.visible = false
	var pause: Control = get_parent().get_node("PauseTouchButton") as Control
	pause.visible = true
	pause.position = Vector2(8.0, get_viewport().get_visible_rect().size.y - 48.0)
	pause.text = "ПАУЗА"
	pause.size = Vector2(104.0, 38.0)
	pause.z_index = 2500
	var actions: Control = get_parent().get_node("ActionsTouchButton") as Control
	actions.visible = true
	actions.position = Vector2(width - 112.0, get_viewport().get_visible_rect().size.y - 48.0)
	actions.size = Vector2(104.0, 38.0)
	actions.z_index = 2500
	var notice: Control = get_parent().get_node("ProgressionNotice") as Control
	notice.set_anchors_preset(Control.PRESET_TOP_LEFT)
	notice.position = Vector2.ZERO
	notice.size = playfield.size
	var pause_menu: Control = get_parent().get_node("PauseMenu") as Control
	pause_menu.visible = false
	pause_menu.set_anchors_preset(Control.PRESET_TOP_LEFT)
	pause_menu.position = Vector2.ZERO
	pause_menu.size = playfield.size
	var base_label: Control = hud.get_node("BaseLabel") as Control
	base_label.visible = false
	var base_bar: Control = hud.get_node("BaseHealth") as Control
	base_bar.visible = false
	var upgrade: Control = hud.get_node("UpgradeButton") as Control
	upgrade.position = Vector2(12.0, 116.0)
	upgrade.size = Vector2((width - 32.0) / 3.0, 34.0)
	var repair: Control = hud.get_node("RepairButton") as Control
	repair.position = Vector2(16.0 + (width - 32.0) / 3.0, 116.0)
	repair.size = Vector2((width - 32.0) / 3.0, 34.0)
	var sell: Control = hud.get_node("SellButton") as Control
	sell.position = Vector2(20.0 + (width - 32.0) * 2.0 / 3.0, 116.0)
	sell.size = Vector2((width - 32.0) / 3.0, 34.0)
	var status: Control = hud.get_node("Status") as Control
	status.visible = false
	var instructions: Control = hud.get_node("Instructions") as Control
	instructions.visible = false
	var build: Control = hud.get_node("BuildButton") as Control
	build.visible = false
	var cancel: Control = hud.get_node("CancelBuildButton") as Control
	cancel.visible = false
	cancel.position = Vector2(width - 116.0, get_viewport().get_visible_rect().size.y - 92.0)
	cancel.size = Vector2(108.0, 36.0)

func _grid_cell_from_world(world_position: Vector2) -> Vector2i:
	var origin_x: float = -float(MapGrid.WIDTH) * MapGrid.CELL_SIZE * 0.5
	var origin_y: float = -float(MapGrid.HEIGHT) * MapGrid.CELL_SIZE * 0.5
	return Vector2i(floori((world_position.x - origin_x) / MapGrid.CELL_SIZE), floori((world_position.y - origin_y) / MapGrid.CELL_SIZE))

func _toggle_test_hud() -> void:
	test_hud.visible = not test_hud.visible
	test_hud_button.text = "Тест HUD: ВКЛ" if test_hud.visible else "Тест HUD"