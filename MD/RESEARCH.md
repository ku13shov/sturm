# STURMTRUPP MARS — RESEARCH / FORENSICS

> This file preserves the full original `Sturmtrupp_Mars_Roadmap_v10.md` as the forensic and research archive.
> No research evidence has been discarded. The material below is intentionally historical and may contain
> hypotheses or conclusions that were later corrected. For current implementation decisions, use
> `SOURCE_OF_TRUTH.md` first, then `ROADMAP.md`.
>
> Original source preserved verbatim below.
>
> Historical note: the archived roadmap text may describe a full-3D target. The
> current presentation decision is now 2.5D/isometric; see `ROADMAP.md` and
> `SOURCE_OF_TRUTH.md`. This does not alter the forensic evidence below.

---

# STURMTRUPP MARS --- GODOT 4 REMAKE

## MASTER ROADMAP / ТЕХНИЧЕСКАЯ АРХИТЕКТУРА

**Цель проекта:** реконструкция игрового дизайна и механик оригинальной
Java/J2ME-игры *Sturmtrupp Mars (2007)* и создание современного
3D-ремейка на Godot 4.

**Главный принцип:** сначала максимально точно восстановить оригинальную
структуру и баланс, затем адаптировать её к современной 3D-архитектуре.
Не подменять неизвестные данные выдуманными значениями без явной
маркировки.


------------------------------------------------------------------------

# GODOT ARCHITECTURE MASTER RULE — SCENE-FIRST

**Статус: [Обязательно для всех Godot-фаз]**

Это обязательное правило разработки проекта.

> **Visual and gameplay entities must be authored as editable scenes.  
> Code provides reusable behavior and systems only.**

В Godot визуальные и игровые сущности должны существовать как
редактируемые `.tscn` scenes. Скрипты могут быть прикреплены к этим
сценам и предоставлять переиспользуемое поведение, но состав объекта,
его визуальные элементы, точки, коллайдеры, маркеры и scene-level
параметры должны оставаться доступными для редактирования непосредственно
в Godot Editor.

## Scene-editable

```text
- units
- buildings
- map
- grid markers
- collision
- attack points
- spawn points
- cameras
- UI
- VFX
```

## Code-only

```text
- pathfinding
- AI state logic
- damage calculation
- wave scheduling
- save/load
- global managers
```

## Architectural boundary

```text
GODOT SCENES
	↓
visual composition
spatial composition
editable gameplay points
collision
markers
VFX
UI
	↓
SCRIPTED BEHAVIOR
	↓
reusable logic
AI
pathfinding
combat calculations
wave scheduling
save/load
global systems
```

### Правило

Если сущность визуальная или пространственно-игровая — она должна быть
редактируемой scene. Код не должен скрывать её основную композицию внутри
runtime-конструкции.

Например:

```text
Unit.tscn
├── Visual
├── Collision
├── AttackPoint(s)
├── Detection / Target markers
└── Unit script
```

```text
Building.tscn
├── Visual
├── Collision
├── AttackPoint(s)
├── Upgrade / state nodes
└── Building script
```

```text
Map.tscn
├── Grid
├── Terrain
├── GridMarkers
├── SpawnPoints
└── Map systems/references
```

Скрипты предоставляют поведение и системы, но не заменяют editable scene
composition.


------------------------------------------------------------------------

# 0. СТАТУС ПРОЕКТА

  ---------------------------------------------------------------------
  Область                                      Статус
  -------------------------------------------- ------------------------
  Анализ `C.class`                             **\[Выполнено\]**

  Анализ `RU.MAIN.lng`                         **\[Выполнено\]**

  Первичный анализ `a`                         **\[Выполнено\]**

  Определение структуры игровых объектов       **\[Выполнено\]**

  Определение сетки                            **\[Выполнено\]**

  Определение 9 типов жуков                    **\[Выполнено\]**

  Определение 14 зданий                        **\[Выполнено\]**

  Определение пауэр-апов                       **\[Выполнено\]**

  Полная расшифровка `a`                       **\[Частично выполнено /
											   Заблокирован\]**

  Расшифровка `HG.class`                       **\[Выполнено\]**

  Точный оригинальный баланс                   **[Частично подтверждён — Enemy Damage/Range, Building HP/Cost и отдельные static-effect Damage подтверждены; Enemy Initial HP, универсальные Range/Fire Rate остаются unresolved]**

  Точная таблица турелей                       **[Частично подтверждена — static-effect consumers найдены; универсальной TurretStats таблицы не найдено]**

  Точный HP жуков                              **[UNRESOLVED — runtime HP path найден; source/mapping для enemy ID 70–78 не доказан]**

  Godot 4 core architecture                    **[Частично выполнено — scene-first каркас]**

  3D-карта                                     **[Частично выполнено — MapGrid/MapRoot прототип]**

  AI                                           **\[Проектирование\]**

  Система строительства                        **\[Проектирование\]**

  Боевая система                               **\[Проектирование\]**

  Wave system                                  **\[Проектирование\]**

  UI                                           **\[Проектирование\]**
  ---------------------------------------------------------------------

------------------------------------------------------------------------

# PHASE 1 --- FORENSIC ANALYSIS ORIGINAL GAME

## 1.1 Анализ Java-архитектуры

**Статус: \[Выполнено\]**

Проанализирован `C.class`.

Установлено:

-   `C` наследуется от `javax.microedition.lcdui.Canvas`;
-   реализует `Runnable`;
-   содержит основной игровой цикл;
-   присутствует обработка ввода;
-   присутствует логика игровых объектов;
-   присутствует логика карты;
-   присутствует логика движения;
-   присутствуют боевые/прогрессионные расчёты;
-   присутствует работа с внешними ресурсами.

### Игровые объекты

Обнаружена структура:

``` text
lA[50][25]
```

То есть оригинал использует до:

``` text
50 игровых объектов
```

с:

``` text
25 integer-параметрами на объект.
```

Эта структура будет использоваться как источник информации, но **не
будет напрямую копироваться в Godot**.

------------------------------------------------------------------------

# PHASE 2 --- MAP / GRID SYSTEM + ORIGINAL VISUAL RESOURCE MAPPING

## 2.1 Размер игровой сетки

**Статус: \[Выполнено\]**

Оригинальная карта:

``` text
64 × 64
```

Обнаружены:

``` java
short[][] wA;
short[][] ab;
```

обе структуры:

``` text
64 × 64
```

### Godot representation

Планируется:

``` gdscript
const MAP_WIDTH := 64
const MAP_HEIGHT := 64
```

и отдельная система:

``` text
MapGrid
├── Tile data
├── Occupancy
├── Walkability
├── Building occupancy
├── Enemy navigation
└── Spatial queries
```

------------------------------------------------------------------------

## 2.2 Типы клеток

**Статус: \[Выполнено\]**

Подтверждены как минимум значения:

``` text
0
16
21
40
```

Их точное визуальное назначение теперь отделено от логики сетки: визуальные
ресурсы загружаются через `C.ZA(int)` из таблицы `aD`, а отрисовка кадров
выполняется `C.C(Graphics,int,int,int,int)`. Полное resource mapping
зафиксировано ниже в PHASE 2.3.

### Godot

Предварительно:

``` gdscript
const TILE_EMPTY := 0
const TILE_BASE := 16
const TILE_SPECIAL_A := 21
const TILE_SPECIAL_B := 40
```

**Важно:** названия `BASE`, `SPECIAL_A` и т. п. являются рабочими
обозначениями, пока семантика не подтверждена.

------------------------------------------------------------------------

# PHASE 3 --- ORIGINAL PATHFINDING / MOVEMENT

## 3.1 Исследование движения

**Статус: \[Выполнено\]**

В `C.class` обнаружены:

-   рекурсивный обход;
-   проверка соседних клеток;
-   распространение по карте;
-   проверка 8 соседних клеток;
-   логика доступности областей;
-   диагональная система координат.

Обнаружены методы:

``` text
A(...)
B(...)
F(...)
M(...)
```

------------------------------------------------------------------------

## 3.2 Перенос в Godot

**Статус: \[Проектирование\]**

Оригинальную реализацию не копировать буквально.

В Godot использовать:

``` text
GridMap / custom grid
+
AStarGrid2D / собственный navigation layer
```

Архитектура:

``` text
NavigationSystem
├── is_walkable()
├── get_neighbours()
├── find_path()
├── reserve_cell()
├── release_cell()
└── get_attack_position()
```

### Особенность

Для жуков необходимо сохранить ощущение оригинального движения, даже
если внутренняя реализация будет современной.

------------------------------------------------------------------------

# PHASE 4 --- LOCALIZATION / GAME DESIGN DATA

## 4.1 `RU.MAIN.lng`

**Статус: \[Выполнено\]**

Локализация содержит игровые термины, описания юнитов, зданий и
способностей.

------------------------------------------------------------------------

# PHASE 5 --- ENEMY DATABASE

## 5.1 Количество типов

**Статус: \[Выполнено\]**

Обнаружено:

``` text
9 типов жуков
```

Предварительные рабочие идентификаторы:

``` text
basic_bug
heavy_bug
eye_shooter
acid_ram
flying_shooter
queen
venom_bug
hidden_bug
sand_worm
```

------------------------------------------------------------------------

## 5.2 Поведение жуков

**Статус: \[Проектирование\]**

На основании локализации:

### Basic Bug

``` text
Поведение:
swarm / melee
```

Особенность:

``` text
атакует группами
```

### Heavy Bug

``` text
melee
```

Особенность:

``` text
крупнее
выносливее
```

### Eye Shooter

``` text
ranged
```

Особенность:

``` text
дальний энергетический/лучевой огонь
```

### Acid Ram

``` text
ram / acid
```

Особенность:

``` text
кислота
таран зданий
```

### Flying Shooter

``` text
flying_ranged
```

Особенность:

``` text
летает
дальняя атака
```

### Queen

``` text
queen / spawn
```

Особенность:

``` text
после смерти появляются отпрыски
```

### Venom Bug

``` text
poison
```

Особенность:

``` text
ядовитая кислота
```

### Hidden Bug

``` text
stealth
```

Особенность:

``` text
скрытность
```

### Sand Worm

``` text
burrow
```

Особенность:

``` text
подземное перемещение
```

------------------------------------------------------------------------

# PHASE 6 --- ENEMY BALANCE DATA

## 6.1 Таблица ID

**Статус: \[Выполнено\]**

Обнаружены ID:

``` text
70
71
72
73
74
75
76
77
78
```

Соответствующая таблица содержит:

``` text
9 × 16 × int32
```

------------------------------------------------------------------------

## 6.2 Подтверждённые поля

**Статус: \[Выполнено\]**

### Точная позиция таблицы

Таблица жуков имеет формат:

``` text
9 × 16 × int32
```

и начинается строго с:

``` text
offset 12984
```

Это соответствует девяти типам жуков и 16 `int32`-полям на запись.

### Предварительно восстановленные значения

  --------------------------------------------------------------------------------------------
	 ID Рабочее имя        Damage   Range      Bullet      Energy        Fire   Reward   Speed
											component   component   component          
  ----- ---------------- -------- ------- ----------- ----------- ----------- -------- -------
	 70 basic_bug             200    2600          50           0          25       95    1300

	 71 heavy_bug             150    2400           0          50          25       65    1000

	 72 eye_shooter            45    8600          45          25          50       35    1200

	 73 acid_ram              120    2700         120           0          50       45    1500

	 74 flying_shooter         25    3500          25           0          25       25     900

	 75 queen                   5    2400           5          25           0       13     700

	 76 venom_bug             125    2600         125          25           0       65    1200

	 77 hidden_bug             80    1900          80          50          25       55    1300

	 78 sand_worm             250    2300          25          50           0      125    1200
  --------------------------------------------------------------------------------------------

**Статус интерпретации:**

``` text
HP      → ORIGINAL_CONFIRMED
Damage  → ORIGINAL_CONFIRMED
Range   → ORIGINAL_CONFIRMED (enemy attack range; rA[][12])
```

Сопротивления, reward-related value и speed сохраняют ранее
подтверждённую семантику. HP и урон пока не следует считать
`ORIGINAL_CONFIRMED`: их семантика восстановлена как сильная рабочая
интерпретация, но требует окончательной проверки по потребителям полей в
`C.class`.

Подтверждено:

``` text
field[3]  → enemy ID
field[5]  → bullet resistance
field[6]  → energy resistance
field[7]  → fire resistance
field[10] → reward / score-related value
field[13] → movement speed
```

------------------------------------------------------------------------

## 6.3 Resistance system

**Статус: \[Выполнено\]**

Типы сопротивлений:

``` text
Bullet
Energy
Fire
```

Предварительная Godot-модель:

``` gdscript
"resistance": {
	"bullet": 25,
	"energy": 50,
	"fire": 0
}
```

------------------------------------------------------------------------

## 6.4 Точные HP / Damage / Range жуков

**Статус: \[Выполнено\]**

Прямая трассировка `C.class` теперь подтверждает семантику трёх ключевых
полей `rA`:

``` text
rA[][4]  → base damage
rA[][12] → attack range
rA[][5]  → bullet-damage component
rA[][6]  → energy-damage component
rA[][7]  → fire-damage component
rA[][13] → movement speed
```

`rA[][3]` является ID жука. В методе `A(int,int)` effective damage
рассчитывается из `rA[attacker][5..7]` и трёх защитных/сопротивляющих
компонентов цели `lA[target][1..3]`. Это не является источником базового
Damage: базовый damage профиль жука хранится в `rA[][4]`.

Метод `Z(int)` использует `rA[attacker][12]` при создании/настройке
атаки, что связывает это поле с дальностью атаки.

`lA[target][22]` --- runtime HP-поле активной сущности: в projectile-hit
pipeline (`M()`) и в `MA(int)` из него вычитается рассчитанный урон.

Следствие: прежняя рабочая маркировка `field[12] = HP` должна быть
снята. По коду `field[12]` участвует как дистанционный параметр атаки, а
runtime HP хранится в `lA[][22]`. Точное начальное значение `lA[][22]`
нужно фиксировать по consumer/инициализатору `lA`, а не по одной лишь
строке `rA`.

------------------------------------------------------------------------

# PHASE 7 --- BUILDINGS / TURRETS

## 7.1 Количество зданий

**Статус: \[Выполнено\]**

В локализации обнаружены 14 строительных/оборонительных объектов:

``` text
1. Энергостанция
2. Огневая башня
3. Центральная база
4. Лазерная башня
5. Маяк
6. Штурмовое орудие
7. Солдаты
8. Минное поле
9. Плазменная башня
10. Радарная вышка
11. Сателлит
12. Центр коммуникации
13. Станция исследования
14. Башня Теслы
```

`Стройка` рассматривается как UI/state, а не как отдельный объект.

### Новый результат анализа файла `a`

В `a` обнаружен структурированный блок баланса зданий/турелей,
начинающийся строго с:

``` text
offset 11374
```

Блок содержит ровно 12 записей с подтверждёнными ID:

``` text
151, 153, 155, 157, 159, 161,
163, 165, 167, 169, 171, 173
```

Обнаружены характерные числовые поля, в том числе:

``` text
ID 163 → ... 30000 ... 60000 1500 15
ID 165 → ...  8000 ... 90000 4000 15
ID 167 → ... 25000 ... 80000 2000 15
ID 169 → ... 20000 ... 50000 3000 15
ID 171 → ... 17500 ...120000 5000 1
ID 173 → ...     1 ...100000 4000 13
```

Эти значения подтверждают наличие отдельного структурированного
балансного блока, но **не подтверждают сами по себе семантику каждого
поля**. В частности, нельзя без кода-потребителя автоматически объявлять
конкретное число `Cost`, `HP`, `Damage` или `Range`.

------------------------------------------------------------------------

# PHASE 8 --- BUILDING SYSTEM

> **SCENE-FIRST:** здания и их editable composition реализуются как Godot scenes.

## 8.1 Архитектура

**Статус: \[Проектирование\]**

Каждое здание должно иметь:

``` text
Building
├── ID
├── Display Name
├── Category
├── Cost
├── Max HP
├── Build Time
├── Grid Size
├── Damage
├── Range
├── Fire Rate
├── Damage Type
├── Target Rules
├── Upgrade Levels
└── Special Ability
```

------------------------------------------------------------------------

# PHASE 9 --- TURRET BALANCE

## 9.1 Текущий результат обратной трассировки

**Статус: \[Выполнено для enemy combat pipeline; building Damage/Range
--- не доказаны\]**

Для боевого конвейера найдено разделение runtime-данных:

``` text
lA[active_entity][22]
	↓
runtime current HP
```

В `M()` (projectile-hit pipeline) для `rb[][7] == 2` выбирается target
`lA`, а для `rb[][7] == 1` выполняется прямой damage path. В ветке
прямого damage:

``` text
target = rb[][10]
attacker = rb[][8]
	↓
A(target, attacker)
	↓
rA[ attacker ][5..7] × target components lA[target][1..3]
	↓
effective damage
	↓
lA[target][22] -= effective damage
```

Метод `A(int,int)` выполняет именно resistance/damage-type часть:

``` text
d_bullet = rA[attacker][5] × lA[target][1]
d_energy = rA[attacker][6] × lA[target][2]
d_fire   = rA[attacker][7] × lA[target][3]

каждый результат / 100 с Java-style rounding
final = max(1, d_bullet + d_energy + d_fire)
```

После этого `M()` вычитает `final` из low-16 части `lA[target][22]`.

## 9.2 Цепочка для атаки жука

**Статус: \[Выполнено\]**

Для runtime-атакующего `vA[attacker][3]` хранится индекс строки `rA`:

``` text
vA[attacker][3]
		↓
rA[attacker]
```

В `Z(int)` код использует:

``` text
rA[attacker][12]
```

как дистанционный параметр при создании атаки и:

``` text
rA[attacker][13]
```

как скорость/шаг runtime attack state.

В `B(int,int,int,int,int,int,int,int,int)` при создании projectile state
также используется:

``` text
rA[attacker][4]
```

как базовый damage payload, с последующей передачей в `vA[][22]`.

Итого для жуков:

``` text
rA[][3]  = enemy ID
rA[][4]  = base damage
rA[][5]  = bullet component
rA[][6]  = energy component
rA[][7]  = fire component
rA[][12] = attack range
rA[][13] = movement/attack speed parameter
```

## 9.3 Источник `rA`

**Статус: \[Выполнено\]**

`rA` **не hardcoded** через switch-case.

При загрузке `C.class` последовательно вызывает:

``` java
HG.D(InputStream) → qa
HG.B(InputStream) → aD
HG.C(InputStream) → bD
HG.B(InputStream) → mA
HG.B(InputStream) → nA
HG.B(InputStream) → oA
HG.E(InputStream) → pA
HG.E(InputStream) → qA
HG.B(InputStream) → rA
```

Таким образом:

``` text
file a
  @ offset 12984
	  ↓
HG.B(InputStream)
	  ↓
rA : int[9][16]
```

Размер и конец блока подтверждены:

``` text
9 × 16 × int32
offset = 12984
end    = 13564
```

Это ровно 9 строк --- по одной на каждый ID жука 70--78.

### Доказанные Damage / Range жуков

  ------------------------------------------------------------------------
		   ID      Damage        Range      Bullet      Energy        Fire
				`rA[][4]`   `rA[][12]`     `[][5]`     `[][6]`     `[][7]`
  ----------- ----------- ------------ ----------- ----------- -----------
		   70         200         2600          50           0          25

		   71         150         2400           0          50          25

		   72          45         8600          45          25          50

		   73         120         2700         120           0          50

		   74          25         3500          25           0          25

		   75           5         2400           5          25           0

		   76         125         2600         125          25           0

		   77          80         1900          80          50          25

		   78         250         2300          25          50           0
  ------------------------------------------------------------------------

## 9.4 Building / static-effect balance

**Статус: [Частично подтверждено — отдельные static-effect Damage consumers найдены; универсальные Turret Range/Fire Rate не доказаны]**

12 строительных записей находятся в:

``` text
oA : int[12][9]
offset = 11518
```

с ID:

``` text
151, 153, 155, 157, 159, 161,
163, 165, 167, 169, 171, 173
```

Но `rA` к этим 12 ID **не относится**: его девять строк имеют enemy IDs
70--78.

`oA[][7]` участвует в UI/debug lookup, но его универсальная семантика
как категории не доказана, но в найденном consumer-коде нет доказательства, что
конкретные `mA` поля являются turret Damage/Range. Поэтому нельзя
переносить `rA[][4]`/`rA[][12]` на 12 building IDs.

Текущий строгий вывод после нового forensic-pass:

``` text
Enemy Damage  → a @ 12984 → rA[][4]
Enemy Range   → a @ 12984 → rA[][12]

Static-building damage:
  несколько прямых consumers найдены
  → не все 12 building IDs покрыты

Static-building range:
  частично восстановлена геометрия damage-zone
  → универсальный attack range не найден

Static-building fire interval:
  timer mechanism найден
  → семантика именно fire-rate требует отдельной проверки
```

Следовательно, универсальные Damage/Range для всех 12 building IDs всё ещё нельзя объявлять полностью восстановленными. При этом отдельные static-effect Damage уже доказаны: `C.class` содержит прямые ветки, которые уменьшают `lA[][22]` активных врагов с использованием параметров `oA`. Эти значения не следует автоматически называть универсальными `TurretStats`.

## 9.5 Подтверждённые значения зданий и static effects

	 ID   Max HP   Cost   Static Damage   Range Статус
  ----- -------- ------ -------- ------- ----------------------------
	151    30000    300        ?       ? HP/Cost ORIGINAL_CONFIRMED
	153    30000    500        ?       ? HP/Cost ORIGINAL_CONFIRMED
	155    30000    750      125       ? Damage=125 via P() CONFIRMED; effect radius=2
	157    15000    250        ?       ? HP/Cost ORIGINAL_CONFIRMED
	159    30000    800      800       ? Damage=800 CONFIRMED; Range unresolved
	161    60000   1000     1000       ? Damage=1000 CONFIRMED; Range unresolved
	163    60000   1500        ?       ? HP/Cost ORIGINAL_CONFIRMED
	165    90000   4000        ?       ? HP/Cost ORIGINAL_CONFIRMED
	167    80000   2000        ?       ? HP/Cost ORIGINAL_CONFIRMED
	169    50000   3000        ?       ? HP/Cost ORIGINAL_CONFIRMED
	171   120000   5000        ?       ? HP/Cost ORIGINAL_CONFIRMED
	173   100000   4000      200       ? Damage=200 via P() CONFIRMED; Range unresolved

## 9.6 Следующая точка трассировки

Продолжать от:

``` text
oA[building][7]
	  ↓
mA[category]
	  ↓
consumer of attack parameters
	  ↓
runtime vA / rb
	  ↓
projectile creation
	  ↓
M()
```

До нахождения такого consumer `Damage/Range` 12 зданий остаются
`ORIGINAL_INFERRED`/неподтверждёнными.

# PHASE 10 --- POWER-UP SYSTEM

## 10.1 Обнаруженные способности

**Статус: \[Выполнено\]**

``` text
Recon Flight
Quick Repair
Bomb
Instant Kill
Paralyzing Rays
Poison Gas
Super Shield
Invulnerability
Range Bonus
Extreme Damage
Stunning Rays
Smart Bomb
```

------------------------------------------------------------------------

## 10.2 Godot architecture

**Статус: \[Проектирование\]**

Каждый power-up:

``` gdscript
{
	"id": "...",
	"duration": 0.0,
	"target": "...",
	"effect": "...",
	"cooldown": 0.0
}
```

Реализовать через:

``` text
PowerUpSystem
├── activate()
├── apply_effect()
├── remove_effect()
├── spawn_effect()
└── validate_target()
```

------------------------------------------------------------------------

# PHASE 11 --- DAMAGE SYSTEM

## 11.1 Типы урона

**Статус: \[Проектирование\]**

Базовые типы:

``` text
bullet
energy
fire
explosive
poison
```

Первые три подтверждены оригинальной логикой сопротивлений.

Последние два нужны для реконструкции специальных атак.

------------------------------------------------------------------------

## 11.2 Resistance formula

**Статус: \[Выполнено\]**

Базовая современная модель:

``` gdscript
final_damage = damage * (1.0 - resistance / 100.0)
```

Но при полном порте необходимо сверить:

-   округление;
-   minimum damage;
-   special modifiers;
-   critical/special attacks.

------------------------------------------------------------------------

# PHASE 12 --- WAVE SYSTEM

## 12.1 Формулы оригинала

**Статус: \[Выполнено\]**

В `C.class` обнаружена формула:

``` text
value = 2000 + ib * 250 + ac * 50
```

с ограничением:

``` text
value = min(value, limit)
```

Также обнаружена специальная прогрессия:

``` text
10000 * (((ib + 2) / 2) + 1)
```

с поведением integer division Java.

------------------------------------------------------------------------

## 12.2 Распределение нагрузки

**Статус: \[Выполнено\]**

Обнаружены коэффициенты:

``` text
60%
50%
40%
```

с последующим распределением остатка между несколькими
направлениями/объектами.

Точная семантика требует дополнительной проверки.

------------------------------------------------------------------------

## 12.3 Godot Wave Manager

**Статус: \[Проектирование\]**

Архитектура:

``` text
WaveManager
├── current_wave
├── difficulty
├── spawn_budget
├── enemy_pool
├── spawn_points
├── spawn_interval
├── wave_timer
├── calculate_budget()
├── spawn_enemy()
├── distribute_budget()
└── finish_wave()
```

------------------------------------------------------------------------

# PHASE 13 --- ECONOMY

## 13.1 Ресурсы

**Статус: [Частично подтверждено — Building Cost подтверждён; остальные категории требуют дальнейшей проверки]**

Необходимо установить из оригинальных данных:

``` text
currency
building cost
upgrade cost
power-up cost
wave rewards
enemy rewards
```

------------------------------------------------------------------------

## 13.2 Почему нельзя фиксировать значения

Пока отсутствует полная расшифровка всех потребителей `a`, нельзя считать любые значения автоматически подтверждёнными.

Исключение — Building Cost для подтверждённых записей `oA`, где consumer-код доказан.

``` text
Building Cost       → ORIGINAL_CONFIRMED для подтверждённых записей
Upgrade Cost → UNRESOLVED
Power-up Cost       → UNRESOLVED
Wave Rewards        → UNRESOLVED
```

Неподтверждённые значения не должны считаться реконструированным балансом Sturmtrupp Mars.

------------------------------------------------------------------------

# PHASE 14 --- `HG.class` REVERSE ENGINEERING

## 14.1 Главная текущая задача

**Статус: \[Выполнено\]**

### Цель

Полностью восстановить:

``` text
HG.B()
HG.C()
HG.D()
HG.E()
```

и все связанные структуры.

------------------------------------------------------------------------

## 14.2 Что необходимо получить

**Статус: \[Проектирование\]**

Создать таблицу:

``` text
offset
datatype
array dimensions
meaning
consumer
confidence
```

Например:

``` text
offset 0
int32
enemy ID
C.class
HIGH
```

------------------------------------------------------------------------

## 14.3 После расшифровки HG

**Статус: \[Проектирование\]**

Повторно проанализировать `a` и построить:

``` text
EnemyStats
BuildingStats
TurretStats
WaveStats
UpgradeStats
MapStats
```

------------------------------------------------------------------------

# PHASE 15 --- GODOT DATA ARCHITECTURE

## 15.1 Центральная база

**Статус: \[Проектирование\]**

Файл:

``` text
data/game_balance.gd
```

Структура:

``` gdscript
const UNITS = {}
const BUILDINGS = {}
const TURRETS = {}
const UPGRADES = {}
const POWERUPS = {}
const WAVES = {}
```

------------------------------------------------------------------------

## 15.2 Принцип данных

**Статус: \[Проектирование\]**

Каждое значение должно иметь один из статусов:

``` text
ORIGINAL_CONFIRMED
ORIGINAL_INFERRED
TEMPORARY_BALANCE
```

Нельзя смешивать эти категории.

------------------------------------------------------------------------

# PHASE 16 --- GODOT PROJECT STRUCTURE

> **SCENE-FIRST:** структура проекта должна явно разделять editable scenes и code-only systems.

## 16.1 Папки

**Статус: [Частично выполнено — базовые map/data/scenes созданы; остальные systems проектируются]**

Предлагаемая структура:

``` text
res://
│
├── core/
│   ├── game_manager.gd
│   ├── game_state.gd
│   └── event_bus.gd
│
├── map/
│   ├── map_grid.gd
│   ├── map_manager.gd
│   └── navigation_system.gd
│
├── units/
│   ├── bug_base.gd
│   ├── bug_ai.gd
│   ├── bug_spawner.gd
│   └── behaviors/
│
├── buildings/
│   ├── building_base.gd
│   ├── turret_base.gd
│   └── buildings/
│
├── combat/
│   ├── damage_system.gd
│   ├── projectile.gd
│   └── target_system.gd
│
├── waves/
│   ├── wave_manager.gd
│   └── spawn_director.gd
│
├── powerups/
│   └── power_up_manager.gd
│
├── data/
│   ├── game_balance.gd
│   ├── units.gd
│   ├── buildings.gd
│   ├── turrets.gd
│   └── waves.gd
│
├── ui/
│
├── world/
│
└── assets/
```

------------------------------------------------------------------------

# CURRENT GODOT IMPLEMENTATION STATUS

**Статус: [Частично выполнено — архитектурный scene-first каркас и прототипы]**

В проекте уже реализовано и проверено:

```text
res://map/map_grid.gd
	64×64 логическая сетка
	walkability / occupancy
	grid_to_world() / world_to_grid()

res://map/navigation_system.gd
	8-связная навигация
	get_neighbours()
	find_path()

res://scenes/units/basic_bug.tscn
	CharacterBody3D
	basic-bug.glb
	CollisionShape3D
	AttackPoint
	walk animation playback

res://scenes/buildings/building_base.tscn
	editable building scene template
	collision
	TargetPoint / AttackPoint
	exported scene-level parameters

res://scenes/map/map_root.tscn
	GridOrigin
	Buildings
	Units
	SpawnPoints

res://scenes/gameplay/game_level.tscn
	MapRoot instance
	ground and collision
	camera and lighting
	BasicBug instance
```

`res://data/game_balance.gd` и `res://data/asset_catalog.gd` содержат
начальный data/catalog каркас с логическими ID и статусами данных. Полные
подтверждённые числовые balance-таблицы ещё не подключены.

Тестовая `game_level.tscn` запускается без ошибок; basic bug появляется на
уровне, перемещается и проигрывает `walk`. Полноценные map, building,
combat, wave и UI systems пока не реализованы.

------------------------------------------------------------------------

# PHASE 17 --- 3D WORLD / GRAPHICS

## 17.1 Переход 2D → 3D

**Статус: \[Выполнено — оригинальные визуальные ресурсы сопоставлены с 3D-ассетами\]**

Оригинальная логика сетки:

``` text
64 × 64
```

сохраняется.

Но визуальное представление:

``` text
Grid Cell
→
3D world position
```

Например:

``` gdscript
func grid_to_world(cell: Vector2i) -> Vector3:
	return Vector3(
		cell.x * CELL_SIZE,
		0.0,
		cell.y * CELL_SIZE
	)
```

------------------------------------------------------------------------


------------------------------------------------------------------------

# PHASE 2.3 — ORIGINAL GRAPHICS FORENSICS / RESOURCE MAPPING

**Статус: [Выполнено]**

## 2.3.1 Техническая схема загрузки PNG

В `C.class` найден универсальный загрузчик:

``` java
C.ZA(int)
```

Он не содержит отдельных `switch` для `100`, `200`, `500` или `800`.
Вместо этого он читает таблицу:

``` java
aD[][]
```

и строит имя ресурса из `aD[i][0]`:

``` text
/000.png
/100.png
/101.png
...
/841.png
```

Правила форматирования:

``` text
N < 10   → /00N.png
N < 100  → /0N.png
N >= 100 → /N.png
```

Загруженные изображения хранятся в:

``` java
dD[][]
```

а универсальный renderer:

``` java
C(Graphics, imageIndex, frame, x, y)
```

использует `aD[imageIndex]` для размеров кадра, offsets и разбиения
sprite-sheet. При наличии `bD` используются frame-specific offsets.

Следовательно:

``` text
logical entity ID
	  ≠
PNG filename
	  ≠
aD array index
```

Это принципиально для Godot-переноса: нельзя делать `entity_id.png`.

`aD` содержит 130 ресурсных записей; `icon.png` является отдельным
ресурсом интерфейса и в `aD` как numeric resource не представлен.

## 2.3.2 Диапазоны ресурсов

| Диапазон | Назначение, подтверждённое по ресурсам | Основные файлы |
|---|---|---|
| `1xx` | игровые здания, юниты, defence/build-state sprites и их animation sheets | `100–150` |
| `2xx` | projectile / hit / fire / energy / combat effects | `201–217` |
| `5xx` | bug sprites, bug animation states и combat effects | `500–515` |
| `8xx` | UI, portraits, backgrounds, logos и интерфейсные элементы | `800–841` |

`ZA()` является общим loader для всех четырёх диапазонов. Отдельного
loader `load100()`, `load500()` и т. п. в `C.class` нет.

## 2.3.3 Важное исправление терминологии

В диапазоне логических ID `151–173` находится **не 12 зданий**, а
11 building/defence entries + 1 infantry entry:

``` text
163 = Солдаты
```

Это подтверждается порядком оригинальных строк `RU.MAIN.lng` и визуальным
набором `134–136.png`. В Godot этот объект должен быть `InfantryDefender`,
а не `Building`.

## 2.3.4 Финальная таблица: building / defender mapping

| Logical ID | Original localized name | PNG resource(s) | Role | Forensic basis |
|---:|---|---|---|---|
| **151** | Энергостанция | `119.png`, `120.png`, `121.png` | energy/economy building, 3 visual levels | industrial generator sprite + 3 sequential upgrade states |
| **153** | Огневая башня | `113.png` | fire-defense turret | armored cannon/turret sprite |
| **155** | Центральная база | `100.png`, `101.png`, `102.png` | command/base, 3 upgrade levels | unique large central structure + explicit multi-level sheets |
| **157** | Лазерная башня | `114.png` | laser-defense turret | same turret chassis with blue energy emitter |
| **159** | Маяк | `124.png` | lure/beacon building | isolated vertical beacon with domed top |
| **161** | Штурмовое орудие | `145.png`, `146.png` | heavy artillery / assault gun, 2 visual states | reinforced emplacement with black gun aperture |
| **163** | Солдаты | `134.png`, `135.png`, `136.png` | infantry defender/unit | human soldier animation/pose set; **not a building** |
| **165** | Минное поле | `147.png`, `148.png`, `149.png`, `150.png` | mines / minefield / impact states | ground mine/explosion/debris resource family |
| **167** | Плазменная башня | `115.png` | plasma-defense turret | purple plasma core + blue energy discharge |
| **169** | Радарная вышка | `122.png` | radar / detection structure | twin antenna radar installation |
| **171** | Сателлит | `123.png` | visibility satellite, animated dish states | 8-frame rotating dish/satellite sheet |
| **173** | Центр коммуникации | `137.png` | current mapping: communications building; revalidation required | previous visual classification; conflicts with observed persistent base-attached ship module |

### Forensic addendum — resources 137 and 000

The original game archive is available under `res://original/`, including
`C.class`, `HG.class`, the binary data files, localization and PNG resources.

#### Resource 137

Confirmed:

- `res://original/137.png` exists;
- dimensions: `47 × 29`;
- `C.class` maps resource index `74` to numeric PNG resource `137` through
  the normal `aD` / `dD` resource pipeline;
- it is an ordinary PNG resource, not a separate animation file format.

Gameplay observation:

- `137.png` is observed as a ship-like upper module that descends onto and
  attaches to the central base;
- after attachment it remains present until the end of the level.

Current status:

```text
137.png → persistent ship-like module attached to the base (observed)
137.png → exact logical/runtime role (not yet proven from C.class)
```

The previous mapping of `137.png` to logical ID `173` Communication Center
requires revalidation against the gameplay observation. No logical ID is
changed here until the runtime consumer is traced.

`HG.B/C/D/E(InputStream)` are deserialization helpers. `C.class` loads resource
metadata and calls `ZA(int)`; `aD` maps resource indexes to numeric PNG IDs.
The current evidence confirms the ordinary resource/frame pipeline, but does
not yet prove which method creates or draws the persistent 137 object, whether
it is a base sub-layer or separate object, or whether the descent uses frames,
position changes, or both.

#### Resource 000

Confirmed:

- `res://original/000.png` exists;
- dimensions: `168 × 168`;
- it is a normal indexed PNG.

Visual observation:

- it appears to contain terrain/map material or map objects such as rocks,
  roads and ground elements.

Current status:

```text
000.png → map/terrain candidate (visually plausible)
000.png → exact tile/frame semantics (not yet proven)
```

Binary audit update: `C.BB(1)` loads `/a` through several `HG` binary readers. The first fixed-width `int[][]` table is 130×10; row 0 is `[0, 7, 7, -1, -1, 0, 0, 0, 0, -1]`. `C.ZA(int)` uses this table to construct `/000.png` for resource index 0. In `C.C(Graphics,int,int,int,int)`, metadata columns 1 and 2 are frame-origin strides; non-positive columns 3 and 4 make the loader derive frame counts from image width/height divided by those strides. The draw helper positions the full image by `frame_index % frame_columns * stride_x` and `frame_index / frame_columns % frame_rows * stride_y`, then clips a 24×24 window. Thus for `000.png`, 24×24 windows overlap at source origins separated by 7 px. Separately, the map renderer traverses in 24-pixel world/screen increments. The source map/cell-to-frame lookup and how these overlapping crops are selected remain `UNRESOLVED`; the diagnostic preview demonstrates only the draw-helper sampling, not final map terrain.

### Asset variants that must NOT be mistaken for additional buildings

``` text
125.png / 126.png / 127.png
128.png / 129.png / 130.png
131.png / 132.png / 133.png
138.png / 139.png / 140.png
141.png / 142.png / 143.png
144.png
```

These belong to animation/effect/other object layers rather than creating
new logical IDs `151–173`. In particular, `138–140` are a separate
three-state structure family associated with later technology/defence
content; they are not another ID inside the requested `151–173` block.

## 2.3.5 Bug mapping

## ORIGINAL_CONFIRMED — финальный 5xx bug mapping

**Статус: `[Выполнено]` — визуально подтверждено.**

| Logical ID | Name | Confirmed original PNG | Role |
|---:|---|---|---|
| **70** | Basic Bug | `505.png` | базовый жук |
| **71** | Heavy Bug | `507.png` | тяжелый жук |
| **72** | Eye Shooter | `501.png` | дальнобойный жук-стрелок |
| **73** | Acid Ram | `504.png` | кислотный таран |
| **74** | Flying Shooter | `503.png` | летающий стрелок |
| **75** | Queen | `502.png` | королева |
| **76** | Venom Bug | `500.png` | ядовитый жук |
| **77** | Hidden Bug | `512.png` + `513.png` | обычная форма + силуэт режима невидимости |
| **78** | Sand Worm | `508.png` + `509.png` + `510.png` + `511.png` | полный цикл анимации червя |
| — | Unit FX / Combat / Death | `514.png` + `515.png` | эффекты боя/смерти юнитов |

Эта таблица является единственным авторитетным mapping для 5xx bug resources. Все предыдущие варианты сопоставления 500–515 с ID 70–78 считаются устаревшими.

## 2.3.6 Combat-effect range

The `2xx` range is visually distinct from entity sprites:

``` text
201  — small projectile/marker
202–205 — green/yellow/orange energy/fire effects
206–210 — hit/explosion/fire animation families
211–217 — additional projectile/impact/energy effects
```

The exact damage semantics remain governed by combat code; the image itself
must not be used as a substitute for the numeric damage table.

------------------------------------------------------------------------

# PHASE 17.2 — GODOT 2.5D ASSET TARGETS

**Статус: [Выполнено — source-to-target visual specification fixed]**

## 17.2.1 General conversion rule

Every original sprite family becomes a 2.5D Godot asset family:

``` text
Original PNG
	↓
silhouette + palette + functional geometry extraction
	↓
2D/isometric concept and sprite-ready layers
	↓
clean separated colors and materials
	↓
idle / attack / damage / destruction animations
	↓
Godot scene
```

The target presentation is:

``` text
modern sci-fi strategy
2D illustrated but mechanically believable
fixed 45-degree isometric orthographic-friendly view
isolated white background
no text
no UI
no watermark
game-ready orthographic-friendly silhouette
sprite-ready composition with clean separated layers
cutout-animation-friendly parts where useful
```

## 17.2.2 21 production prompts

All prompts in this section are intended to be used with the corresponding
original PNG attached as a strict visual reference. The original reference
controls silhouette, proportions, recognizable functional elements, palette and
base identity. The generated result must remain the same object, not a newly
invented design.

Current 2.5D output requirements for every prompt:

- fixed 45-degree isometric/orthographic-friendly view;
- one complete object on a clean white or transparent background;
- readable sprite silhouette;
- separated visual layers where cutout animation may be useful;
- no text, UI, extra objects or unrequested modules;
- suitable for `Sprite2D`, `AnimatedSprite2D`, `AnimationPlayer` or a Godot scene.

### Bugs

**ID 70 — Basic Bug**

> Modern 2.5D/isometric sci-fi RTS alien insect inspired strictly by a tiny aggressive reddish-brown Mars bug, compact segmented exoskeleton, four thin articulated legs, small forward body, dark brown shell with rusty red highlights, hostile swarm-creature silhouette, compact proportions, hard-surface insect armor, subtle organic joints, believable weight and mechanical-game readability, clean separated colors and materials, no weapons, no extra limbs, fixed 45-degree isometric orthographic-friendly view, isolated on pure white background, studio lighting, centered full-body 2D game asset, modern AAA sci-fi strategy aesthetic, sprite-ready composition with clean separated layers, orthographic-friendly silhouette.

**ID 71 — Heavy Bug**

> Modern 2.5D/isometric sci-fi RTS heavy alien insect, visibly larger and tougher than a basic swarm bug, thick reddish-brown segmented exoskeleton, broad armored thorax, reinforced legs, heavier abdomen, dense hard shell, dark rust and burnt-orange palette, aggressive low stance, robust combat creature silhouette, believable articulated insect anatomy, clean separated colors and materials, no wings, no futuristic weapons, fixed 45-degree isometric orthographic-friendly view, isolated on pure white background, studio lighting, centered full-body 2D game asset, modern sci-fi strategy game, sprite-ready 2D composition.

**ID 72 — Eye Shooter**

> Modern 2.5D/isometric sci-fi RTS ranged alien insect based on a reddish-brown agile bug with prominent luminous eye-like emitters, slim articulated body, multiple precise legs, armored head focused forward, small glowing energy apertures around the eyes, dark brown shell with red-orange accents, visual language of a biological energy-beam shooter, restrained sci-fi detailing, clean separated colors and materials, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered full-body asset, modern AAA sci-fi strategy style, sprite-ready 2D composition, no text, no extra weapons.

**ID 73 — Acid Ram**

> Modern 2.5D/isometric sci-fi RTS acid-ramming alien insect, nasty compact armored creature with a reinforced front for building impacts and a visible rear acid-sac/tail mechanism, reddish-orange and dark brown exoskeleton, heavy abdomen, aggressive forward-leaning posture, corrosive alien biology expressed through translucent greenish acid details kept subtle, believable collision silhouette, robust articulated legs, clean separated colors and materials, fixed 45-degree isometric orthographic-friendly view, isolated on pure white background, studio lighting, centered full-body 2D game asset, modern sci-fi strategy aesthetic, sprite-ready composition with clean separated layers.

**ID 74 — Flying Shooter**

> Modern 2.5D/isometric sci-fi RTS flying alien insect with four translucent armored wings, compact reddish-brown body, long-range weapon-like biological emitter integrated into the front/head, angular wing joints, dark rust shell, orange highlights, clearly airborne combat silhouette, aerodynamic insect proportions, restrained alien technology, clean separated colors and materials, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered full-body 2D game asset, modern AAA sci-fi strategy game, sprite-ready 2D composition, no UI.

**ID 75 — Queen**

> Modern 2.5D/isometric sci-fi RTS alien insect queen, much larger and more imposing than regular bugs, bulky pale gray and rusty brown exoskeleton, massive armored abdomen, thick segmented limbs, heavy central body mass, queen-like commanding silhouette without humanoid features, rugged Mars-worn biological armor, subtle orange heat accents, believable boss creature proportions, clean separated colors and materials, fixed 45-degree isometric orthographic-friendly view, isolated on pure white background, studio lighting, centered full-body 2D game asset, modern sci-fi strategy aesthetic, sprite-ready composition with clean separated layers.

**ID 76 — Venom Bug**

> Modern 2.5D/isometric sci-fi RTS poisonous alien insect, medium-large reddish-brown body with a clearly visible curved stinger, segmented armored abdomen, compact muscular legs, dark rust shell with orange highlights, venom delivery tail anatomy, aggressive combat stance, believable insect articulation, clean separated colors and materials, no wings, no humanoid anatomy, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered full-body 2D game asset, modern AAA sci-fi strategy style, sprite-ready 2D composition.

**ID 77 — Hidden Bug**

> Modern 2.5D/isometric sci-fi RTS stealth alien insect, same core reddish-brown insect silhouette as a dangerous Mars crawler but designed around partial invisibility, dark segmented exoskeleton with subtle refractive distortion along the edges, faint broken outline and translucent camouflage patches, compact articulated legs, threatening but difficult-to-see silhouette, restrained optical-cloaking effect, physically plausible translucent material, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered full-body 2D game asset, modern sci-fi strategy aesthetic, sprite-ready composition with clean separated layers.

**ID 78 — Sand Worm**

> Modern 2.5D/isometric sci-fi RTS Martian sand worm, compact burrowing alien creature with a low elongated body, armored segmented brown-orange surface, partially buried visual language, reinforced head, gritty desert coloration, dense rugged exoskeleton adapted to underground movement, no wings, no humanoid features, threatening subterranean silhouette, clean separated colors and materials with subtle sand dust, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered full-body 2D game asset, modern AAA sci-fi strategy aesthetic, sprite-ready 2D composition.

### Buildings / defenders

**ID 151 — Energy Station**

> Modern 2.5D/isometric sci-fi RTS energy station inspired strictly by the original industrial Mars generator: compact rectangular dark steel power building, prominent red reactor housing, cyan status lights, yellow industrial hazard accents, heavy armored panels, exposed service modules, practical cables and vents, believable modular upgrade architecture, rugged colony engineering, no text, no antennas unless structurally justified, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered sprite-ready game asset, modern AAA sci-fi strategy style, clean separated colors and materials, sprite-ready composition with clean separated layers.

**ID 153 — Fire Tower**

> Modern 2.5D/isometric sci-fi RTS fire-defense turret inspired by the original squat armored cannon: dark weathered steel chassis, compact central ballistic cannon, mechanical side braces, red warning accents, reinforced circular turret housing, practical recoil mechanism, heavy industrial construction, compact footprint suitable for a 64x64 strategy grid, clearly defensive silhouette, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered game asset, modern sci-fi strategy aesthetic, clean separated colors and materials, sprite-ready 2D composition.

**ID 155 — Central Base**

> Modern 2.5D/isometric sci-fi RTS central Mars command base, large symmetrical armored command structure based on the original broad mechanical silhouette, dark gray industrial hull, cyan illuminated central control panels, red vertical side modules, angular reinforced outer shell, heavy landing/support geometry, layered command core, believable three-tier upgrade architecture, iconic headquarters silhouette, no text, no flags, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered full building with clear sprite silhouette, modern AAA sci-fi strategy aesthetic, clean separated colors and materials, sprite-ready composition with clean separated layers.

**ID 157 — Laser Tower**

> Modern 2.5D/isometric sci-fi RTS laser defense turret, compact armored mechanical chassis derived from the original turret family, dark steel plating, narrow high-energy emitter, restrained cyan-blue laser glow, red warning strips, articulated aiming assembly, heat-management vents, practical hard-surface engineering, small strategic footprint, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered sprite-ready game asset, modern sci-fi strategy aesthetic, clean separated colors and materials, sprite-ready 2D composition.

**ID 159 — Beacon**

> Modern 2.5D/isometric sci-fi RTS Martian beacon building, narrow vertical industrial tower with a pale armored dome at the top, dark gray cylindrical housing, strong red vertical panels, small blue energy/service details, compact lure/navigation beacon silhouette, rugged colony construction, believable maintenance panels, no exaggerated futuristic ornament, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered game asset, modern AAA sci-fi strategy aesthetic, clean separated colors and materials, sprite-ready composition with clean separated layers.

**ID 161 — Assault Gun**

> Modern 2.5D/isometric sci-fi RTS heavy assault artillery emplacement based on the original compact armored gun, dark steel bunker-like chassis, large black forward gun aperture/barrel, strong yellow-gold hazard armor around the sides, reinforced firing cradle, heavy recoil supports, rugged Mars colony engineering, clearly heavier than a basic turret, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered sprite-ready game asset, modern sci-fi strategy aesthetic, clean separated colors and materials, sprite-ready composition with clean separated layers.

**ID 163 — Soldiers**

> Modern 2.5D/isometric sci-fi RTS Mars infantry defender, compact armored human soldier based on the original blue-and-white uniform silhouette, protective helmet, dark tactical body armor, blue visor/energy accents, rugged boots and gloves, compact rifle held in a ready position, practical colonial military design, readable from an isometric strategy camera, no excessive tactical accessories, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered full-body character, modern AAA sci-fi strategy aesthetic, clean separated colors and materials, sprite-ready composition with clean separated layers.

**ID 165 — Minefield**

> Modern 2.5D/isometric sci-fi RTS minefield asset, compact cluster of buried Martian anti-insect mines and disturbed soil, dark brown metallic mine housings partially concealed by reddish Martian dust, several subtle explosive impact/debris states, low silhouette suitable for ground placement, practical military engineering, no oversized sci-fi effects, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered modular strategy asset, modern sci-fi strategy aesthetic, clean separated colors and materials, sprite-ready 2D composition.

**ID 167 — Plasma Tower**

> Modern 2.5D/isometric sci-fi RTS plasma defense turret, squat armored industrial chassis with a large spherical purple plasma core, blue-white energy discharge around the lower emitter, dark steel cradle, red warning accents, thick mechanical support arms, visible energy containment hardware, powerful but compact silhouette, believable hard-surface science-fiction engineering, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered sprite-ready game asset, modern AAA sci-fi strategy aesthetic, clean separated colors and materials, sprite-ready composition with clean separated layers.

**ID 169 — Radar Tower**

> Modern 2.5D/isometric sci-fi RTS radar tower based on the original twin-antenna installation, two compact dark industrial radar masts on a rugged base, thin red antenna details, mechanical scanning dishes and receiver elements, weathered gray steel, practical sensor housing, clearly non-combat surveillance role, compact colony engineering, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered game asset, modern sci-fi strategy aesthetic, clean separated colors and materials, sprite-ready composition with clean separated layers.

**ID 171 — Satellite**

> Modern 2.5D/isometric sci-fi RTS satellite visibility station, compact cylindrical armored base with a rotating dish/antenna assembly, dark gray industrial housing, pale metal dish, red mechanical accents, multiple believable dish orientations represented by an articulated pivot system, communication/surveillance role, rugged Mars colony technology, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered sprite-ready game asset, modern AAA sci-fi strategy aesthetic, clean separated colors and materials, sprite-ready composition with clean separated layers.

**ID 173 — Communication Center**

> Modern 2.5D/isometric sci-fi RTS communications center inspired by the original wide mechanical building, broad dark-gray command module, cyan illuminated central communication core, symmetrical side equipment blocks, heavy industrial panels, red emergency indicators, compact antenna/service details, believable orbital-command relay architecture, clean functional silhouette, fixed 45-degree isometric orthographic-friendly view, isolated pure white background, studio lighting, centered full building with clear sprite silhouette, modern AAA sci-fi strategy aesthetic, clean separated colors and materials, sprite-ready composition with clean separated layers.

------------------------------------------------------------------------

# PHASE 17.3 — GODOT RESOURCE NAMING CONTRACT

**Статус: [Выполнено]**

Godot asset IDs shall preserve the original numeric resource ID without
pretending that it is the gameplay entity ID.

Recommended structure:

``` text
res://assets/original_map/
	png_100_central_base_l1.png
	png_101_central_base_l2.png
	png_102_central_base_l3.png
	png_113_fire_tower.png
	png_114_laser_tower.png
	png_115_plasma_tower.png
	png_119_energy_station_l1.png
	png_120_energy_station_l2.png
	png_121_energy_station_l3.png
	png_124_beacon.png
	png_134_soldier_l1.png
	png_135_soldier_l2.png
	png_136_soldier_l3.png
	png_137_communication_center.png
	png_145_assault_gun_l1.png
	png_146_assault_gun_l2.png
	png_147_minefield_state_a.png
	png_148_minefield_state_b.png
	png_149_minefield_state_c.png
	png_150_minefield_state_d.png
	png_122_radar_tower.png
	png_123_satellite.png
```

Logical gameplay IDs remain independent:

``` text
151 EnergyStation
153 FireTower
155 CentralBase
157 LaserTower
159 Beacon
161 AssaultGun
163 Soldiers
165 Minefield
167 PlasmaTower
169 RadarTower
171 Satellite
173 CommunicationCenter
```

## 17.3.1 No invented mappings

The following distinction is mandatory:

``` text
PROVEN:
	C.ZA() constructs numeric PNG resource names from aD[][0].
	C.C(Graphics,...) renders frames from dD[] using aD/bD metadata.
	The 1xx/2xx/5xx/8xx resource families are real and present.

PROVEN BY ASSET + LOCALIZATION ORDER:
	the 151–173 and 70–78 functional mapping documented above.

NOT PROVEN:
	numeric combat damage from sprite appearance
	numeric range from sprite dimensions
	upgrade cost from sprite count
	fire rate from animation length alone
```

The graphics pipeline must never derive gameplay balance from pixels.

------------------------------------------------------------------------

# PHASE 17.4 — FINAL GRAPHICS STATUS

**Статус: [Выполнено]**

``` text
[✓] Numeric PNG inventory
[✓] aD → filename loader path
[✓] dD image cache
[✓] C(Graphics,...) sprite-sheet renderer
[✓] 1xx visual family
[✓] 2xx combat-effect family
[✓] 5xx bug family
[✓] 8xx UI/background family
[✓] 9 bug visual mappings
[✓] 11 building + 1 infantry mappings for IDs 151–173
[✓] localization names / functional descriptions
[✓] Godot asset naming contract
[✓] 21 production prompts for Low-Poly 3D generation
```

The only deliberate terminology correction is that logical ID `163` is
the infantry defender, not a building.

------------------------------------------------------------------------

# APPENDIX G — SOURCE GRAPHICS INVENTORY

The supplied graphics archive contains **131 PNG files**, including:

``` text
000.png
100–150.png
201–217.png
300–301.png
500–515.png
600–601.png
800–841.png
icon.png
```

The `aD` table in the original data contains **130 numeric PNG resources**;
`icon.png` is an additional non-numeric UI resource.

This means the Godot importer should retain the complete original numeric
inventory even when a resource is currently classified as an effect,
transition frame, UI fragment, or auxiliary animation.

------------------------------------------------------------------------

# GRAPHICS MASTER RULE

``` text
Original visual truth
		↓
numeric resource ID
		↓
aD frame metadata
		↓
logical entity mapping
		↓
3D reconstruction
		↓
Godot scene / animation
```

Never collapse these layers into a single ID.



## FINAL 5XX BINDING CONTRACT

```text
70 → 505.png
71 → 507.png
72 → 501.png
73 → 504.png
74 → 503.png
75 → 502.png
76 → 500.png
77 → 512.png + 513.png
78 → 508.png + 509.png + 510.png + 511.png
514.png + 515.png → FX / Combat / Death
```

**Правило:** этот `ORIGINAL_CONFIRMED` mapping имеет приоритет над всеми ранее записанными вариантами 5xx. Все существующие английские 3D-промпты сохранены; их asset binding теперь определяется таблицей выше.
# PHASE 18 --- BUG AI

## 18.1 Базовый AI

**Статус: \[Проектирование\]**

Состояния:

``` text
IDLE
SEARCH_TARGET
MOVE
ATTACK
SPECIAL_ATTACK
RETREAT
STUNNED
DEAD
```

------------------------------------------------------------------------

## 18.2 Специализированные AI

**Статус: \[Проектирование\]**

``` text
Basic Bug      → swarm
Heavy Bug      → melee
Eye Shooter    → ranged
Acid Ram       → building assault
Flying Shooter → aerial ranged
Queen          → spawn
Venom Bug      → poison
Hidden Bug     → stealth
Sand Worm      → burrow
```

------------------------------------------------------------------------

# PHASE 19 --- BUILDING AI / TARGETING

## 19.1 Target system

**Статус: \[Проектирование\]**

Приоритеты:

``` text
nearest
lowest_hp
closest_objective
specific_target
```

Для каждого типа врага приоритет может отличаться.

------------------------------------------------------------------------

# PHASE 20 --- COMBAT

> **SCENE-FIRST:** attack points, collision, projectile presentation и VFX — scene-editable; damage calculation и combat rules — code-only.

## 20.1 Combat pipeline

**Статус: \[Проектирование\]**

``` text
Acquire Target
	  ↓
Check Range
	  ↓
Check Line of Sight
	  ↓
Cooldown
	  ↓
Create Attack
	  ↓
Apply Damage
	  ↓
Resistance
	  ↓
Death / Status Effect
```

------------------------------------------------------------------------

# PHASE 21 --- BUILDING / CONSTRUCTION

## 21.1 Placement

**Статус: \[Проектирование\]**

Алгоритм:

``` text
Player selects building
		↓
Preview footprint
		↓
Check 64×64 grid
		↓
Check terrain
		↓
Check occupancy
		↓
Check resource cost
		↓
Place building
		↓
Reserve grid cells
```

------------------------------------------------------------------------

# PHASE 22 --- UPGRADES

## 22.1 Upgrade system

**Статус: \[Проектирование\]**

Поддержать:

``` text
Defense Upgrade
Damage Upgrade
Range Upgrade
Shield
```

Эти четыре направления подтверждаются локализацией.

------------------------------------------------------------------------

# PHASE 23 --- UI / UX

> **SCENE-FIRST:** UI authored as editable Godot scenes; behavior provided by reusable scripts.

## 23.1 Основной интерфейс

**Статус: \[Проектирование\]**

Необходимо:

``` text
Resource counter
Building menu
Turret information
Unit information
Wave counter
Power-up bar
Building HP
Target information
Pause
Settings
```

------------------------------------------------------------------------

# PHASE 24 --- AUDIO / VFX

> **SCENE-FIRST:** VFX authored as editable scenes; reusable effect logic may be code-driven.

## 24.1 Звуки

**Статус: \[Проектирование\]**

Категории:

``` text
building placement
turret fire
enemy hit
enemy death
building damaged
building destroyed
wave start
wave complete
power-up
UI
```

------------------------------------------------------------------------

## 24.2 VFX

**Статус: \[Проектирование\]**

``` text
bullet impact
energy impact
fire
acid
poison
explosion
laser
shield
stealth
burrow
```

------------------------------------------------------------------------

# PHASE 25 --- SAVE / GAME STATE

## 25.1 Save system

**Статус: \[Проектирование\]**

Сохранять:

``` text
current level
wave
resources
buildings
building HP
upgrades
power-ups
game progress
```

------------------------------------------------------------------------

# PHASE 26 --- TESTING / VALIDATION

## 26.1 Data validation

**Статус: \[Проектирование\]**

Каждое восстановленное значение проверять:

``` text
Source
↓
Binary value
↓
C.class consumer
↓
Localization context
↓
Semantic interpretation
↓
Godot representation
```

------------------------------------------------------------------------

## 26.2 Confidence levels

**Статус: \[Проектирование\]**

Каждому параметру присваивать:

``` text
HIGH
MEDIUM
LOW
TEMPORARY
```

------------------------------------------------------------------------

# PHASE 27 --- ОРИГИНАЛЬНЫЕ ДАННЫЕ, КОТОРЫЕ УЖЕ ИЗВЕСТНЫ

## Map

``` text
64 × 64
```

## Enemy types

``` text
9
```

## Buildings / structures

``` text
14
```

## Enemy IDs

``` text
70–78
```

## Enemy table

``` text
9 × 16 × int32
```

## Confirmed enemy parameters

``` text
ID
Bullet Resistance
Energy Resistance
Fire Resistance
Reward-related value
Speed
```

## Confirmed progression formula

``` text
min(
	2000 + ib * 250 + ac * 50,
	limit
)
```

## Special progression

``` text
10000 * (((ib + 2) / 2) + 1)
```

## Distribution coefficients

``` text
40%
50%
60%
```

------------------------------------------------------------------------

# PHASE 28 --- SEMANTIC MAPPING BLOCKER

## `HG.class`

**Статус: \[Заблокирован\]**

Это **главный следующий шаг**.

### Нельзя переходить к окончательному балансу до выполнения:

``` text
[x] Получить HG.class
[x] Декомпилировать / разобрать bytecode
[x] Восстановить HG.B()
[x] Восстановить HG.C()
[x] Восстановить HG.D()
[x] Восстановить HG.E()
[ ] Определить форматы массивов
[ ] Разметить offsets
[ ] Повторно распарсить файл a
[ ] Сопоставить таблицы с C.class
[ ] Сопоставить таблицы с RU.MAIN.lng
[x] Определить HP зданий через consumer — oA[][3] / building HP consumer confirmed
[x] Определить Damage жуков — rA[][4], consumer подтверждён
[x] Определить Range жуков — rA[][12], consumer подтверждён
[x] Провести полный call-site audit B(IIIIIIIII) — выполнено; building Attack Caller не найден
[ ] Определить Damage зданий — UNRESOLVED, отдельный static/event/effect consumer не найден
[ ] Определить Range зданий — UNRESOLVED, отдельный static/event/effect consumer не найден
[ ] Определить Fire Rate зданий — UNRESOLVED
[x] Определить Cost — oA[][6] consumer confirmed
[ ] Определить Upgrade values
```

------------------------------------------------------------------------

# PHASE 29 --- STRICT DEVELOPMENT ORDER

Разработка должна идти в следующем порядке.

## STEP 01

**\[Выполнено\]**

Получить и разобрать:

``` text
HG.class
```

## STEP 02

**\[Выполнено\] — forensic search завершён.**

### Финальный поиск Attack Caller в `C.class`

Проверены все прямые вызовы универсального конструктора:

``` java
B(int,int,int,int,int,int,int,int,int)
```

По bytecode `C.class` существует ровно **3 прямых call-site**:

``` text
A(int,int,int,int,int,int,int,int,int)
	└── B(...)

Z(int)
	└── A(...)
		 └── B(...)

SA(int)
	└── B(...)
```

То есть `A(...)` является только обёрткой, а реальные боевые
call-paths имеют корни:

``` text
Z(int)
SA(int)
```

### Что передаёт `Z(int)`

В `Z(int)` вызов через `A(...)` получает:

``` text
arg0 = vA[attacker][0]                         → X
arg1 = vA[attacker][1]                         → Y
arg2 = lA[target][17] + random offset          → target X
arg3 = lA[target][18] + random offset          → target Y
arg4 = rA[attacker_type][12]                   → attack Range
arg5 = 2                                       → projectile mode/type
arg6 = target entity index
arg7 = 1                                       → attack mode
arg8 = attacker entity index
```

Следовательно, для enemy/unit path `Z()` дальность действительно
передаётся прямо из:

``` text
rA[][12]
```

а не рассчитывается формулой в `B()`.

`B()` при этом не получает отдельный `damage` как один из первых пяти
параметров: damage payload формируется внутри `B()` из данных
атакующего/цели и runtime-state.

### Что передаёт `SA(int)`

`SA(int)` заканчивается прямым вызовом:

``` java
B(x, y, ..., ..., range_like_value, 1, attacker_type, 2, target)
```

Его payload относится к другому **unit/archetype attack path** и
использует `mA`/`lA`, а не `oA`/building record.

### Фильтрация зданий / `nA`

Критический результат поиска:

``` text
НЕТ direct B(...) call-site,
который получает параметры из:

oA[building]
nA[defender]
building ID 151..173
```

Также нет промежуточного вызова вида:

``` text
building ID
	↓
switch/case 151..173
	↓
damage
range
	↓
B(...)
```

В `C.class` не найдено и формулы:

``` text
damage = f(building ID)
range  = g(building ID)
```

для 12 building IDs.

### Почему `nA` не является найденным Attack Caller

`nA` действительно имеет 12 строк:

``` text
nA : 12 × 11 int32
```

но его подтверждённый consumer в `B(int, boolean)` использует
`nA[index][4]` для инициализации:

``` text
lA[entity][22] → HP
```

Это **HP initialization**, а не Damage/Range lookup.

Следовательно, нельзя переименовывать `nA[][4]` в Damage только на
основании совпадения количества строк.

### Финальная таблица 12 зданий

Для всех 12 подтверждённых building IDs результат строгой трассировки
одинаков:

| Building ID | Damage | Range | Доказанный источник |
|---:|---:|---:|---|
| 151 | ? | ? | consumer в `C.class` не найден |
| 153 | ? | ? | consumer в `C.class` не найден |
| 155 | ? | ? | consumer в `C.class` не найден |
| 157 | ? | ? | consumer в `C.class` не найден |
| 159 | ? | ? | consumer в `C.class` не найден |
| 161 | ? | ? | consumer в `C.class` не найден |
| 163 | ? | ? | consumer в `C.class` не найден |
| 165 | ? | ? | consumer в `C.class` не найден |
| 167 | ? | ? | consumer в `C.class` не найден |
| 169 | ? | ? | consumer в `C.class` не найден |
| 171 | ? | ? | consumer в `C.class` не найден |
| 173 | ? | ? | consumer в `C.class` не найден |

Это не пропуск анализа: это **отрицательный результат полного call-site
аудита `B(IIIIIIIII)`**.

### Архитектурный вывод

Подтверждённый runtime pipeline:

``` text
unit/enemy attack data
		↓
Z() / SA()
		↓
B(...)
		↓
rb[80][21]
		↓
projectile/effect processing
		↓
damage resolution
```

Но pipeline:

``` text
oA building
	↓
building Attack Caller
	↓
B(...)
```

в `C.class` **не существует в обнаруженном bytecode**.

Поэтому подстановка чисел из `nA`, `mA`, `pA`, `qA` или произвольных
полей `oA` в Damage/Range была бы нарушением правила
`Не выдумывать оригинальные данные`.

### Важное уточнение статуса

`STEP 02` как **forensic call-site search** выполнен полностью.

При этом:

``` text
Building Damage → UNRESOLVED
Building Range  → UNRESOLVED
Building Fire Rate → UNRESOLVED
```

остаются открытыми данными баланса.

Следующий forensic слой должен искать не ещё один прямой вызов
`B(...)`, а **статический/event/effect механизм**, который может
наносить урон зданиям без использования этого projectile constructor.

## STEP 03

**\[Проектирование\]**

Собрать окончательную:

``` text
EnemyStats
```

## STEP 04

**\[Проектирование\]**

Собрать:

``` text
BuildingStats
TurretStats
UpgradeStats
```

## STEP 05

**\[Проектирование\]**

Создать:

``` text
game_balance.gd
```

## STEP 06

**\[Проектирование\]**

Реализовать:

``` text
64×64 MapGrid
```

## STEP 07

**\[Проектирование\]**

Реализовать:

``` text
NavigationSystem
```

## STEP 08

**\[Проектирование\]**

Реализовать базового:

``` text
BugBase
```

## STEP 09

**\[Проектирование\]**

Добавить 9 AI-профилей.

## STEP 10

**\[Проектирование\]**

Реализовать:

``` text
BuildingBase
TurretBase
```

## STEP 11

**\[Проектирование\]**

Реализовать combat system.

## STEP 12

**\[Проектирование\]**

Реализовать WaveManager.

## STEP 13

**\[Проектирование\]**

Реализовать economy.

## STEP 14

**\[Проектирование\]**

Реализовать upgrades.

## STEP 15

**\[Проектирование\]**

Реализовать power-ups.

## STEP 16

**\[Проектирование\]**

Создать 3D world.

## STEP 17

**\[Проектирование\]**

Перенести UI.

## STEP 18

**\[Проектирование\]**

Добавить VFX/audio.

## STEP 19

**\[Проектирование\]**

Создать save/load.

## STEP 20

**\[Проектирование\]**

Балансировка и regression testing.

------------------------------------------------------------------------

# PHASE 30 --- ПРАВИЛА РАЗРАБОТКИ

## Rule 01 --- Не выдумывать оригинальные данные

Если значение не подтверждено:

``` text
не называть его оригинальным.
```

Использовать:

``` text
TEMPORARY
```

------------------------------------------------------------------------

## Rule 02 --- Сохранять оригинальную логику

Если оригинал использовал:

``` text
integer division
fixed-point
percentage resistance
grid-based movement
```

при реконструкции сначала повторить поведение, а уже потом
модернизировать реализацию.

------------------------------------------------------------------------

## Rule 03 --- Разделять data и logic

``` text
Data
≠
Gameplay logic
≠
Presentation
```

------------------------------------------------------------------------

## Rule 04 --- Godot не должен повторять legacy Java architecture

Старые:

``` text
50 × 25 int arrays
obfuscated variables
global state
```

используются как **источник реконструкции**, но не как архитектура
нового проекта.

------------------------------------------------------------------------

## Rule 05 --- Каждый неизвестный параметр должен иметь confidence

Пример:

``` gdscript
"hp": {
	"value": 200,
	"source": "temporary",
	"confidence": "LOW"
}
```

------------------------------------------------------------------------

# PHASE 9.24 — FINAL STEP 02 CALL-SITE AUDIT

## Result

Полный bytecode-аудит `C.class` по сигнатуре:

``` java
B(int,int,int,int,int,int,int,int,int)
```

нашёл только три прямых вызова:

``` text
A(IIIIIIIII) → B(IIIIIIIII)
Z(I)         → A(IIIIIIIII) → B(IIIIIIIII)
SA(I)        → B(IIIIIIIII)
```

`Z()` — unit/enemy attack path; его `range` берётся из:

``` text
rA[attacker_type][12]
```

`SA()` — другой unit/archetype path, использующий `mA`/`lA`.

Для building IDs:

``` text
151,153,155,157,159,161,163,165,167,169,171,173
```

не найдено ни прямого, ни промежуточного `B(...)` call-path из
`oA`/`nA`.

### Strict conclusion

``` text
Building Damage → ?
Building Range  → ?
```

для всех 12 зданий.

Никакие числовые значения не назначаются этим полям без consumer-proof.

Это является финальным результатом **STEP 02 call-site search**, но не
финальным восстановлением building combat balance.

------------------------------------------------------------------------

# CURRENT PROJECT STATE

На текущем этапе проект находится здесь:

``` text
ORIGINAL JAVA
	  │
	  ├── C.class ────────────────► ANALYZED
	  │
	  ├── RU.MAIN.lng ───────────► ANALYZED
	  │
	  └── a ─────────────────────► PARTIALLY DECODED
									  │
									  ▼
								  HG.class
									  │
									  ▼
							   SEMANTIC MAPPING BLOCKER
									  │
									  ▼
							  COMPLETE BALANCE
									  │
									  ▼
							GODOT DATA DATABASE
									  │
									  ▼
							  GAMEPLAY SYSTEMS
									  │
									  ▼
								3D REMAKE
```

# НЕ НАЧИНАТЬ ПОЛНОЦЕННУЮ РАЗРАБОТКУ GAMEPLAY ДО РАСШИФРОВКИ `HG.class`

Допустима только подготовка архитектуры и прототипов.

**Следующая обязательная задача проекта:**

> **Завершить STEP 02: сопоставить найденные блоки `a` с потребителями
> полей в `C.class`, доказать семантику
> `Cost/HP/Damage/Range/Fire Rate`, после чего собрать окончательные
> `EnemyStats`, `BuildingStats` и `TurretStats`.**

Это является текущей точкой продолжения проекта.

# PHASE 9 ADDENDUM --- BUILDING / STATIC-TOWER FORENSIC TRACE

## 9.7 Deep trace result

**Статус: \[Выполнено --- отрицательный результат, но архитектурно
доказан\]**

Глубокая трассировка `C.class` не обнаружила отдельного combat loop
вида:

``` text
for each built oA[]
	find nearby lA[]
	apply tower damage
```

и не обнаружила consumer, который передаёт:

``` text
oA[][7] → mA category → Damage / Range → projectile
```

Это существенно меняет предыдущую гипотезу.

### `mA` действительно загружается отдельным блоком

При загрузке `a`:

``` text
HG.D(InputStream) → qa
HG.B(InputStream) → aD
HG.C(InputStream) → bD
HG.B(InputStream) → mA
HG.B(InputStream) → nA
HG.B(InputStream) → oA
HG.E(InputStream) → pA
HG.E(InputStream) → qA
HG.B(InputStream) → rA
```

Фактическая структура:

``` text
mA : 45 × 19 int32
offset 7562
nA : 12 × 11 int32
offset 10986
oA : 12 × 9 int32
offset 11518
pA : 1 × variable × 3 int32
offset 11954
qA : 18 × variable × 2 int32
offset 12742
rA : 9 × 16 int32
offset 12984
```

## 9.8 Что на самом деле делает `oA[][7] → mA[][0]`

Связка существует, но она **не является доказанным weapon lookup**.

В `O()`:

``` text
oA[i][7]
	↓
перебор mA[j][0]
	↓
выбор строки mA[j]
	↓
использование mA[j][2]
```

Это используется в состоянии/UI строительства для отображения
категории/описания. Там нет создания projectile, damage payload или
range check.

Для 12 building records фактические category links:

  Building IDs           `oA[][7]`
  -------------------- -----------
  151, 153, 159, 171             1
  155, 157, 161, 173            13
  163, 165, 167, 169            15

`mA` содержит по три записи для каждой из этих категорий:

``` text
category 1  → mA rows 0..2
category 13 → mA rows 36..38
category 15 → mA rows 42..44
```

Это похоже на category/variant data, но **никакое поле этих строк не
потребляется `C.class` как tower Damage или Range**.

## 9.9 Единственный найденный building → enemy proximity pipeline

В `P()` есть реальный proximity check, который ранее легко принять за
tower targeting:

``` text
building state
	↓
выбор oA[2] / oA[11]
	↓
получение его packed position из oA[][4]
	↓
перебор lA[]
	↓
проверка координат lA[][17], lA[][18]
	↓
проверка lA[][13] flags
	↓
если enemy находится в зоне:
	lA[enemy][13] |= 16
```

Критически важно:

``` text
lA[enemy][13] |= 16
```

**не уменьшает `lA[enemy][22]`.**

В этой ветке отсутствуют:

``` text
Damage subtraction
rA[attacker][5..7]
projectile creation
range field lookup
fire-rate timer
oA[][7] → context-dependent effect parameter lookup
```

Следовательно, это proximity/collision/event state, а не tower attack.

## 9.10 Проверка hardcoded switch-case — CORRECTED

В `O()` действительно существует:

```text
switch(oA[i][0])
```

Но теперь доказано, что часть ветвей этого state/timer switch **сама
содержит combat effect**. Для `oA index 4` и `oA index 5` после истечения
timer выполняется прямое уменьшение `vA[][22]` на `oA[][7]`.

Поэтому корректная модель:

```text
oA[][8] timer/state
	  ↓
special building branch
	  ↓
area test
	  ↓
vA[][22] -= oA[][7]
```

## 9.11 Проверка `mA` в combat pipeline

`mA` действительно активно используется в `C.class`, но новый pass не
нашёл доказанного универсального `building → mA → turret weapon` lookup.
`mA` также участвует в upgrade/progression calculations, поэтому числовое
сходство его полей с Damage/Range недостаточно.

## 9.12 Текущий вердикт по 12 зданиям — после нового pass

Полного набора `Damage / Range / Fire Rate` для 151--173 пока нет.
Однако **четыре прямых damage values уже доказаны consumer-кодом**:

```text
ID 155 → Damage 125
ID 159 → Damage 800
ID 161 → Damage 1000
ID 173 → Damage 200
```

Остальные 8 building IDs требуют отдельного effect-path audit.

### Что доказано

```text
ID / resource mapping                 → ORIGINAL_CONFIRMED
Max HP / monetary UI field            → ORIGINAL_CONFIRMED
Static damage for 155/159/161/173    → ORIGINAL_CONFIRMED
Timer/state mechanism                 → ORIGINAL_CONFIRMED
Local damage-zone geometry            → PARTIAL / ORIGINAL_CONFIRMED

mA as universal turret weapon table  → NOT CONFIRMED
rA as building weapon table          → REJECTED
Universal building Range              → UNRESOLVED
Exact Fire Rate semantics             → UNRESOLVED
```

## 9.13 Следующая точка исследования

Искать **per-building effect consumers**, а не единую таблицу
`TurretStats`. В первую очередь:

```text
151 / 153 / 157 / 163 / 165 / 167 / 169 / 171
		↓
state/timer/special-effect callers
		↓
HP mutation / projectile / target selection
```

Параллельно продолжить `enemy spawn/type → nA row → Initial HP`.

## 9.14 Updated BuildingStats

	 ID   Max HP   Cost   Category   Damage   Range Status
  ----- -------- ------ ---------- -------- ------- -------------------------
	151    30000    300          1        ?       ? Damage/Range unresolved
	153    30000    500          1        ?       ? Damage/Range unresolved
	155    30000    750         13      125       ? Damage confirmed; effect radius=2
	157    15000    250         13        ?       ? Damage/Range unresolved
	159    30000    800          1        ?       ? Damage/Range unresolved
	161    60000   1000         13        ?       ? Damage/Range unresolved
	163    60000   1500         15        ?       ? Damage/Range unresolved
	165    90000   4000         15        ?       ? Damage/Range unresolved
	167    80000   2000         15        ?       ? Damage/Range unresolved
	169    50000   3000         15        ?       ? Damage/Range unresolved
	171   120000   5000          1        ?       ? Damage/Range unresolved
	173   100000   4000         13        ?       ? Damage/Range unresolved

### 9.24 NEW FORENSIC RESULT — STATIC DAMAGE CONSUMERS FOUND

**Статус: [Выполнено — частичное закрытие серой зоны]**

После анализа исходного `C.class` через реальный bytecode (а не только
по предыдущему call-site search) найдено несколько **прямых building →
enemy HP** цепочек. Это принципиально меняет статус static-building
combat: проблема не в отсутствии building damage вообще, а в том, что
разные здания используют разные special-effect paths.

### A. `oA[4]` / `oA[7]` → direct HP subtraction

В `O()` есть `switch(oA[i][0])`. Для отдельных building indices
активируется timer branch, после чего код вычисляет область вокруг
`ba/ca` и выполняет:

```text
vA[enemy][22] -= oA[building][7]
```

Это является **прямым consumer-proof для Damage**, потому что изменяется
именно runtime HP-поле `vA[][22]`.

Подтверждённые записи:

```text
oA index 4 → building ID 159 → oA[][7] = 800 → Damage = 800
oA index 5 → building ID 161 → oA[][7] = 1000 → Damage = 1000
```

Для этих двух веток `oA[][7]` больше нельзя описывать только как
«category link». Его значение **в данном consumer является damage
parameter**.

### B. `P()` → direct HP subtraction for building IDs 155 / 173

`P()` выбирает `oA[2]` или `oA[11]`, декодирует `oA[][4]` как два signed
16-bit компонента и затем в зоне вокруг building position выполняет:

```text
vA[enemy][22] -= low16(oA[][4])
```

Подтверждённые значения:

```text
ID 155 → oA[2][4] = 0x0002007D → low16 = 125 → Damage = 125; high16 = 2
ID 173 → oA[11][4] = 131272
	   → low16 = 200       → Damage = 200
```

При этом для ID 173 high16 = 2 участвует в размере зоны; для ID 155
high16 = 0. Поэтому `oA[][4]` нельзя объявлять универсальным
`Damage`-полем: его семантика здесь **packed special-effect parameter**.

### C. Геометрия зоны и Range

В найденных static-effect paths координаты цели проверяются относительно
`ba/ca` и границ, полученных из packed параметров `oA[][4]`. Это доказывает
существование **damage zone**, но не даёт универсального значения
`Turret Range` для всех 12 объектов.

Следовательно:

```text
Damage-zone existence → ORIGINAL_CONFIRMED
Range for ID 159/161 → частично задан геометрией branch
Range for ID 155/173 → частично задан geometry branch
Universal turret Range → UNRESOLVED
```

### D. Timer / fire interval

`F(int)` делает:

```text
oA[i][8] = oA[i][3]
```

а основной loop уменьшает `oA[][8]` на elapsed time `g`. Поэтому
`oA[][3]` — подтверждённый **timer seed / duration parameter**, а
`oA[][8]` — runtime countdown/state.

Для найденных damage branches:

```text
ID 159 → oA[][3] = 26
ID 161 → oA[][3] = 18
```

Но эти числа пока не следует автоматически называть `Fire Rate`: одна и
та же timer mechanism может обслуживать activation/effect duration.
Нужен дополнительный consumer audit, который докажет именно интервал
между двумя damage applications.

### E. Что теперь точно нельзя писать в roadmap

Старое утверждение:

```text
Building Damage → UNRESOLVED для всех 12
```

больше неверно. Корректная формулировка:

```text
Building Damage:
  ID 155 → 125     ORIGINAL_CONFIRMED
  ID 159 → 800     ORIGINAL_CONFIRMED
  ID 161 → 1000    ORIGINAL_CONFIRMED
  ID 173 → 200     ORIGINAL_CONFIRMED
  остальные IDs   → UNRESOLVED

Building Range:
  universal mapping → UNRESOLVED
  local damage-zone geometry → PARTIAL / ORIGINAL_CONFIRMED

Building Fire Rate:
  timer seed/path → ORIGINAL_CONFIRMED
  exact fire interval semantics → UNRESOLVED
```

## 9.25 `oA` FIELD SEMANTICS — CORRECTED

После нового pass прежнюю универсальную интерпретацию `oA[][7]` как
`category` необходимо снять. Consumer-код показывает, что это поле имеет
как минимум **context-dependent gameplay meaning** и для ID 159/161
является непосредственным Damage parameter.

Надёжно подтверждено:

```text
oA[][0] → internal building record index (0..11)
oA[][1] → localization/string key used by building UI
oA[][2] → building visual/resource ID used by rendering
oA[][3] → timer seed / duration used by F()
oA[][4] → packed special-effect parameter in multiple branches
oA[][6] → building Cost; monetary-value consumer confirmed in building UI
Building Max HP → confirmed separately by its own consumer; do not infer it
			 from the Cost field
oA[][7] → context-dependent gameplay/effect parameter; direct Damage
			consumer proven for IDs 159 and 161
oA[][8] → runtime building state/countdown
```

**Важно:** `oA[][6]` является стоимостью в building UI, тогда как
`oA[][7]` нельзя больше маркировать как универсальный `Category`.

## 9.26 `mA` / `nA` reclassification

Дополнительная проверка показала, что `mA` и `nA` активно участвуют в
upgrade/progression calculations. В частности:

```text
mA[][1] → upgrade level/variant selector
H()/G()/I()/D() → поиск записей mA по category + level
L(int,int) → суммирование mA[][6..8] для upgrade cost/effect UI
A(int[],int) / C(int[]) / D(int[]) → применение nA bonuses
```

Поэтому числовое сходство некоторых `mA` полей с Damage/Range больше не
может считаться основанием для `TurretStats`.

`nA[][4]` всё ещё присутствует в runtime HP initialization path, но
структура `nA` одновременно используется upgrade/progression logic;
точное отображение `nA row → enemy ID` не доказано.

# STEP 02 --- FINAL STATUS

**[Выполнено — полный call-site audit `B(IIIIIIIII)` завершён; отдельные building static-effect Damage доказаны, универсальные Range/Fire Rate и остальные building effects остаются UNRESOLVED]**

STEP 02 считается выполненным как **call-site audit**, но не как полное
восстановление всех 12 `Building/TurretStats`: часть building damage уже
доказана, универсальные Range/Fire Rate и остальные effect paths остаются
открытыми.

Критически важное новое доказательство:

``` text
There is no single universal static-tower weapon table in C.class;
multiple per-building effect consumers exist, including direct HP subtraction
for IDs 155/159/161/173.
```

Таким образом, следующий этап должен искать **effect/event/project
database**, а не продолжать подгонять поля `mA` под Damage/Range.

# PHASE 9 FINAL ADDENDUM --- pA / qA / nA / vb / pb / rb TRACE

## 9.15 Deserialization map

The `C.BB(1)` loader reads `/a` in this exact order:

``` text
HG.D(InputStream) → qa
HG.B(InputStream) → aD
HG.C(InputStream) → bD
HG.B(InputStream) → mA
HG.B(InputStream) → nA
HG.B(InputStream) → oA
HG.E(InputStream) → pA
HG.E(InputStream) → qA
HG.B(InputStream) → rA
```

The relevant binary block boundaries in `a` are:

  Array   Loader       Offset Shape
  ------- ---------- -------- ---------------------------
  `nA`    `HG.B()`      10986 `12 × 11 int32`
  `oA`    `HG.B()`      11518 `12 × 9 int32`
  `pA`    `HG.E()`      11954 `1 × 65 × 3 int32`
  `qA`    `HG.E()`      12742 `18 × variable × 2 int32`
  `rA`    `HG.B()`      12984 `9 × 16 int32`

There is **no second hidden weapon table loaded by `HG.C()` or `HG.D()`
after `mA/nA/oA`**. `HG.D()` is used for the initial `qa` block and
`HG.C()` for `bD`.

## 9.16 Runtime arrays `vb`, `pb`, `rb`

These are **not loaded from `a`**.

They are allocated in `C.class`'s static initializer:

``` java
pb = new int[200][4];
rb = new int[80][21];
vb = new int[14][2];
```

Therefore:

``` text
vb → runtime 14×2 state table
pb → runtime 200×4 projectile/effect pool
rb → runtime 80×21 attack/projectile state pool
```

The three arrays are runtime structures, not balance-data sources.

## 9.17 Exact consumer of `rb`

The nine-argument method:

``` java
B(int,int,int,int,int,int,int,int,int)
```

allocates a free `rb` slot and writes its arguments directly:

``` text
rb[][0]  = arg0
rb[][1]  = arg1

rb[][5]  = arg2
rb[][6]  = arg3
rb[][7]  = arg5
rb[][8]  = arg6
rb[][9]  = arg7
rb[][10] = arg8
```

The fourth/fifth argument positions are used by the method's later
projectile-type/target logic; they are not read from `nA`, `pA`, or
`qA`.

This proves:

``` text
B(...) does NOT look up tower damage from a database.
The caller supplies the damage payload.
```

`rb` is therefore the correct runtime consumer for projectile state, but
**not the source of tower balance parameters**.

## 9.18 Where `rA` enters the projectile pipeline

The enemy/unit attack creation path `Z(int)` uses the attacker runtime
record:

``` text
vA[attacker][3] → rA row
```

and reads multiple `rA` fields while constructing the attack state.

The direct projectile creation call is:

``` text
B(...)
```

and the created state is stored in `rb`.

The separate `SA(int)` path also ends in:

``` text
B(targetX, targetY, damage..., ...)
```

but its payload is derived from `mA` fields belonging to the attacking
unit archetype.

Thus the general architecture is:

``` text
balance table (rA / mA)
		↓
attack constructor
		↓
B(...)
		↓
rb[projectile]
		↓
M(...)
		↓
damage resolution
		↓
lA[target][22]
```

## 9.19 Important correction: `B(...)` has no intrinsic tower lookup

The requested hypothesis:

``` text
B(...)
	↓
tower type
	↓
nA / pA / qA
	↓
Damage + Range
```

is not present.

The nine-argument `B` method is a **generic runtime projectile
constructor**. It accepts already-resolved values.

Consequently, searching `B` itself for tower Damage/Range produces the
wrong layer of the architecture.

The relevant question becomes:

``` text
Which caller constructs a tower attack and supplies
the arguments to B(...)?
```

A complete call-site audit found only the following direct nine-argument
call paths:

``` text
A(int,int,int,int,int,int,int,int,int)
		↓
B(...)

Z(int)
		↓
B(...)

SA(int)
		↓
B(...)
```

`Z()` is the enemy/unit path using `rA`.

`SA()` is another unit/archetype attack path using `mA`.

No call path from:

``` text
oA → tower type → B(...)
```

was found.

## 9.20 `nA` consumer audit

`nA` is definitely a gameplay data table, but its demonstrated consumer
is **entity initialization/state**, not tower weapon lookup.

In:

``` java
B(int, boolean)
```

the code does:

``` text
lA[entity][9]
	  ↓
nA[index]
```

and uses:

``` text
nA[index][0]
nA[index][1]
nA[index][4]
```

among other fields.

Most importantly:

``` text
nA[index][4]
	  ↓
lA[entity][22]
```

This is an HP initialization path.

Therefore `nA[][4]` must not be re-labelled as tower Damage merely
because some values look weapon-like.

The table has 12 rows, but **row count alone does not establish a
one-to-one mapping with the 12 `oA` building IDs**. The actual consumer
uses an `lA[][9]` index.

## 9.21 `pA` and `qA` audit

`pA`:

``` text
offset 11954
1 × 65 × 3
```

Its direct accessor is:

``` java
G(int) → pA[0][index]
```

This is a lookup table and is not consumed by the projectile
constructor.

`qA`:

``` text
offset 12742
18 groups
variable number of 2-int records
```

Its consumers are in the `JA()` / related progression/state code. The
structure is used for map/progression unlock relationships.

No `qA` field is passed to `B(...)` as a tower damage/range payload.

Therefore:

``` text
pA → NOT tower weapon database
qA → NOT tower weapon database
```

## 9.22 Final status of the three candidate data sources

``` text
nA → gameplay/entity initialization data; no proven tower Damage/Range consumer
pA → lookup/progression data; no projectile Damage/Range consumer
qA → progression/state relation data; no projectile Damage/Range consumer
```

And for runtime:

``` text
vb → runtime state pool
pb → runtime projectile/effect pool
rb → runtime attack/projectile pool
```

None of `vb/pb/rb` is a balance-data source.

## 9.23 STEP 02 --- FINAL FORENSIC STATUS

**\[Partially completed --- enemy combat matrix confirmed; original 12
building Damage/Range remain unresolved\]**

The additional target set does **not** reveal a hidden tower weapon
table.

The strongest architecture-level conclusion is now:

``` text
rA → enemy/unit attack balance
mA → unit/archetype/category data
nA → entity initialization/gameplay data
pA/qA → lookup/progression structures
vb/pb/rb → runtime state pools
```

The generic projectile constructor:

``` text
B(...)
```

does not perform a tower-type lookup. It receives already-resolved
values.

Therefore the following must remain unresolved:

``` text
Building 151 → Damage ?
Building 151 → Range  ?

...

Building 173 → Damage ?
Building 173 → Range ?
```

No values are inserted into the roadmap as "confirmed" without a
consumer proving their semantics.

### Next forensic target

The remaining search should move one layer **above** `B(...)` and trace
any non-direct/static attack mechanism:

``` text
oA building state
	↓
timer / trigger / event
	↓
direct lA damage
	OR
generic B(...) call
	OR
effect-area consumer
```

The next candidates are the callers/state transitions around:

``` text
O()
P()
M()
GA()
DA()
HA()
MA()
EA()
```

with special attention to writes involving:

``` text
lA[][13]   flags
lA[][14]   attacker/target state
lA[][22]   HP
lA[][23]   projectile/effect reference
oA[][8]    building state/timer
```

**Do not hardcode `nA[][4]`, `mA` fields, or any `pA/qA` values as tower
Damage/Range until such a consumer is found.**


# PHASE 31 — FORENSIC BALANCE AUDIT v4 (2026-09-22)

## 31.1 Цель

Проведён повторный forensic-pass по `C.class`, `HG.class`, `A.class`,
`B.class` и бинарному `a` с целью закрыть оставшиеся серые зоны:

- Enemy Initial HP;
- Turret / static-building Damage;
- Turret / static-building Range;
- Turret / static-building Fire Rate;
- неизвестные поля `oA`;
- `pA/qA` как возможный источник combat parameters;
- связь `nA` с EnemyStats.

Главный принцип этого pass: числовое совпадение само по себе не считается
доказательством семантики; требуется consumer/runtime chain.

## 31.2 Enemy Initial HP — результат

### Подтверждён runtime initialization path

Метод `C.B(int, boolean)` делает следующее:

```text
lA[entity][9]
	↓
C.nA[lA[entity][9]]
	↓
nA[row][4]
	↓
lA[entity][22]
```

Поле `lA[][22]` действительно является packed runtime HP state.
При инициализации `nA[row][4]` записывается в его HP-компонент.

### Но `nA[][4]` НЕ является доказанной таблицей EnemyStats HP

Бинарный блок `nA` имеет структуру:

```text
12 × 11 × int32
offset 10986
```

и содержит packed values. Например:

```text
nA[0][4] = 983108 = 0x000F0044
nA[1][4] = 983108 = 0x000F0044
nA[2][4] = 983108 = 0x000F0044
nA[3][4] = 1441792 = 0x00160000
nA[6][4] = 1507328 = 0x00170000
nA[9][4] = 1310720 = 0x00140000
```

Runtime код извлекает компоненту из этого packed значения; следовательно,
само наличие `nA[][4]` в HP initialization path не доказывает, что 12 строк
`nA` — это девять EnemyStats по ID 70–78.

### Статус

```text
Enemy runtime HP field       → ORIGINAL_CONFIRMED
nA → runtime HP initialization → ORIGINAL_CONFIRMED
nA row → enemy ID 70..78        → NOT PROVEN
EnemyStats Initial HP 70..78    → UNRESOLVED
```

Следующая задача для HP: восстановить exact mapping `spawn definition →
enemy ID → nA row` либо найти другой source of truth, из которого
`lA[][9]` получает тип врага.

## 31.3 Turret / static-building combat — дополнительный audit

Проведена отдельная проверка consumers:

```text
mA
nA
pA
qA
oA
rA
```

и цепочек, вызываемых из building/map logic.

### `oA`

После нового pass семантика `oA` должна описываться context-dependent:

```text
oA[][0] → internal record index
oA[][1] → localization key
oA[][2] → building/resource ID
oA[][3] → timer seed / duration
oA[][4] → packed special-effect parameter
oA[][6] → Cost / monetary UI value; Max HP is oA[][3] in the building record
oA[][7] → gameplay/effect parameter; direct Damage proven for 159/161
oA[][8] → runtime state/countdown
```

Для прямых consumers подтверждено:

```text
ID 155 → oA[2][4] = 0x0002007D → low16 = 125 → Damage 125; high16 = 2
ID 159 → oA[][7] = 800            → Damage 800
ID 161 → oA[][7] = 1000           → Damage 1000
ID 173 → low16(oA[][4]) = 200     → Damage 200
```

Следовательно, прежняя универсальная маркировка `oA[][7] = category`
снята.

### `oA → mA`

Связка/lookup в UI/debug-коде существует, но новый pass не подтверждает
её как универсальный weapon database. `mA` также участвует в
upgrade/progression logic.

### `pA`

`pA` используется в map/grid rendering logic. В найденном consumer нет
цепочки, которая извлекает из `pA` damage, range или fire interval.

### `qA`

`qA` используется как таблица условий/требований, связанных с `mA` и
map/progression availability. Найденный consumer перебирает пары
`qA[][0..1]` и проверяет состояние карты/разблокировки. Это не является
weapon consumer.

### `rA`

`rA` остаётся доказанной таблицей **enemy combat profiles**, а не static-
turret database.

### Статус turret/static-building parameters

```text
Building Damage:
  155 → 1       ORIGINAL_CONFIRMED
  159 → 800     ORIGINAL_CONFIRMED
  161 → 1000    ORIGINAL_CONFIRMED
  173 → 200     ORIGINAL_CONFIRMED
  остальные    UNRESOLVED

Building Range      → PARTIAL / universal mapping UNRESOLVED
Building Fire Rate  → timer path confirmed; exact fire interval UNRESOLVED
```

Важно: значения `mA` с числами, похожими на damage/range/cost/cooldown,
нельзя переносить в `TurretStats` без отдельного consumer-доказательства.

## 31.4 Поля `oA` — что осталось

Для `oA : 12 × 9 int32` после нового pass подтверждено:

```text
oA[][0] → internal record index
oA[][1] → localization key
oA[][2] → building/resource ID
oA[][3] → timer seed / duration
oA[][4] → packed special-effect parameter (context-dependent)
oA[][6] → Cost / monetary UI value
oA[][7] → context-dependent gameplay/effect parameter
oA[][8] → runtime state/countdown
```

`oA[][5]` пока остаётся без полной семантики.

Статус полного `BuildingStats`:

```text
ID / Max HP / Cost → ORIGINAL_CONFIRMED
Damage             → PARTIAL (4 IDs confirmed)
Timer path         → ORIGINAL_CONFIRMED
Range              → PARTIAL / UNRESOLVED
Fire Rate          → UNRESOLVED as exact semantic
oA[][4]/[][5]/[][7] universal semantics → PARTIAL / UNRESOLVED
```

## 31.5 Исправление предыдущей гипотезы

Предыдущая гипотеза:

```text
nA[][4] = Enemy Initial HP table
```

снята.

Корректная формулировка:

```text
nA[][4]
   ↓
runtime initialization of lA[][22]
```

но exact semantic mapping `nA row → enemy type/ID` пока отсутствует.

## 31.6 Текущий forensic backlog

### BLOCKER A — Enemy Initial HP

Найти:

```text
lA[][5] / lA[][9]
		↓
source of enemy type
		↓
Enemy ID 70..78
		↓
corresponding nA row or independent HP source
```

### BLOCKER B — Static Turret Combat

Искать не только в `oA/mA`, но также:

```text
projectile/effect state
static trigger/event tables
map scripts
hardcoded constants
methods that mutate lA[][22] while originating from building state
```

Особенно проверять consumers вокруг:

```text
pA
qA
nA
mA
```

которые ещё не имеют полностью восстановленной семантики.

### SECONDARY — Remaining `oA` fields

После blockers A/B восстановить remaining building fields и проверить,
не являются ли некоторые из них размером, радиусом, временем или
production parameter.

# CURRENT BALANCE STATUS — v4

| Область | Статус |
|---|---|
| Enemy ID | ORIGINAL_CONFIRMED |
| Enemy Damage | ORIGINAL_CONFIRMED |
| Enemy Range | ORIGINAL_CONFIRMED |
| Enemy resistances | ORIGINAL_CONFIRMED |
| Enemy reward-related value | ORIGINAL_CONFIRMED / context-dependent |
| Enemy speed | ORIGINAL_CONFIRMED |
| Enemy Initial HP | **UNRESOLVED** |
| Building ID | ORIGINAL_CONFIRMED |
| Building Max HP | ORIGINAL_CONFIRMED |
| Building Cost | ORIGINAL_CONFIRMED |
| Building Category | **REMOVED — not universally proven** |
| Building Damage (IDs 155/159/161/173) | ORIGINAL_CONFIRMED |
| Building Damage (remaining IDs) | **UNRESOLVED** |
| Building Range | PARTIAL / **UNRESOLVED universally** |
| Building Fire Rate | timer path confirmed / exact semantic **UNRESOLVED** |
| Remaining Building fields | PARTIAL / UNRESOLVED |
| `pA/qA` as turret combat source | NOT CONFIRMED |

## 31.7 Updated forensic verdict

```text
STEP 02 call-site audit                    → COMPLETED
Enemy Damage / Range                      → CONFIRMED
Enemy Initial HP                          → UNRESOLVED
Static damage consumer                    → PARTIALLY FOUND
Static damage IDs 155/159/161/173         → CONFIRMED
Universal static Range                    → UNRESOLVED
Static timer mechanism                    → CONFIRMED
Exact Fire Rate semantics                 → UNRESOLVED
mA/nA as generic turret database         → REJECTED
```

Новый принцип для дальнейшего анализа: искать не «таблицу TurretStats»
как единый блок, а **per-building effect consumer**. Оригинальная игра
использует несколько разных runtime paths для разных строительных
объектов.

# NEXT REQUIRED STEP

Не считать forensic balance полностью завершённым.

Следующая обязательная задача:

> **Закрыть оставшиеся building combat paths: найти consumers для ID
> 151/153/157/163/165/167/169/171, доказать универсальную Range и exact
> Fire Rate, а параллельно восстановить mapping `enemy spawn/type → nA row`
> для Initial HP.**


------------------------------------------------------------------------

# GODOT SCENE-FIRST VALIDATION CHECKLIST

Перед каждой production-фазой Godot:

```text
[ ] Units are editable scenes
[ ] Buildings are editable scenes
[ ] Map is an editable scene
[ ] Grid markers are editable
[ ] Collision is editable in scenes
[ ] Attack points are editable
[ ] Spawn points are editable
[ ] Cameras are editable
[ ] UI is authored as scenes
[ ] VFX are authored as scenes

[ ] Pathfinding is code-only
[ ] AI state logic is code-only
[ ] Damage calculation is code-only
[ ] Wave scheduling is code-only
[ ] Save/load is code-only
[ ] Global managers are code-only
```

**SCENE-FIRST является обязательным архитектурным правилом и применяется
ко всем последующим Godot-фазам roadmap.**


# PHASE 32 — FORENSIC BALANCE AUDIT v5 / FINAL PASS ON CURRENT ARCHIVE (2026-09-22)

## 32.1 Scope

**Supersession rule:** conclusions in this phase supersede earlier intermediate forensic notes where they conflict. Earlier sections are retained as audit history.

Проведён дополнительный bytecode + binary pass непосредственно по текущему
архиву `sturmtrupp_mars.zip`:

```text
C.class
HG.class
A.class
B.class
a
roadmap_v6.md
```

Целью было не повторить уже подтверждённое, а проверить, есть ли новые
доказательства для оставшихся серых зон:

```text
Enemy Initial HP
Building/static Damage
Building/static Range
Building Fire Rate
oA[][5]
nA row → enemy ID mapping
```

## 32.2 Новое подтверждение: точный raw decode `oA`

Бинарный блок:

```text
offset 11518
12 × 9 int32
```

повторно декодирован напрямую из `a`.

Для четырёх найденных static-effect consumers важны значения:

```text
ID 155 → oA[2][4]  = 0x0002007D
		  high16    = 2
		  low16     = 125

ID 159 → oA[4][4]  = 0
		  oA[4][7]  = 800

ID 161 → oA[5][4]  = 0x00020001
		  high16    = 2
		  oA[5][7]  = 1000

ID 173 → oA[11][4] = 0x000200C8
		  high16    = 2
		  low16     = 200
```

### Важное исправление roadmap

Предыдущее значение:

```text
ID 155 → Damage = 1
```

было ошибочным.

Bytecode `P()` не получает `1`; он берёт:

```text
low16(oA[2][4])
```

а raw value равен:

```text
0x0002007D = 125 + (2 << 16)
```

Следовательно:

```text
ID 155 → Damage = 125 ORIGINAL_CONFIRMED
```

Это исправление теперь считается официальной частью roadmap.

## 32.3 Static-effect geometry — теперь доказан exact effect radius

`O()` и `P()` декодируют high16 `oA[][4]` как радиус по tile/grid
координатам.

`HG.A(int,int,int)` имеет строгую семантику:

```text
value >= lower && value < upper
```

Поэтому проверка:

```text
x ∈ [center-radius, center+radius+1)
y ∈ [center-radius, center+radius+1)
```

даёт:

```text
radius 0 → 1 × 1 tile effect area
radius 2 → 5 × 5 tile effect area
```

Подтверждено:

```text
ID 155 → radius 2 → 5×5 effect area → Damage 125
ID 159 → radius 0 → 1×1 effect area → Damage 800
ID 161 → radius 2 → 5×5 effect area → Damage 1000
ID 173 → radius 2 → 5×5 effect area → Damage 200
```

### Статус

Это **не следует переименовывать в универсальный turret Range**.

Корректная семантика:

```text
Static-effect Damage Zone → ORIGINAL_CONFIRMED
Effect radius / area       → ORIGINAL_CONFIRMED для этих 4 consumers
Universal turret Range     → UNRESOLVED
```

То есть мы закрыли важную часть geometry gray zone, но не доказали
дальность обычных автоматических башен.

## 32.4 Fire Rate — exact semantics остаётся unresolved

Для `oA` runtime timer:

```text
F(int):
	oA[index][8] = oA[index][3]

run():
	g = currentTimeMillis - previousTime
	if g < 100 ms:
		sleep(100-g)
	g = 100 ms
```

Следовательно:

```text
g → milliseconds
oA[][8] → runtime countdown
```

Для найденных static-effect branches:

```text
ID 159 → seed 26
ID 161 → seed 18
```

Но `oA[][3]` одновременно является building balance field `Max HP`
и после deployment используется как timer seed, поэтому эти значения нельзя объявлять
`Fire Rate = 26 ms / 18 ms`.

**Статус:**

```text
timer mechanism       → ORIGINAL_CONFIRMED
millisecond timebase  → ORIGINAL_CONFIRMED
exact Fire Rate       → UNRESOLVED
```

## 32.5 Enemy Initial HP — новый результат: nA не является EnemyStats

Raw decode `nA`:

```text
offset 10986
12 × 11 int32
```

показывает структурированные группы:

```text
rows 0..2  → group/category 0
rows 3..5  → group/category 2
rows 6..8  → group/category 4
rows 9..11 → group/category 6
```

с тремя вариантами внутри каждой группы.

Это хорошо согласуется с upgrade/progression structure, а не с девятью
enemy records:

```text
nA row count = 12
enemy ID count = 9
```

Runtime действительно делает:

```text
lA[entity][9]
	↓
nA[row]
	↓
nA[row][4]
	↓
lA[entity][22] HP component
```

Но это не доказывает:

```text
Enemy ID 70 → nA row X
...
Enemy ID 78 → nA row Y
```

На текущем bytecode mapping `enemy spawn/type → nA row` не найден.

### Статус

```text
Runtime HP field             → ORIGINAL_CONFIRMED
nA → runtime HP initialization → ORIGINAL_CONFIRMED
nA → EnemyStats table          → REJECTED
Enemy Initial HP 70..78       → UNRESOLVED
```

Это важное отрицательное forensic-решение: `nA[][4]` больше нельзя
использовать как таблицу HP жуков.

## 32.6 Building Damage — current exact status

```text
ID 155 → 125  ORIGINAL_CONFIRMED
ID 159 → 800  ORIGINAL_CONFIRMED
ID 161 → 1000 ORIGINAL_CONFIRMED
ID 173 → 200  ORIGINAL_CONFIRMED
```

Для остальных building IDs:

```text
151 → unresolved
153 → unresolved
157 → unresolved
163 → unresolved / not a conventional building
165 → unresolved
167 → unresolved
169 → unresolved
171 → unresolved
```

Важно: `163 = Soldiers` не следует смешивать с building turret table.

## 32.7 `oA[][5]`

Прямого consumer, который однозначно даёт семантику `oA[][5]`, в
текущем audit не найдено.

```text
oA[][5] → UNRESOLVED
```

Не присваивать ему `Range`, `Fire Rate`, `Splash`, `Build Time` или иной
параметр без consumer-proof.

## 32.8 What is now closed vs what remains

### CLOSED

```text
HG deserialization order
binary offsets / shapes
Enemy ID
Enemy Damage
Enemy Range
Enemy resistances
Enemy speed
Building ID
Building Max HP
Building Cost
Static Damage for 155/159/161/173
Static effect radius for 155/159/161/173
Static timer mechanism
```

### REMAINING REAL GRAY ZONES

```text
1. Enemy Initial HP 70..78
2. Conventional turret Damage for 153/157/167
3. Conventional turret Range
4. Conventional turret Fire Rate
5. Remaining special/static building Damage
6. oA[][5] semantic
7. Production/build-time/upgrade parameters if present
```

## 32.9 Research order after v5

Не продолжать бесконечный поиск «универсальной TurretStats table».

Следующий forensic order:

```text
1. Enemy spawn/type → exact Enemy ID → Initial HP source
2. Trace conventional turret runtime path for:
	   153 Fire Tower
	   157 Laser Tower
	   167 Plasma Tower
3. Search hardcoded/static event consumers for their attacks
4. Determine whether Range/Fire Rate are code constants or absent
5. Audit oA[][5]
6. Audit production/build-time/upgrade consumers
```

Если шаги 1–4 не дают consumer-proof, это следует зафиксировать как
архитектурно доказанный absence/unknown, а не заполнять числами
по аналогии.

## 32.10 Final forensic rule

```text
Numeric coincidence ≠ original balance confirmation.

Only:
source → consumer → runtime effect
```

даёт `ORIGINAL_CONFIRMED`.

Это правило остаётся обязательным для переноса баланса в Godot.


------------------------------------------------------------------------

# PHASE 33 --- FORENSIC BALANCE AUDIT v6

**Дата:** 2026-09-22

Цель pass: продолжить исследование после Phase 32, не переиспользуя
неподтверждённые гипотезы. В этом pass дополнительно проверены:

```text
C.B(int, boolean)
C.B(int,int,int,int,int)
C.B(int,int,int,int,int,int,int,int,int)
C.A(int,int)
C.M()
C.SA(int)
C.Y(int,int)
```

а также raw `a` для `nA` и `rA`.

Главный результат: найдено несколько важных consumer-level связей,
которые уточняют боевой pipeline, но не позволяют искусственно закрыть
оставшиеся universal Turret Range / Fire Rate.

## 33.1 Enemy Initial HP — runtime chain окончательно подтверждён

Метод:

```text
C.B(int, boolean)
```

делает:

```text
lA[entity][9]
	  ↓
C.nA[lA[entity][9]]
	  ↓
nA[row][4]
	  ↓
low/high packed HP component
	  ↓
lA[entity][22]
```

При этом `lA[][22]` затем используется как runtime HP state и реально
уменьшается damage consumers.

Это закрывает именно **mechanical initialization chain**.

Но источник значения `lA[][9]` остаётся отдельным вопросом. Найденный
метод `J(int,int,int)` может присваивать:

```text
lA[entity][9] = arg2
```

после проверки состояния объекта, однако call-sites этого метода не дают
доказанного универсального соответствия:

```text
Enemy ID 70..78 → nA row
```

Следовательно:

```text
Runtime HP initialization       → ORIGINAL_CONFIRMED
nA[row][4] → runtime HP         → ORIGINAL_CONFIRMED
nA row → Enemy ID 70..78        → UNRESOLVED
Initial HP table 70..78         → UNRESOLVED
```

### Важное forensic-решение

Raw `nA`:

```text
offset 10986
12 × 11 int32
```

имеет четыре группы по три строки:

```text
0..2
3..5
6..8
9..11
```

и не является прямой таблицей из девяти enemy records.

Нельзя переносить `nA[][4]` в Godot как `EnemyStats.HP[70..78]` без
дополнительного mapping proof.

## 33.2 `rA` — точная связь row → Enemy ID подтверждена

Raw `rA`:

```text
offset 12984
9 × 16 int32
```

получает следующие значения по column `[4]`:

```text
rA[0][4] = 75
rA[1][4] = 74
rA[2][4] = 72
rA[3][4] = 77
rA[4][4] = 73
rA[5][4] = 76
rA[6][4] = 71
rA[7][4] = 70
rA[8][4] = 78
```

Следовательно, `rA` действительно содержит ровно девять combat profiles,
соответствующих enemy IDs:

```text
70..78
```

Это существенно отличается от `nA` и подтверждает, что `rA` —
enemy-combat profile table, тогда как `nA` нельзя автоматически считать
EnemyStats HP table.

## 33.3 Projectile damage consumer — найден полный runtime consumer

Метод:

```text
C.M()
```

обрабатывает projectile pool `rb`.

При попадании projectile type `1` выполняется:

```text
rb[10] → target lA entity
rb[8]  → projectile/source runtime entity
```

и затем:

```text
A(rb[10], rb[8])
```

определяет фактический damage с учётом target combat parameters.

После этого damage применяется непосредственно к:

```text
lA[target][22]
```

через subtraction path.

Таким образом теперь доказана полная runtime chain:

```text
projectile
   ↓
projectile/source profile
   ↓
C.A(int,int)
   ↓
damage calculation
   ↓
C.M()
   ↓
lA[target][22] -= damage
```

## 33.4 `C.A(int,int)` — damage calculation использует `rA` columns 5/6/7

В `C.A(int,int)`:

```text
lA[target][1]
lA[target][2]
lA[target][3]
```

используются как три target-side factors.

Затем выбирается:

```text
rA[lA[projectile/source][3]]
```

и используются:

```text
rA[][5]
rA[][6]
rA[][7]
```

После процентного расчёта и округления результат складывается в итоговый
damage.

Это дополнительно подтверждает, что `rA[][5..7]` являются боевыми
параметрами damage/resistance calculation, а не произвольными UI fields.

Важно: это **не означает**, что `rA[][5]`, `rA[][6]`, `rA[][7]` можно
переименовать в три независимых типа урона без дальнейшего semantic proof.
Они участвуют в одной формуле damage calculation.

## 33.5 Projectile creation — `B(int,int,int,int,int)`

Найден consumer:

```text
C.B(int,int,int,int,int)
```

Он создаёт runtime projectile в `vA` и устанавливает:

```text
vA[][21] = k[rA[type][2]]
vA[][22] = rA[type][4] + source_parameter * 3
```

То есть `rA[][4]` непосредственно попадает в projectile runtime state,
но это поле не следует автоматически называть final Damage: финальный
урон рассчитывается отдельным consumer `C.A(int,int)`.

Это важное различие между:

```text
projectile payload/state
```

и:

```text
final applied damage
```

## 33.6 Conventional attack path — consumer найден, но он не доказывает
universal turret stats

Метод:

```text
C.SA(int)
```

строит projectile через:

```text
C.B(int,int,int,int,int,int,int,int,int)
```

и получает weapon-related parameter из:

```text
mA[entityType][16]
```

который затем участвует в выборе `rA` profile.

Однако call-site `SA(int)` находится внутри общего runtime attack logic,
где атакующий объект определяется через `lA` / `vA` и `mA` type checks.

На текущем доказательстве это позволяет сказать:

```text
unit/entity attack → projectile → rA → damage consumer
```

но ещё не позволяет сказать:

```text
building ID 153/157/167 → конкретный rA weapon row
```

Поэтому universal turret Damage остаётся unresolved.

## 33.7 `Fire Rate` — важное уточнение

В `C.SA(int)` перед созданием projectile обновляется:

```text
lA[entity][19] += mA[type][15]
```

Это показывает, что `mA[][15]` участвует в attack timing/state progression.

Но это значение не доказано как универсальный `Fire Rate` в миллисекундах:
оно является частью runtime attack-state logic и зависит от entity type.

Следовательно:

```text
attack timer mechanism        → ORIGINAL_CONFIRMED
mA[][15] as timing input      → ORIGINAL_CONFIRMED
exact turret Fire Rate        → UNRESOLVED
```

## 33.8 Static building effects — universal turret table всё ещё не найдена

Предыдущие exact confirmations сохраняются:

```text
ID 155 → Damage 125
ID 159 → Damage 800
ID 161 → Damage 1000
ID 173 → Damage 200
```

и их static-effect radii:

```text
155 → radius 2
159 → radius 0
161 → radius 2
173 → radius 2
```

Эти radius values относятся именно к найденным static-effect consumers.
Они не объявляются универсальным `Turret Range`.

## 33.9 `oA[][5]` — всё ещё не доказан

Новый pass не нашёл consumer, который однозначно связывает:

```text
oA[][5]
```

с:

```text
Damage
Range
Fire Rate
Build Time
Splash
Production
```

Статус сохраняется:

```text
oA[][5] → UNRESOLVED
```

## 33.10 Updated gray-zone classification

### 🔴 Обязательно продолжить

```text
1. Enemy ID 70..78 → exact Initial HP source
2. Building IDs 153/157/167 → exact attack consumer
3. Conventional building Range
4. Conventional building Fire Rate
```

### 🟠 Имеет смысл исследовать

```text
5. Remaining building Damage
6. oA[][5]
7. Remaining rA columns
8. mA[][15] / mA[][16] mapping for building entities
```

### 🟡 Вторичный audit

```text
9. Build time
10. Production cooldown
11. Prerequisites / upgrades
12. ID → localization/resource mapping
```

## 33.11 Current balance status — v6

| Parameter | Status |
|---|---|
| Enemy ID 70..78 | ORIGINAL_CONFIRMED |
| `rA` row → Enemy ID | ORIGINAL_CONFIRMED |
| Enemy Damage | ORIGINAL_CONFIRMED |
| Enemy Range | ORIGINAL_CONFIRMED |
| Enemy resistances | ORIGINAL_CONFIRMED |
| Enemy speed | ORIGINAL_CONFIRMED |
| Enemy runtime HP field | ORIGINAL_CONFIRMED |
| `nA` → runtime HP initialization | ORIGINAL_CONFIRMED |
| `nA` row → Enemy ID | **UNRESOLVED** |
| Enemy Initial HP 70..78 | **UNRESOLVED** |
| Building ID | ORIGINAL_CONFIRMED |
| Building Max HP | ORIGINAL_CONFIRMED |
| Building Cost | ORIGINAL_CONFIRMED |
| Building Damage 155 | ORIGINAL_CONFIRMED = 125 |
| Building Damage 159 | ORIGINAL_CONFIRMED = 800 |
| Building Damage 161 | ORIGINAL_CONFIRMED = 1000 |
| Building Damage 173 | ORIGINAL_CONFIRMED = 200 |
| Other building Damage | **UNRESOLVED** |
| Static effect radius for confirmed IDs | ORIGINAL_CONFIRMED |
| Universal Building Range | **UNRESOLVED** |
| Attack timer mechanism | ORIGINAL_CONFIRMED |
| Exact Building Fire Rate | **UNRESOLVED** |
| `oA[][5]` | **UNRESOLVED** |
| `rA[][5..7]` in damage formula | ORIGINAL_CONFIRMED as damage-formula inputs |
| Universal TurretStats table | **NOT FOUND / NOT PROVEN** |

## 33.12 Next required step

Следующий pass должен быть направлен не на повторный аудит уже закрытого
projectile pipeline, а на поиск **building-specific caller**.

Приоритет:

```text
building entity
	  ↓
its mA type / runtime state
	  ↓
attack trigger
	  ↓
SA / B(9 args) or alternative static consumer
	  ↓
weapon/profile selection
	  ↓
rA row / hardcoded parameter
```

Отдельно продолжить:

```text
spawn/event source
	  ↓
lA[][9]
	  ↓
nA row
	  ↓
Initial HP
```

Если для конкретного building ID consumer не существует, это должно быть
зафиксировано как доказанный отдельный runtime path, а не заменено
аналогией с другой башней.

## 33.13 Forensic conclusion

Phase 33 существенно сузил серую зону:

```text
Projectile creation       → CONFIRMED
Projectile hit processing → CONFIRMED
Damage application         → CONFIRMED
rA combat-profile usage   → CONFIRMED
Enemy rA row ↔ ID         → CONFIRMED
Enemy Initial HP mapping  → STILL OPEN
Universal turret mapping  → STILL OPEN
```

Ключевой принцип остаётся неизменным:

```text
numeric coincidence ≠ ORIGINAL_CONFIRMED

source
  ↓
consumer
  ↓
runtime effect
```

Только замкнутая цепочка получает статус `ORIGINAL_CONFIRMED`.

---

# PHASE 34 — FORENSIC BALANCE AUDIT v7

**Дата:** 2026-09-22

## 34.1 Critical correction: `oA[][4]` consumers are not universal turret Damage

Новый pass по `C.class` позволил замкнуть ещё одну важную цепочку.

`oA[][4]` действительно участвует в непосредственном уменьшении runtime HP:

```text
O() / P()
  ↓
oA[row][4]
  ↓
lA / vA[][22] -= value
```

Но контекст consumer-а имеет принципиальное значение.

В `P()`:

```text
oA[2][4] = 0x0002007D
			 high16 = 2
			 low16  = 125

oA[11][4] = 0x000200C8
			  high16 = 2
			  low16  = 200
```

`P()` вызывается из ветки дополнительного действия, а не из обычного
building attack loop. Он выбирает прямоугольную область вокруг текущей
позиции и уменьшает `vA[][22]` у сущностей внутри неё.

Следовательно:

```text
125 / 200
→ ORIGINAL_CONFIRMED как damage values данного special-action/effect path
→ НЕ доказаны как turret Damage
```

Это исправляет более раннюю ошибочную маркировку:

```text
ID 155 → Damage 125
ID 173 → Damage 200
```

как universal/static turret Damage.

Они должны оставаться в forensic разделе как **special-action damage**,
а не как `TurretStats`.

## 34.2 `oA[][8]` — runtime state/countdown, а не balance stat

В `O()`, `F()`, `P()`, `Q()`, `R()` поле:

```text
oA[row][8]
```

не читается как постоянная характеристика здания. Оно сравнивается с
`g`, уменьшается относительно текущего времени, устанавливается в `1`
или получает значение `oA[row][3]`.

Статус:

```text
oA[][8] → runtime activation/countdown state
ORIGINAL_CONFIRMED
```

## 34.3 `mA` содержит отдельный upgrade-level stat block для defensive structures

Прямое чтение `mA` из бинарного блока:

```text
mA : 45 × 19
```

показывает три последовательных уровня для категорий `13`, `14`, `15`:

```text
category 13:
  row 36 → [400, 15, ...]
  row 37 → [600, 15, ...]
  row 38 → [800, 15, ...]

category 14:
  row 39 → [500, 20, ...]
  row 40 → [700, 20, ...]
  row 41 → [900, 20, ...]

category 15:
  row 42 → [600, 20, ...]
  row 43 → [800, 20, ...]
  row 44 → [1000, 20, ...]
```

Кроме того, UI consumer в `C.class` непосредственно читает:

```text
mA[type][4]
mA[type][5]
mA[type][6..8]
mA[type][14]
```

и выводит их как отдельные характеристики здания/оружия.

Это существенно сужает поиск Damage/Range: теперь необходимо не искать
произвольные поля `oA`, а замкнуть семантику именно:

```text
building category
	  ↓
mA[type][4]
mA[type][5]
	  ↓
combat consumer
```

### Текущий статус

```text
mA[][4] → attack-stat candidate      HIGH CONFIDENCE
mA[][5] → second attack-stat candidate HIGH CONFIDENCE
mA[][6..8] → upgrade/economy values  CONFIRMED
mA[][14] → separate stat/parameter    CONFIRMED as UI-consumed field,
									exact combat semantics unresolved
```

`mA[][4]` и `mA[][5]` пока **не получают `ORIGINAL_CONFIRMED Damage/Range`**,
потому что найденный UI consumer показывает отображение чисел, но ещё не
доказывает, какой из них используется непосредственно в target/range или
damage calculation.

## 34.4 Важное разделение: building categories ≠ enemy weapon profiles

Для обычного enemy attack:

```text
lA[entity][5]
	↓
mA[type]
	↓
mA[type][16]
	↓
rA[weapon profile]
	↓
projectile
```

Для defensive-structure categories `13/14/15` поле `mA[][16]` не даёт
обычного `rA` projectile profile. Это объясняет, почему прежний поиск
универсального `building → rA → projectile` не замыкается.

Следовательно, conventional defensive-structure combat должен искать
**отдельный consumer `mA[type][4/5]`**, а не очередной вызов общего
`B(IIIIIIIII)`.

## 34.5 Current balance status after this pass

```text
Enemy Damage               ORIGINAL_CONFIRMED
Enemy Range                ORIGINAL_CONFIRMED
Enemy Initial HP source   ORIGINAL_CONFIRMED
Building Max HP            ORIGINAL_CONFIRMED
Building Cost              ORIGINAL_CONFIRMED
Special-action Damage      ORIGINAL_CONFIRMED for discovered consumers

Turret Damage              UNRESOLVED
Turret Range               UNRESOLVED
Turret Fire Rate           UNRESOLVED
```

### Removed from confirmed turret table

Следующие старые записи больше нельзя считать turret Damage:

```text
155 → 125
173 → 200
```

Они подтверждены как значения special-action damage path.

Для `159 → 800` и `161 → 1000` также требуется отдельный consumer audit;
само числовое присутствие в `oA`/related runtime paths недостаточно для
`ORIGINAL_CONFIRMED`.

# PHASE 35 — NEXT FORENSIC TARGET

Следующий pass должен быть максимально узким:

```text
building category 13 / 14 / 15
		↓
 mA[type][4]
 mA[type][5]
		↓
 поиск всех consumers
		↓
 target selection
		↓
 distance/range comparison
		↓
 damage application
		↓
 cooldown/timer
```

Приоритетные runtime categories:

```text
13 → mA rows 36..38
14 → mA rows 39..41
15 → mA rows 42..44
```

Затем необходимо сопоставить эти categories с building IDs:

```text
151,153,155,157,159,161,163,165,167,169,171,173
```

через фактический runtime construction/upgrade consumer, а не только
через `oA[][7]`.

**Цель следующего pass:** получить хотя бы одну полностью замкнутую
цепочку:

```text
Building ID
 → category
 → mA row / level
 → Damage
 → Range
 → Fire interval
```

Если такая цепочка будет найдена для одной defensive structure, остальные
уровни той же категории можно восстановить тем же consumer-правилом.

---

# RESEARCH PASS 36 — `mA` COMBAT SEMANTICS CORRECTION

**Date:** 2026-09-23

## Target

Re-check the Phase 35 assumption:

```text
category 13/14/15
→ mA[type][4/5]
→ target selection
→ range
→ damage
→ cooldown
```

using `C.class`, `HG.class`, binary `a`, and `RU.MAIN.lng`.

## 36.1 Source / loader

Binary `a` contains:

```text
mA : int[45][19]
offset = 7562
loader = HG.B(InputStream)
```

The block begins with the big-endian dimension header:

```text
00 2D 00 13
   45    19
```

## 36.2 Localization evidence corrects the `[4]/[5]` hypothesis

`HG.I(int)` resolves low16 string IDs from the loaded language table.

Decoding `RU.MAIN.lng` through the same index table gives:

```text
HG.I(1) = "А"
HG.I(2) = "О"
HG.I(3) = "ОЖ"
HG.I(4) = "Р"
```

In `C.D(Graphics,int)` the UI reads:

```text
mA[type][4]     → HG.I(3) = "ОЖ"
mA[type][5]     → HG.I(2) = "О"
mA[type][6..8]  → HG.I(1) = "А"
low16 mA[type][14] → HG.I(4) = "Р"
```

This evidence alone is **not** accepted as gameplay proof. It does, however,
invalidate the old assumption that `[4]` / `[5]` were the best Damage/Range targets.

## 36.3 Damage components — runtime chain closed

`C.L(int,int)` reads the three component fields:

```text
component 1 → mA[type][6]
component 2 → mA[type][7]
component 3 → mA[type][8]
```

`C.A(int[],int)` obtains the current entity type from `lA[][5]`, calls
`L(type, component)`, and applies upgrade/modifier contributions.

`C.A(int attacker,int target)` then obtains:

```text
A(lA[attacker],1)
A(lA[attacker],2)
A(lA[attacker],3)
```

and combines them against:

```text
rA[target_profile][5]
rA[target_profile][6]
rA[target_profile][7]
```

which are already confirmed Bullet / Energy / Fire resistance fields.

The method subtracts the corresponding resistance percentage from each attack component,
sums the remaining three components, clamps zero damage to at least `1`, and returns the
resulting damage value.

`C.Y(attacker,target)` calls that damage routine and performs:

```text
vA[target][22] -= calculated_damage
```

Therefore:

```text
mA[][6] → Bullet damage component
mA[][7] → Energy damage component
mA[][8] → Fire damage component

Status: ORIGINAL_CONFIRMED
```

for the conventional `lA → vA` combat path.

## 36.4 Range — runtime chain closed

`C.N(type)` returns the signed low16 value of:

```text
mA[type][14]
```

`C.D(int[] entity)` starts from that value and applies the currently active
upgrade/special modifiers.

The resulting value is consumed in runtime spatial tests:

### `C.MA()`

For an active `lA` entity, `D(lA[index])` is used to build the target-search area:

```text
x - range
x + range
y - range
y + range
```

Candidate `vA` targets are checked against that area and then passed through the
line/visibility test `B(IIIIII)` before the selected target is stored in:

```text
lA[index][14]
```

### `C.RA(int)`

The same `D(lA[index])` result is used as the spatial bound around the attacker
when validating its current target.

Thus, for the conventional attack path:

```text
low16 mA[type][14] → target/engagement range

Status: ORIGINAL_CONFIRMED
```

## 36.5 Cooldown / attack interval — runtime chain closed

At the beginning of `C.Y(attacker,target)`:

```text
type = lA[attacker][5]
cooldown = mA[type][15]
lA[attacker][19] += cooldown
```

The main entity loop `C.MA()` does not execute the acquisition/attack branch while:

```text
lA[index][19] > 0
```

This closes the timer role:

```text
mA[type][15] → attack cooldown / interval
Status: ORIGINAL_CONFIRMED
```

for the conventional combat path.

## 36.6 `[4]` and `[5]` reclassification

### `mA[][4]`

The direct consumer found in the stats UI labels the value with:

```text
HG.I(3) = "ОЖ"
```

No new source → runtime HP initialization chain was closed in this pass.

Status:

```text
HP/life-related candidate
ORIGINAL_INFERRED
```

### `mA[][5]`

The stats UI labels it with:

```text
HG.I(2) = "О"
```

`C.M(int)` returns `mA[type][5]`, and `C.C(int[])` builds a modified runtime
value from it. That value is consumed in path/spatial routines such as `EA()`
and related calculations.

No evidence in this pass supports `[5]` as the primary Damage or Range field.

Status:

```text
exact semantics → UNRESOLVED
previous "attack-stat candidate" classification → REJECTED
```

## 36.7 Critical result for rows 36..44

Direct binary decoding gives:

```text
rows 36..38:
  mA[][6..8] = 0,0,0
  low16 mA[][14] = -1
  mA[][15] = -1

rows 39..41:
  mA[][6..8] = 0,0,0
  low16 mA[][14] = -1
  mA[][15] = -1

rows 42..44:
  mA[][6..8] = 0,0,0
  low16 mA[][14] = -1
  mA[][15] = -1
```

Therefore these rows cannot participate in the conventional attack pipeline proven above.

The previous Phase 35 target:

```text
13/14/15 → mA[][4/5] → Damage/Range
```

is rejected as the next forensic route.

If structures associated with these rows cause damage or have radius/timing behavior, that
behavior must be traced through a separate static/special-effect path.

## 36.8 Conflict

```text
CONFLICT
```

Old interpretation:

```text
mA[][4] → attack-stat candidate
mA[][5] → second attack-stat candidate
```

New evidence:

```text
UI:
  [4] → "ОЖ"
  [5] → "О"
  [6..8] → "А"
  [14] → "Р"

Runtime:
  [6..8] → resistance-aware HP damage
  low16 [14] → target search/validation radius
  [15] → attack cooldown timer
```

Why the old interpretation fails:

- `[4]/[5]` do not close the damage/range runtime chain.
- `[6..8]`, `[14]`, `[15]` do.
- Rows 36..44 have zero/disabled values in the confirmed conventional combat fields.

## 36.9 Remaining grey areas

### GREY-01 — Building ID → runtime type/path

```text
Question:
Which of building IDs 151..173 instantiate an lA entity with an mA type,
and which stay in oA/static/special-effect logic?

Missing link:
construction/spawn/upgrade consumer → runtime record

Priority:
P0

Blocks implementation:
YES
```

### GREY-02 — Exact semantics of `mA[][4]`

```text
Known:
UI label = "ОЖ"

Missing:
runtime initialization / HP consumer chain

Priority:
P1
```

### GREY-03 — Exact semantics of `mA[][5]`

```text
Known:
UI label = "О"
M(int) / C(int[]) runtime helper
spatial/path consumers exist

Missing:
exact gameplay definition

Priority:
P1
```

### GREY-04 — Static/special building combat

```text
Known:
some oA special-effect damage consumers already confirmed

Missing:
complete per-building mapping for all combat-capable building IDs

Priority:
P0

Blocks implementation:
YES
```

# NEXT FORENSIC STEP

```text
Target:
building IDs 151..173 → construction/spawn/upgrade → runtime combat path

Why:
Damage/Range/Cooldown semantics for the conventional mA combat pipeline are now known.
The remaining blocker is identity/mapping, not generic combat-field semantics.

Trace:
building ID
→ construction/upgrade consumer
→ lA/mA type OR oA/static state
→ confirmed conventional fields [6..8]/[14]/[15] OR special-effect consumer
→ target
→ HP subtraction
→ timer

Success:
Every combat-capable building ID is assigned to one verified runtime combat path.

Unlocks:
Per-building TurretStats / static-effect stats and safe Godot implementation.
```



---

# RESEARCH PASS 37 — `oA` STATIC/SPECIAL EFFECT CONSUMERS AND BUILDING-ID RECLASSIFICATION

**Дата:** 2026-09-23

**Цель:** продолжить P0 после Pass 36: сопоставить реальные `oA` runtime states с building IDs и закрыть прямые HP consumers, не предполагая универсальную `TurretStats` таблицу.

## 37.1 Источник и метод

Проверены непосредственно:

```text
source: C.class
source: HG.class
binary: a
```

`C.class` повторно просмотрен через bytecode (`javap -p -c`).
`HG.class` дополнительно проверен на внешние call-sites метода `C.F(int)`.
`oA` повторно декодирован из `a` по подтверждённому offset `11518` как `12 × 9 int32`.

Это соответствует принципу:

```text
SOURCE → LOADER → ARRAY/OFFSET → CONSUMER → RUNTIME → HP MUTATION
```

Внешние веб-материалы не использовались как доказательство игровой семантики; они не содержат исходных данных этого title.

## 37.2 Повторная фиксация `oA` rows

По raw binary `a @ 11518`:

| index | building ID | `oA[][0]` | `oA[][3]` | `oA[][4]` | `oA[][7]` | `oA[][8]` source value |
|---:|---:|---:|---:|---:|---:|---:|
| 0 | 151 | 786441 | 21 | 30000 | 300 | 1 |
| 1 | 153 | 0 | 19 | 1 | 500 | 1 |
| 2 | 155 | 1 | 16 | 1 / packed | 750 | 13 |
| 3 | 157 | 0 | 24 | 1 | 250 | 13 |
| 4 | 159 | 20000 | 26 | 20000 | 800 | 1 |
| 5 | 161 | 15000 | 18 | 15000 / packed | 1000 | 13 |
| 6 | 163 | 30000 | 20 | 30000 | 1500 | 15 |
| 7 | 165 | 8000 | 27 | 8000 | 4000 | 15 |
| 8 | 167 | 25000 | 22 | 25000 | 2000 | 15 |
| 9 | 169 | 20000 | 23 | 20000 | 3000 | 15 |
| 10 | 171 | 17500 | 25 | 17500 | 5000 | 1 |
| 11 | 173 | 1 | 17 | 1 / packed | 4000 | 13 |

**Important:** `oA[][8]` is runtime state, not a static balance value. `G()` explicitly resets every `oA[][8]` to `0` during runtime initialization. The raw value `1` in the serialized row therefore must not be interpreted as the runtime activation state after initialization.

## 37.3 `C.F(int)` is not dead code — external caller found in `HG.class`

Pass 36 had only searched `C.class` call-sites and therefore did not see the external caller.

`HG.class` contains:

```text
na[oa * 4 + 2]
	↓
C.F(value)
```

at the relevant UI/event branch (`HG.javap`, around bytecode offset 1083 of the enclosing method).

Therefore `C.F(int)` is a real activation entry point from the UI/event layer.

`C.F(int)` performs:

```text
oA[index][8] = oA[index][3]
```

and has special handling for indices:

```text
0, 1, 2, 4, 5, 11
```

For index `4`, the method also modifies active `vA` entity state; for indices `1,2,5,11` it enters the corresponding building-effect state path.

This closes the missing activation edge:

```text
UI/event input
	↓
HG
	↓
C.F(index)
	↓
oA[index][8] = oA[index][3]
	↓
C.O() / C.P() / other consumer
```

## 37.4 Building ID 155 — direct special-effect HP damage confirmed and corrected

Mapping:

```text
oA index 2 → building ID 155
```

`C.P()` selects index `2` when `oA[11][8] != 1` and `oA[2][8] == 1`.
It decodes the packed geometry from `oA[2][4]`, then loops over active `vA` entities.
For entities inside the calculated area it executes:

```text
vA[target][22] -= oA[2][7]
```

The raw source value is:

```text
oA[2][7] = 750
```

Therefore the strict current result is:

```text
Building ID 155
	→ oA index 2
	→ C.P()
	→ area test
	→ vA[][22] -= 750
```

**Status: `ORIGINAL_CONFIRMED` — special/static-effect damage = 750.**

This **supersedes** the historical `155 → 125` classification. `125` is not the value consumed by this direct HP-subtraction path.

## 37.5 Building ID 173 — direct special-effect HP damage confirmed and corrected

Mapping:

```text
oA index 11 → building ID 173
```

The same `C.P()` path selects index `11` when `oA[11][8] == 1`.
It then executes:

```text
vA[target][22] -= oA[11][7]
```

with raw value:

```text
oA[11][7] = 4000
```

Therefore:

```text
Building ID 173
	→ oA index 11
	→ C.P()
	→ area test
	→ vA[][22] -= 4000
```

**Status: `ORIGINAL_CONFIRMED` — special/static-effect damage = 4000.**

This **supersedes** the historical `173 → 200` classification.

## 37.6 Building ID 159 — direct area HP damage confirmed

Mapping:

```text
oA index 4 → building ID 159
```

`C.O()` contains `tableswitch` case `4`. After the timer in `oA[4][8]` expires, it decodes the packed geometry from `oA[4][4]`, scans `vA`, checks whether each active entity lies in the effect rectangle, and performs:

```text
vA[target][22] -= oA[4][7]
```

with:

```text
oA[4][7] = 800
```

**Status: `ORIGINAL_CONFIRMED` — special/static-effect damage = 800.**

## 37.7 Building ID 161 — direct area HP damage confirmed

Mapping:

```text
oA index 5 → building ID 161
```

`C.O()` case `5` uses the same area-damage structure and subtracts:

```text
vA[target][22] -= oA[5][7]
```

with:

```text
oA[5][7] = 1000
```

**Status: `ORIGINAL_CONFIRMED` — special/static-effect damage = 1000.**

`C.R()` is additionally invoked when the index-5 state is active, but that method builds the corresponding `vb/pb` visual/effect state; it is not the HP subtraction itself.

## 37.8 Building ID 157 — special projectile consumer found; numeric Damage still unresolved

Mapping:

```text
oA index 3 → building ID 157
```

`C.M()` is the projectile/effect processing loop. In the `rb[][7] == 1` hit path it computes the conventional damage value through:

```text
A(target, attacker)
```

but contains an additional building-state branch:

```text
if oA[3][8] == 1 and nb == false:
	vA[rb[][8]][22] = 0
```

Thus when the index-3 effect state is active, the hit can set the target HP directly to zero instead of performing the ordinary subtraction.

**What is proven:**

```text
oA index 3 / ID 157
	→ C.M()
	→ projectile-hit consumer
	→ target HP can be set to 0 when special state is active
```

**What is not proven:**

```text
ID 157 → fixed numeric Damage = X
ID 157 → universal Range = Y
ID 157 → universal Fire Rate = Z
```

The raw `oA[3][7] = 250` is therefore **not** promoted to Damage. It is not the operand of the demonstrated HP mutation in this branch.

**Status: `ORIGINAL_CONFIRMED` for the special zero-HP effect; numeric Damage `UNRESOLVED`.**

## 37.9 Building ID 153 — state consumer found, but no HP subtraction

Mapping:

```text
oA index 1 → building ID 153
```

The UI/gameplay action path checks `oA[1][8]`, finds a target using the map/entity lookup, modifies the packed `lA[target][12]` state, and then resets `oA[1][8]`.

No instruction in this consumer subtracts from:

```text
vA[target][22]
lA[target][22]
```

Therefore `oA[1][7] = 500` cannot currently be labelled Damage.

**Status:** special/state consumer `ORIGINAL_CONFIRMED`; Damage `UNRESOLVED`.

## 37.10 Building ID 151 and IDs 163–171 — no direct HP mutation in the audited `oA` effect switch

The main `C.O()` `oA[][0]` switch has branches for all 12 runtime state types.
For indices corresponding to:

```text
151 (0)
163 (6)
165 (7)
167 (8)
169 (9)
171 (10)
```

the observed branch is timer/state handling or another state transition, not direct:

```text
vA[][22] -= oA[][7]
```

This is a **negative result for this consumer**, not proof that these IDs can never cause combat damage elsewhere.

Current status remains:

```text
151 → Damage UNRESOLVED
163 → Damage UNRESOLVED / likely non-turret record; do not assume building weapon
165 → Damage UNRESOLVED / likely non-turret record; do not assume building weapon
167 → Damage UNRESOLVED / likely non-turret record; do not assume building weapon
169 → Damage UNRESOLVED / likely non-turret record; do not assume building weapon
171 → Damage UNRESOLVED
```

## 37.11 `oA[][7]` is now proven as a direct effect-damage operand in four paths — but not a universal turret field

The following four consumers are now closed:

```text
ID 155 → oA[2][7] = 750 → vA[][22] -= 750
ID 159 → oA[4][7] = 800 → vA[][22] -= 800
ID 161 → oA[5][7] = 1000 → vA[][22] -= 1000
ID 173 → oA[11][7] = 4000 → vA[][22] -= 4000
```

This proves the semantics of `oA[][7]` **in those specific effect consumers**.
It still does not prove:

```text
oA[][7] = universal turret Damage for all 12 records
```

The same field in ID 153 is not consumed as HP damage in its audited state path, and ID 157 uses a separate zero-HP effect branch.

## 37.12 Updated per-building forensic table

| ID | oA index | direct effect consumer | HP mutation proven? | `oA[][7]` role | Current status |
|---:|---:|---|---|---:|---|
| 151 | 0 | `C.O()` state/timer | No in audited branch | unresolved | Damage UNRESOLVED |
| 153 | 1 | UI/action state path | No | not Damage in audited path | Damage UNRESOLVED |
| 155 | 2 | `C.P()` area effect | Yes | 750 damage | ORIGINAL_CONFIRMED |
| 157 | 3 | `C.M()` projectile-hit special branch | Yes, target HP → 0 | not numeric Damage | ORIGINAL_CONFIRMED special effect; Damage UNRESOLVED |
| 159 | 4 | `C.O()` area effect | Yes | 800 damage | ORIGINAL_CONFIRMED |
| 161 | 5 | `C.O()` area effect | Yes | 1000 damage | ORIGINAL_CONFIRMED |
| 163 | 6 | `C.O()` state/timer | No in audited branch | unresolved | Damage UNRESOLVED |
| 165 | 7 | `C.O()` state/timer | No in audited branch | unresolved | Damage UNRESOLVED |
| 167 | 8 | `C.O()` state/timer | No in audited branch | unresolved | Damage UNRESOLVED |
| 169 | 9 | `C.O()` state/timer | No in audited branch | unresolved | Damage UNRESOLVED |
| 171 | 10 | `C.O()` state/timer | No in audited branch | unresolved | Damage UNRESOLVED |
| 173 | 11 | `C.P()` area effect | Yes | 4000 damage | ORIGINAL_CONFIRMED |

## 37.13 Range / timing result

The four numeric effect paths establish an **effect-zone geometry** derived from packed `oA[][4]` plus global center coordinates. This is not yet promoted to a universal `Turret Range` field.

Likewise `oA[][8]` is a runtime timer/state and `oA[][3]` supplies the activation duration/state value through `C.F(int)`, but this is not yet enough to define a universal `Fire Rate` or attack interval.

Therefore:

```text
Special-effect damage: partially closed
Special-effect zone geometry: consumer-confirmed for the four paths
Universal building Range: UNRESOLVED
Universal building Fire Rate: UNRESOLVED
```

## 37.14 Important correction to historical records

The following old entries must no longer be used as source-of-truth values:

```text
155 → 125
173 → 200
```

The actual direct HP consumers found in the current bytecode use:

```text
155 → 750
173 → 4000
```

The old numbers are retained only as historical rejected/reclassified evidence.

## 37.15 Pass 37 conclusion

### Proven

```text
HG → C.F(index) activation edge
building ID → oA index mapping
155 → 750 direct special-effect damage
159 → 800 direct special-effect damage
161 → 1000 direct special-effect damage
173 → 4000 direct special-effect damage
157 → special projectile hit can set target HP to 0
153 → state/action consumer exists but is not HP damage in audited path
```

### Rejected / corrected

```text
155 → 125   REJECTED as direct effect damage
173 → 200   REJECTED as direct effect damage
```

### Still unresolved

```text
151 Damage / Range / Fire Rate
153 Damage / Range / Fire Rate
157 numeric Damage / Range / Fire Rate
163/165/167/169 Damage / Range / Fire Rate
171 Damage / Range / Fire Rate
universal building Range
universal building Fire Rate
```

### Next forensic step

Do not return to the retired `mA[4/5]` hypothesis.

The highest-value next step is:

```text
HG action table `na[]`
	↓
C.F(index)
	↓
oA index / building ID
	↓
all activation callers for indices 0..11
	↓
for unresolved IDs 151,153,157,163,165,167,169,171:
	identify the exact gameplay action/state
	↓
trace whether that action eventually mutates HP, target state,
range geometry, or timing
```

This will distinguish actual combat-capable structures from production/support/utility records before any Godot `TurretStats` table is created.
