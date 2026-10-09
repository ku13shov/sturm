# Landing Dust / Docking Energy Mist — image-generation prompt

## Референсы

Для этого эффекта прикрепи все актуальные современные ассеты презентации:

- `central_base_l1.webp`;
- `central_base_l2.webp`;
- `central_base_l3.webp`;
- `attached_ship_module.webp`;
- `docking_beam.webp`.

Да, на этом этапе лучше прикрепить все эти ассеты: эффект должен совпадать с
их палитрой, масштабом, направлением света и docking-композицией. Оригинальный
`137.png` прикреплять не нужно — он не нужен для генерации пыли и может
исказить современный визуальный стиль.

## Запрос

Создай отдельный 2D VFX-ассет **landing dust / docking energy mist** для
сцены спуска и стыковки `AttachedShipModule` с центральной базой. Это должен
быть самостоятельный широкий слой, который размещается под модулем и вокруг
нижней docking-зоны базы.

Эффект должен сочетать:

- мягкую красно-коричневую марсианскую пыль;
- холодную cyan-blue энергетическую дымку от docking beam;
- низкие симметричные волны тумана по поверхности;
- небольшие светящиеся частицы;
- тонкие голубые электрические завихрения;
- более сильную концентрацию эффекта в центре стыковки;
- постепенное затухание к краям;
- читаемую форму в уменьшенном виде;
- sci-fi industrial RTS visual effects style;
- умеренную интенсивность без огромного взрыва.

Visual prompt:

> Standalone wide landing dust and docking energy mist VFX for a 2.5D
> isometric sci-fi RTS, generated to match the attached armored Mars command
> base, descending orbital docking module and cyan energy beam references,
> low symmetrical reddish Martian dust clouds mixed with translucent cyan-blue
> energy haze, soft ground-hugging waves, subtle electrical wisps, small
> contained glowing particles, brightest concentration directly beneath the
> docking point, fading smoothly toward both sides, clean readable game VFX,
> transparent RGBA background, isolated centered effect, no building, no ship,
> no beam column, no floor, no environment, no text, no UI, no hard shadow.

## Технические требования

- настоящий прозрачный alpha-канал;
- PNG или WebP RGBA;
- рекомендуемый canvas: `1024×512`;
- широкий горизонтальный слой;
- эффект полностью помещается в canvas;
- центр эффекта совпадает с центром canvas;
- без обрезанных частиц по краям;
- без белого или чёрного фона;
- без встроенного модуля, базы или полного docking beam;
- без механических деталей;
- края должны хорошо работать с alpha/additive blending;
- пригодно для `Sprite2D`, `AnimationPlayer` и композиции с
  `GPUParticles2D`.

Сгенерируй один статичный базовый VFX-слой, а не видео и не sprite sheet.
Динамику позже создадим в Godot масштабированием, прозрачностью, смещением и
пульсацией слоя.
