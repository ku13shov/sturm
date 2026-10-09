# STURMTRUPP MARS — CHANGELOG / RESEARCH CORRECTIONS

## Добавлена отдельная физическая кнопка паузы

Поскольку основной HUD скрывается portrait-layout контроллером, кнопка паузы перенесена в отдельный корневой `PauseTouchButton`. Она всегда отображается поверх игры в нижнем левом углу и подключается непосредственно к `_toggle_pause`, независимо от видимости legacy HUD.

Изменены: `scenes/gameplay/graybox_vertical_slice.tscn`, `scripts/graybox_vertical_slice.gd`, `scripts/portrait_survival_layout.gd`.


## Добавлена мобильная кнопка паузы и исправлена статистика

Кнопка `ПАУЗА` снова отображается в portrait gameplay в правом нижнем углу и работает как сенсорная альтернатива Escape/старой клавише 0. Карточка паузы увеличена, статистика игрока вынесена в отдельный блок, а системное сообщение перемещено ниже, чтобы строки «Продержался», «Очки», «Уровень» и «Чин» не перекрывались.

Изменены: `scripts/portrait_survival_layout.gd`, `scenes/ui/pause_menu.tscn`.


## Статистика игрока в паузе

В меню паузы добавлена статистика по образцу оригинала: время выживания, очки, уровень игрока и чин. Игрок начинается с уровня 1, звание отображается как «Сержант», очки начинаются с 0. Очки увеличиваются на 1 за уничтоженного жука. Кнопка `ПАУЗА` остаётся мобильным способом открыть экран вместо старой клавиши 0.

Изменены: `scenes/ui/pause_menu.tscn`, `scripts/graybox_vertical_slice.gd`.


## Баланс первой волны и HP жука

Количество жуков в первой волне изменено с 2 на 10 как временное приближение к сообщаемому оригинальному значению (10–12). Последовательность graybox-волн теперь: `10, 12, 14, 16, 18, 20`. HP базового жука дополнительно уменьшено с 30 до 25, чтобы увеличенное количество противников не превращало первую волну в чрезмерно долгую. Оба параметра остаются `TEMPORARY_BALANCE`; точные оригинальные значения волн ещё не подтверждены документацией.

Изменены: `scenes/gameplay/graybox_vertical_slice.tscn`, `data/game_balance.gd`.


## Автоматический запуск следующих волн

Убрана необходимость нажимать кнопку начала атаки. После уничтожения всех жуков текущей волны запускается межволновый таймер на 8 секунд, затем следующая волна начинается автоматически. В сцене сохраняются 6 временных волн: `2, 3, 4, 5, 6, 8` жуков.

Изменены: `scripts/graybox_wave_manager.gd`, `scenes/gameplay/graybox_vertical_slice.tscn`.


## Уточнено отвлечение жуков на здания

Логика изменена с проверки «только здания на линии движения» на радиус интереса. Пока вторичная цель не выбрана, база имеет приоритет, если находится в радиусе интереса жука. Если база вне радиуса, жук может выбрать ближайшее живое оборонительное здание в радиусе 150 пикселей. После того как жук дошёл до вторичной цели и начал её атаковать, цель фиксируется до уничтожения здания; затем жук снова выбирает базу или доступную вторичную цель.

Изменены: `scripts/graybox_vertical_slice.gd`, `scripts/graybox_bug.gd`.


## Уточнено поведение целей жуков

Исправлена логика приоритета: база остаётся стратегической целью, но теперь жук выбирает ближайшее оборонительное здание, если оно находится непосредственно в коридоре движения между жуком и базой. Жук атакует такое здание до его уничтожения, после чего пересчитывает маршрут и продолжает движение к базе или следующему зданию на пути. Здания сбоку от маршрута не становятся целью.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Исправлен приоритет цели жуков

Жуки больше не могут выбирать защитное здание как стратегическую цель. Их целевой объект теперь всегда `CentralBase`: энергостанция и солдаты остаются оборонительными объектами, которые могут наносить урон и физически мешать проходу, но не перетягивают цель с базы. Это устраняет ситуацию, когда жук обходил базу и шёл атаковать солдат позади неё.

Изменены: `scripts/graybox_vertical_slice.gd`.


## Debug-радиус привязан к CollisionShape2D

Убран отдельный жёлтый радиус выбора. Теперь при наведении отображается один оранжевый круг, рассчитанный из реального `CollisionShape2D` объекта. Радиус используется и для определения наведения: база и здания больше не используют независимые ручные значения выбора. Радиус атаки боевых зданий по-прежнему отображается отдельным голубым кругом.

Для прямоугольной формы используется радиус описанной окружности, чтобы вся форма гарантированно попадала внутрь физической зоны. Если у нового ассета изменится `CollisionShape2D`, debug-граница обновится автоматически.

Изменены: `scripts/graybox_hover_debug.gd`, `scripts/graybox_vertical_slice.gd`.


## Усилено ограничение строительства рядом с базой

Исправлено наложение Energy Station на Central Base. Ранее проверка строительства использовала общий радиус базы 80 пикселей, который был достаточен для выбора, но недостаточен для физического разнесения крупных объектов. Для Energy Station введён временный радиус свободной зоны 140 пикселей от центра базы; для остальных зданий используется 110 пикселей. Debug-радиус Energy Station также отображает увеличенную занимаемую зону 64 пикселя.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Временная визуализация радиусов объектов

Добавлен отключаемый по состоянию наведения debug-слой `HoverDebugRadii`. При наведении показываются: жёлтый радиус выбора/информации, красный радиус занимаемой зоны, голубой радиус атаки для боевых зданий. Для центральной базы используются радиусы 80/70, для зданий — временные значения 80/48. Это инструмент разработки и не является подтверждёнными оригинальными параметрами.

Добавлены: `scripts/graybox_hover_debug.gd`, узел `HoverDebugRadii` в gameplay-сцене и обновление hover-логики в `scripts/graybox_vertical_slice.gd`.


## Исправлена зона выбора центральной базы

Зона наведения и выбора центральной базы уменьшена с 150 до 80 пикселей. Ранее база считалась выбранной на заметном расстоянии от визуального объекта, из-за чего свободные клетки рядом с базой не открывали меню строительства. Изменение применено и к наведению, и к клику.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Исправлена ошибка Nil при зуме

После очистки TestHUD gameplay-скрипт всё ещё обращался к его контейнеру через `test_hud_panel.visible`. Из-за временного `null` при обработке ввода это вызывало `Invalid access to property or key 'visible' on a base object of type 'Nil'`. Ссылка восстановлена на пустой скрытый контейнер TestHUD; тестовые элементы и кнопки при этом не возвращены.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Дополнительно уменьшено HP basic bug

Для улучшения темпа боя HP basic bug в graybox-балансе уменьшены с 40 до 30. Солдаты сохраняют свои текущие характеристики, а оригинальные исследовательские значения не изменяются. Параметр остаётся `TEMPORARY_BALANCE`.

Изменён: `data/game_balance.gd`.


## TestHUD полностью очищен

Удалены все тестовые кнопки и подписи TestHUD, а также подключения их сигналов в gameplay-скрипте. В сцене оставлен только пустой скрытый контейнер для будущих диагностических инструментов. Удалена видимая кнопка открытия TestHUD, поэтому она больше не может конфликтовать с меню строительства или запускать устаревшие тестовые действия.

Изменены: `scenes/gameplay/graybox_vertical_slice.tscn`, `scripts/graybox_vertical_slice.gd`.


## Временно очищен TestHUD

TestHUD оставлен в сцене как контейнер для будущих диагностических инструментов, но все его дочерние элементы сейчас скрыты. Кнопка `DEBUG` больше не открывает рабочие тестовые команды и не должна запускать меню строительства: для неё установлен `MOUSE_FILTER_STOP`, чтобы нажатие не проходило к элементам под ней. Реальные debug-инструменты будут добавляться позже по одному после проверки.

Изменён: `scripts/portrait_survival_layout.gd`.


## Очищен основной gameplay-интерфейс

Из текущего Vertical Slice убраны из обычного отображения debug-маркеры границ карты, старый нижний HUD и ContextPanel. `TestHUD` оставлен доступным через небольшую кнопку `DEBUG` в нижнем левом углу. Основной gameplay теперь показывает только карту, верхнюю плашку объекта, баланс, миникарту, строительство и необходимые игровые сообщения.

Изменены: `scenes/gameplay/graybox_vertical_slice.tscn`, `scripts/portrait_survival_layout.gd`.


## Смягчён basic bug для тестового баланса

По результатам текущего игрового теста Soldier L1 слишком долго уничтожает basic bug. В отдельном `GRAYBOX_ENEMY_BALANCE` HP basic bug уменьшены с 75 до 40, а временное сопротивление пулям установлено в 0%. Оригинальные сопротивления и значения `rA` не изменялись; это исключительно `TEMPORARY_BALANCE` для playable-среза.

Изменены: `data/game_balance.gd`, `scripts/graybox_vertical_slice.gd`.


## Зафиксирована политика визуальной интерпретации баланса

Для параметров, которые нельзя надёжно восстановить из оригинального JAR, bytecode, таблиц или контролируемых наблюдений, разрешена визуальная/игровая интерпретация. Такие значения не считаются оригинальными: они будут помечаться `ORIGINAL_INFERRED` или `TEMPORARY_BALANCE`, затем сведены в отдельную таблицу и отбалансированы по результатам тестирования. Повышать их статус до `ORIGINAL_CONFIRMED` нельзя без новых доказательств.

Обновлён: `MD/SOURCE_OF_TRUTH.md`.


## Выделен отдельный graybox-баланс врагов

Добавлена таблица `GameBalance.GRAYBOX_ENEMY_BALANCE`, отделённая от оригинальных `ENEMY_PROFILES`. Для basic bug ID 70 временно заданы: HP 75, урон 3, интервал атаки 1.5 с, скорость 42, радиус обнаружения 150 и награда 25. Эти значения имеют статус `TEMPORARY_BALANCE` и не заменяют исследованные данные оригинала. Жук получает параметры из таблицы при спавне.

Изменены: `data/game_balance.gd`, `scripts/graybox_vertical_slice.gd`, `scripts/graybox_bug.gd`.


## Продолжена трассировка runtime-профилей

Подтверждено по bytecode, что `lA[entity][5]` является runtime-индексом типа `mA`, через который выбирается conventional attack behavior. Прямого присваивания, замыкающего enemy ID 70 на конкретную строку `lA` и компоненты `lA[1..3]`, в текущем аудите пока не найдено. Финальный урон basic bug по солдату остаётся `UNRESOLVED`.


## Уточнена семантика `rA[][4]`

Bytecode-трассировка `C.A(int,int)` показала, что conventional damage formula читает атакующие компоненты `lA[attacker][1..3]` и сопротивления цели `rA[target][5..7]`; поле `rA[][4]` в финальном HP-вычитании не используется. Поэтому значение `200` для ID 70 больше не помечается как прямой урон за удар: его семантика — `ORIGINAL_INFERRED`, а финальный урон basic bug по солдату остаётся `UNRESOLVED` до восстановления mapping enemy runtime type → `lA`.


## Добавлен forensic research report

Создан `MD/ORIGINAL_RESEARCH_REPORT.md`: инвентаризация `res://original/`, подтверждённые таблицы `rA`/`oA`, уровни достоверности и незамкнутые вопросы. Баланс и runtime-поведение не изменялись.


## Исправлен маркер точки спавна на миникарте

Маркер теперь создаётся сразу при запуске с предварительно выбранной точкой будущего спавна. Перед началом каждой волны выбирается новая точка, и все жуки этой волны появляются именно там. Координаты маркера нормализуются и ограничиваются внутренними границами миникарты, поэтому точка не выходит за её пределы даже при спавне за краем игрового поля.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Награда за жуков и фиксация цели базы

Награда за уничтожение жука уже была реализована: `25 $` (`TEMPORARY_BALANCE`) и +1 опыт через `_on_bug_died`. Исправлено поведение цели: после того как жук достиг базы и начал её атаковать, устанавливается `base_engaged`, и поиск новых башен отключается. Поэтому строительство башни рядом с уже атакуемой базой больше не переключает внимание жука.

Изменён: `scripts/graybox_bug.gd`.


## Исправлен возврат жуков после уничтожения цели

Причина остановки найдена в fallback-логике: после уничтожения башни жук передавал уже мёртвую башню как запасную цель, а поиск возвращал её снова. Теперь fallback всегда проверяется по здоровью; при уничтоженной башне выбирается центральная база. Урон дополнительно уменьшен с `0.25` до `0.1` (`TEMPORARY_BALANCE`).

Изменены: `scripts/graybox_vertical_slice.gd`, `scripts/graybox_bug.gd`.


## Исправлена атака жуков и возврат к базе

Урон жуков в graybox-режиме уменьшен множителем `0.25` (`TEMPORARY_BALANCE`): исходные значения профиля сохранены, но в текущем вертикальном срезе атака больше не уничтожает объекты слишком быстро. Исправлен порядок обновления цели: жук теперь сначала запрашивает актуальную цель, а уже затем проверяет её здоровье. После уничтожения башни он корректно переключается обратно на базу и продолжает движение.

Изменён: `scripts/graybox_bug.gd`.


## Переработаны спавн и поведение жуков

Жуки волновых атак теперь случайно появляются за одной из четырёх границ карты: сверху, справа, снизу или слева, с случайной координатой вдоль выбранной стороны. Мигание `AttackMarker` переносится на соответствующую координату миникарты. Жук получает путь к базе и временно переключается на ближайшее здание в радиусе `150` пикселей, после уничтожения цели возвращаясь к движению к базе. Значения границы спавна и радиуса отмечены как `TEMPORARY_BALANCE`.

Изменены: `scripts/graybox_vertical_slice.gd`, `scripts/graybox_bug.gd`.


## Исправлена причина «зависания» через 10–15 секунд

Причина подтверждена: жуки доходили до базы и наносили ей урон `200` за атаку; после уничтожения базы устанавливался `game_over = true`, поэтому строительство и карта блокировались. Визуально это выглядело как зависание, поскольку экран поражения не был очевиден. Добавлена стартовая задержка первой волны `12 секунд` (`TEMPORARY_BALANCE`), чтобы успеть разместить оборону до подхода жуков. После уничтожения базы игровая блокировка остаётся штатной.

Изменён: `scripts/graybox_wave_manager.gd`.


## Исправлено блокирование строительства после выбора базы

Найден баг: hover/тап по базе устанавливал `base_selected = true`, а это состояние отключало кнопку строительства. На мобильном устройстве при отсутствии движения мыши состояние могло сохраняться, из-за чего спустя время нельзя было начать строительство. Теперь вход в build mode всегда сбрасывает выбор базы, а кнопка строительства не блокируется только из-за выбранной базы.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Исправлено ощущение зависания при запуске в Godot

Стартовый экран командира раньше ставил весь SceneTree на паузу ещё до подтверждения. В embedded playtest Godot это могло выглядеть как зависание и мешать вводу. Теперь gameplay по-прежнему заблокирован флагом `intro_pending`, но SceneTree остаётся активным, поэтому окно запуска и ввод в Godot не зависают. Волна стартует только после подтверждения.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Добавлена защитная зона вокруг зданий

Запрещено строительство вплотную и внахлёст. Солдаты занимают одну клетку и дополнительно блокируют одну клетку по периметру — фактическая зона запрета `3×3`. Энергостанция и остальные большие объекты занимают `2×2` и дополнительно блокируют по одной клетке вокруг — зона запрета `4×4`. Освобождение всей зоны выполняется при продаже здания.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Добавлены разные площади строительства

Площадь занятости теперь зависит от типа объекта. Солдаты используют footprint `1×1`, энергостанция — `2×2`, остальные крупные/боевые объекты — временный footprint `2×2` до подтверждения оригинальных размеров. Preview показывает соответствующий прямоугольник, а все клетки footprint блокируются и освобождаются при продаже.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Обновлён стиль плашки объекта

Информационная плашка сделана непрозрачной и стилистически приближена к старому интерфейсу: тёплый бежевый фон, тёмная рамка, отдельная иконка и красная полоска HP под иконкой. Полоса получает максимум и текущее здоровье выбранного объекта или базы.

Изменены: `scenes/gameplay/graybox_vertical_slice.tscn`, `scripts/graybox_vertical_slice.gd`.


## Исправлен порядок слоёв информационной плашки

`RetroTopStrip` получил `z_index = 20`, поэтому плашка объекта теперь находится поверх миникарты и баланса (`z_index = 6/8`) и не перекрывается ими.

Изменён: `scenes/gameplay/graybox_vertical_slice.tscn`.


## Плашка полностью скрывается вне объекта

При уходе курсора с объекта теперь скрывается вся верхняя информационная плашка, а не только сбрасывается её текст. Она снова становится видимой только при наведении или выборе базы/здания.

Изменены: `scripts/graybox_vertical_slice.gd`, `scripts/portrait_survival_layout.gd`.


## Плашка скрывается при уходе курсора

Информационная плашка теперь очищается, когда курсор покидает базу или выбранное здание. При наведении на объект данные снова появляются; при тапе на мобильном устройстве выбор сохраняется до следующего действия.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Включена верхняя плашка выбора объекта

Причина отсутствия информации найдена в `portrait_survival_layout.gd`: при портретной раскладке `RetroTopStrip` принудительно скрывался (`visible = false`). Плашка включена обратно. Также расширена зона попадания для современной базы и крупных спрайтов, поэтому hover и тап теперь корректно выбирают объект.

Изменены: `scripts/portrait_survival_layout.gd`, `scripts/graybox_vertical_slice.gd`.


## Исправлен выбор крупных объектов

Информационная плашка не обновлялась при попадании курсора рядом с объектом, потому что радиус проверки оставался рассчитанным на старый маленький graybox-визуал. Радиус базы увеличен до `150`, радиус зданий — до `72`. Теперь современные крупные спрайты корректно выбираются наведением и тапом.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Добавлена информационная плашка объекта

При наведении курсора на базу или здание верхняя плашка теперь обновляет название, иконку и текущие характеристики. Добавлена иконка объекта слева. Для боевых объектов отображаются ОЖ, О, А и Р; для энергостанции боевые параметры не выводятся. Характеристики здоровья используют текущее значение, поэтому полученный урон отображается корректно (например, 356/400).

Изменены: `scripts/graybox_vertical_slice.gd`, `scenes/gameplay/graybox_vertical_slice.tscn`.


## Исправлено подключение современной базы в gameplay

Gameplay-сцена напрямую инстанцировала старую `graybox_base.tscn`, поэтому замена шаблона не влияла на отображение. `graybox_vertical_slice.tscn` теперь напрямую использует `graybox_modern_central_base.tscn`.


## Центральная база заменена на современный ассет

Создана игровая сцена `graybox_modern_central_base.tscn` на основе подготовленных ассетов `central_base_l1.webp` и `central_base_l1_lights_overlay.png`. Сохранены gameplay-скрипт базы, здоровье, защита, collision и скрытая полоса здоровья. Шаблон `graybox_central_base_template.tscn` теперь использует современную базу вместо `original/100.png`. Showcase-сцена не изменялась.

Масштаб визуала: `0.18` (`TEMPORARY_VISUAL_SCALE`), collision адаптирован под новый размер.


## Убраны случайные синие элементы после строительства

Исправлено восстановление видимости дочерних узлов после завершения строительства. Теперь `RangeIndicator` и `UpgradeAccent` возвращаются к исходному состоянию сцены, поэтому случайные синие ромбы и радиусы не появляются у солдат или энергостанции. Полоса здоровья базы скрыта в обычном состоянии и больше не отображается как постоянная синяя линия.

Изменены: `scripts/graybox_vertical_slice.gd`, `scenes/graybox/graybox_base.tscn`.


## Сохранена исходная позиция начала строительства

Исправлен переход из меню выбора здания в режим размещения. Теперь экранная позиция первого тапа по свободной клетке сохраняется отдельно и используется для начального положения preview. После выбора здания курсор/объект больше не перескакивает ближе к базе; перемещение начинается именно с исходной точки, после чего повторный тап подтверждает строительство.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Добавлено визуальное строительство с прогрессом

При размещении здания теперь создаются постоянная площадка и строительный визуал: малые объекты используют `145.png + 147.png`, крупные — `146.png + 148.png`. Под строительным объектом отображается горизонтальная прогресс-полоса. На время строительства боевые визуалы и combat отключены; после заполнения полосы строительный модуль исчезает, готовое здание появляется поверх оставшейся площадки. Временная длительность: 2 секунды для малых объектов и 3 секунды для крупных.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Радиус атаки сделан круговым, энергостанция исключена из боевых радиусов

Индикаторы дальности башен и солдат теперь формируются как круги из 32 точек вместо вытянутых эллиптических/многоугольных форм. Энергостанция отключена от боевой логики и больше не показывает радиус атаки.

Изменены: `scripts/graybox_tower.gd`, `scenes/graybox/graybox_energy_station.tscn`.


## Исправлен двухэтапный выбор места строительства

После подтверждения здания в строительном меню объект больше не создаётся немедленно. Игра теперь переходит в режим размещения: выбранный юнит и крестообразный preview следуют за перемещением пальца/курсора, а повторный тап по доступной клетке подтверждает строительство. Добавлена подсказка о необходимости повторного нажатия.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Реализован первый оригинальный flow строительства

Строительное меню graybox приведено к скриншотам оригинала: первоначально доступны только Солдаты L1 и Энергостанция L1. Добавлена информационная панель с расходами и характеристиками. Для энергостанции показываются только `ОЖ` и `О`, без `А` и `Р`; для солдат — `ОЖ`, `О`, `А`, `Р`. Подтверждены значения: Солдаты — `500 $`, `ОЖ 80`, `О 5`, `А 3`, `Р 2`; Энергостанция — `1500 $`, `ОЖ 400`, `О 15`. Предпросмотр строительства заменён на крестообразную область, повторный тап подтверждает размещение.

Изменены: `scripts/graybox_vertical_slice.gd`, `data/game_balance.gd`, `scenes/ui/build_palette_popup.tscn`, `scenes/gameplay/graybox_vertical_slice.tscn`.


## Размер объектов отделён от стартового zoom карты

Стартовый масштаб карты возвращён к `1.0`, диапазон camera zoom установлен `0.75–1.5`. Убрано принудительное масштабирование всего `Entities` при запуске. Визуальные узлы объектов уменьшены примерно на 35% независимо от логики: база `4× → 2.6×`, Fire Tower base `3× → 1.95×`, turret `2× → 1.3×`, Soldiers `2.5× → 1.625×`, визуальная часть врага и его HP bar — `0.65×`. Коллайдеры, grid и gameplay-радиусы не изменены.

Изменены: `scripts/graybox_vertical_slice.gd`, `scenes/graybox/graybox_base.tscn`, `scenes/graybox/graybox_tower.tscn`, `scenes/graybox/graybox_soldier_defender.tscn`, `scenes/graybox/graybox_bug.tscn`.


## Исправлено центрирование базы при уменьшенном zoom

Портретный layout теперь учитывает масштаб `Entities` при вычислении экранной позиции базы. База центрируется по фактическому визуальному положению, а не по локальным координатам. При этом башни и враги получают соответствующее локальное смещение, а повторное изменение размера окна не накапливает смещение.

Изменён: `scripts/portrait_survival_layout.gd`.


## Уточнён диапазон масштаба карты

Масштаб карты скорректирован для более компактного отображения объектов: значение по умолчанию `0.5`, минимальное `0.3`, максимальное `1.0`. Визуальный масштаб базы остаётся `4×`, логические размеры и коллайдеры не изменяются.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Настроен меньший масштаб карты по умолчанию

Визуальный масштаб центральной базы возвращён к `4×`. Для уменьшения общего размера объектов изменён масштаб карты: значение по умолчанию теперь `0.65`, минимальное — `0.5`, максимальное — `1.25`. Масштабирование применяется согласованно ко всем объектам карты, без изменения их логических размеров и коллайдеров.

Изменены: `scripts/graybox_vertical_slice.gd`, `scenes/graybox/graybox_base.tscn`.


## Добавлены zoom карты и уменьшен спрайт базы

Добавлено масштабирование карты через `InputEventMagnifyGesture` для Android и колесо мыши для desktop-проверки. Диапазон масштаба: `0.75–1.5`, HUD и мини-карта не масштабируются. Панорамирование и границы пересчитываются с учётом текущего zoom. Центральная база визуально уменьшена с масштаба `4×` до `3×`; логический размер и коллайдер не изменены. Для Android включена генерация pan/scale gesture-событий.

Изменены: `scripts/graybox_vertical_slice.gd`, `scenes/graybox/graybox_base.tscn`, `project.godot`.


Добавлено масштабирование карты через `InputEventMagnifyGesture` для Android и колесо мыши для desktop-проверки. Диапазон масштаба: `0.75–1.5`, HUD и мини-карта не масштабируются. Панорамирование и границы пересчитываются с учётом текущего zoom. Центральная база визуально уменьшена с масштаба `4×` до `3×`; логический размер и коллайдер не изменены.

Изменены: `scripts/graybox_vertical_slice.gd`, `scenes/graybox/graybox_base.tscn`.


## Полноэкранный адаптивный режим для Android

Для проверки на реальном устройстве переключено масштабирование на `Canvas Items + Expand + Fractional`, включён полноэкранный режим окна. Это устраняет внутренние чёрные поля, возникавшие из-за `Viewport + Integer`, и позволяет игре занимать доступную площадь дисплея. Системные панели Android дополнительно контролируются параметрами Android Export Preset: `Screen > Immersive Mode` следует включить для полного скрытия status/navigation bar.

Изменён: `project.godot` через Project Settings.


## Уточнён режим масштабирования pixel-art

После проверки направления проекта уточнено: для оригинальных пиксельных ресурсов выбран `Viewport` вместо `Canvas Items`, сохранён `Expand`, а режим масштаба переключён на `Integer`. Это предотвращает неравномерное дробное масштабирование пикселей на современных экранах. Базовое разрешение остаётся `432×768`, ориентация — Portrait.

Изменён: `project.godot` через Project Settings.


## Настройки масштабирования под современные устройства

Для портретной версии настроено адаптивное масштабирование: `Canvas Items`, аспект `Expand` и дробный режим масштаба. Это позволяет использовать доступную площадь современных экранов с различными соотношениями сторон без принудительных чёрных полос и без неравномерного растяжения. Окно также сделано изменяемым для корректной проверки разных размеров устройств.

Базовый дизайн сохранён `432×768`, ориентация — Portrait.

Изменён: `project.godot` через Project Settings.


## Размер области панорамирования увеличен в два раза

Размер отображаемой области карты для панорамирования увеличен минимум в 2 раза по ширине и высоте. Логическая сетка `64×64` и размер клетки не изменены: увеличение относится к presentation-границам карты, чтобы расширить доступное игровое пространство без изменения подтверждённой логики оригинальной сетки.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Исправлен симметричный диапазон вертикальной панорамы

Границы панорамирования теперь рассчитываются относительно позиции центральной базы, а не относительно локального нуля карты. Благодаря этому база находится в центре карты и получает сопоставимый запас перемещения вверх и вниз. Координаты мини-карты синхронизированы с тем же началом карты.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Исправлена граница маркера базы на мини-карте

Маркер центральной базы на мини-карте теперь принудительно ограничивается её прямоугольником и не может выходить за пределы даже при панорамировании карты до края. Прямоугольник видимой области также ограничивается размерами мини-карты. Проверено в запущенной сцене.

Изменён: `scripts/graybox_vertical_slice.gd`.


## Миникарта: область обзора и маркер базы

Индикаторы `КРАЙ` на границах игрового поля отключены как недостаточно заметные. На мини-карту добавлены полупрозрачный прямоугольник текущей видимой области и маленький зелёный квадрат, показывающий положение центральной базы. Оба элемента обновляются при панорамировании карты.

Изменены: `scripts/graybox_vertical_slice.gd`, `scenes/gameplay/graybox_vertical_slice.tscn`.


## Карта центрирована и добавлена индикация границ

Исправлено начальное позиционирование graybox-карты: центральная база теперь располагается в центре портретного игрового поля. Панорамирование больше не ограничено только направлениями вправо и вниз — допустимый диапазон рассчитывается относительно фактических границ центрированной карты. Добавлены индикаторы краёв карты, отображаемые при достижении северной, южной, западной или восточной границы.

Изменены: `scripts/graybox_vertical_slice.gd`, `scenes/gameplay/graybox_vertical_slice.tscn`.


## Survival entry and interaction revised from user screenshot evidence

New games now pause before the first wave and show the commander message “Неподалеку обнаружены инопланетные существа”; confirmation begins the attack. Removed the debug/test UI and persistent lower gameplay panel from the standard view. Expanded the graybox playfield to the full portrait viewport, centered the base, retained only minimap/resource balance in the top corners with fog-of-war perimeter, and changed a free-cell tap to open a build picker followed by placement. Live run verified intro confirmation, picker opening and building placement. The terrain remains explicitly graybox, and no unconfirmed original balance values were promoted to confirmed.

## Portrait test overlay and pause flow verified

Corrected the debug Test HUD stacking so it stays above the world sprites without obscuring the normal selection strip, and kept the pause modal hidden until activated. Escape now opens a centered pause dialog with save, continue and main-menu choices; live run confirmed pause/resume and the automatic save status message. Save validation/restore suite passes **9/9** tests. Touch placement and complete between-wave flow were not part of this verification.

## Original-style build/context panel pass completed

Added a scene-authored selection strip, radar marker and bottom context panel. Action buttons are now conditional: Repair appears only for damaged objects, Upgrade/Sell appear only for ordinary selected buildings, and the base has no Sell action. This follows the captured original menu behavior while retaining a touch-friendly side control panel.

## Manual Survival interaction pass completed

Added the buildable Soldier defender scene using `110.png`, removed the automatic starter tower, and made Energy Station, Fire Tower and Soldiers the initial player palette. Added scene-authored top selection strip and radar marker. Verified manual soldier placement and six-wave survival startup in live playtest.

## Prototype changed from showcase/autoplay bias to manual survival play

The first scene was visually a graybox showcase with a starter tower and automatically progressing test waves. The prototype now starts with the base and resources, requires the player to build the defense manually, uses a longer six-wave test run, and keeps automated waves only as the opponent behavior. Added debug-only test shortcuts: `F1` spawn enemy, `F2` damage base, `F3` add credits, `F4` repair base, `D` damage selected tower, `U` upgrade selected tower.

## First retro-inspired prototype pass started

Updated the playable graybox slice toward the confirmed original start: `$2500`, Central Base level 1 with `ОЖ 750` and `О 25`, Russian player-facing HUD labels, and a layered Fire Tower visual using the confirmed `103.png` base plus `107.png` directional upper asset. Unresolved build/combat values remain temporary by design.

## Initial Survival values captured

Recorded `ziva-attachment:T-CYv5ptddj5oQjCmQH7o`: Central Base level 1 shows `ОЖ 750`, `О 25`, and the initial resource counter is `$2500`. Added these as screenshot-confirmed starting values to `SOURCE_OF_TRUTH.md`.

## Initial Survival-mode screen captured

Recorded `ziva-attachment:IZj897eehdcTKAIDtdQ_M` as evidence for the start of Survival mode: central base, revealed Mars area, black unexplored perimeter, defender presence and the one-sided attack warning marked by a small red radar/minimap dot.

## Help evidence capture completed

Completed the current screenshot-based Help capture pass. The register now covers game description, controls, game process, buildings and individual building entries, enemies, research, and all listed additional actions. The future in-game Help UI should consume `res://MD/HELP_CONTENT.md` without presenting invented text as original.

## 2026-09-22 — Documentation split

The former single `Sturmtrupp_Mars_Roadmap_v10.md` was reorganized into:

- `ROADMAP.md` — normative development plan.
- `SOURCE_OF_TRUTH.md` — current confirmed/unresolved reconstruction state.
- `RESEARCH.md` — complete forensic archive, preserving the original document.
- `CHANGELOG.md` — important corrections and reclassifications.

No original research material was discarded; the complete original file is preserved in `RESEARCH.md`.

## Presentation strategy changed to 2.5D

The project no longer requires full 3D models for ordinary units and buildings.
The target presentation is now 2.5D/isometric:

- editable 2D Godot scenes are the default;
- original PNG resources may be used directly where appropriate;
- `AnimatedSprite2D`, sprite sheets, cutout parts, `AnimationPlayer` and
  particles provide animation;
- limited 3D depth elements remain optional;
- the existing basic-bug 3D scene remains a prototype and is not a mandatory
  direction for the complete asset set.

Gameplay data, grid logic, forensic IDs and unresolved balance fields are not
changed by this presentation decision.

## Important forensic corrections preserved from the original research

### Turret/static damage classification

Earlier material associated:

```text
155 → 125
173 → 200
```

with building/static damage.

Later forensic work established that these are special-action/static-effect damage paths and
must not be treated as universal turret Damage.

### `rA` classification

`rA` is the enemy combat matrix:

```text
int[9][16]
offset 12984
enemy IDs 70–78
```

It must not be copied to the twelve building IDs.

### `oA[][7]`

The earlier assumption that `oA[][7]` universally identifies an `mA` category was rejected.
It participates in UI/debug lookup, but the universal category mapping remains unproven.

### `mA`

`mA[type][4]` and `mA[type][5]` remain attack-stat candidates for defensive categories
13/14/15, but UI usage does not by itself prove Damage/Range semantics.

### Current research priority

The next required chain is:

```text
category 13/14/15
→ mA[type][4/5]
→ all consumers
→ target selection
→ range
→ damage
→ cooldown
→ building ID mapping
```

This correction history is intentionally kept separate from the normative roadmap so that old
hypotheses remain visible without becoming current implementation requirements.


## 2026-09-23 — Research Pass 36: `mA` combat semantics corrected

### Confirmed

For the conventional `lA → vA` combat path:

```text
mA[][6]       → Bullet damage component
mA[][7]       → Energy damage component
mA[][8]       → Fire damage component
low16 mA[][14] → target/engagement range
mA[][15]      → attack cooldown / interval
```

The damage chain reaches `vA[target][22] -= damage`, range reaches target acquisition/
validation in `MA()` / `RA()`, and cooldown reaches runtime timer `lA[][19]`.

### Rejected

The previous research direction:

```text
mA[][4] / mA[][5] → primary Damage / Range candidates
```

is rejected.

### Reclassified

```text
mA[][4] → UI-labelled "ОЖ"; HP/life-related candidate, ORIGINAL_INFERRED
mA[][5] → exact semantics UNRESOLVED
```

### Important data check

Rows 36..44 contain:

```text
mA[][6..8] = 0,0,0
low16 mA[][14] = -1
mA[][15] = -1
```

so the old `13/14/15 → [4/5] → Damage/Range` next-step chain is retired.

### New P0 target

```text
building IDs 151..173
→ runtime construction/spawn/upgrade mapping
→ conventional lA/mA combat OR oA/static/special path
→ per-building Damage/Range/Cooldown
```


## 2026-09-23 — Research Pass 37: `oA` effect consumers corrected

### New confirmed activation edge

`HG.class` calls:

```text
C.F(index)
```

from the UI/event action table. `C.F(index)` initializes the runtime state:

```text
oA[index][8] = oA[index][3]
```

Therefore the special `oA` consumers are reachable runtime paths; the earlier C-only call-site search was incomplete because it did not include `HG.class` callers.

### Corrected direct damage values

The bytecode now directly proves:

```text
155 → oA[2][7]  = 750 → vA[][22] -= 750
159 → oA[4][7]  = 800 → vA[][22] -= 800
161 → oA[5][7]  = 1000 → vA[][22] -= 1000
173 → oA[11][7] = 4000 → vA[][22] -= 4000
```

The historical entries:

```text
155 → 125
173 → 200
```

are rejected as direct effect damage and must not be used by the remake.

### Building 157 special effect

`oA` index 3 / building ID 157 reaches `C.M()`'s projectile-hit consumer. When the special state is active, the target's `vA[][22]` can be set to `0`.

This proves a special zero-HP effect but does **not** prove a numeric Damage value of `250`; `oA[3][7]` is not the operand of that HP mutation.

### Current status

```text
Confirmed special-effect damage: 155, 159, 161, 173
Confirmed special zero-HP effect: 157
Damage unresolved: 151, 153, 163, 165, 167, 169, 171
Universal Range: unresolved
Universal Fire Rate: unresolved
```

The next forensic target is the complete `HG action table → C.F(index) → oA state → consumer` mapping for all 12 indices.

## Graybox vertical slice — temporary logic implementation

Added a playable logic slice without treating placeholder values as original data:

- `res://scenes/gameplay/graybox_vertical_slice.tscn` is now the temporary gameplay entry point.
- Added editable placeholder scenes for the central base, fire tower and enemy.
- Added grid-based enemy routing through `MapGrid` and `NavigationSystem`.
- Added tower placement, occupied-cell checks, target selection, attacks, damage and credits.
- Added `GrayboxWaveManager` with three temporary waves, victory and defeat states.
- Added restart flow after defeat/victory.
- Added `MapGrid`/`NavigationSystem` path routing with occupied-cell checks for placements.
- Temporary costs, rewards and wave counts are centralized in `GameBalance.GRAYBOX` and marked `TEMPORARY_BALANCE`.

This slice intentionally does not claim faithful original wave, upgrade, turret damage, range or fire-rate values. The current showcase remains a separate editable presentation sandbox and is not a visual gold master.

## Enemy profile and resistance pass

Added a data-driven `GameBalance.ENEMY_PROFILES` table for enemy IDs 70–78 using the documented `rA` fields from `SOURCE_OF_TRUTH.md` / `RESEARCH.md`:

- base damage;
- attack range;
- bullet, energy and fire resistance components;
- reward-related value;
- source movement-speed field.

The graybox now applies typed `bullet` / `energy` / `fire` damage with percentage resistance reduction. Basic enemy runtime HP and pixel movement conversion remain explicitly temporary because the original HP mapping and coordinate-unit conversion are not closed.

## Building foundation pass

Added `GameBalance.BUILDINGS` records for IDs `151..173` with confirmed Max HP and Cost values. Graybox scenes now expose their source IDs:

- Central base placeholder → building ID `155`;
- Fire tower placeholder → building ID `153`.

Confirmed special/static-effect metadata is recorded only for the documented IDs. Universal building Damage/Range/Fire Rate remains `UNRESOLVED`; graybox tower combat therefore continues to use explicit `TEMPORARY_BALANCE` values. Enemy `rA` profiles are kept separate from building records.

## Graybox building selection and placement

Added a scene-compatible placement selection layer for the graybox slice:

- selected building ID is displayed in the HUD;
- Fire Tower ID `153` can be selected with key `1`;
- placement writes the selected building ID into the instantiated scene;
- source cost and temporary graybox cost are shown separately;
- occupied grid cells still reject placement.

This keeps source economy data visible without silently replacing the temporary graybox economy.

## Building lifecycle pass

Added explicit graybox building states:

```text
built → active → damaged → destroyed
```

Base and tower scenes now expose health/state signals and editable health values. Destroyed towers release their occupied grid cell. A temporary `D` debug input damages the first placed tower so the lifecycle can be verified without inventing enemy-to-building combat semantics.

## Upgrade-state framework

Added the first scene-backed upgrade scaffold for graybox Fire Tower ID `153`:

- editable `upgrade_level` and `upgrade_cost` fields;
- `active → upgraded` state transition;
- temporary upgrade effect: increased damage and reduced fire interval;
- visible `UpgradeAccent` scene node and changed range presentation;
- `U` debug input upgrades the first placed tower;
- original upgrade cost remains `UNRESOLVED`; current cost is explicitly temporary.

## Tower selection and targeted upgrade

Added click/touch-compatible tower selection:

- tapping an existing tower selects it instead of placing another tower;
- HUD shows selected ID, state, level, HP and upgrade cost;
- `U` upgrades the selected tower only;
- `D` damages the selected tower only for lifecycle testing;
- empty playfield taps retain the build behavior.

## Scene-based mobile building actions

Added HUD action buttons to the graybox scene:

- `Upgrade` for the selected tower;
- `Repair` with temporary repair cost;
- `Sell` with temporary refund;
- buttons enable/disable from selected tower state, HP, level and credits;
- all controls are scene nodes and can be replaced by touch-oriented UI later.

The original repair/sell rules and prices remain `UNRESOLVED`; graybox values are explicitly temporary.

## Mobile build mode and placement preview

Added a scene-backed mobile build flow:

- `Build Fire Tower` enters placement mode;
- `Cancel Build` exits placement mode;
- green/red preview shows whether the current cell is available;
- mouse, touch and screen-drag input update the preview;
- placement uses the existing grid occupancy and temporary economy checks;
- successful placement exits build mode automatically.

The current preview is graybox presentation only; final building art remains separate from this gameplay scene.

## Scene-based building palette

Added a compact building palette to the graybox HUD:

- ID `153` Fire Tower is the currently supported selectable/buildable entry;
- IDs `151` and `155` are displayed with source names/costs but remain disabled until their scenes are implemented;
- palette entries are driven from `GameBalance.BUILDINGS` values;
- unavailable entries are visible rather than silently omitted;
- temporary graybox cost remains separate from source cost.

## Energy station scene template

Added scene-first templates for the next building slice:

- `res://scenes/graybox/graybox_energy_station.tscn` for ID `151`;
- `res://scenes/graybox/graybox_central_base_template.tscn` for ID `155`, based on the existing base scene;
- palette ID `151` is now selectable and buildable with its own blue energy presentation;
- palette ID `155` remains disabled because the central base is a singleton gameplay object, not a normal placement target;
- building combat values for ID `151` remain explicit temporary graybox values; confirmed source HP/Cost stay data-driven.

## Player-facing graybox UI pass

The graybox HUD was reorganized toward a player-facing mobile presentation:

- debug labels and internal IDs were removed from the visible gameplay text;
- source-vs-temporary economy wording is hidden from the player HUD;
- building palette now uses readable names and actions;
- instructions describe player actions rather than implementation details;
- title and subtitle now present the scene as a base-defense game;
- touch action buttons remain scene nodes and retain their state logic.

This is still a graybox presentation pass, not the final visual identity or art style.

## Satellite Help entry captured

Added the Satellite description from `ziva-attachment:-2nqC4P7iODUfoIpn-0KS` to `MD/HELP_CONTENT.md`. Recorded `144.png`. It increases visibility, does not detect invisible insects, and an upgraded satellite provides full battlefield visibility.

## Tesla Tower Help entry captured

Added the Tesla Tower description from `ziva-attachment:dMqSoQCZ8hpeei4eoGJn0` to `MD/HELP_CONTENT.md`. Recorded `134.png`, `135.png`, `136.png` as levels 1–3. It is described as the strongest weapon, dealing very strong energy and fire damage.

## Assault Gun Help entry captured

Added the Assault Gun description from `ziva-attachment:DJ49sUG9EeN-MnzOCb0FL` to `MD/HELP_CONTENT.md`. Recorded `141.png`, `142.png`, `143.png` as levels 1–3. Its projectiles deal rocket and fire damage.

## UAV Help entry captured

Added the UAV description from `ziva-attachment:h507Z2L_UEz76TW_Azgwt` to `MD/HELP_CONTENT.md`. Recorded `116.png`, `117.png`, `118.png` as levels 1–3. It flies high and is attackable only by winged enemies or enemies equipped with long-range weapons.

## Beacon Help entry captured

Added the Beacon description from `ziva-attachment:XHJ2JFnKzNiXjct5MIZxg` to `MD/HELP_CONTENT.md`. Recorded `128.png`, `129.png`, `130.png` as levels 1–3. The Beacon attracts less intelligent bugs with its light and functions as a trap.

## Shared 103.png building base clarified

The user confirmed that `original/103.png` is not exclusive to the Laser Tower: it is also used as the lower/base part of the Fire Tower. Updated `MD/HELP_CONTENT.md` and `MD/VISUAL_ASSET_MAPPING.md` to record the shared visual resource.

## Radar Tower Help entry captured

Added the Radar Tower description from `ziva-attachment:y72GXkEytl9nPQq00z2dx` to `MD/HELP_CONTENT.md`. Recorded `122.png`, `123.png`, `124.png` as levels 1–3. It increases visibility, detects invisible bugs and has no defensive function.

## Plasma Tower Help entry captured

Added the Plasma Tower description from `ziva-attachment:0SzsNhBZlrnWhe7WWUh_v` to `MD/HELP_CONTENT.md`. Recorded `131.png`, `132.png`, `133.png` as levels 1–3. Each asset contains eight turret orientations for firing directions.

## Fire Tower Help entry captured

Added the Fire Tower description from `ziva-attachment:WFPtFvxfqWHYL1TV9rBVi` to `MD/HELP_CONTENT.md`. Recorded `107.png`, `108.png`, `109.png` as levels 1–3. Each asset contains eight turret orientations for firing directions. This closes the previous Fire Tower visual mapping gap.

## Soldier Help entry and animation interpretation captured

Added the original Soldier description from `ziva-attachment:JBSul8J8e6_cA_AwJMpWx` to `MD/HELP_CONTENT.md`. Recorded level mappings `110.png`, `111.png`, `112.png`. The sheets are treated as directional animated units with idle and shooting states; exact frame/direction ordering remains to be mapped.

## Central Base and Research Station entries captured

Added the original descriptions from `ziva-attachment:K1hrRNFrJftcJpZHEuHAb` and `ziva-attachment:Kr0mPVWp_6h2jrAMVN1br` to `MD/HELP_CONTENT.md`. Recorded the user-provided mappings: Central Base level 1 → `100.png`; Research Station levels 1–3 → `119.png`, `120.png`, `121.png`.

Laser Tower clarification: `103.png` is the shared lower part; `104.png`, `105.png`, `106.png` are upper parts for levels 1, 2 and 3. Each upper asset contains one idle image plus four progressive blue-cyan charge/preparation frames. The firing laser effect is separate and not yet mapped.

## Buildings / Basics help pages captured

Added the Building index and Basics text from `ziva-attachment:xNO5cnuvHDP-TNNBnLLwO` and `ziva-attachment:dhB-P0AycMHKbHLk4gBsr` to `MD/HELP_CONTENT.md`. This confirms the main-building vs defensive-structure taxonomy and the displayed meanings of `ОЖ`, `О`, `А` and `Р`. Word endings clipped at the right edge are unambiguous from context and user confirmation, so no recheck is required.

## Game process help page captured

Added the visible text from `ziva-attachment:n0cRNJXExNAXcUpI-HjGn` to `MD/HELP_CONTENT.md`. It confirms the central-base defense premise, modernization-based technology unlocks, surviving a defined number of attacks, progression to subsequent levels, persistent progress/technology, and the “Attack Mars” random-map mode. The screenshot cuts off the end of the final sentence, so that portion remains untranscribed.

## Original controls reference captured

Added the original keypad control page from `ziva-attachment:buSdNqJZubPqi5lw5JvwG` to `MD/HELP_CONTENT.md` and `MD/VISUAL_ASSET_MAPPING.md`. It records directional cursor movement, diagonal movement, selection, context actions, return to base, back/cancel and pause. The Android remake will translate these actions to touch controls rather than copying the numeric keypad as the primary interface.

## HUD layout pass and touch placement live check

Reorganized the 1152×648 graybox HUD to remove the wave/base-health overlap, group next-wave control with the wave count, separate base integrity and management actions, and give build/status/instruction rows their own space. Updated the status and instructions to Russian and used larger touch targets. Live run screenshots exposed and guided corrections to a remaining button overlap and base-health placement. Tapping Build followed by a map cell placed a tower and spent the displayed temporary cost; the resulting screenshot confirmed the interaction. Save tests remain 9/9 passing. Wave-clear through next-wave start is still awaiting a longer live run.

## Pause menu pass

Added an actual paused overlay rather than only relabeling the pause toggle: it dims gameplay and offers Save, Continue and Return to Main Menu. ESC now toggles pause (or cancels build mode first); pausing attempts a checkpoint save and the overlay buttons remain available while SceneTree is paused. The existing Test HUD remains a separate debug panel. Live verification is pending.

## Portrait HUD conversion started

Confirmed portrait orientation is the intended target (matching original). Project handheld orientation is set to portrait in Project Settings (the user's screenshot also confirms this setting). Added a portrait gameplay layout controller and a dedicated Test HUD toggle/panel. Debug buttons are separate from the primary play HUD; keyboard debug shortcuts are gated by the Test HUD visibility. Converted gameplay field to a tall full-width region with bottom control strip, compact wave/resource/base indicators, and context actions. This remains an early layout pass: verify the portrait live scene and adapt original fixed-coordinate movement/grid boundaries before considering complete.

## Wave intermission and touch placement pass implemented

Added a player-controlled preparation intermission and visible next-attack button, rather than advancing to a new wave automatically after the short balance timer. The final wave still ends in victory. Added an explicit armed placement mode with live green/red preview, tap-cell-to-place, Cancel, and instructional button copy; added Pause/Resume with save attempt and Escape cancellation/restart behavior. No new balance values were introduced. All 9 save validation tests pass. A follow-up live gameplay run could not be started because another scene was already running in the Game tab; the existing run was left untouched, so the full wave-clear→next-wave gameplay behavior remains pending live verification.

## Start menu and Help chapter browser completed

Expanded the Russian start menu's Help entry into a separate, scene-first chapter browser with seven scrollable pages based on screenshot-confirmed `MD/HELP_CONTENT.md` sections: introduction, game process, original controls, building basics, research, additional actions, and available building descriptions. Previous/Next page navigation and return to menu are wired and live-tested; user-provided run screenshots confirm the Help page is readable. Partial/cropped source text and prototype mechanics are labeled cautiously; no unconfirmed building descriptions were invented. The playable map remains a graybox placeholder.

## Start menu and navigation pass completed

Added an editable Russian title/menu scene as the project entry point, with New Game and save-aware Continue. Continue checks the primary and backup save and uses the existing gameplay restore path; New Game starts fresh. Verified the menu visually, navigated New Game into Survival, opened Help, and tested Continue from an existing saved attack checkpoint. The playable map is still the replaceable graybox and does not depend on the terrain research preview.

## Runtime save round-trip and terrain inspection completed

Expanded the suite to nine passing tests, including an in-tree capture/restore round-trip checking credits, a damaged/upgraded tower, live enemy health/path/wave registration, and restored wave scheduling counters. Terrain `000.png` was examined directly: 168×168 RGBA, fully opaque, 44 colors. Original draw bytecode indicates 24×24 clipped source windows whose origins move by 7 pixels, while map traversal separately advances at 24 pixels. Added an isolated crop-sampling scene displaying overlapping example windows, explicitly not claimed as map-cell assignments.

## Save UX and validation tests completed

Added automated tests for legacy v1 acceptance, valid v2 active-wave saves, invalid versions/buildings/enemies/routes, malformed JSON, and absent saves. The HUD load control now reads **Continue**, shows the saved attack number when a valid primary or backup is present, and disables itself when neither file is usable. Save/load feedback names the saved/restored attack checkpoint.

## Resumable wave-save pass completed

Bumped save schema to version 2 while retaining version-1 compatibility. Save data now includes wave number, pending spawn count, spawn index/timers, active-enemy accounting and finished/running state. Alive enemies serialize their ID, world position, HP, path/path index, attack cooldown, remaining paralysis and wave-registration flag. Restore clears prior runtime enemies, reinstantiates saved enemies, reconnects death handling, and reconciles the wave manager to the number of restored registered enemies. Live-tested with a wave save containing both wave and manually spawned enemies; subsequent save JSON retained their continuing positions and correct wave registration. This is checkpoint-style resume, not frame-exact deterministic replay.

## Save/load hardening pass completed

Added version/type/range validation for save data, bounded progression values, safe temporary-file writes with one previous-save backup, and backup recovery when the primary file is absent or malformed. Corrupt-JSON fallback was manually tested with a valid backup. Remaining save limitation: wave manager phase and active enemy positions are not serialized, so loaded games restart the wave schedule rather than resume it exactly.

## Save/load and research-gate prototype pass completed

Added touch HUD Save/Load controls and keyboard shortcuts F6/F7. Versioned JSON saves in `user://sturmtrupp_survival_save.json` record credits, rank/experience, action charges/unlocks, research, base health/defense/shield/upgrade level, building unlocks, and placed building IDs/cells/health/upgrade level. Restore rebuilds grid occupancy and defense instances. App pause triggers a save attempt. Save/load round-trip was live-tested; a built Energy Station is now required before research can be applied. This prerequisite is a prototype assumption, not confirmed original behavior.

## Progression and unlock pass completed

Added one-use action charges gated by experience/rank, persistent in-run research choices, and base modernization gating. Central Base upgrade now costs a temporary `1000 $` and unlocks the advanced Laser/Plasma/Radar/Beacon picker entries. Debug `F5` is reserved for unlocking all actions for testing.

## Research and additional-action prototype pass completed

Added scene-authored Survival controls for the captured Research and Additional Actions categories. Implemented prototype effects: reconnaissance fog reveal, quick repair, bomb/quick death, paralysis, poison damage, shield, invulnerability, radius boost, extreme damage and intelligent bomb. Research controls apply radius, defense, attack intensity and shield effects to placed defenses. Values remain prototype effects unless separately confirmed.

## Extended building picker and confirmed visual prototype pass

Added prototype scenes and picker entries for Laser Tower, Plasma Tower, Radar Tower and Beacon. Laser Tower uses shared `103.png` plus level-1 upper asset `104.png`; utility buildings are combat-disabled until their special effects are implemented. The picker now exposes seven initial build choices and displays the confirmed Laser Tower L1 cost of `$600`.

## Enemy feedback and fog pass completed

Added conditional enemy HP bars that appear after damage, a blinking radar attack marker, and scene-authored dark perimeter fog. Fixed the warning in the marker blink expression and re-ran the Survival scene without runtime errors.

## Confirmed UI stat register added

Added `GameBalance.SCREENSHOT_CONFIRMED_UI` for screenshot-confirmed player-facing values: Central Base L1, Laser Tower L1, and displayed Soldier stats. These are intentionally separated from temporary combat/economy values until each runtime rule is confirmed.

## Additional Actions descriptions completed

Added Super Shield, Invulnerability, Damage Radius Bonus, Extreme Damage Power, Stunning Rays and Intelligent Bomb descriptions from the supplied screenshots. All are mapped to shared `600.png`; evidence and wording are recorded in `MD/HELP_CONTENT.md`.

## Reconnaissance Flight description captured

Added the description from `ziva-attachment:8ivrakwFcEMPl_bLp5-lG`: the battlefield is completely revealed for a short time. This closes the previously pending text entry for the Reconnaissance Flight action.

## Additional Actions descriptions captured

Added the Basics, Quick Repair, Bomb, Quick Death, Paralyzing Rays and Poison Gas pages from the supplied screenshots to `MD/HELP_CONTENT.md`. All are mapped to shared `600.png`. Reconnaissance Flight is recorded as an icon mapping only because its description page was not included yet.

## Additional Actions Help index captured

Added the Additional Actions index from `ziva-attachment:zynLVuAsWdh5q_KKmqGoS` to `MD/HELP_CONTENT.md` and `MD/VISUAL_ASSET_MAPPING.md`. Recorded 12 action chapters plus Basics. Individual mechanics will be transcribed from subsequent pages.

## Research Help pages captured

Added research descriptions from `ziva-attachment:09NCrOkvoAKijGGIzjBPs` and `ziva-attachment:Q_FD65nejdIbtsMpe_Mlr` to `MD/HELP_CONTENT.md`. Recorded Radius of Damage, Armament, Attack Intensity and Shield Protection. All research icons are mapped by the user to shared asset `600.png`; shield installation is manual while other research is automatic.

## Additional Enemy Help page captured

Added the second enemy reference page from `ziva-attachment:6EPRRx755iA56-kD0RogX`. Recorded `501`, hidden enemy `512` with camouflage `513`, and Sand Worm cycle `508`–`511`, including the visible descriptions and resistance/sensitivity labels.

## Enemy Help page captured

Added the enemy reference page from `ziva-attachment:v8L4oFxHfIZln7m7eDTvZ` to `MD/HELP_CONTENT.md` and `MD/VISUAL_ASSET_MAPPING.md`. Recorded top-to-bottom mappings `505`, `504`, `502`, `507`, `503`, `506`, plus visible behavior, resistances and sensitivities. Enemy names and numeric stats are not displayed. One phrase in the acid creature description remains intentionally incomplete because it is not reliably readable.

## Help content register created

Added `res://MD/HELP_CONTENT.md` as the evidence-backed register for the remake's future in-game Help section. The introductory Russian text from `ziva-attachment:zj0MqioR8AWumlPzMiNyf` is transcribed with `SCREENSHOT_CONFIRMED` status. Future chapters remain pending screenshots rather than being invented.

## Original game-description screen captured

Recorded `ziva-attachment:zj0MqioR8AWumlPzMiNyf` in `MD/VISUAL_ASSET_MAPPING.md`. It confirms the original narrative premise: insect-like enemies threaten Mars, while the player commands a defense team, constructs defensive structures and research stations, and uses technology to survive. This is narrative evidence, not a building-stat table.

## In-game Help evidence for building statistics

The user reports that the original game's Help section explicitly defines the building stat labels:

```text
ОЖ → life / HP
О  → defense
А  → attack intensity / damage per shot
Р  → area-of-effect radius
```

This is recorded in `MD/VISUAL_ASSET_MAPPING.md` as `HELP_SCREEN_USER_REPORTED`. It can be used for the player-facing UI and building profile presentation, but does not by itself prove the underlying binary field/formula mapping.

## Building menu and action-menu screenshot evidence

Recorded two additional original-game screenshots in `MD/VISUAL_ASSET_MAPPING.md`:

- level-aware construction selection with cost, icon, name and four stat fields;
- conditional Repair action plus Upgrade and Demolish actions;
- Central Base exception: no Demolish action.

The visible labels `ОЖ`, `О`, `А`, `Р` are documented as observations. Only HP/life is treated as a strong working interpretation; defense, attack and radius remain pending runtime confirmation.

## Soldier and terrain visual templates

Added scene-first visual templates from the user-provided asset mapping:

- `graybox_soldier_level_1.tscn` → `original/110.png`;
- `graybox_soldier_level_2.tscn` → `original/111.png`;
- `graybox_soldier_level_3.tscn` → `original/112.png`;
- `retro_terrain_asset_preview.tscn` → `original/000.png`.

Soldier sheets are configured as `3×8` frame grids with nearest filtering. The terrain file remains isolated in an asset preview scene until its sheet/tile semantics are validated; it is not yet used as a gameplay TileMap.

## User asset-mapping correction received

The user supplied an initial correction to the visual resource mapping:

- `000.png` → Mars ground/terrain;
- `110.png`, `111.png`, `112.png` → Soldier levels 1–3;
- `113.png`, `114.png`, `115.png` → Energy Station levels 1–3.

This conflicts with the previous working `151 → 119.png` and `153 → 113.png` bindings. The correction is recorded as `USER_REPORTED` in `MD/VISUAL_ASSET_MAPPING.md`; the Fire Tower sprite is now treated as unresolved until revalidated. Existing bindings must not be promoted to confirmed based on the old table alone.

## Visual evidence mapping workflow

Created `res://MD/VISUAL_ASSET_MAPPING.md` as a dedicated register for user-provided original-game screenshots, visual identifications and PNG-to-object hypotheses. Screenshot observations will remain separate from `SOURCE_OF_TRUTH.md` until they are reconciled with runtime/resource evidence.

## Correction: Energy Station role

The Energy Station (`151`) no longer inherits active turret firing behavior. Its scene now uses `GrayboxEnergyStation`, which retains shared health/lifecycle and selection support but does not acquire targets or deal damage. No income rule has been invented; the confirmed energy/economy role remains separate from unresolved runtime economy semantics.

## Confirmed original sprite integration

Connected confirmed original PNG resources to the gameplay scenes without modifying the archive:

- building `151` Energy Station → `res://original/119.png`;
- building `153` Fire Tower → `res://original/113.png`;
- building `155` Central Base level 1 → `res://original/100.png`.

The sprites are referenced directly by editable `.tscn` `Sprite2D` nodes with nearest texture filtering. Existing polygon placeholders remain in the scenes but are hidden, so the logic and collision structure are preserved while the presentation now uses original pixel resources. Upgrade-level sprites `120–121` and base levels `101–102` remain queued for the next animation/state pass.

## Central base special interaction

Added special handling for base ID `155`:

- clicking the central base selects it as a singleton object;
- HUD displays its source ID, state, HP, source cost and singleton role;
- base cannot be sold or upgraded;
- Repair action can repair the selected base using the temporary repair cost;
- palette displays ID `155` and its source cost, but Build is disabled for the singleton.

