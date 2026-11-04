class_name SoldierSheetData
extends RefCounted
## Сгенерировано export_soldier.py из студии. Не править руками: данные листов нового солдата.

const FRAME_SIZE: Vector2i = Vector2i(128, 184)
const PIVOT: Vector2 = Vector2(64.0, 183.0)
const IDLE_FRAMES: int = 12
const SHOT_FRAMES: int = 8
const IDLE_PERIOD: float = 2.2
const SHOT_DURATION: float = 0.28
## Масштаб листа относительно студийного холста (1/3).
const SHEET_SCALE: float = 0.333333
## Видимая высота солдата (ступни — макушка) в px листа, вид S.
const VISIBLE_HEIGHT_PX: float = 180.7

## Порядок видов в листах: 0 S, 1 SE, 2 E, 3 NE, 4 N.
const ROW_OF_DIRECTION: Array[int] = [0, 1, 2, 3, 4, 3, 2, 1]
const FLIP_OF_DIRECTION: Array[bool] = [false, true, true, true, false, false, false, false]

## Параметры видов в координатах студийного холста 424x736 (до масштаба листа).
## anchor = (CX, FY) точка опоры; muzzle = (mx, my) до сдвига рук; arms/head_shift = (ax, ay)/(hx, hy).
const VIEWS: Array[Dictionary] = [
	{
		"name": "s", "behind": false, "an": 27.0,
		"anchor": Vector2(212, 627), "head_c": Vector2(213, 145), "arms_c": Vector2(203, 308),
		"muzzle": Vector2(361, 373), "head_shift": Vector2(-1.5, 5.5), "arms_shift": Vector2(0, -3.5),
		"sparks": [[213, 145, 12], [200, 308, 10], [110, 235, 5], [315, 235, 5]],
	},
	{
		"name": "se", "behind": false, "an": 27.0,
		"anchor": Vector2(208, 625), "head_c": Vector2(204, 133), "arms_c": Vector2(195, 301),
		"muzzle": Vector2(339, 366), "head_shift": Vector2(6.5, 13.5), "arms_shift": Vector2(10.5, 3.5),
		"sparks": [[225, 141, 12], [195, 301, 10], [110, 235, 5], [300, 235, 5]],
	},
	{
		"name": "e", "behind": false, "an": 38.0,
		"anchor": Vector2(182, 628), "head_c": Vector2(184, 142), "arms_c": Vector2(240, 312),
		"muzzle": Vector2(365, 373), "head_shift": Vector2(-1, 1), "arms_shift": Vector2(-2, 0),
		"sparks": [[224, 138, 12], [240, 312, 10], [105, 225, 5], [205, 225, 5]],
	},
	{
		"name": "ne", "behind": false, "an": 23.0,
		"anchor": Vector2(195, 629), "head_c": Vector2(190, 136), "arms_c": Vector2(213, 328),
		"muzzle": Vector2(387, 367), "head_shift": Vector2(0, -1.5), "arms_shift": Vector2(-1.5, -3.5),
		"sparks": [[124, 235, 12], [294, 232, 8], [350, 355, 10], [190, 135, 4]],
	},
	{
		"name": "n", "behind": true, "an": -70.0,
		"anchor": Vector2(212, 627), "head_c": Vector2(211, 133), "arms_c": Vector2(212, 309),
		"muzzle": Vector2(285, 195), "head_shift": Vector2(0, -2), "arms_shift": Vector2(-1.5, -10.5),
		"sparks": [[206, 235, 14], [349, 235, 6], [212, 309, 8], [211, 133, 4]],
	},
]

## LAYERS: [view][layer] -> {rect (в атласе), origin (левый верх в координатах холста)}
const LAYERS: Array[Dictionary] = [
	{"body": {"rect": Rect2(0, 0, 112, 153), "origin": Vector2(45, 168)}, "head": {"rect": Rect2(120, 0, 44, 43), "origin": Vector2(147, 84)}, "arms": {"rect": Rect2(168, 0, 99, 47), "origin": Vector2(54, 237)}},
	{"body": {"rect": Rect2(272, 0, 108, 152), "origin": Vector2(45, 171)}, "head": {"rect": Rect2(384, 0, 39, 40), "origin": Vector2(144, 75)}, "arms": {"rect": Rect2(0, 160, 90, 48), "origin": Vector2(60, 228)}},
	{"body": {"rect": Rect2(96, 160, 64, 154), "origin": Vector2(72, 165)}, "head": {"rect": Rect2(168, 160, 43, 38), "origin": Vector2(120, 84)}, "arms": {"rect": Rect2(216, 160, 77, 47), "origin": Vector2(123, 240)}},
	{"body": {"rect": Rect2(296, 160, 94, 158), "origin": Vector2(51, 156)}, "head": {"rect": Rect2(392, 160, 36, 32), "origin": Vector2(135, 87)}, "arms": {"rect": Rect2(0, 320, 108, 37), "origin": Vector2(51, 273)}},
	{"body": {"rect": Rect2(112, 320, 95, 157), "origin": Vector2(69, 156)}, "head": {"rect": Rect2(208, 320, 39, 30), "origin": Vector2(153, 87)}, "arms": {"rect": Rect2(248, 320, 95, 23), "origin": Vector2(69, 273)}},
]

## GLOW_LAYERS: [view][layer] -> {rect (в атласе), origin (левый верх в координатах холста)}
const GLOW_LAYERS: Array[Dictionary] = [
	{"body": {"rect": Rect2(0, 0, 107, 17), "origin": Vector2(51, 207)}, "head": {"rect": Rect2(112, 0, 40, 16), "origin": Vector2(168, 129)}, "arms": {"rect": Rect2(160, 0, 31, 35), "origin": Vector2(210, 252)}},
	{"body": {"rect": Rect2(192, 0, 91, 23), "origin": Vector2(72, 189)}, "head": {"rect": Rect2(288, 0, 31, 26), "origin": Vector2(177, 87)}, "arms": {"rect": Rect2(320, 0, 74, 36), "origin": Vector2(57, 243)}},
	{"body": {"rect": Rect2(400, 0, 16, 13), "origin": Vector2(147, 204)}, "head": {"rect": Rect2(424, 0, 39, 20), "origin": Vector2(138, 117)}, "arms": {"rect": Rect2(464, 0, 24, 33), "origin": Vector2(267, 258)}},
	{"body": {"rect": Rect2(0, 40, 71, 91), "origin": Vector2(99, 192)}, "head": {"rect": Rect2(72, 40, 3, 8), "origin": Vector2(174, 102)}, "arms": {"rect": Rect2(80, 40, 8, 8), "origin": Vector2(306, 294)}},
	{"body": {"rect": Rect2(96, 40, 76, 29), "origin": Vector2(129, 186)}},
]
