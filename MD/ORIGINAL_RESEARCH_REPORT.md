# Sturmtrupp Mars — forensic research report

Дата: 2026-09-23

## 0. Правило достоверности

- `ORIGINAL_CONFIRMED`: значение найдено в оригинальном ресурсе и подтверждено загрузчиком/потребителем.
- `ORIGINAL_INFERRED`: сильная реконструкция, но семантика или связь не замкнута полностью.
- `UNRESOLVED`: в доступных файлах доказательства нет.
- `TEMPORARY_BALANCE`: только graybox-параметр, не оригинал.

## 1. Инвентаризация `res://original/`

### Added original JAR

`res://original/s40.kiev.ua_1644_sturmtrupp_mars_operation_roasted_bugs-s.jar` is a valid MIDlet archive. Manifest confirms `MIDlet-1: SturmtruppMars,/icon.png,HG`, `CLDC-1.0`, `MIDP-2.0`, version `1.0`, vendor `mob.ua`. The archive contains 161 entries, including the four classes, all binary tables, all PNGs, all three RU localization files and 14 AMR files. SHA-256: `3794e15fcdd1b9b1313dc49a7d5618e471a3746549385683bc2aaadf11fec302`. Extracted class hashes match the existing `res://original/A.class`, `B.class`, `C.class`, `HG.class` byte-for-byte; therefore the JAR adds executable packaging/runtime context but does not add hidden balance classes or alternate class bytecode. Its main new value is enabling an emulator/dynamic black-box run.


Каталог содержит 289 файлов: PNG-ресурсы и их Godot `.import`-метаданные, 4 Java class-файла (`A.class`, `B.class`, `C.class`, `HG.class`), 3 локализации (`RU.MAIN.lng`, `RU.MALE.lng`, `RU.FEMALE.lng`), 14 AMR-файлов, 5 бинарных ресурсов (`a`, `c`, `f`, `ldf`, `mi`) и `icon.png` (+ import). PNG охватывают `000`, `100–150`, `201–217` (с пропуском 213), `300–301`, `500–515`, `600–601`, `800–841`.

Размеры/границы PNG и SHA-256 должны считаться из файлов при каждом forensic-пересчёте; Godot-импортные файлы не являются оригинальными доказательствами и в mapping не учитываются. Подтверждённые размеры: `000.png = 168×168`, `137.png = 47×29`. `000.png` полностью непрозрачен, наблюдалось 44 цвета. `137.png` визуально похож на корабельный модуль, который садится на базу; логическая роль UNRESOLVED.

`.class` имеют Java class-file формат; по `C.class` подтверждено наследование `javax.microedition.lcdui.Canvas` и реализация `Runnable`, то есть это J2ME/MIDP-игровой код. `HG.class` содержит бинарные таблицы-загрузчики. Полноценный исходник/декомпиляция в проекте не хранится; доказательства ниже основаны на bytecode offsets, таблицах и runtime-потребителях, зафиксированных в `SOURCE_OF_TRUTH.md` и `RESEARCH.md`.

## 2. Ресурсные и языковые связи

`C.ZA(int)` загружает ресурсную таблицу из `a`; `C.class` связывает resource index 74 с PNG `137`; `C.ZA(1)` разрешает resource ID 0 в `000.png`. `C.C(Graphics,int,int,int,int)` рисует clipped source-window. Это подтверждает pipeline, но не доказывает, что PNG ID равен логическому типу объекта.

Изображения 145–148 имеют подтверждённую проектом визуальную роль только на уровне construction family: `145`/`147` — малая строительная композиция, `146`/`148` — крупная. Точная оригинальная длительность, clearance и правила соседства UNRESOLVED. Все остальные PNG mapping требуют визуального просмотра и bytecode-ссылки; по номеру ID тип объекта не назначается.

Локализационные файлы являются бинарными/legacy `.lng`; наличие названий не замыкает связь с asset ID без общей таблицы индексов. Словарь имён и полная hash-таблица пока не извлечены — UNRESOLVED.

## 3. Подтверждённые таблицы баланса

### Враги: `HG.B(InputStream)` → `rA`

Источник: `rA: int[9][16]`, offset `12984`; строки соответствуют ID 70–78. Подтверждены потребителями: `[3]` ID, `[4]` базовый урон, `[5..7]` сопротивления Bullet/Energy/Fire, `[10]` reward/score-related, `[12]` attack range, `[13]` movement speed.

| ID | имя | damage | bullet | energy | fire | reward/score | attack range | speed | статус |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---|
|70|basic_bug|200|50|0|25|95|2600|1300|ORIGINAL_CONFIRMED|
|71|heavy_bug|150|0|50|25|65|2400|1000|ORIGINAL_CONFIRMED|
|72|eye_shooter|45|45|25|50|35|8600|1200|ORIGINAL_CONFIRMED|
|73|acid_ram|120|120|0|50|45|2700|1500|ORIGINAL_CONFIRMED|
|74|flying_shooter|25|25|0|25|25|3500|900|ORIGINAL_CONFIRMED|
|75|queen|5|5|25|0|13|2400|700|ORIGINAL_CONFIRMED|
|76|venom_bug|125|125|25|0|65|2600|1200|ORIGINAL_CONFIRMED|
|77|hidden_bug|80|80|50|25|55|1900|1300|ORIGINAL_CONFIRMED|
|78|sand_worm|250|25|50|0|125|2300|1200|ORIGINAL_CONFIRMED|

`200` — значение `rA[][4]`, ранее ошибочно названное прямым уроном basic bug. Прямая трассировка метода `C.A(int,int)` показывает, что conventional HP damage читает `lA[attacker][1..3]` и `rA[target_profile][5..7]`; `rA[][4]` в этой формуле не читается. Поэтому `rA[70][4]=200` не может быть объявлено финальным уроном по солдату. Current graybox scale `0.1` is TEMPORARY_BALANCE. Enemy max HP, attack interval, detection radius, footprint, target priority and wave membership remain UNRESOLVED.

### Buildings: `HG.B(InputStream)` → `oA`

`oA: int[12][9]`, offset `11518`; IDs: 151,153,155,157,159,161,163,165,167,169,171,173. Max HP and cost are ORIGINAL_CONFIRMED from the table/consumers. Universal turret damage/range/fire-rate is not established.

| ID | имя | HP | cost | combat/damage | статус |
|---:|---|---:|---:|---|---|
|151|energy_station|400|1500|non-combat UI evidence|ORIGINAL_CONFIRMED|
|153|fire_tower|30000|500|UNRESOLVED|ORIGINAL_INFERRED (identity only)|
|155|central_base|750|750|static effect 750; combat semantics unresolved|ORIGINAL_CONFIRMED (HP/cost)|
|157|laser_tower|15000|250|special/zero-HP effect interpretation unresolved|ORIGINAL_INFERRED|
|159|beacon|30000|800|static effect 800; semantics unresolved|ORIGINAL_INFERRED|
|161|assault_gun|60000|1000|static effect 1000; semantics unresolved|ORIGINAL_INFERRED|
|163|soldiers|80|500|combat values from screenshot: defense 5, attack 3, radius 2|ORIGINAL_CONFIRMED for screenshot values|
|165|minefield|90000|4000|UNRESOLVED|ORIGINAL_INFERRED (identity only)|
|167|plasma_tower|80000|2000|UNRESOLVED|ORIGINAL_INFERRED (identity only)|
|169|radar_tower|50000|3000|UNRESOLVED|ORIGINAL_INFERRED (identity only)|
|171|satellite|120000|5000|UNRESOLVED|ORIGINAL_INFERRED (identity only)|
|173|communication_center|100000|4000|static effect 4000; semantics unresolved|ORIGINAL_INFERRED|

Screenshot-only UI: Central Base L1 `HP 750, defense 25`; Soldiers screenshot values conflict with the earlier user note (`80/5/3/2`) and project UI snapshot (`76/10/4/2`). Treat `80/5/3/2` as original screenshot-confirmed gameplay/build data, `76/10/4/2` as separate screenshot UI evidence; do not merge.

## 3.1 Bytecode correction: actual conventional damage formula

Direct `javap -verbose` disassembly of `C.class`, method `A(int,int)` confirms the final HP damage path. For attacker entity `a` and target entity `t`, the game reads attacker components `lA[a][1..3]`, target profile index from `vA[t][3]`, then target resistances `rA[profile][5..7]`. Each component is multiplied by its corresponding resistance and divided by 100 with half-up rounding; the reduced components are clamped at zero and summed, with a minimum result of 1. The result is later subtracted from the target HP field.

Consequently `rA[][4]` is not read by this final formula. The value `rA[70][4]=200` is not a proven per-hit HP damage value and is now `ORIGINAL_INFERRED` only. The remaining unresolved step is the initialization of the basic bug's `lA[][1..3]` attacker row and the exact runtime target profile for Soldiers ID 163. Additional tracing confirms `lA[entity][5]` is a runtime `mA` type index used to select attack behavior, but the audited constructor/update path still does not expose a closed enemy-ID-70 → `lA` row assignment.

## 3.2 Directly decoded `mA` rows

The `HG.B` loader was decoded as big-endian `uint16 rows, uint16 cols`, followed by signed 32-bit integers. At `res://original/a` offset `7562`, `mA` is `45×19`.

Rows 6–8 are strongly identified as Soldier levels because they contain the screenshot values and the UI radius encoding:

| mA row | HP field [4] | defense [5] | attack components [6..8] | radius low16 [14] | cooldown/other [15] | status |
|---:|---:|---:|---|---:|---:|---|
|6|80|5|0,0,3|2|300|ORIGINAL_CONFIRMED screenshot+table alignment|
|7|100|10|0,0,4|2|300|ORIGINAL_INFERRED level progression|
|8|120|15|0,0,5|2|300|ORIGINAL_INFERRED level progression|

This resolves the original Soldier L1 attack field as an energy/fire-component vector `0,0,3`, not a direct universal damage number. Rows 3–5 form a separate three-level unit family with HP `75/75/75`, defense `0`, attack vectors `(0,10,40)`, `(0,30,70)`, `(10,40,150)` and cooldown-like values `700/600/500`; Their mapping to enemy IDs 70–78 is not yet proven and remains `ORIGINAL_INFERRED`. The rows share class field `[0]=2` and levels `[1]=0..2`, while Soldier rows share `[0]=3`; this strongly suggests class 2 is an enemy family and class 3 is Soldiers. The most plausible mapping is `mA[3]` = first/basic enemy level. This is strengthened by the three-level class grouping and the fact that `mA[3]` is the first non-player combat family in the table, but it remains `ORIGINAL_INFERRED`, not confirmed. The raw category field `[3]=6` is a runtime behavior category, not itself an enemy ID.

## 4. Construction, dimensions and waves

Asset families 145/147 (small) and 146/148 (large) are project-supported visual correspondences, not complete original proof. `1×1`, `2×2`, one-cell clearance, progress duration 2/3 seconds and persistent pad are TEMPORARY_BALANCE/UNRESOLVED. Original footprint, build time, adjacent-building rules and upgrade costs: UNRESOLVED.

Original wave counts, first-wave delay, spawn interval, side selection, random coordinate, wave reward and type ordering: UNRESOLVED. Current 12-second first delay, four-side spawn, radius 150 and graybox wave schedule are TEMPORARY_BALANCE. No original target-priority proof was found: base lock, nearest-building diversion, path-only targeting, destruction fallback and post-kill return are UNRESOLVED.

## 5. Research matrix

| параметр | результат | статус | источник |
|---|---|---|---|
| asset ID = logical object type | not generally proven | UNRESOLVED | resource pipeline |
| enemy IDs 70–78 | proven | ORIGINAL_CONFIRMED | `rA[9][16]` |
| enemy damage/resistance/range/speed/reward | proven by consumers | ORIGINAL_CONFIRMED | `rA`, `C.class` damage/range pipeline |
| enemy HP | no closed source mapping | UNRESOLVED | `lA[][22]` is runtime HP only |
| building IDs 151–173 | proven table rows | ORIGINAL_CONFIRMED | `oA[12][9]` |
| building HP/cost | proven | ORIGINAL_CONFIRMED | `oA`, consumers |
| tower DPS/range/cooldown | no universal table | UNRESOLVED | `mA` only closes conventional combat fields |
| footprints/build time/waves/target AI | not proven | UNRESOLVED | no closed consumer evidence |
| current graybox reward/interval/scale | prototype only | TEMPORARY_BALANCE | `data/game_balance.gd`, `CHANGELOG.md` |

## 6. Recommended project policy

Do not promote unresolved values into original profiles. Keep `ORIGINAL_PROFILES` separate from `GRAYBOX_BALANCE`; retain current graybox values as `TEMPORARY_BALANCE`. Do not change confirmed HP/cost/damage/resistance values without a new source+consumer citation. This report supplements, rather than overwrites, `SOURCE_OF_TRUTH.md` and `RESEARCH.md`.

## 7. Open work

1. Generate reproducible inventory with file size, MIME, SHA-256 and PNG alpha bounds.
2. Run `javap`/CFR/Procyon or a J2ME-aware disassembler and attach method/offset excerpts.
3. Decode all `.lng` strings and map localization indices to classes/assets.
4. Visually inspect every PNG and record only evidence-backed mappings.
5. Decode `a`, `c`, `f`, `ldf`, `mi`; search binary structures for wave/spawn/footprint consumers.
6. Add tests after any data migration; no migration is performed by this report.
