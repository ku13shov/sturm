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

  Точный оригинальный баланс                   **\[Заблокирован — building Damage/Range consumer не найден\]**

  Точная таблица турелей                       **\[Заблокирован — Attack Caller отсутствует в C.class\]**

  Точный HP жуков                              **\[Заблокирован\]**

  Godot 4 core architecture                    **\[Проектирование\]**

  3D-карта                                     **\[Проектирование\]**

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

## 9.4 Что с 12 building/turret ID

**Статус: \[Не доказано\]**

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

`oA[][7]` действительно связывает building record с категорией
`mA[][0]`, но в найденном consumer-коде нет доказательства, что
конкретные `mA` поля являются turret Damage/Range. Поэтому нельзя
переносить `rA[][4]`/`rA[][12]` на 12 building IDs.

Текущий строгий вывод:

``` text
Enemy Damage  → a @ 12984 → rA[][4]
Enemy Range   → a @ 12984 → rA[][12]

Building Damage → пока не доказан
Building Range  → пока не доказан
```

Следовательно, **12 building Damage/Range нельзя честно объявить
найденными на основании этой трассировки**. Следующая трассировка должна
идти от building category `oA[][7]` → `mA` → конкретного consumer,
который формирует runtime attack/projectile state для стационарного
оружия.

## 9.5 Подтверждённые значения зданий

     ID   Max HP   Cost   Damage   Range Статус
  ----- -------- ------ -------- ------- ----------------------------
    151    30000    300        ?       ? HP/Cost ORIGINAL_CONFIRMED
    153    30000    500        ?       ? HP/Cost ORIGINAL_CONFIRMED
    155    30000    750        ?       ? HP/Cost ORIGINAL_CONFIRMED
    157    15000    250        ?       ? HP/Cost ORIGINAL_CONFIRMED
    159    30000    800        ?       ? HP/Cost ORIGINAL_CONFIRMED
    161    60000   1000        ?       ? HP/Cost ORIGINAL_CONFIRMED
    163    60000   1500        ?       ? HP/Cost ORIGINAL_CONFIRMED
    165    90000   4000        ?       ? HP/Cost ORIGINAL_CONFIRMED
    167    80000   2000        ?       ? HP/Cost ORIGINAL_CONFIRMED
    169    50000   3000        ?       ? HP/Cost ORIGINAL_CONFIRMED
    171   120000   5000        ?       ? HP/Cost ORIGINAL_CONFIRMED
    173   100000   4000        ?       ? HP/Cost ORIGINAL_CONFIRMED

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

**Статус: \[Заблокирован\]**

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

Пока отсутствует полная расшифровка `a`, любые конкретные значения:

``` text
Cost = X
Upgrade = Y
```

являются только стартовым балансом нового проекта.

Они не должны считаться реконструированным балансом Sturmtrupp Mars.

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

## 16.1 Папки

**Статус: \[Проектирование\]**

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
| **173** | Центр коммуникации | `137.png` | communications building | wide command/communications module with cyan central unit |

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

# PHASE 17.2 — GODOT 4 3D ASSET TARGETS

**Статус: [Выполнено — source-to-target visual specification fixed]**

## 17.2.1 General conversion rule

Every original sprite family becomes a 3D asset family:

``` text
Original PNG
    ↓
silhouette + palette + functional geometry extraction
    ↓
Low-Poly 3D model
    ↓
PBR materials
    ↓
idle / attack / damage / destruction animations
    ↓
Godot scene
```

The target presentation is:

``` text
modern sci-fi strategy
low-poly but mechanically believable
45-degree three-quarter view
isolated white background
no text
no UI
no watermark
game-ready orthographic-friendly silhouette
```

## 17.2.2 21 production prompts

### Bugs

**ID 70 — Basic Bug**

> Modern low-poly sci-fi RTS alien insect inspired strictly by a tiny aggressive reddish-brown Mars bug, compact segmented exoskeleton, four thin articulated legs, small forward body, dark brown shell with rusty red highlights, hostile swarm-creature silhouette, compact proportions, hard-surface insect armor, subtle organic joints, believable weight and mechanical-game readability, clean PBR materials, no weapons, no extra limbs, 45-degree three-quarter view, isolated on pure white background, studio lighting, centered full-body game asset, modern AAA sci-fi strategy aesthetic, optimized low-poly topology, orthographic-friendly silhouette.

**ID 71 — Heavy Bug**

> Modern low-poly sci-fi RTS heavy alien insect, visibly larger and tougher than a basic swarm bug, thick reddish-brown segmented exoskeleton, broad armored thorax, reinforced legs, heavier abdomen, dense hard shell, dark rust and burnt-orange palette, aggressive low stance, robust combat creature silhouette, believable articulated insect anatomy, clean PBR materials, no wings, no futuristic weapons, 45-degree three-quarter view, isolated on pure white background, studio lighting, centered full-body game asset, modern sci-fi strategy game, low-poly production topology.

**ID 72 — Eye Shooter**

> Modern low-poly sci-fi RTS ranged alien insect based on a reddish-brown agile bug with prominent luminous eye-like emitters, slim articulated body, multiple precise legs, armored head focused forward, small glowing energy apertures around the eyes, dark brown shell with red-orange accents, visual language of a biological energy-beam shooter, restrained sci-fi detailing, clean PBR materials, 45-degree three-quarter view, isolated pure white background, studio lighting, centered full-body asset, modern AAA sci-fi strategy style, low-poly topology, no text, no extra weapons.

**ID 73 — Acid Ram**

> Modern low-poly sci-fi RTS acid-ramming alien insect, nasty compact armored creature with a reinforced front for building impacts and a visible rear acid-sac/tail mechanism, reddish-orange and dark brown exoskeleton, heavy abdomen, aggressive forward-leaning posture, corrosive alien biology expressed through translucent greenish acid details kept subtle, believable collision silhouette, robust articulated legs, clean PBR materials, 45-degree three-quarter view, isolated on pure white background, studio lighting, centered full-body game asset, modern sci-fi strategy aesthetic, optimized low-poly topology.

**ID 74 — Flying Shooter**

> Modern low-poly sci-fi RTS flying alien insect with four translucent armored wings, compact reddish-brown body, long-range weapon-like biological emitter integrated into the front/head, angular wing joints, dark rust shell, orange highlights, clearly airborne combat silhouette, aerodynamic insect proportions, restrained alien technology, clean PBR materials, 45-degree three-quarter view, isolated pure white background, studio lighting, centered full-body game asset, modern AAA sci-fi strategy game, low-poly production topology, no UI.

**ID 75 — Queen**

> Modern low-poly sci-fi RTS alien insect queen, much larger and more imposing than regular bugs, bulky pale gray and rusty brown exoskeleton, massive armored abdomen, thick segmented limbs, heavy central body mass, queen-like commanding silhouette without humanoid features, rugged Mars-worn biological armor, subtle orange heat accents, believable boss creature proportions, clean PBR materials, 45-degree three-quarter view, isolated on pure white background, studio lighting, centered full-body game asset, modern sci-fi strategy aesthetic, optimized low-poly topology.

**ID 76 — Venom Bug**

> Modern low-poly sci-fi RTS poisonous alien insect, medium-large reddish-brown body with a clearly visible curved stinger, segmented armored abdomen, compact muscular legs, dark rust shell with orange highlights, venom delivery tail anatomy, aggressive combat stance, believable insect articulation, clean PBR materials, no wings, no humanoid anatomy, 45-degree three-quarter view, isolated pure white background, studio lighting, centered full-body game asset, modern AAA sci-fi strategy style, low-poly topology.

**ID 77 — Hidden Bug**

> Modern low-poly sci-fi RTS stealth alien insect, same core reddish-brown insect silhouette as a dangerous Mars crawler but designed around partial invisibility, dark segmented exoskeleton with subtle refractive distortion along the edges, faint broken outline and translucent camouflage patches, compact articulated legs, threatening but difficult-to-see silhouette, restrained optical-cloaking effect, physically plausible translucent material, 45-degree three-quarter view, isolated pure white background, studio lighting, centered full-body game asset, modern sci-fi strategy aesthetic, optimized low-poly topology.

**ID 78 — Sand Worm**

> Modern low-poly sci-fi RTS Martian sand worm, compact burrowing alien creature with a low elongated body, armored segmented brown-orange surface, partially buried visual language, reinforced head, gritty desert coloration, dense rugged exoskeleton adapted to underground movement, no wings, no humanoid features, threatening subterranean silhouette, clean PBR materials with subtle sand dust, 45-degree three-quarter view, isolated pure white background, studio lighting, centered full-body game asset, modern AAA sci-fi strategy aesthetic, low-poly topology.

### Buildings / defenders

**ID 151 — Energy Station**

> Modern low-poly sci-fi RTS energy station inspired strictly by the original industrial Mars generator: compact rectangular dark steel power building, prominent red reactor housing, cyan status lights, yellow industrial hazard accents, heavy armored panels, exposed service modules, practical cables and vents, believable modular upgrade architecture, rugged colony engineering, no text, no antennas unless structurally justified, 45-degree three-quarter view, isolated pure white background, studio lighting, centered game-ready asset, modern AAA sci-fi strategy style, clean PBR materials, optimized low-poly topology.

**ID 153 — Fire Tower**

> Modern low-poly sci-fi RTS fire-defense turret inspired by the original squat armored cannon: dark weathered steel chassis, compact central ballistic cannon, mechanical side braces, red warning accents, reinforced circular turret housing, practical recoil mechanism, heavy industrial construction, compact footprint suitable for a 64x64 strategy grid, clearly defensive silhouette, 45-degree three-quarter view, isolated pure white background, studio lighting, centered game asset, modern sci-fi strategy aesthetic, clean PBR materials, low-poly topology.

**ID 155 — Central Base**

> Modern low-poly sci-fi RTS central Mars command base, large symmetrical armored command structure based on the original broad mechanical silhouette, dark gray industrial hull, cyan illuminated central control panels, red vertical side modules, angular reinforced outer shell, heavy landing/support geometry, layered command core, believable three-tier upgrade architecture, iconic headquarters silhouette, no text, no flags, 45-degree three-quarter view, isolated pure white background, studio lighting, centered full building, modern AAA sci-fi strategy aesthetic, clean PBR materials, optimized low-poly topology.

**ID 157 — Laser Tower**

> Modern low-poly sci-fi RTS laser defense turret, compact armored mechanical chassis derived from the original turret family, dark steel plating, narrow high-energy emitter, restrained cyan-blue laser glow, red warning strips, articulated aiming assembly, heat-management vents, practical hard-surface engineering, small strategic footprint, 45-degree three-quarter view, isolated pure white background, studio lighting, centered game-ready asset, modern sci-fi strategy aesthetic, clean PBR materials, low-poly topology.

**ID 159 — Beacon**

> Modern low-poly sci-fi RTS Martian beacon building, narrow vertical industrial tower with a pale armored dome at the top, dark gray cylindrical housing, strong red vertical panels, small blue energy/service details, compact lure/navigation beacon silhouette, rugged colony construction, believable maintenance panels, no exaggerated futuristic ornament, 45-degree three-quarter view, isolated pure white background, studio lighting, centered game asset, modern AAA sci-fi strategy aesthetic, clean PBR materials, optimized low-poly topology.

**ID 161 — Assault Gun**

> Modern low-poly sci-fi RTS heavy assault artillery emplacement based on the original compact armored gun, dark steel bunker-like chassis, large black forward gun aperture/barrel, strong yellow-gold hazard armor around the sides, reinforced firing cradle, heavy recoil supports, rugged Mars colony engineering, clearly heavier than a basic turret, 45-degree three-quarter view, isolated pure white background, studio lighting, centered game-ready asset, modern sci-fi strategy aesthetic, clean PBR materials, optimized low-poly topology.

**ID 163 — Soldiers**

> Modern low-poly sci-fi RTS Mars infantry defender, compact armored human soldier based on the original blue-and-white uniform silhouette, protective helmet, dark tactical body armor, blue visor/energy accents, rugged boots and gloves, compact rifle held in a ready position, practical colonial military design, readable from an isometric strategy camera, no excessive tactical accessories, 45-degree three-quarter view, isolated pure white background, studio lighting, centered full-body character, modern AAA sci-fi strategy aesthetic, clean PBR materials, optimized low-poly topology.

**ID 165 — Minefield**

> Modern low-poly sci-fi RTS minefield asset, compact cluster of buried Martian anti-insect mines and disturbed soil, dark brown metallic mine housings partially concealed by reddish Martian dust, several subtle explosive impact/debris states, low silhouette suitable for ground placement, practical military engineering, no oversized sci-fi effects, 45-degree three-quarter view, isolated pure white background, studio lighting, centered modular strategy asset, modern sci-fi strategy aesthetic, clean PBR materials, optimized low-poly geometry.

**ID 167 — Plasma Tower**

> Modern low-poly sci-fi RTS plasma defense turret, squat armored industrial chassis with a large spherical purple plasma core, blue-white energy discharge around the lower emitter, dark steel cradle, red warning accents, thick mechanical support arms, visible energy containment hardware, powerful but compact silhouette, believable hard-surface science-fiction engineering, 45-degree three-quarter view, isolated pure white background, studio lighting, centered game-ready asset, modern AAA sci-fi strategy aesthetic, clean PBR materials, optimized low-poly topology.

**ID 169 — Radar Tower**

> Modern low-poly sci-fi RTS radar tower based on the original twin-antenna installation, two compact dark industrial radar masts on a rugged base, thin red antenna details, mechanical scanning dishes and receiver elements, weathered gray steel, practical sensor housing, clearly non-combat surveillance role, compact colony engineering, 45-degree three-quarter view, isolated pure white background, studio lighting, centered game asset, modern sci-fi strategy aesthetic, clean PBR materials, optimized low-poly topology.

**ID 171 — Satellite**

> Modern low-poly sci-fi RTS satellite visibility station, compact cylindrical armored base with a rotating dish/antenna assembly, dark gray industrial housing, pale metal dish, red mechanical accents, multiple believable dish orientations represented by an articulated pivot system, communication/surveillance role, rugged Mars colony technology, 45-degree three-quarter view, isolated pure white background, studio lighting, centered game-ready asset, modern AAA sci-fi strategy aesthetic, clean PBR materials, optimized low-poly topology.

**ID 173 — Communication Center**

> Modern low-poly sci-fi RTS communications center inspired by the original wide mechanical building, broad dark-gray command module, cyan illuminated central communication core, symmetrical side equipment blocks, heavy industrial panels, red emergency indicators, compact antenna/service details, believable orbital-command relay architecture, clean functional silhouette, 45-degree three-quarter view, isolated pure white background, studio lighting, centered full building, modern AAA sci-fi strategy aesthetic, PBR materials, optimized low-poly topology.

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
[ ] Определить HP зданий через consumer
[x] Определить Damage жуков — rA[][4], consumer подтверждён
[x] Определить Range жуков — rA[][12], consumer подтверждён
[x] Провести полный call-site audit B(IIIIIIIII) — выполнено; building Attack Caller не найден
[ ] Определить Damage зданий — UNRESOLVED, отдельный static/event/effect consumer не найден
[ ] Определить Range зданий — UNRESOLVED, отдельный static/event/effect consumer не найден
[ ] Определить Fire Rate зданий — UNRESOLVED
[ ] Определить Cost
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
oA[][7] → weapon parameter lookup
```

Следовательно, это proximity/collision/event state, а не tower attack.

## 9.10 Проверка hardcoded switch-case

В `O()` действительно существует:

``` text
switch(oA[i][0])
```

с case `0..11`.

Но этот switch обрабатывает **state/timer behaviour здания** (`oA[][8]`)
--- например, countdown/reset/state transitions.

Он **не содержит**:

``` text
Damage
Range
projectile creation
lA[][22] -= ...
```

Отдельного `switch(building_type)` для боевого урона также не найдено.

## 9.11 Проверка `mA` в боевом конвейере

`mA` активно используется в `C.class`, но найденные consumers относятся
к классификации/карте/юнитам:

``` text
lA[][5] → mA[type]
mA[type][3] → entity/category classification
mA[type][9], [10], [14], [16], [18] → различные map/entity parameters
```

В частности, боевой target-selection код (`Z(int)`, `GA()`, `DA()` и
связанные методы) использует `mA` для определения **типа цели**, а не
для определения Damage/Range стационарной башни.

## 9.12 Финальный вердикт по 12 зданиям

**Damage / Range для ID 151--173 не находятся в `rA`, `oA` или в
доказанном weapon consumer `mA`.**

На основании полного прохода по `C.class` нельзя честно написать:

``` text
151 → Damage X, Range Y
...
173 → Damage X, Range Y
```

потому что в исходном runtime-конвейере `C.class` отсутствует доказанная
операция, которая вообще превращает эти `oA` records в атакующего.

### Что доказано

``` text
oA[][3] → Max HP
oA[][6] → Cost
oA[][7] → category link
oA[][8] → current HP / timer state

mA → category/entity/map data
rA → enemy combat profiles

lA[][17..18] → enemy position
lA[][22] → enemy current HP
```

### Что НЕ доказано и не должно быть захардкожено в ремейке

``` text
Building Damage → unresolved / no consumer found
Building Range  → unresolved / no consumer found
Building Fire Rate → unresolved / no consumer found
```

Это означает, что предыдущая постановка:

``` text
oA[][7] → mA[][0] → tower weapon database
```

была рабочей гипотезой, но **не подтверждается оригинальным `C.class`**.

## 9.13 Следующая точка исследования

Если 12 ID действительно соответствуют оборонительным объектам, их
attack behaviour, вероятно, находится вне предполагаемого
`oA → mA → weapon` пути.

Следующий forensic pass должен искать:

``` text
static damage-zone / trigger tables
special-effect state
map/event scripts
pA / qA consumers
nA consumers
hardcoded damage constants outside oA/mA
```

Особенно следует трассировать consumers:

``` text
pA
qA
nA
vb
pb
rb
```

потому что именно эти runtime structures могут содержать
event/projectile/effect state, не связанный напрямую с `oA`.

До нахождения такого consumer **не переносить значения `mA` fields
4/11/13 в Damage/Range**. Их числовые значения выглядят правдоподобно
как gameplay parameters, но consumer-доказательства для такой семантики
отсутствуют.

## 9.14 Updated BuildingStats

     ID   Max HP   Cost   Category   Damage   Range Status
  ----- -------- ------ ---------- -------- ------- -------------------------
    151    30000    300          1        ?       ? Damage/Range unresolved
    153    30000    500          1        ?       ? Damage/Range unresolved
    155    30000    750         13        ?       ? Damage/Range unresolved
    157    15000    250         13        ?       ? Damage/Range unresolved
    159    30000    800          1        ?       ? Damage/Range unresolved
    161    60000   1000         13        ?       ? Damage/Range unresolved
    163    60000   1500         15        ?       ? Damage/Range unresolved
    165    90000   4000         15        ?       ? Damage/Range unresolved
    167    80000   2000         15        ?       ? Damage/Range unresolved
    169    50000   3000         15        ?       ? Damage/Range unresolved
    171   120000   5000          1        ?       ? Damage/Range unresolved
    173   100000   4000         13        ?       ? Damage/Range unresolved

## STEP 02 --- FINAL STATUS

**\[Выполнено — полный call-site audit `B(IIIIIIIII)` завершён; building Damage/Range в `C.class` не доказаны и остаются UNRESOLVED\]**

STEP 02 не переводится в `[Выполнено]`, поскольку это потребовало бы
утверждать неподтверждённые Damage/Range для 12 зданий.

Критически важное новое доказательство:

``` text
There is no proven static-tower attack consumer in C.class
that maps oA[][7] / mA to Damage + Range.
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
