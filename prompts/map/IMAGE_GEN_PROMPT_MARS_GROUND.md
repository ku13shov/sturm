# Mars Ground Texture — image-generation prompt

## Как использовать прикреплённый архив

В архиве находятся ассет старой оригинальной игры 000.png, ассеты новой современной центральной базы в трёх вариациях (central_base_l1.webp, central_base_l2.webp, central_base_l3.webp), а также текущий ассет новой карты/грунта. Текущий ассет карты используй как референс назначения, масштаба и композиции поверхности, но не копируй его фотореалистичную детализацию, если она конфликтует со стилем базы. Используй три современные вариации базы как главный референс палитры, материалов, освещения, масштаба и 2.5D/isometric-языка. Оригинальный ассет используй только как историческую справку о марсианской среде — не копируй его пиксельный стиль, форму или детали.

Создай новый современный production-ready ассет для ремейка Sturmtrupp Mars: тёплая марсианская поверхность, тёмный графитовый техно-индустриальный контраст и cyan-акценты только там, где они функционально нужны.

## Основной запрос

> Seamless stylized Mars ground terrain texture for a modern 2.5D/isometric sci-fi RTS, designed to match a crisp readable game sprite of a dark graphite armored command base, controlled flat-to-painted materials rather than photorealistic soil, warm muted rust-red and burnt-orange regolith, broad simplified color masses, subtle hand-painted gradients, sparse small-scale stones, restrained shallow cracks, low visual noise, tileable in every direction, no obvious repeating pattern, no central focal point, consistent even detail density, strong readability behind pixel-art-inspired isometric buildings, modern game-ready environment art, no photorealism, no macro-camera soil detail, no retro 2007 pixel-art copy.

## Требования

- Только бесшовная ground-текстура; tileable по горизонтали и вертикали.
- Не изображай карту, отдельные клетки, здания, дороги, UI или grid lines.
- Не добавляй текст, логотипы, символы, интерфейс, персонажей, транспорт и старые пиксельные элементы.
- Никакого заметного центра, рамки, горизонта, перспективы или падающей тени.
- Плотность деталей низкая или умеренная: поверхность не должна конкурировать с базой.
- Детали должны быть заметно меньше основания центральной базы; никаких крупных фотореалистичных камней.
- Поверхность должна выглядеть как stylized game terrain, а не фотография марсианского грунта.
- Цвета: muted Mars red, burnt orange, dusty terracotta, ochre и dark brown; без кислотно-яркого фона.
- Сохрани мягкий контактный цветовой переход, чтобы тёмно-серая база не выглядела наклеенной поверх земли.
- Подготовь результат для Godot TileMap/TileMapLayer и масштабирования в 2.5D сцене.

## Технический результат

- Квадратный RGBA или RGB image без видимого шва; непрозрачная поверхность допустима.
- Рекомендуемый canvas: 512×512 или 1024×1024.
- Для повторения используй seamless/tileable composition, одинаковые края и согласованную частотность деталей.
- Сгенерируй один базовый ground-материал, не sprite sheet и не набор UI-иконок.
