# STURMTRUPP MARS — GODOT 4 REMAKE ROADMAP

## 1. Project Goal

Create a faithful **2.5D/isometric remake** of **Sturmtrupp Mars (2007)** in Godot 4 for Android.

The project keeps the original grid, gameplay rules and resource identity, but uses
editable 2D scenes with limited depth, layered sprites, lighting, particles and
orthographic presentation instead of requiring fully modeled 3D entities.

The original Java game and its binary data are the reconstruction source. Godot is a new
implementation and must not reproduce the legacy Java architecture merely because the
original code used obfuscated/global arrays.

## 2. Non-Negotiable Rules

1. **Do not invent original data.** Unknown values remain `UNRESOLVED` or `TEMPORARY_BALANCE`.
2. **Preserve original behavior first.** Reproduce integer division, fixed-point behavior,
   percentage resistance, grid movement, timers, and other observed semantics before modernization.
3. **Separate data, gameplay logic, and presentation.**
4. **Do not copy legacy Java architecture into Godot.**
5. Every reconstructed value has a confidence/status:
   - `ORIGINAL_CONFIRMED`
   - `ORIGINAL_INFERRED`
   - `TEMPORARY_BALANCE`
   - `UNRESOLVED`
6. A numerical coincidence is not evidence. A value becomes confirmed only when the relevant
   source → consumer → runtime chain is demonstrated.
7. Historical research belongs in `RESEARCH.md`; current facts belong in `SOURCE_OF_TRUTH.md`.

## Current implementation note — original-style Survival entry and map HUD

The gameplay scene now opens with a commander message (“Неподалеку обнаружены инопланетные существа”); confirming it starts wave one. The initial base is centered, the map fills the portrait viewport, with only the minimap at top-left, resource balance at top-right, and fog edging the play area. Tapping a free map cell opens a build-selection dialog. The user screenshot confirms the new-game intro and free-cell → choose building → place flow. Visual ground/map art is still graybox, and original layout behavior should be judged against supplied screenshot references rather than treated as confirmed original data beyond those observations.


The prototype has a portrait-oriented gameplay layout, an optional debug Test HUD, and a pause overlay with save/continue/main-menu actions. Live checks confirmed the pause dialog appears and resumes play; save validation tests pass 9/9. This remains a prototype layout, not device-matrix validated. Touch placement and the complete intermission-to-next-wave flow still need live verification.

## Help section evidence track — content capture complete

`res://MD/HELP_CONTENT.md` is the source register for the remake's in-game Help section. The current screenshot capture pass covers the original game description, controls, process, buildings, enemies, research and additional actions. Transcribed original text is marked `SCREENSHOT_CONFIRMED`; any future missing page remains `PENDING_SCREENSHOT` and must not be silently invented as original wording.

The Help UI should be implemented as editable scene content with separate pages and a modern Android presentation while preserving the captured original wording and structure.

## 3. Current Confirmed Reconstruction Inputs

### Enemy data

- `rA` is loaded from binary `a` through `HG.B(InputStream)`.
- `rA` is `int[9][16]`.
- Block offset: `12984`.
- Nine rows correspond to enemy IDs `70–78`.
- Confirmed enemy damage: `rA[][4]`.
- Confirmed enemy attack range: `rA[][12]`.
- Confirmed resistance fields:
  - `rA[][5]` = bullet resistance
  - `rA[][6]` = energy resistance
  - `rA[][7]` = fire resistance
- Enemy initial HP remains `UNRESOLVED`; the runtime HP initialization path is
  confirmed, but the source-to-enemy-ID mapping is not closed.

### Buildings

- Twelve building records are in `oA : int[12][9]`.
- `oA` block offset: `11518`.
- Building IDs:
  `151, 153, 155, 157, 159, 161, 163, 165, 167, 169, 171, 173`.
- Building Max HP is confirmed.
- Building Cost is confirmed.
- `rA` is **enemy** combat data and must not be reused as a building/turret table.
- Universal turret Damage / Range / Fire Rate are **not yet fully confirmed**.

### `mA`

The 2026-09-23 forensic pass supersedes the old `[4]/[5]` Damage/Range hypothesis.

For the conventional `lA` combat pipeline:

- `mA[type][6..8]` = three damage components — `ORIGINAL_CONFIRMED`.
- low16 `mA[type][14]` = target/engagement range — `ORIGINAL_CONFIRMED`.
- `mA[type][15]` = attack cooldown/interval — `ORIGINAL_CONFIRMED`.
- `mA[type][4]` is UI-labelled `ОЖ`; runtime HP semantics remain `ORIGINAL_INFERRED`.
- `mA[type][5]` is not a confirmed Damage/Range field; exact semantics remain `UNRESOLVED`.

Rows 36..44 (the previously targeted 13/14/15 blocks) contain zero attack components,
range `-1`, and cooldown `-1`, so they do not use this conventional attack path.


## 4. Current Research Blockers

The project no longer treats exhaustive bytecode tracing as the primary route for closing
building behavior. Several long forensic passes did not produce enough additional evidence
for the remaining building activation paths. The practical source strategy is now:

1. Use `res://MD/HELP_CONTENT.md` as the primary source for the intended purpose and
   player-facing description of buildings and towers. Its text was transferred from the
   original game's Help section.
2. Close missing behavior through controlled play of the original game. Record what the
   player observes for construction, upgrade, targeting, attack type, range, visibility,
   special effects, timers and prerequisites.
3. Keep user observations separate from screenshot-transcribed Help text and from
   bytecode-confirmed facts.
4. Return to forensic tracing only for a narrow question that cannot be answered by Help
   or controlled gameplay observation.

The old blocker `13/14/15 → mA[][4/5] → Damage/Range` remains retired. The unresolved
activation paths for IDs `151, 153, 157, 163, 165, 167, 169, 171` are now tracked as
observation tasks, not mandatory blockers for continuing the Godot prototype.


## 5. Godot Target Architecture

The Godot implementation should use clean domain structures rather than Java arrays.
Building records are centralized in `res://data/building_registry.gd`; see
`res://MD/BUILDING_REGISTRY.md` for evidence status, source fields and the separation between
source-facing values and temporary prototype balance.

The presentation layer is **scene-first 2.5D**:

- gameplay entities are editable `.tscn` scenes;
- `Node2D`, `CharacterBody2D`, `Sprite2D` and `AnimatedSprite2D` are the default
  presentation primitives;
- `AnimationPlayer`, sprite sheets, cutout parts and particles provide animation;
- limited `Node3D`/depth elements are allowed only when they clearly improve the
  fixed/isometric presentation;
- no Blender rigging or full 3D model is required for ordinary units/buildings.

The Godot implementation should use clean domain structures rather than Java arrays:

```text
data/
  game_balance.gd

systems/
  combat/
  navigation/
  economy/
  waves/
  upgrades/

entities/
  enemies/
  buildings/

scenes/
  world/
  enemies/
  buildings/
  ui/
```

The exact final folder structure can evolve, but data, gameplay systems, entities, scenes, and
presentation must remain explicitly separated.

## 6. Development Order

### DEV-01 — Source/data foundation
- Freeze the current source-of-truth tables.
- Keep all unresolved fields explicitly marked.
- Establish `game_balance.gd` data structures.

**Done when:** confirmed source values can be represented without inserting invented values.

### DEV-02 — Map/grid foundation
- Implement the 64×64 map/grid representation.
- Preserve original grid semantics.

**Done when:** map coordinates and grid behavior match the reconstructed original rules.

### DEV-03 — Navigation
- Implement the navigation/movement system.
- Preserve grid-based movement behavior.

**Done when:** enemy movement follows reconstructed navigation rules.

### DEV-04 — Enemy foundation
- Implement `BugBase`.
- Add the nine enemy AI/data profiles only from confirmed/inferred source data.

**Done when:** each enemy type has a traceable data source and no invented original values.

### DEV-05 — Building foundation
- Implement `BuildingBase`.
- Implement building HP/cost from confirmed data.
- Keep turret combat fields unresolved until supported by Help content, direct original-game observation, or a separately documented forensic result.

**Done when:** all twelve building records load with confirmed HP/cost and explicit unresolved combat fields.

### DEV-06 — Combat system
- Implement resistance handling using the confirmed Bullet/Energy/Fire model.
- Implement enemy damage/range from `rA`.
- Add defensive-structure combat only after the `mA` consumer chain is proven.

**Done when:** enemy combat matches the reconstructed source semantics and turret behavior is sourced.

### DEV-07 — Waves
- Implement `WaveManager`.
- Do not hardcode unresolved wave data as original.

### DEV-08 — Economy
- Implement currency and spending systems.
- Keep unresolved costs explicitly marked.

### DEV-09 — Upgrades
- Implement upgrade data/logic only where the source chain is established.

### DEV-10 — Power-ups
- Implement power-up behavior after source semantics are established.

### DEV-11 — 2.5D World Presentation
- Build the 2.5D/isometric presentation layer over the reconstructed gameplay systems.
- Use editable scenes, original PNG resources where appropriate, sprite sheets,
  cutout animation, AnimationPlayer and particles.
- Reserve 3D assets for optional depth accents or hero objects, not as a mandatory
  requirement for every unit and building.

### DEV-11A — 2.5D Animation Strategy
- Use `AnimatedSprite2D` for frame-based movement, attacks, impacts and deaths.
- Use `AnimationPlayer` for building modules, turret rotation, lights, recoil,
  smoke and other scene-editable animation.
- Use cutout parts or `Bone2D` only where they reduce the amount of manually drawn
  frames.
- AI-generated video may be used as a visual reference, but must not be treated
  as a game-ready animation source without stable frames, transparency and a
  consistent silhouette.

### DEV-12 — UI
- Reconstruct UI behavior and presentation separately from gameplay data.

### DEV-13 — VFX / Audio
- Add effects and audio without changing gameplay semantics.

### DEV-14 — Save / Load
- Implement persistence after core state structures are stable.

### DEV-15 — Balance / Regression
- Run regression tests against all confirmed source behavior.
- Review every remaining `UNRESOLVED` value before calling the remake source-faithful.

## 7. Definition of Done

A subsystem is complete only when:

- its original behavior is traced or explicitly classified as an inference;
- source data and runtime consumers are documented;
- no temporary balance value is mislabeled as original;
- Godot implementation is separated from legacy Java architecture;
- regression tests cover the reconstructed behavior.

## 8. Current Development Plan

The current showcase is a **presentation sandbox**, not a visual gold master. It remains intentionally editable and may continue to change.

### DEV-00 — Playable retro-inspired prototype (current implementation step)

The screenshot evidence pass is sufficient to begin a working vertical prototype. The first implementation pass now uses the confirmed Survival start values (`$2500`, Central Base L1 `ОЖ 750`, `О 25`) and original visual candidates where mappings are confirmed, while unresolved costs/combat values remain explicitly temporary.

Build a playable logic slice with temporary scene-authored placeholders:

```text
MapGrid
  ↓
CentralBasePlaceholder
  ↓
FireTowerPlaceholder
  ↓
BasicBugPlaceholder
  ↓
placement → resources → movement → targeting → attack → damage → destruction
```

Rules for this phase:

- use `TEMPORARY_BALANCE` for values not yet reconstructed;
- keep every entity as an editable `.tscn` scene;
- keep logic in reusable scripts/systems;
- do not bind gameplay systems to the current showcase composition;
- do not treat placeholder visuals or current VFX timing as final.

**Success condition:** one complete playable loop works with explicit temporary values and can later accept final art without rewriting core gameplay.

The prototype is intended to be manually played, not an autoplay demo. Waves and enemy attacks are automated as the tower-defense opponent, while the player must choose buildings, enter build mode, place them, select objects and use repair/upgrade/sell actions.

Debug-only test shortcuts currently available: `F1` spawn enemy, `F2` damage base, `F3` add 500 credits, `F4` repair base, `D` damage selected tower, `U` upgrade selected tower.

### DEV-01 — Retro survival interaction pass (completed)

Completed the first manual survival interaction pass:

- removed the automatic starter tower;
- added buildable Soldiers using `110.png` and a dedicated defender scene;
- kept Energy Station, Fire Tower and Soldiers as the initial palette;
- added original-style top selection strip and radar marker;
- retained touch/mouse build, selection, repair, upgrade and demolish flows;
- added six-wave test survival and debug shortcuts.

### Recent implementation step — intermission and touch placement

Added a post-wave preparation intermission with a visible **Начать атаку N** action. The next wave begins when the player requests it rather than launching automatically when the short countdown expires. Final-wave clear still raises victory; the wave number, timers and states remain included in the existing checkpoint save structure.

Build placement is now an explicit touch flow: tap Build to arm placement, tap an available field cell to place; the preview changes green/red as the pointer or touch moves, Cancel exits placement, and the button label tells the player to select a cell or place at the current preview. The project uses no new balance values for these UX changes. Added a Pause/Resume control that saves on pause, and Escape cancels placement or restarts after game over.

**Verification:** all 9 save validation tests pass. Live screenshots of the gameplay scene exposed HUD collisions; the panel was rearranged and retested. Touch placement was exercised by tapping Build and tapping a valid map cell, and the screenshot showed the newly placed tower and reduced credits. The full enemy-wave-clear → intermission → requested-next-wave loop still needs a longer live check. The graybox map remains replaceable and is not blocked on terrain forensics. Version-2 saves resume at checkpoints, not frame-exact physics states.

### Portrait conversion — active

The original is portrait, so the Godot target is portrait too. Handheld orientation is configured to Portrait (confirmed in the user's Project Settings screenshot). A new portrait layout controller places the field above a compact bottom control strip, with resource/wave/base indicators and touch actions. Excess save/load/build-picker/instruction/debug UI is removed from the primary HUD. A separate **Тест HUD** toggle reveals save/load and debug buttons; keyboard debug shortcuts now require that panel to be visible. Project base viewport is now configured to 432×768 (Portrait, 9:16). Stretch settings still need to be selected/verified in the editor. The portrait layout controller and gameplay-coordinate adaptation require live visual verification across device aspect ratios.

### Pause menu pass

Replaced pause-as-a-toggle-only with a real paused overlay: Save Game, Continue and Return to Main Menu. ESC pauses/resumes or cancels placement first. The pause panel is configured to process while the tree is paused, and opening pause attempts an autosave checkpoint. The Test HUD remains separate. Live pause/resume and menu transitions still need confirmation in a live gameplay session.

### Next implementation step

Live-check portrait layout, pause/save/resume/menu transitions, and full wave clear → requested next wave. Then continue touch-first UX and map placeholder polish. Keep unverified original rules and combat values explicitly marked.

### DEV-00A — Parallel forensic closure

Continue tracing the twelve building IDs in parallel:

```text
151, 153, 155, 157, 159, 161,
163, 165, 167, 169, 171, 173
```

through:

```text
construction / spawn / upgrade
    ↓
runtime lA entity and mA type, OR oA/static-effect state
    ↓
HP mutation / target state / geometry / timer
```

For conventional entities, verify:

```text
mA[type][6..8] → damage components
low16 mA[type][14] → range
mA[type][15] → cooldown
```

Do not promote unresolved building fields to original data merely to complete the graybox.

### DEV-00B — Showcase iteration

Keep `central_base_showcase.tscn` separate from gameplay implementation. Continue visual improvements as an independent track; no current showcase values are considered final.

**Current next action:** implement the graybox vertical slice, while the building forensic target and showcase iteration continue independently.


## 9. Document Workflow

```text
RESEARCH.md
    ↓
SOURCE_OF_TRUTH.md
    ↓
ROADMAP.md
    ↓
Godot implementation
```

`CHANGELOG.md` records corrections and important reclassifications.
