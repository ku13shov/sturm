# STURMTRUPP MARS — SOURCE OF TRUTH

> Current-state reference. This file contains only the conclusions that are currently safe to
> use as reconstruction facts, plus explicitly marked unresolved items.
>
> For evidence and historical reasoning, see `RESEARCH.md`.
> For implementation order, see `ROADMAP.md`.

## Status vocabulary

### Graybox balance policy

When original runtime semantics cannot be closed from the available JAR, bytecode, tables or controlled emulator observations, the prototype may use visually and mechanically inferred values for playability. These values must remain separate from reconstructed original data and must be labelled `TEMPORARY_BALANCE` or `ORIGINAL_INFERRED` as appropriate. A later balance pass will consolidate them into a dedicated comparison table with rationale, observed gameplay result and planned tuning. No visually estimated value may be promoted to `ORIGINAL_CONFIRMED` without new evidence.

- `ORIGINAL_CONFIRMED` — source and consumer/runtime semantics are demonstrated.
- `ORIGINAL_INFERRED` — strong interpretation, but not yet fully closed.
- `TEMPORARY_BALANCE` — placeholder for the remake; not original data.
- `UNRESOLVED` — do not treat as reconstructed original behavior.

### Evidence priority for building behavior

The project now uses a Help-first and observation-driven strategy for building and tower
behavior. `res://MD/HELP_CONTENT.md` is the primary source for the intended player-facing
purpose of each building because it was transferred from the original game's Help section.
Missing operational details will be documented from controlled play of the original game by
the user: construction, upgrades, targets, attack/effect type, range, visibility, timers,
prerequisites and other observable behavior.

These evidence classes must remain distinct:

- `SCREENSHOT_CONFIRMED` — text or value visible in captured original-game material;
- `USER_OBSERVED` — behavior directly reported after playing the original game;
- `ORIGINAL_CONFIRMED` — source and consumer/runtime semantics demonstrated;
- `ORIGINAL_INFERRED` — strong interpretation not fully closed;
- `TEMPORARY_BALANCE` — remake placeholder;
- `UNRESOLVED` — insufficient evidence.

The previous plan to exhaustively trace activation callers for every remaining building ID is
no longer a project blocker. Forensic tracing may still be used for a specific unresolved
question, but it should not delay implementation when Help content and direct gameplay
observations provide an adequate description.

### Building data registry

The prototype's centralized building data lives in `res://data/building_registry.gd`.
It stores IDs, names, source-facing costs, separate temporary prototype costs, placement
footprints, scene paths and evidence statuses. `res://data/game_balance.gd` keeps
`GameBalance.BUILDINGS` as a compatibility alias during migration. See
`res://MD/BUILDING_REGISTRY.md` for the field definitions and update policy.

---

## Prototype implementation status

The first manual Survival interaction pass is implemented and playable.

A `GameBalance.SCREENSHOT_CONFIRMED_UI` register now stores confirmed player-facing values separately from temporary runtime balance.

User-observed Soldier values now include: Level 1 — `ОЖ 80`, `О 5`, `А 3`, `Р 2`, construction cost `$500`; Level 2 upgrade cost `$600`, with bonuses `ОЖ +20`, `О +5`, `А +1` and unchanged `Р`; Level 3 upgrade cost `$1000`, with the same additional bonuses `ОЖ +20`, `О +5`, `А +1` and unchanged `Р`. Buildings can be upgraded through level 3. These values are recorded as `USER_OBSERVED` and are implemented in the Soldier scene/registry.

The current prototype picker exposes Energy Station, Fire Tower, Soldiers, Laser Tower, Plasma Tower, Radar Tower and Beacon as registered/prototype entries. The prototype has versioned user:// JSON saves (v2) for progression, placed buildings, wave schedule state and active enemy snapshots. These are implementation details of the prototype and do not assert original save-file semantics. The original opening state currently observed by the user provides Soldiers (`163`) and Energy Station (`151`) immediately; the registry therefore keeps `163` first and `151` second in `INITIAL_IDS`. The unlock path for Fire Tower and later structures remains to be documented from original gameplay. Research is currently gated by building an Energy Station as a temporary gameplay assumption; the original research building/prerequisite remains unresolved. Advanced entries are now gated behind the prototype's Central Base modernization flow; the unlock cost and rank rules remain `TEMPORARY_BALANCE` until confirmed. The Survival context panel now exposes the captured Research and Additional Actions categories; their current gameplay effects are explicitly prototype implementations, not claims about hidden formulas. Laser Tower L1 uses the confirmed `$600` UI cost; other prototype costs remain explicitly marked temporary until their screenshots provide exact values. It includes Central Base L1 (`ОЖ 750`, `О 25`), Laser Tower L1 (`600 $`, `ОЖ 125`, `О 10`, `А 6`, `Р 3`) and the displayed Soldier values (`ОЖ 76`, `О 10`, `А 4`, `Р 2`). These values are not yet forced into every combat formula; their UI evidence and runtime semantics remain separated. Soldiers use a dedicated scene with the confirmed `110.png` visual family. The player must choose and place defenses; waves remain automated as the opposing game system.

The top selection strip and radar marker are now scene-authored presentation elements. They are deliberately separated from combat logic so later retro UI refinement can replace them without rewriting gameplay. Selecting a built structure now opens a context menu with upgrade, repair and (for non-base structures) sell actions. The Central Base intentionally has no sell action. The original-game observation confirms that selling a fully healthy non-base building returns half of its total invested cost. A damaged building returns that amount multiplied by its remaining HP percentage (current HP / maximum HP); lost HP therefore reduces the refund proportionally. The prototype calculates this as half of the construction cost plus the upgrade cost for each completed upgrade; repair prices remain prototype balance until confirmed. Repairs are non-instantaneous: they restore approximately 2 HP per second and cost $3 per restored HP; the repair action stops when the building is full or funds run out. Upgrading is not instantaneous: it uses the same construction/progress lifecycle as initial building, disables combat during the work and applies the new level only when construction completes. Soldier level 1 construction takes 5 seconds; each Soldier upgrade takes 3 seconds. Energy Station construction takes 25 seconds. It is unique: only one Energy Station may exist on the map.



The first playable prototype pass has begun. It uses the confirmed Survival-mode start values and keeps unresolved balance fields temporary:

- starting credits: `$2500`;
- Central Base level 1: `ОЖ 750`, `О 25`;
- original Central Base visual: `100.png`;
- original Fire Tower visual layering: shared base `103.png` plus directional upper asset `107.png` for the prototype level;
- unresolved construction costs and combat values remain `TEMPORARY_BALANCE`.

## Screenshot-confirmed starting values

The user-provided Survival-mode screenshot confirms:

```text
Central Base level 1: ОЖ 750, О 25
Starting credits: $2500
```

Evidence: `ziva-attachment:T-CYv5ptddj5oQjCmQH7o`.

These are player-facing starting values and are safe to use as `SCREENSHOT_CONFIRMED` balance inputs for the initial Survival setup.

## 0. Current presentation decision — 2.5D

The current direction is **2.5D/isometric**, not mandatory full 3D.

Confirmed project decision:

- gameplay remains grid-based and independent from presentation;
- units, buildings, map elements, UI and VFX are authored as editable Godot scenes;
- 2D presentation uses `Sprite2D`, `AnimatedSprite2D`, `AnimationPlayer`, sprite
  sheets, cutout parts and particles;
- limited 3D depth elements remain allowed when useful;
- AI-generated video is reference material only unless converted into stable,
  transparent and consistent game frames;
- existing 3D basic-bug prototype is retained as a technical experiment, not as
  a requirement that all future assets must be full 3D.

This decision changes presentation strategy only. It does not change the original
IDs, balance evidence, grid rules or forensic status below.

## 0.1 Original visual resources — current status

- `res://original/137.png` exists and is `47×29` pixels.
- `C.class` maps resource index `74` to numeric PNG resource `137` through the
  normal `aD`/`dD` resource pipeline.
- In gameplay, `137.png` is observed as a ship-like module that descends onto
  and remains attached to the central base.
- Its exact logical/runtime role is still `UNRESOLVED`; the previous mapping to
  logical ID `173` Communication Center requires revalidation.
- `res://original/000.png` exists and is `168×168` pixels.
- `000.png` is the user-reported Mars ground/terrain resource (`USER_REPORTED`);
  it is 168×168, fully opaque, and has 44 observed colors. The original resource
  table in `original/a`, loaded by `C.ZA(1)`, begins with resource ID 0; its
  image loader resolves ID 0 to `/000.png`. Metadata columns 1–2 specify a
  7-pixel frame-origin stride; the draw helper positions the full source image
  at that offset and clips a 24×24 window, producing overlapping source windows.
  The map renderer separately advances at 24-pixel world spacing. This does not
  establish the cell-to-frame mapping or prove conventional TileMap atlas
  semantics. `000.png` visibly combines ground and wall/edge artwork. Repeat
  rules and map selection remain `UNRESOLVED`; keep the sampling preview only.

These observations do not yet change logical IDs or asset bindings.

## 1. Enemy combat data — CONFIRMED

### `rA`

```text
loader: HG.B(InputStream)
type:   int[9][16]
offset: 12984
rows:   enemy IDs 70–78
```

Confirmed fields:

| Field | Meaning | Status |
|---|---|---|
| `rA[][3]` | Enemy ID | ORIGINAL_CONFIRMED |
| `rA[][4]` | enemy-profile field; previous 'Enemy Damage' label rejected as final HP damage because `C.A(int,int)` does not read it | ORIGINAL_INFERRED |
| `rA[][5]` | Bullet resistance | ORIGINAL_CONFIRMED |
| `rA[][6]` | Energy resistance | ORIGINAL_CONFIRMED |
| `rA[][7]` | Fire resistance | ORIGINAL_CONFIRMED |
| `rA[][10]` | Reward/score-related | ORIGINAL_CONFIRMED |
| `rA[][12]` | Enemy attack range | ORIGINAL_CONFIRMED |
| `rA[][13]` | Movement speed | ORIGINAL_CONFIRMED |

The reconstructed enemy IDs are `70–78`.

## 1.1 Final damage formula — bytecode confirmed

`C.A(int,int)` reads attacker components `lA[attacker][1..3]` and target resistances `rA[target_profile][5..7]`. Each component is multiplied by its matching resistance, divided by 100 with half-up rounding, subtracted from the corresponding attacker component, clamped to zero, then summed; zero is replaced with 1 before HP subtraction. `rA[][4]` is not read by this final HP damage path, so its earlier interpretation as direct enemy damage is rejected.

The exact basic-bug hit still requires mapping enemy runtime initialization to `lA[][1..3]`. However, `mA` rows 6–8 at `a` offset 7562 align directly with Soldier levels: L1 is `[4]=80`, `[5]=5`, `[6..8]=0,0,3`, radius low16 `[14]=2`, cooldown-like `[15]=300`. This confirms the Soldier attack vector, but not yet its target-side resistance mapping. `mA` rows 3–5 are a separate candidate enemy family with attack vectors `0,10,40`, `0,30,70`, `10,40,150`; enemy-ID mapping remains unresolved.

## 2. Enemy resistance model — CONFIRMED

The three resistance components are:

```text
Bullet
Energy
Fire
```

The current Godot representation may use:

```gdscript
"resistance": {
    "bullet": ...,
    "energy": ...,
    "fire": ...
}
```

The exact values must come from the source table, not placeholders.

## 3. Building records — PARTIALLY CONFIRMED

```text
oA : int[12][9]
offset: 11518

IDs:
151, 153, 155, 157, 159, 161,
163, 165, 167, 169, 171, 173
```

Confirmed:

- Building Max HP — `ORIGINAL_CONFIRMED`
- Building Cost — `ORIGINAL_CONFIRMED`

Not confirmed universally:

- Turret Damage
- Turret Range
- Turret Fire Rate

## 4. `mA` — CURRENT VERIFIED INTERPRETATION

```text
loader: HG.B(InputStream)
type:   int[45][19]
offset: 7562
```

The previous hypothesis that `mA[][4]` / `mA[][5]` were the primary
Damage/Range candidates is superseded by the 2026-09-23 forensic pass.

### Runtime-confirmed conventional `lA` combat fields

| Field | Meaning | Status |
|---|---|---|
| `mA[][6]` | damage component matched to `rA[][5]` (Bullet resistance) | ORIGINAL_CONFIRMED |
| `mA[][7]` | damage component matched to `rA[][6]` (Energy resistance) | ORIGINAL_CONFIRMED |
| `mA[][8]` | damage component matched to `rA[][7]` (Fire resistance) | ORIGINAL_CONFIRMED |
| low16 `mA[][14]` | target/engagement range used by conventional `lA` combat | ORIGINAL_CONFIRMED |
| `mA[][15]` | attack cooldown / interval added to runtime timer `lA[][19]` | ORIGINAL_CONFIRMED |

Confirmed damage chain:

```text
mA[type][6..8]
    ↓
L(type, component)
    ↓
A(lA_entity, component)
    ↓
A(attacker, target)
    ↓
rA[target_profile][5..7] resistance reduction
    ↓
Y(attacker, target)
    ↓
vA[target][22] -= calculated_damage
```

Confirmed range chain:

```text
low16 mA[type][14]
    ↓
N(type)
    ↓
D(lA_entity)
    ↓
MA() / RA() target-area tests
    ↓
target assignment / line-of-sight validation
```

Confirmed cooldown chain:

```text
mA[type][15]
    ↓
Y(attacker, target)
    ↓
lA[attacker][19] += cooldown
```

`MA()` also skips the attack/target-acquisition branch while `lA[][19] > 0`,
which closes the runtime timer role.

### Fields `[4]` and `[5]`

The UI consumer displays:

```text
mA[type][4]  with HG.I(3) = "ОЖ"
mA[type][5]  with HG.I(2) = "О"
mA[type][6..8] with HG.I(1) = "А"
low16 mA[type][14] with HG.I(4) = "Р"
```

UI labels are not accepted as gameplay proof by themselves.

Therefore:

```text
mA[][4] → HP/life-related candidate, ORIGINAL_INFERRED
mA[][5] → exact semantics UNRESOLVED; no longer treated as Damage/Range candidate
```

`mA[][5]` is also consumed through `M(int)` / `C(int[])` in spatial/path
logic, so its previous classification as a primary turret attack stat is rejected.

### Rows 36..44 / category blocks 13..15

For these nine rows the source data contains:

```text
mA[][6..8] = 0,0,0
low16 mA[][14] = -1
mA[][15] = -1
```

Thus these rows do **not** use the conventional `mA → lA` attack chain above.
Any damage/range behavior associated with structures mapped to these rows must be
traced through a separate static/special-effect consumer path.


## 5. Building/static-effect consumers — updated 2026-09-23

The `oA` block is **not** a universal turret table. However, several per-index consumers now have direct HP-mutation proof.

Confirmed special/static-effect paths:

| Building ID | `oA` index | Direct consumer | Proven effect | Status |
|---:|---:|---|---:|---|
| 155 | 2 | `C.P()` | `vA[][22] -= 750` inside effect zone | ORIGINAL_CONFIRMED |
| 157 | 3 | `C.M()` | special hit can set target `vA[][22] = 0` | ORIGINAL_CONFIRMED special effect; numeric Damage UNRESOLVED |
| 159 | 4 | `C.O()` | `vA[][22] -= 800` inside effect zone | ORIGINAL_CONFIRMED |
| 161 | 5 | `C.O()` | `vA[][22] -= 1000` inside effect zone | ORIGINAL_CONFIRMED |
| 173 | 11 | `C.P()` | `vA[][22] -= 4000` inside effect zone | ORIGINAL_CONFIRMED |

Historical values:

```text
155 → 125   REJECTED as direct effect damage
173 → 200   REJECTED as direct effect damage
```

The current source consumers use `750` and `4000` respectively. The old values remain only in `RESEARCH.md` as historical/rejected evidence.

For IDs `151,153,163,165,167,169,171`, no direct HP subtraction was found in the audited `oA` state switch. This is a negative result for that consumer, not proof that every possible action path is exhausted.

## 6. `oA[][7]`

`oA[][7]` participates in UI/debug lookup, but its universal interpretation as a building
category is **not proven**.

Therefore:

```text
oA[][7] ≠ automatically mA category
```

Do not use that assumption to map all twelve building IDs.

## 7. Current unresolved forensic chain

The former target:

```text
category 13/14/15 → mA[type][4/5] → Damage/Range
```

is superseded.

The next unresolved chain is now:

```text
building ID 151..173
    ↓
runtime construction / spawn / upgrade path
    ↓
actual lA/mA type (if any)
    ↓
classify combat path:
    ├─ conventional mA[6..8] / mA[14] / mA[15]
    └─ oA / special / static-effect path
    ↓
prove per-building Damage / Range / Cooldown
```

Priority is now to map the twelve `oA` indices through the real activation/event path (`HG → C.F(index)`) and classify each ID as combat/effect, production/support, or utility before attempting a universal `TurretStats` table.


## 8. Rules for future findings

A new value is not promoted to `ORIGINAL_CONFIRMED` merely because:

- it matches a plausible number;
- it appears in a UI field;
- it appears in a building row;
- it resembles an enemy value;
- it fits a hypothesized category.

Promotion requires a demonstrated consumer/runtime chain.

