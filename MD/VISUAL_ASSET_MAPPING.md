# Sturmtrupp Mars — Visual Asset Mapping

## Purpose

This document records visual observations from original-game screenshots and the mapping between visible objects and numeric PNG resources.

It is intentionally separate from `SOURCE_OF_TRUTH.md` because screenshots and visual identification may begin as evidence or hypotheses before the runtime resource path is fully proven.

## Evidence policy

A mapping must carry one of these statuses:

- `SCREENSHOT_CONFIRMED` — the user identified the object in an annotated original-game screenshot;
- `RUNTIME_CONFIRMED` — the original code/resource path proves the mapping;
- `SCREENSHOT_AND_RUNTIME_CONFIRMED` — both evidence chains agree;
- `ORIGINAL_INFERRED` — plausible visual interpretation, not yet proven;
- `UNRESOLVED` — insufficient evidence or conflicting evidence.

Visual similarity alone does not prove a logical building ID.

## User screenshot register

| Screenshot | Scene / context | User explanation | Relevant IDs / PNGs | Status |
|---|---|---|---|---|
| _pending_ | _pending_ | _pending_ | _pending_ | `UNRESOLVED` |

## Building mapping under review

| Logical ID | Current name | Candidate PNG resource(s) | Current status | Notes |
|---:|---|---|---|---|
| 151 | Energy Station | `113.png`, `114.png`, `115.png` | `USER_REPORTED` | Supersedes the earlier working candidate `119–121`; runtime cross-check pending. |
| 153 | Fire Tower | _unknown_ | `UNRESOLVED` | Previous `113.png` binding is rejected pending correction. |
| 155 | Central Base | `100.png`, `101.png`, `102.png` | `ORIGINAL_INFERRED` | Current working mapping; verify against screenshots/runtime. |
| 157 | Laser Tower | `114.png` | `ORIGINAL_INFERRED` | Shared chassis family requires context. |
| 159 | Beacon | `124.png` | `ORIGINAL_INFERRED` | Verify placement and gameplay context. |
| 161 | Assault Gun | `145.png`, `146.png` | `ORIGINAL_INFERRED` | Verify state/upgrade semantics. |
| 163 | Soldiers / Infantry | `134.png`, `135.png`, `136.png` | `ORIGINAL_INFERRED` | Not necessarily a building. |
| 165 | Minefield | `147.png`, `148.png`, `149.png`, `150.png` | `ORIGINAL_INFERRED` | Verify mine and impact states. |
| 167 | Plasma Tower | `115.png` | `ORIGINAL_INFERRED` | Verify visual role in original UI. |
| 169 | Radar | `122.png` | `ORIGINAL_INFERRED` | Verify placement and active state. |
| 171 | Satellite | `123.png` | `ORIGINAL_INFERRED` | Verify animation/state frames. |
| 173 | Communication Center | `137.png` | `UNRESOLVED` | Conflicts with observed base-attached ship module. |

## Building stat capture workflow

User-provided building screenshots can provide a practical reconstruction path for visible construction and management data even when the original code trace is expensive or incomplete.

For each building and level, capture if possible:

- construction selection panel;
- selected building name and icon;
- cost;
- `ОЖ`, `О`, `А`, `Р` values;
- level number;
- whether the panel is construction, selection or upgrade context;
- the logical name/ID if known.

These values will be recorded as:

```text
SCREENSHOT_CONFIRMED
```

for the displayed value and UI meaning. They will not automatically be relabeled `ORIGINAL_CONFIRMED` for hidden runtime semantics unless the source/runtime evidence agrees.

Suggested capture table:

| Logical ID | Name | Level | Cost | ОЖ | О | А | Р | Context | Evidence | Status |
|---:|---|---:|---:|---:|---:|---:|---:|---|---|---|
| _pending_ | _pending_ | _pending_ | _pending_ | _pending_ | _pending_ | _pending_ | _pending_ | _pending_ | user screenshot | `UNRESOLVED` |

## Additional Actions Help index

The original Help index lists the following additional-action chapters:

```text
Основы
Разведывательный полёт
Быстрый ремонт
Бомба
Быстрая смерть
Парализующие лучи
Ядовитый газ
Суперщит
Неразрушимость
Бонус радиуса поражения
Экстремальная сила повреждения
Оглушительные лучи
Интеллигентная бомба
```

Evidence: `ziva-attachment:zynLVuAsWdh5q_KKmqGoS`.

Only the chapter names are confirmed so far; effects, costs, prerequisites, duration and activation rules remain unresolved until the individual pages are captured.

## Additional Actions Help entries

| Action | Confirmed description | Asset | Evidence | Status |
|---|---|---|---|---|
| Basics | Destroying enemies grants experience; enough experience grants a rank and a new additional action, which can be activated at the corresponding building and then used when desired. | `600.png` | `DDoJhfMiep-nAJ4kMTYUJ`, `8swMQiAOuWbmXsPPnfwdg` | `SCREENSHOT_CONFIRMED` |
| Reconnaissance Flight | Reveals the entire battlefield for a short time. | `600.png` | `8ivrakwFcEMPl_bLp5-lG` | `SCREENSHOT_CONFIRMED` / `USER_REPORTED` |
| Quick Repair | Select one building and it is repaired immediately. | `600.png` | `BKRV_xfq1eHQbMT9irwnK` | `SCREENSHOT_CONFIRMED` |
| Bomb | Deals heavy damage to an enemy and can also damage own buildings. | `600.png` | `KPlqhlJQpgIiQeLDPb8jv` | `SCREENSHOT_CONFIRMED` |
| Quick Death | The next hit immediately destroys an enemy. | `600.png` | `yu0YkAYZLwTaYb6c6mist` | `SCREENSHOT_CONFIRMED` |
| Paralyzing Rays | Paralyzes all enemies for a short time. | `600.png` | `815Q0Dv4huP512Zh-b2v_` | `SCREENSHOT_CONFIRMED` |
| Poison Gas | Creates a gas cloud in a selected area; enemies there die slowly. | `600.png` | `z3eozRFzhQtD9aJ8zOh4F` | `SCREENSHOT_CONFIRMED` |
| Super Shield | Gives buildings additional protection for a short time. | `600.png` | `HeIhejR1jbAGg_XdTKeYe` | `SCREENSHOT_CONFIRMED` |
| Invulnerability | Buildings become invulnerable for a short time. | `600.png` | `L4rduBMA4ywGL3h1OU50q` | `SCREENSHOT_CONFIRMED` |
| Damage Radius Bonus | Raises the damage radius of defensive structures. | `600.png` | `d6VrVcr7WvGZ7svGXJOuk` | `SCREENSHOT_CONFIRMED` |
| Extreme Damage Power | Weapons deal extreme damage for a short time. | `600.png` | `lhin0alrHtTLcUxyj4M6T` | `SCREENSHOT_CONFIRMED` |
| Stunning Rays | Enemies become incapacitated for a short time. | `600.png` | `CjF9XjPmHdsZmng11_mS3` | `SCREENSHOT_CONFIRMED` |
| Intelligent Bomb | Ultimate weapon against all types of insects. | `600.png` | `PVI8ssiVR9LyQ6HdPz9hw` | `SCREENSHOT_CONFIRMED` |

## Research Help page mapping

| Research | Visible effect | Asset | Status |
|---|---|---|---|
| Radius of damage | Raises the damage radius of defensive structures. | `600.png` shared research resource | `SCREENSHOT_CONFIRMED` / `USER_REPORTED` |
| Armament | Raises defense of all structures. | `600.png` shared research resource | `SCREENSHOT_CONFIRMED` / `USER_REPORTED` |
| Attack intensity | Defensive structures deal more damage. | `600.png` shared research resource | `SCREENSHOT_CONFIRMED` / `USER_REPORTED` |
| Shield protection | Can be installed on each structure; absorbs damage and regenerates; breaks under heavy damage. | `600.png` shared research resource | `SCREENSHOT_CONFIRMED` / `USER_REPORTED` |

Research is automatically installed into the corresponding building except Shield Protection, which must be mounted manually according to the Help text.

## Enemy Help page mapping

| Order | Asset | Visible description | Resistance | Weakness / sensitivity | Status |
|---:|---:|---|---|---|---|
| 1 | `505.png` | Deceptive harmless appearance; dangerous because it attacks in groups. | Bullets | Fire | `SCREENSHOT_CONFIRMED` |
| 2 | `504.png` | Larger and more durable bug type. | Bullets | Energy weapons | `SCREENSHOT_CONFIRMED` |
| 3 | `502.png` | Agile enemy that shoots beams from its eyes. | Fire | Bullets | `SCREENSHOT_CONFIRMED` |
| 4 | `507.png` | Acid-spitting creature that attacks buildings. | Energy weapons | Bullets | `SCREENSHOT_CONFIRMED`; one phrase unclear |
| 5 | `503.png` | Flying insect with a long-range weapon. | Fire | Energy weapons | `SCREENSHOT_CONFIRMED` |
| 6 | `506.png` | Powerful queen; offspring remain dangerous after her destruction. | Bullets | Fire | `SCREENSHOT_CONFIRMED` |
| 7 | `501.png` | Insect whose stinger drips poisonous acid. | Fire | Energy weapons | `SCREENSHOT_CONFIRMED` |
| 8 | `512.png` + `513.png` | Particularly dangerous creature with strong hiding/camouflage ability. | Energy weapons | Fire | `SCREENSHOT_CONFIRMED`; camouflage mapping `USER_REPORTED` |
| 9 | `508.png`–`511.png` | Sand Worm; difficult to hit because it moves mostly underground. | Fire | Bullets | `SCREENSHOT_CONFIRMED`; cycle mapping `USER_REPORTED` |

The page is ordered top-to-bottom as supplied. A second page adds `501`, `512` with camouflage `513`, and the Sand Worm asset cycle `508`–`511`. It does not expose enemy names, numeric IDs or exact HP/damage values. The acid-creature sentence contains one unreadable/ambiguous phrase; only its building-targeting behavior and resistance labels are treated as safe.

## Enemy-data limitation

Enemy screenshots cannot currently provide the same stat panel because the user cannot select/inspect bugs in the original game. Enemy damage, resistances, speed, attack range and exact HP therefore remain a separate forensic/data-recovery track. Screenshot evidence can still confirm enemy appearance, animation state, conditional HP-bar behavior and attack direction.

## Screenshot submission format

For each screenshot, provide if possible:

1. where it was taken (menu, map, build screen, combat, upgrade screen);
2. what object is visible;
3. what action is happening;
4. which object is a building, turret, economy structure, unit or effect;
5. any known logical ID or localized name;
6. arrows/circles or a short text explanation.

## User-provided asset corrections

The user supplied an initial manual mapping based on the original game and prior reverse-engineering:

| Visual role | PNG resources | User status | Consequence |
|---|---|---|---|
| Mars ground / terrain surface | `000.png` | `USER_REPORTED` | Original resource table maps image resource ID 0 to `/000.png`. Metadata gives a 7-pixel source-origin stride; the original draw helper clips overlapping 24×24 source windows, while map traversal separately advances 24 pixels. This is not a conventional tile-atlas proof: ground and wall/edge art share the image, and map-cell-to-frame selection remains `UNRESOLVED`. Keep diagnostic preview only. |
| Soldiers, level 1 → 3 | `110.png`, `111.png`, `112.png` | `USER_REPORTED` | Must be implemented as a separate infantry/defender scene path, not as a turret. |
| Energy Station, level 1 → 3 | `113.png`, `114.png`, `115.png` | `USER_REPORTED` | Conflicts with the earlier research table that assigned `119–121` to Energy Station. |

### Mapping conflict requiring correction

The previous working bindings in gameplay scenes were:

```text
151 Energy Station → 113.png / 114.png / 115.png
153 Fire Tower     → unresolved
```

The user's mapping indicates that `113.png` belongs to the Energy Station family, so the current `153 → 113.png` binding must not be treated as valid. Fire Tower visual resources are now `UNRESOLVED` until another screenshot or runtime/resource trace identifies them.

The user's mapping takes precedence as project evidence for the next asset pass, but is recorded as `USER_REPORTED` until cross-checked against the original renderer path.

The three soldier resources are sprite sheets rather than single-frame images:

```text
110.png = 3 columns × 8 rows, level 1
111.png = 3 columns × 8 rows, level 2
112.png = 3 columns × 8 rows, level 3
```

The initial Godot templates expose the first frame with nearest filtering. They are visual/scene templates only; defender combat and placement rules remain separate work.

## Screenshot observations — survival / Mars attack mode

| Screenshot | Observation | Status |
|---|---|---|
| `ziva-attachment:T-CYv5ptddj5oQjCmQH7o` | Central Base level 1 selected at Survival-mode start. Top strip shows `ОЖ: 750`, `О: 25`; resource counter shows initial `$2500`. | `SCREENSHOT_CONFIRMED` |


| Screenshot | Observation | Status |
|---|---|---|
| `ziva-attachment:IZj897eehdcTKAIDtdQ_M` | Initial Survival-mode screen after launch. A central base stands in a small revealed orange Mars area surrounded by black unexplored space. A defender is visible near the lower-left edge. The instruction says alien creatures were detected nearby; they attack from one side, marked on the radar/minimap by a small red dot. | `SCREENSHOT_CONFIRMED` |


User-provided screenshots from the original Android/J2ME game establish the following visual and interaction evidence.

| Screenshot | Observation | Status |
|---|---|---|
| `ziva-attachment:Of99VivIBa1xq5PNMlfMc` | Survival/attack mode start. Central base is on an orange tiled Mars terrain. The surrounding area is black/fogged. A minimap is visible in the upper-left, with a blinking red marker indicating the incoming bug direction. A mouse-like in-game cursor is visible. | `SCREENSHOT_CONFIRMED` |
| `ziva-attachment:VOppYRowuq4bmh5NwkCKA` | Hovering/selecting the central base opens an information strip at the top. Visible text: `Центральная база`, `ОЖ: 750`, `О: 25`. The upper-left also shows a base icon and red HP bar. | `SCREENSHOT_CONFIRMED` |
| `ziva-attachment:buc5ie_HeSnByZ_8hgN8r` | Building/combat context with the central base, a nearby placed object/unit and an enemy HP bar. The cursor remains part of the game presentation. | `SCREENSHOT_CONFIRMED` |
| `ziva-attachment:233xhRd2XamtQhkP7bmwi` | Active attack: several soldier/defender units are positioned around the central base. Bugs approach from above. A wounded bug has a visible HP bar. A blinking warning indicator appears near the minimap when the base is under attack. | `SCREENSHOT_CONFIRMED` |
| `ziva-attachment:QgCGRp50HwhSWsOufnus_` | Pre-placement preview: a selected soldier/defender group appears inside a black plus-shaped footprint showing the occupied construction area. The plus shape is an observed original presentation, not a mandatory implementation constraint. | `SCREENSHOT_CONFIRMED` |

### UI/interaction observations

- The game is a survival/attack mode rather than a conventional level-select flow.
- The map presentation is pixel-art, top-down/orthographic, with orange cracked Mars terrain and a black unexplored/fogged perimeter.
- The original UI has a minimap, resource counter, selected-object information strip, object icon and HP bar.
- Hover/selection is a first-class interaction: buildings and other objects expose HP and defense-like information.
- Building construction is initiated by selecting free map space, then choosing from a context/build panel.
- At the start, the user reports that the available options are the central/base building, Energy Station and Soldiers.
- Soldier placement uses a footprint preview; the exact geometry can be approximated, but the occupation feedback should remain visible.
- Enemy HP bars are conditional: they appear when a bug has taken damage, rather than permanently for every enemy.
- A base-under-attack warning is represented by a blinking indicator near the minimap.
- The Android emulator keyboard overlay is external input tooling and is not part of the original game UI.

## Building-specific Help entries and asset mappings

| Entry | Original text / observation | Asset mapping | Status |
|---|---|---|---|
| Energy Station | Required for Laser Tower, Plasma Tower, Tesla Tower and shield protection. | Levels 1–3 → `113.png`, `114.png`, `115.png` | `SCREENSHOT_CONFIRMED` / `USER_REPORTED` |
| Communication Center | Required for UAV, Radar Tower and Satellite. | Levels 1–3 → `138.png`, `139.png`, `140.png` | `SCREENSHOT_CONFIRMED` / `USER_REPORTED` |
| Laser Tower | Weakest defensive tower; at level 2 it also deals fire damage. | Shared lower/base part → `103.png`; level 1/2/3 upper parts → `104.png` / `105.png` / `106.png`; each contains about five charge frames | Description `SCREENSHOT_CONFIRMED`; layered animation mapping `USER_REPORTED` |
| Fire Tower base | Shares the lower/base visual with the Laser Tower. | Shared lower/base part → `103.png`; upper directional assets → `107.png` / `108.png` / `109.png` | `USER_REPORTED` |

The Laser Tower asset is layered. `103.png` is the shared lower/base part for the Laser Tower and Fire Tower. `104.png`, `105.png` and `106.png` are the upper turret assets for levels 1, 2 and 3 respectively. Each upper asset contains an idle frame plus four progressive blue-cyan charge/preparation frames. The laser projectile/firing effect is not included in these assets and remains `UNRESOLVED` as a separate effect resource.

| Entry | Observation | Asset mapping | Status |
|---|---|---|---|
| Satellite | Increases visibility radius but does not detect invisible insects; an upgraded satellite provides full battlefield visibility. | `144.png` | `SCREENSHOT_CONFIRMED` / `USER_REPORTED` |
| Tesla Tower | Strongest weapon in the arsenal; deals very strong energy and fire damage. | Level 1/2/3 → `134.png` / `135.png` / `136.png` | `SCREENSHOT_CONFIRMED` / `USER_REPORTED` |
| Assault Gun | Its projectiles deal rocket and fire damage. | Level 1/2/3 → `141.png` / `142.png` / `143.png` | `SCREENSHOT_CONFIRMED` / `USER_REPORTED` |
| UAV | Flies high and can only be attacked by winged insects and bugs equipped with long-range weapons. | Level 1/2/3 → `116.png` / `117.png` / `118.png` | `SCREENSHOT_CONFIRMED` / `USER_REPORTED` |
| Beacon | Attracts less intelligent bugs with its light and acts as a strong trap. | Level 1/2/3 → `128.png` / `129.png` / `130.png` | `SCREENSHOT_CONFIRMED` / `USER_REPORTED` |
| Radar Tower | Increases visibility radius, detects invisible bugs and has no defensive function. | Level 1/2/3 → `122.png` / `123.png` / `124.png` | `SCREENSHOT_CONFIRMED` / `USER_REPORTED` |
| Plasma Tower | Improved laser tower with higher damage radius and stronger energy damage. Each level asset contains eight turret orientations for different firing directions. | Level 1/2/3 → `131.png` / `132.png` / `133.png` | Description and level mapping `SCREENSHOT_CONFIRMED` / `USER_REPORTED`; eight-direction layout `USER_REPORTED` |
| Fire Tower | Low damage radius but very high fire damage. Each level asset contains eight turret orientations for different firing directions. | Level 1/2/3 → `107.png` / `108.png` / `109.png` | Description and level mapping `SCREENSHOT_CONFIRMED` / `USER_REPORTED`; eight-direction layout `USER_REPORTED` |
| Soldiers | Original Help says soldiers are initially available, shoot at everything that moves, deal bullet damage, and after modernization hide in bunkers. The sheets visibly contain multiple directions plus idle and shooting states. | Level 1/2/3 → `110.png` / `111.png` / `112.png` | Description `SCREENSHOT_CONFIRMED`; animation mapping `USER_REPORTED` |

The existing soldier scenes are only first-frame visual templates. They must later be upgraded to directional idle/fire animation without assuming that the current `3×8` sheet division is the complete semantic layout.


Evidence: `ziva-attachment:K1hrRNFrJftcJpZHEuHAb`, `ziva-attachment:Kr0mPVWp_6h2jrAMVN1br`.

## Buildings — Basics help screens

| Screenshot | Observation | Status |
|---|---|---|
| `ziva-attachment:xNO5cnuvHDP-TNNBnLLwO` | Building Help index. It lists `Основы`, Central Base, Research Station, Energy Station, Communication Center, Laser Tower, Soldiers, Fire Tower, Plasma Tower, Radar Tower, Beacon, UAV, Assault Gun, Minefield, Tesla Tower and Satellite. | `SCREENSHOT_CONFIRMED` |
| `ziva-attachment:dhB-P0AycMHKbHLk4gBsr` | Basics text: two building types are described — main buildings and defensive structures. Upgrading main buildings enables new buildings, technologies and additional actions. Every building has life points (`ОЖ`) that decrease when damaged; higher defense (`О`) reduces damage from enemies. Defensive structures additionally have attack intensity (`А`) per shot and attack damage radius (`Р`). | `SCREENSHOT_CONFIRMED` |

This is direct in-game documentation for the building taxonomy and stat meanings. A few word endings are clipped, but their completion is unambiguous from context and user confirmation; the content is treated as confirmed.

## Game process help screen

| Screenshot | Observation | Status |
|---|---|---|
| `ziva-attachment:n0cRNJXExNAXcUpI-HjGn` | Describes the campaign process: the ship docks with the central base; the main task is base defense; central-base modernization unlocks technologies and defensive structures; the player must survive a defined number of attacks; then the next level and assignment begin; progress and developed technologies are saved for future use. It also introduces “Attack Mars” mode: a random map and play continuing until enemies destroy the base. The final line is cut off by the screenshot boundary. | `SCREENSHOT_CONFIRMED` / `PARTIAL_CAPTURE` |

This gives the remake a confirmed high-level progression model without proving the exact number of attacks, unlock order, save format or victory conditions for each level.

## Controls help screen

| Screenshot | Observation | Status |
|---|---|---|
| `ziva-attachment:buSdNqJZubPqi5lw5JvwG` | Original control reference. Numeric keypad moves the cursor: `4/6/2/8` cardinal directions and `1/3/7/9` diagonals. `#` performs additional actions, `*` returns to the central base, the left soft key and center navigation key select, the right soft key closes/goes back/cancels, and `0` pauses. | `SCREENSHOT_CONFIRMED` |

This is original control evidence, not a requirement to reproduce a numeric keypad on Android. The modern interface can map the same actions to touch controls while retaining this page as a compatibility reference.

## Game description screen

| Screenshot | Observation | Status |
|---|---|---|
| `ziva-attachment:zj0MqioR8AWumlPzMiNyf` | Original introductory description. It states that insect-like enemies threaten survival on Mars; the player commands a defense team, builds defensive structures and research stations, uses available technology to survive, and witnesses the Mars group fight. It also points to `www.handy-games.com`. | `SCREENSHOT_CONFIRMED` |

This screen is narrative/product description evidence, not the detailed building-stat help page. It confirms the high-level pillars: defense construction, research stations, technology, survival and insect enemies.

## Construction and building action-menu observations

| Screenshot | Observation | Status |
|---|---|---|
| `ziva-attachment:c6ctIZ_t0IF_bFnqfKnZH` | Construction selection view. The top panel shows an icon, a building name/description, cost (`Расходы: 600 $`) and four visible stat fields: `ОЖ`, `О`, `А`, `Р`. The lower selector shows `Уровень: 1`, the selected name `Лазерная башня`, and level/building icons. A previously upgraded building can expose multiple level choices; unavailable levels appear visually blocked. | `SCREENSHOT_CONFIRMED` |
| `ziva-attachment:f3jjrx2icG73x7i4iAEtt` | Object action menu after selecting Soldiers. Top panel shows icon, HP and three stat values. Menu contains `Ремонтировать`, `Модернизировать`, and `Снести`. Repair is conditional on damage; upgrade and demolish are normal actions. | `SCREENSHOT_CONFIRMED` |

### UI semantics — help/manual evidence

The user reports that the in-game Help section explicitly describes the building statistics and game process. This upgrades the working UI interpretation:

```text
ОЖ → life / hit points
О  → defense
А  → attack intensity / damage dealt by one shot
Р  → area-of-effect radius
```

Status:

- the presence of the labels and displayed values is `SCREENSHOT_CONFIRMED`;
- the meanings above are `HELP_SCREEN_USER_REPORTED`;
- the exact source fields and formulas remain a separate runtime/data question.

This is stronger evidence than visual guessing and should drive the player-facing building panel, while still avoiding an unsupported claim about which binary field stores each value.

Additional interaction rules recorded from the user:

- construction can select a specific building level, not only the building family;
- damaged buildings show `Repair`; full-health buildings do not;
- `Upgrade` and `Demolish` are standard building actions;
- the central base has no `Demolish` action.

## Change log

- Initial register created before user screenshot review.
- Existing research mappings are intentionally recorded as `ORIGINAL_INFERRED` here until screenshot and runtime evidence agree.
- Added five user-provided screenshot observations for the survival/attack mode.
