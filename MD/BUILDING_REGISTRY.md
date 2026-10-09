# Building Registry — source and usage

## Purpose

`res://data/building_registry.gd` is the single data registry for building and defence
records used by the Godot prototype. It prevents IDs, names, costs and presentation paths
from being duplicated across gameplay code and UI.

The registry is a prototype data layer, not a claim that every field is already reconstructed
from the original game.

## Evidence policy

Each record keeps evidence status alongside the value:

- `ORIGINAL_CONFIRMED` — supported by a demonstrated original source/runtime chain;
- `SCREENSHOT_CONFIRMED` — visible in captured original-game material;
- `USER_OBSERVED` — reported after controlled play of the original game;
- `ORIGINAL_INFERRED` — strong interpretation that is not fully closed;
- `TEMPORARY_BALANCE` — value used only to make the prototype playable;
- `UNRESOLVED` — do not treat as known original behavior.

The Help descriptions in `res://MD/HELP_CONTENT.md` are the primary source for the intended
purpose of buildings and towers. Missing operational details are added from user observations
while playing the original game. Forensic/bytecode analysis is reserved for narrow questions
that cannot be answered by Help or observation.

## Field meanings

| Field | Meaning |
|---|---|
| `name` | Stable internal identifier |
| `display_name` | Name shown by the Godot prototype |
| `help_name` | Corresponding Help entry name |
| `cost` | Reconstructed/source-facing cost; retain its evidence status |
| `prototype_cost` | Temporary cost currently used by the playable slice |
| `max_health`, `defense`, `attack`, `radius` | Known or temporary gameplay values |
| `max_upgrade_level` | Maximum prototype level; level 3 is represented as upgrade level 2 |
| `upgrade_costs` | Costs for each upgrade step |
| `upgrade_*_bonus` | Per-upgrade observed/statistical bonuses |
| `construction_time` | Construction duration in seconds; Energy Station: 25, Soldiers: 5 |
| `unique` | If true, only one instance may be built on the map |

| `upgrade_time` | Upgrade construction duration in seconds |
| Repair | Approximately 2 HP/s at $3 per restored HP; user-observed estimate |
| Sell refund | 50% of total investment multiplied by remaining HP percentage; base cannot be sold |
| `footprint` | Grid cells occupied by the prototype building |
| `base_clearance_radius` | Prototype placement restriction near the base |
| `combat_status` | Current classification of combat/effect behavior |
| `scene_path` | Godot scene used to instantiate the building |
| `status` | Evidence status for the record/value set |

Selling a non-base building returns half of its total invested cost, including completed upgrade costs; the Central Base cannot be sold. The prototype uses half of `prototype_cost` plus each completed upgrade cost for the current refund until original cost mappings are fully confirmed.

`cost` and `prototype_cost` must not be silently conflated. A value observed in the original
should update the evidence-facing field only after its source/status is recorded; prototype
balance may remain separate until the behavior is confirmed.

## Registry groups

- `INITIAL_IDS`: buildings available immediately in the original opening state: Soldiers (`163`) and Energy Station (`151`), in that order;
- `PLAYABLE_IDS`: buildings currently supported by the prototype placement/save path;
- `BUILDINGS`: all currently registered original building IDs, including unresolved entries.

Adding a building to `BUILDINGS` does not automatically make it playable. It must also have a
scene and be deliberately added to `PLAYABLE_IDS` after its placement/save behavior is ready.

## Current implementation boundary

`res://data/game_balance.gd` exposes `GameBalance.BUILDINGS` as a compatibility alias to the
registry. New code should read from `BuildingRegistry` directly. Existing scripts may continue
to use the alias while being migrated.

The registry is covered by `res://tests/test_building_registry.gd`.
