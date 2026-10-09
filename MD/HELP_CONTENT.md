# STURMTRUPP MARS — HELP CONTENT REGISTER

This file is the source register for the in-game Help section. Text is transcribed from user-provided screenshots and must remain distinguishable from newly authored remake guidance.

## Game description / introduction

> Противные существа, напоминающие насекомых, подвергают опасности выживание людей на Марсе.
> Командуй обороной на Марсе! Строй оборонительные сооружения и исследовательские станции и применяй все имеющиеся технологии, чтобы избежать худшего.
> Штурмовая группа Марс! Будь свидетелем того, как летают клопы!
>
> Больше информации на:
> www.handy-games.com

**Evidence:** `ziva-attachment:zj0MqioR8AWumlPzMiNyf`

**Status:** `SCREENSHOT_CONFIRMED`

## How missing behavior is documented

This file remains the register for text transferred from the original game's Help section.
It is also the primary reference for the intended purpose of buildings and towers.

Details not present in Help will be added separately from controlled play of the original
game. User reports should be marked `USER_OBSERVED` and include, where possible:

- building ID/name and level;
- game mode and prerequisites;
- construction or upgrade cost;
- target selection and attack/effect type;
- range, visibility and timing behavior;
- the exact test situation and observed result.

Observed behavior must not be silently rewritten as screenshot evidence or bytecode-confirmed
fact. Conflicting observations should remain recorded until resolved.

## Buildings — Basics

### Building index

The original Help menu lists this subsection and the following entries:

```text
Основы
Центральная база
Станция исследования
Энергостанция
Центр коммуникации
Лазерная башня
Солдаты
Огневая башня
Плазменная башня
Радарная вышка
Маяк
БПЛА
Штурмовое орудие
Минное поле
Башня теслы
Сателлит
```

**Evidence:** `ziva-attachment:xNO5cnuvHDP-TNNBnLLwO`

**Status:** `SCREENSHOT_CONFIRMED`

### Basics text

> В игре имеется два вида зданий: главные здания и оборонительные сооружения. Модернизация главных зданий даёт возможность строить новые здания, развивать новые технологии и активировать дополнительные действия.
>
> Каждое здание имеет определённое количество очков жизни (ОЖ). При повреждении ОЖ понижаются. При повышенной обороне (О) минимизируется ущерб, наносимый врагами.
>
> Оборонительные сооружения имеют дополнительные данные: интенсивность атаки (А), наносимая одним выстрелом; радиус поражения (Р) при атаке.

**Evidence:** `ziva-attachment:dhB-P0AycMHKbHLk4gBsr`

**Status:** `SCREENSHOT_CONFIRMED`. The user confirmed that the clipped word endings are unambiguous from context (`жизни`, `данные`); no further capture is required.

## Buildings — individual entries

### Satellite

> Сателлит повышает радиус видимости. К сожалению, он не обнаруживает невидимых насекомых. Модернизированный сателлит даёт возможность иметь полный обзор над полем боя.

**Asset:** `original/144.png`, according to user mapping.

**Screenshot evidence:** `ziva-attachment:-2nqC4P7iODUfoIpn-0KS`

**Status:** `SCREENSHOT_CONFIRMED` / `USER_REPORTED` asset mapping.

### Tesla Tower

> Самая сильная из твоего арсенала. Наносит очень сильное энергетическое и огневое повреждение.

**Assets:** `original/134.png` (level 1), `original/135.png` (level 2), `original/136.png` (level 3), according to user mapping.

**Screenshot evidence:** `ziva-attachment:dMqSoQCZ8hpeei4eoGJn0`

**Status:** `SCREENSHOT_CONFIRMED` / `USER_REPORTED` asset mapping.

### Assault Gun

> Снаряды штурмового орудия наносят ракетные и огневые повреждения.

**Assets:** `original/141.png` (level 1), `original/142.png` (level 2), `original/143.png` (level 3), according to user mapping.

**Screenshot evidence:** `ziva-attachment:DJ49sUG9EeN-MnzOCb0FL`

**Status:** `SCREENSHOT_CONFIRMED` / `USER_REPORTED` asset mapping.

### UAV

> Парит высоко в небе и поэтому может быть атакован только крылатыми насекомыми и жуками оснащёнными дальнобойным орудием.

**Assets:** `original/116.png` (level 1), `original/117.png` (level 2), `original/118.png` (level 3), according to user mapping.

**Screenshot evidence:** `ziva-attachment:h507Z2L_UEz76TW_Azgwt`

**Status:** `SCREENSHOT_CONFIRMED` / `USER_REPORTED` asset mapping.

### Beacon

> Маяк приманивает своим светом менее интеллигентных жучков. Маяк — очень хорошая ловушка.

**Assets:** `original/128.png` (level 1), `original/129.png` (level 2), `original/130.png` (level 3), according to user mapping.

**Screenshot evidence:** `ziva-attachment:XHJ2JFnKzNiXjct5MIZxg`

**Status:** `SCREENSHOT_CONFIRMED` / `USER_REPORTED` asset mapping.

### Radar Tower

> Радарная вышка повышает радиус видимости, а также обнаруживает невидимых жуков. Это сооружение не имеет оборонительных функций.

**Assets:** `original/122.png` (level 1), `original/123.png` (level 2), `original/124.png` (level 3), according to user mapping.

**Screenshot evidence:** `ziva-attachment:y72GXkEytl9nPQq00z2dx`

**Status:** `SCREENSHOT_CONFIRMED` / `USER_REPORTED` asset mapping.

### Plasma Tower

> Улучшенная лазерная башня, имеет более высокий радиус поражения и наносит более сильное энергетическое повреждение.

**Assets:** `original/131.png` (level 1), `original/132.png` (level 2), `original/133.png` (level 3), according to user mapping.

Each asset contains eight turret orientations for firing in different directions. The exact orientation order within each asset remains to be mapped.

**Screenshot evidence:** `ziva-attachment:0SzsNhBZlrnWhe7WWUh_v`

**Status:** `SCREENSHOT_CONFIRMED` / `USER_REPORTED` asset mapping.

### Fire Tower

> Низкий радиус поражения, но очень высокое огневое повреждение.

**Assets:** `original/107.png` (level 1), `original/108.png` (level 2), `original/109.png` (level 3), according to user mapping.

Each asset contains eight separately drawn turret orientations for firing in different directions. The exact orientation order within each asset remains to be mapped.

**Screenshot evidence:** `ziva-attachment:WFPtFvxfqWHYL1TV9rBVi`

**Status:** `SCREENSHOT_CONFIRMED` / `USER_REPORTED` asset mapping.

### Soldiers

> Сначала в твоём распоряжении находятся только солдаты. Они стреляют во всё, что движется. Солдаты наносят пулевое повреждение. После модернизации они спрячутся в бункерах.

**Assets:** `original/110.png` (level 1), `original/111.png` (level 2), `original/112.png` (level 3), according to user mapping.

The soldier sheets contain multiple directional and action images. They include idle/rest states and shooting states across several directions, so they should be treated as directional animated units rather than single static sprites. Exact direction/frame ordering remains to be mapped from the sheet and runtime behavior.

**Screenshot evidence:** `ziva-attachment:JBSul8J8e6_cA_AwJMpWx`

**Status:** `SCREENSHOT_CONFIRMED` for the description; `USER_REPORTED` for animation interpretation and asset mapping.

**User gameplay observation:** Buildings can be upgraded to level 3. Level 1 has `ОЖ 80`, `О 5`, `А 3`, `Р 2` and costs `$500` to build. The level 2 upgrade costs `$600` and adds `ОЖ +20`, `О +5` and `А +1`; level 3 costs `$1000` and adds the same bonuses again. `Р` remains unchanged.

**Observation status:** `USER_OBSERVED`.

### Laser Tower

> Самая слабая башня из твоих оборонительных сооружений. Втором уровне она также наносит огневое повреждение.

**Assets:** shared lower/base part `original/103.png` (also used by the Fire Tower); upper parts by level: `original/104.png` (level 1), `original/105.png` (level 2), `original/106.png` (level 3), according to user mapping.

Each upper-part asset contains approximately five visual frames/states: the first is idle, followed by four charge/preparation states in which the turret progressively fills with a blue-cyan glow. These frames represent a charge-up animation, not the laser projectile itself. The actual laser firing effect is a separate asset or effect and remains unresolved.

**Screenshot evidence:** `ziva-attachment:CJzwJ6oTF1Vfpg28tWS7p`

**Status:** `SCREENSHOT_CONFIRMED` for the description; `USER_REPORTED` for layered asset/state mapping.

### Central Base

> Ты должен всеми силами оборонять центральную базу! Её надо модернизировать, для того чтобы суметь строить новые здания.

**Asset evidence:** `original/100.png`, level 1, according to user mapping.

**Screenshot evidence:** `ziva-attachment:K1hrRNFrJftcJpZHEuHAb`

**Status:** `SCREENSHOT_CONFIRMED` / `USER_REPORTED` asset mapping.

### Energy Station

> Нужна для: лазерной башни, плазменной башни, башни теслы и щитового прикрытия.

**Assets:** `original/113.png`, `original/114.png`, `original/115.png` for levels 1–3, according to user mapping.

**Screenshot evidence:** `ziva-attachment:g1lIzjhhqnSaR0gcaR1xP`

**Status:** `SCREENSHOT_CONFIRMED` / `USER_REPORTED` asset mapping.

### Communication Center

> Нужен для: БПЛА, радарной вышки и сателлита.

**Assets:** `original/138.png`, `original/139.png`, `original/140.png` for levels 1–3, according to user mapping.

**Screenshot evidence:** `ziva-attachment:0_HKvyiA11uS75jeJ4f4w`

**Status:** `SCREENSHOT_CONFIRMED` / `USER_REPORTED` asset mapping.

### Research Station

> Здесь ты можешь исследовать важные технологии, нужные для твоих зданий. Также ты можешь улучшить здесь оборону, радиус повреждения, интенсивность атаки и разработать щитовое прикрытие. Станция исследования является предпосылкой для многих оборонительных сооружений.

**Assets:** `original/119.png`, `original/120.png`, `original/121.png` for levels 1–3, according to user mapping.

**Screenshot evidence:** `ziva-attachment:Kr0mPVWp_6h2jrAMVN1br`

**Status:** `SCREENSHOT_CONFIRMED` / `USER_REPORTED` asset mapping.

## Survival mode — initial on-screen instruction

> Неподалёку обнаружены инопланетные существа! К счастью, атакуют только с одной стороны, которая обозначена на радаре маленькой красной точкой.

**Evidence:** `ziva-attachment:IZj897eehdcTKAIDtdQ_M`

**Status:** `SCREENSHOT_CONFIRMED`; the final wording is completed from context where the lower edge clips the line.

## Game process — original reference

> В начале игры твой корабль стыкуется с центральной базой. Теперь твоё главное задание — оборона этого важного сооружения. После модернизации таких зданий как центральная база, тебе откроются новые технологии и оборонительные сооружения. Применяй их умело, чтобы выстоять определённое количество атак. После этого ты перейдёшь в следующий уровень и получишь новое ответственное задание. В это время твой прогресс и разработанные технологии будут сохранены и ты можешь использовать их и в будущем.
>
> В модусе «Атака Марса» ты начнёшь игру на случайной карте. Игра будет длиться пока враги не уничтожат твою базу.

The final visible sentence is cut off at the bottom of the supplied screenshot; the missing remainder is not reconstructed here.

**Evidence:** `ziva-attachment:n0cRNJXExNAXcUpI-HjGn`

**Status:** `SCREENSHOT_CONFIRMED` for visible text; `PARTIAL_CAPTURE` for the page ending.

## Controls — original keypad reference

> Клавиша навигации влево, 4. Курсор влево
>
> Клавиша навигации вправо, 6. Курсор вправо
>
> Клавиша навигации вверх, 2. Курсор вверх
>
> Клавиша навигации вниз, 8. Курсор вниз
>
> 1: Курсор влево и вверх
>
> 3: Курсор вправо и вверх
>
> 7: Курсор влево и вниз
>
> 9: Курсор вправо и вниз
>
> #: Дополнительные действия
>
> *: Вернуться на центральную базу
>
> Левая экранная клавиша, Центральная клавиша навигации: Выбор
>
> Правая экранная клавиша: Закрыть, назад, отменить
>
> 0: Пауза

**Evidence:** `ziva-attachment:buSdNqJZubPqi5lw5JvwG`

**Status:** `SCREENSHOT_CONFIRMED`

### Android remake interpretation

This is valuable as original input evidence, but the remake should not copy the numeric keypad literally as the primary Android interface. It maps naturally to:

- virtual D-pad or swipe/drag navigation;
- tap/select for the center key;
- back/cancel button for the right soft key;
- context/action button for `#`;
- return-to-base control for `*`;
- pause button for `0`.

The original key bindings should remain available in a compatibility/control-reference page.

## Additional Actions — original reference

The Help menu lists these subsections:

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

**Evidence:** `ziva-attachment:zynLVuAsWdh5q_KKmqGoS`

**Status:** `SCREENSHOT_CONFIRMED` for the index. Individual descriptions and mechanics are pending their respective pages.

### Additional Actions — Basics

> За каждого уничтоженного врага ты получаешь очки опыта. Если ты имеешь достаточно очков опыта, тебе присвоят новое звание, и ты получишь новое дополнительное действие. Ты можешь активировать его в соответствующем здании и при желании применить.

**Evidence:** `ziva-attachment:DDoJhfMiep-nAJ4kMTYUJ`, `ziva-attachment:8swMQiAOuWbmXsPPnfwdg`

### Разведывательный полёт

> Поле боя будет на короткое время полностью раскрыто.

**Evidence:** `ziva-attachment:8ivrakwFcEMPl_bLp5-lG`

**Status:** `SCREENSHOT_CONFIRMED`. The icon is part of the shared `600.png` asset.

### Быстрый ремонт

> Выбери одно здание, и оно будет сразу отремонтировано.

**Evidence:** `ziva-attachment:BKRV_xfq1eHQbMT9irwnK`

### Бомба

> Бомба наносит сильное повреждение врагу, а также может повредить собственные здания.

**Evidence:** `ziva-attachment:KPlqhlJQpgIiQeLDPb8jv`

### Быстрая смерть

> Следующее попадание сразу уничтожит врага.

**Evidence:** `ziva-attachment:yu0YkAYZLwTaYb6c6mist`

### Парализующие лучи

> Парализует всех врагов на короткое время.

**Evidence:** `ziva-attachment:815Q0Dv4huP512Zh-b2v_`

### Ядовитый газ

> В выбранном районе образуется газовое облако. Враги, находящиеся в этом районе, обретут медленную смерть.

**Evidence:** `ziva-attachment:z3eozRFzhQtD9aJ8zOh4F`

### Суперщит

> Придаёт твоим зданиям на короткое время дополнительную защиту.

**Evidence:** `ziva-attachment:HeIhejR1jbAGg_XdTKeYe`

### Неразрушимость

> На короткое время твои здания становятся неповредимыми.

**Evidence:** `ziva-attachment:L4rduBMA4ywGL3h1OU50q`

### Бонус радиуса поражения

> Повышает радиус поражения твоих оборонительных сооружений.

**Evidence:** `ziva-attachment:d6VrVcr7WvGZ7svGXJOuk`

### Экстремальная сила повреждения

> На короткое время твои орудия наносят экстремальное повреждение.

**Evidence:** `ziva-attachment:lhin0alrHtTLcUxyj4M6T`

### Оглушительные лучи

> На короткое время враги становятся недееспособными.

**Evidence:** `ziva-attachment:CjF9XjPmHdsZmng11_mS3`

### Интеллигентная бомба

> Ультимативное орудие против всех видов насекомых.

**Evidence:** `ziva-attachment:PVI8ssiVR9LyQ6HdPz9hw`

**Shared asset:** all listed additional-action icons are mapped by the user to `original/600.png`.

## Research — original reference

All research icons shown in this section use `original/600.png` according to the user mapping. The file is a shared research icon sheet/resource; individual icon/frame semantics should be mapped separately if needed.

> В станции исследования можно разрабатывать новые технологии. Они будут автоматически установлены в соответствующем здании. Только щитовое прикрытие надо монтировать вручную.

### Радиус поражения

> Повышает радиус поражения твоих оборонительных сооружений.

### Вооружение

> Повышает оборону всех сооружений.

### Интенсивность атаки

> Твои оборонительные сооружения наносят больше вреда.

### Щитовое прикрытие

> Ты можешь установить щитовое прикрытие на каждом сооружении. Оно поглощает нанесённый ущерб и самостоятельно восстанавливается. При тяжёлом повреждении щитовое прикрытие будет сорвано.

**Evidence:** `ziva-attachment:09NCrOkvoAKijGGIzjBPs`, `ziva-attachment:Q_FD65nejdIbtsMpe_Mlr`

**Status:** `SCREENSHOT_CONFIRMED` for descriptions; `USER_REPORTED` for shared asset mapping.

## Enemies — original reference

The supplied enemy pages show nine enemy entries from top to bottom (with the hidden form and Sand Worm represented by multiple assets). The screenshot does not display enemy names; assets are used as stable identifiers until names or IDs are confirmed elsewhere.

### Enemy 1 — asset 505

> Безобидный вид этих жучков обманчив! Они очень опасны, так как всегда нападают группами.
>
> Выносливость: Пули
>
> Чувствительность: Огонь

### Enemy 2 — asset 504

> Этот вид жучков крупнее, и они более выносливы.
>
> Выносливость: Пули
>
> Чувствительность: Энергетические орудия

### Enemy 3 — asset 502

> Эти ловкие бесы стреляют лучами из своих глаз.
>
> Выносливость: Огонь
>
> Чувствительность: Пули

### Enemy 4 — asset 507

> Очень противное чудовище, которое разбрызгивает кислоту своей задницей ... нашим зданиям.
>
> Выносливость: Энергетические орудия
>
> Чувствительность: Пули

The middle phrase in the acid sentence is not fully reliable in the supplied capture; the enemy behavior and resistances are clear, but the exact wording is left incomplete rather than invented.

### Enemy 5 — asset 503

> Летающее насекомое оснащённое дальнобойным орудием.
>
> Выносливость: Огонь
>
> Чувствительность: Энергетические орудия

### Enemy 6 — asset 506

> Мощная матка! Даже если тебе удастся уничтожить её, её отпрыски не оставят тебя так просто в покое.
>
> Выносливость: Пули
>
> Чувствительность: Огонь

**Evidence:** `ziva-attachment:v8L4oFxHfIZln7m7eDTvZ`

**Status:** `SCREENSHOT_CONFIRMED` for visible descriptions and resistance labels; exact enemy names remain `UNRESOLVED`.

### Enemy 7 — asset 501

> Из жала этого насекомого капает ядовитая кислота.
>
> Выносливость: Огонь
>
> Чувствительность: Энергетические орудия

### Enemy 8 — assets 512 and camouflage 513

> Это особо опасное существо может очень хорошо прятаться.
>
> Выносливость: Энергетические орудия
>
> Чувствительность: Огонь

`513.png` is recorded as the camouflage/hidden visual associated with `512.png`.

### Enemy 9 — Sand Worm, assets 508–511

> Песчаный червь: В него очень тяжело попасть, так как он передвигается в основном под землёй.
>
> Выносливость: Огонь
>
> Чувствительность: Пули

The four assets `508.png`–`511.png` are recorded as the Sand Worm visual set, likely covering its visible/action cycle; exact frame order remains to be mapped.

**Additional evidence:** `ziva-attachment:6EPRRx755iA56-kD0RogX`

## Planned Help chapters

The remake Help section should be assembled as separate chapters so each chapter can be validated against later screenshots:

- Game objective and Mars survival mode;
- controls and cursor interaction;
- construction and placement;
- building levels and upgrades;
- building statistics: `ОЖ`, `О`, `А`, `Р`;
- repair and demolition rules;
- defensive structures and research stations;
- soldiers/defenders;
- enemy waves and attack warnings;
- fog, minimap and victory/defeat conditions.

Uncaptured chapters must not be presented as original quoted text. They should be marked as `PENDING_SCREENSHOT` or written as clearly labelled remake guidance until evidence is supplied.
