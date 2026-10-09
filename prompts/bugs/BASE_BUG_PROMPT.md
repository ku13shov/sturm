# Базовый марсианский жук — production prompt

## Назначение

Создай современную 2.5D-версию базового марсианского жука для sci-fi RTS в Godot. Используй прикреплённый оригинальный маленький пиксельный спрайт как главный и обязательный референс. Это не новый вид существа: нужно сохранить узнаваемый силуэт, направление корпуса, пропорции и компактный характер оригинала.

## Основной prompt

> Modern 2.5D sci-fi RTS game asset based strictly on the attached tiny original pixel-art Mars insect reference. Recreate the same compact, squat, low-to-the-ground insect silhouette rather than inventing a new beetle. Preserve the reference body length-to-width ratio, head-to-body relationship, forward-facing direction, leg placement, and compact crawling posture. Create one small hostile reddish-brown Mars bug for an isometric strategy map: short broad segmented body, relatively small head, short mandibles, short compact legs close to the body, dark rust-brown chitin with restrained burnt-orange highlights and deep brown shadows. Use a mostly top-down three-quarter game view with only mild elevation, not a dramatic side perspective. Keep the creature small, dense, and centered, filling about 65–75% of the canvas. The original silhouette and proportions are more important than adding detail. Keep the creature low to the ground and visually compact, with no oversized spider proportions, no long dramatic limbs, no giant thorax, no extra anatomy, no weapons, no technology, no armor modules, no wings, no tail, no antenna exaggeration. Modern painted 2.5D game-art finish, clean readable shapes, restrained detail, strong silhouette at small in-game scale, subtle warm rim light, soft directional shading, consistent Mars palette, production-ready strategy-game sprite.

## Обязательные ограничения

- строго один жук;
- полностью видимый объект, без обрезанных лап или корпуса;
- объект по центру изображения с равными полями по краям;
- фиксированный единый ракурс для последующих вариантов;
- сохранить направление головы и общую позу оригинала;
- не превращать жука в крупного паука, скорпиона или механическое существо;
- не добавлять оружие, бронепластины военной техники, турели, импланты или светящиеся устройства;
- не добавлять окружение, камни, грунт, растения, туман, кровь, следы движения или других существ;
- не добавлять текст, логотипы, UI или рамку;
- прозрачный фон с настоящим alpha-каналом;
- без белой подложки и без серого ореола вокруг силуэта;
- без падающей тени и без контактной тени: тень будет добавлена отдельно в Godot;
- не использовать сильную перспективу или кинематографический наклон;
- не делать фотореалистичную иллюстрацию, где теряется игровой силуэт;
- не добавлять случайные детали, которые будут исчезать при уменьшении спрайта.

## Стилизация

Используй современный 2.5D/isometric sci-fi RTS стиль, но с визуальной дисциплиной небольшого игрового юнита:

- чистые границы крупных форм;
- ограниченная палитра: тёмный коричневый, ржаво-красный, приглушённый оранжевый, почти чёрные тени;
- умеренный контраст между сегментами;
- мягкое студийное освещение только для читаемости объёма;
- матовый слегка шероховатый хитин;
- минимум мелких бликов;
- отсутствие чрезмерной глянцевости;
- силуэт должен оставаться узнаваемым на размере около 32–64 px.

## Важное требование для движения и вращения

Жук будет двигаться в любом направлении по карте, поэтому силуэт должен хорошо работать при повороте вокруг вертикальной оси. Не создавай композицию, которая читается только с одной стороны. Сделай корпус визуально сбалансированным вокруг центральной продольной оси: три короткие ноги должны быть читаемы с каждой стороны, без ситуации, когда одна сторона показывает две ноги, а другая три. Ноги должны быть равномерно распределены по передней, средней и задней части корпуса и не сливаться друг с другом.

Используй нейтральное почти верхнее освещение без сильной тени только с одной стороны, без выраженной передней или задней цветовой границы и без асимметричных деталей, которые будут выглядеть неправильно при повороте. Голова и жало/задняя часть должны быть различимы, но общий силуэт должен оставаться узнаваемым при повороте на 90, 180 и 270 градусов. Не рисуй плоскую иконку строго сбоку: создай единый master-asset, который можно поворачивать в Godot без потери читаемости.

Если генератор поддерживает turnaround или multi-view output, сначала используй тот же дизайн в четырёх ортогональных направлениях — front, right, back, left — с одинаковым масштабом, pivot и освещением. Если нужен один PNG, создай один нейтральный верхний master-view; не добавляй несколько жуков в один кадр.

## Подготовка к Godot

Сгенерируй квадратный PNG с прозрачностью, пригодный для Sprite2D. Сохрани одинаковый canvas, положение основания и визуальный масштаб для будущих кадров ходьбы и атаки. Корпус должен быть цельным и стабильным, а лапы — визуально разделёнными и достаточно читаемыми для последующей cutout-анимации или AnimatedSprite2D.

## Negative prompt

> giant spider, oversized spider legs, long spider limbs, scorpion tail, rhinoceros beetle, giant beetle, elongated beetle body, bulky armored insect, huge thorax, huge head, giant mandibles, dramatic side view, strong perspective, low side angle, extreme three-quarter angle, exaggerated anatomy, oversized legs, legs spread far from the body, extra limbs, missing limbs, multiple creatures, humanoid anatomy, dramatic action pose, flying pose, cropped body, cropped legs, excessive empty canvas, tiny object in the center, environmental background, Mars ground, rocks, plants, dust, smoke, blood, cast shadow, white background, gray halo, opaque background, text, logo, UI, frame, photorealistic macro insect, horror mutation, random spikes, excessive tiny details, neon cyberpunk parts

## Результат

Итоговый asset должен выглядеть как тот же базовый жук из оригинальной игры, переосмысленный в современном 2.5D стиле, а не как новый самостоятельный монстр. Главный критерий качества — узнаваемый силуэт оригинала при маленьком размере и корректная интеграция в Mars RTS карту.