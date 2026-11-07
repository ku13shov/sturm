class_name BunkerShardData
extends RefCounted
## Заранее нарезанные осколки бункера (из критического состояния). Позиция = левый верхний угол
## осколка в кадре 384x244. Файлы лежат в art_dir/shards/.

const SUBDIR := "shards/"
const SHARDS: Array = [
	["bunker_shard_00", Vector2(95, 26)],
	["bunker_shard_01", Vector2(119, 0)],
	["bunker_shard_02", Vector2(172, 0)],
	["bunker_shard_03", Vector2(235, 16)],
	["bunker_shard_04", Vector2(0, 80)],
	["bunker_shard_05", Vector2(42, 47)],
	["bunker_shard_06", Vector2(105, 68)],
	["bunker_shard_07", Vector2(174, 55)],
	["bunker_shard_08", Vector2(263, 50)],
	["bunker_shard_09", Vector2(330, 81)],
	["bunker_shard_10", Vector2(0, 117)],
	["bunker_shard_11", Vector2(43, 122)],
	["bunker_shard_12", Vector2(104, 122)],
	["bunker_shard_13", Vector2(186, 117)],
	["bunker_shard_14", Vector2(251, 100)],
	["bunker_shard_15", Vector2(301, 105)],
	["bunker_shard_16", Vector2(103, 192)],
	["bunker_shard_17", Vector2(117, 176)],
	["bunker_shard_18", Vector2(189, 184)],
	["bunker_shard_19", Vector2(248, 175)],
]
