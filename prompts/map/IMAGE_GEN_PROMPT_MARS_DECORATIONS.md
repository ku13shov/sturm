# Mars Decorations — image-generation prompt

## Как использовать прикреплённый архив

В архиве находятся ассет старой оригинальной игры, ассеты новой современной центральной базы в трёх вариациях, а также текущий ассет новой карты/грунта. Используй три вариации базы как главный референс для материалов, палитры, освещения, масштаба и современного 2.5D/isometric sci-fi RTS-стиля. Оригинальный ассет используй только как историческую справку; не копируй его пиксельную стилистику или детали. Текущий ассет карты используй для подбора цвета пыли, масштаба камней и уровня визуальной детализации, но не встраивай карту или её фон в декоративные объекты.

Сгенерируй новые модульные декоративные объекты для карты, которые органично принадлежат тому же современному визуальному миру, что и новая база.

## Основной запрос

> Modular set of modern Mars battlefield decoration props for a 2.5D isometric sci-fi RTS, isolated production-ready game assets: low industrial sensor pylon, broken dark graphite survey marker, small weathered utility crate, compact cable conduit fragment, red-brown metal debris, and sparse mineral shard, all sharing one coherent Mars environment language, graphite and desaturated gray manufactured surfaces, oxidized red dust, subtle cyan indicator lights only on functional technology, readable chunky silhouettes, fixed 45-degree orthographic-friendly isometric view, contemporary AAA strategy-game art, consistent scale and lighting.

## Правила набора

- Создай набор раздельно читаемых модульных props; каждый объект должен легко отделяться и размещаться независимо в Godot.
- Объекты должны разнообразить ground, но не конкурировать с базой, юнитами или UI.
- Декор — функциональный и сдержанный: никаких случайных зданий, огромных машин или сюжетных сцен.
- Не добавляй текст, логотипы, номера, UI, сетку, персонажей, транспорт или оружие.
- Не используй старый пиксельный стиль, контуры и повторение `original/`.

## Технические требования

- Настоящий прозрачный RGBA-фон для каждого объекта; без пола, горизонта и общей сцены.
- Объекты полностью в кадре, с одинаковым pivot/масштабом и безопасными полями.
- Фиксированный 45° isometric three-quarter view, минимальная перспектива.
- Чистые силуэты для Sprite2D; пригодно для ручной расстановки на grid-based карте.
- Рекомендуемый результат: отдельные изображения 256×256 или единый аккуратный atlas только если каждый элемент имеет чистую изоляцию.
- Не создавай анимацию или sprite sheet без отдельного запроса.
