# Docking Beam — image-generation prompt

## Референсы

Прикрепи следующие современные ассеты:

1. `res://assets/sprites/buildings/attached_ship_module.webp` — главный
   референс формы и нижней docking-зоны;
2. `res://assets/sprites/buildings/central_base_l1.webp` — референс базы и
   точки стыковки;
3. `res://assets/sprites/buildings/central_base_l2.webp`;
4. `res://assets/sprites/buildings/central_base_l3.webp`.

Для этого эффекта достаточно современных ассетов. Оригинальный `137.png`
прикреплять необязательно: он нужен для исследования формы модуля, но не
нужен для генерации отдельного энергетического эффекта.

## Запрос

Создай отдельный 2D-эффект **docking beam** для вертикальной стыковки
`AttachedShipModule` с центральной базой. Эффект должен быть самостоятельным
слоем, который можно положить под модуль и над базой в Godot-сцене.

Сделай чистый симметричный вертикальный cyan-blue энергетический луч:

- узкий яркий центральный поток;
- мягкое полупрозрачное внешнее свечение;
- несколько тонких энергетических колец и вертикальных световых линий;
- более яркая верхняя зона около модуля;
- более яркая нижняя зона около docking-площадки базы;
- небольшие частицы внутри луча;
- визуальная связь с cyan-освещением базы и модуля;
- sci-fi industrial energy technology;
- restrained, readable game VFX, not a giant explosion;
- fixed vertical orientation matching the attached references;
- suitable for a 2.5D/isometric RTS presentation.

Используй этот visual prompt:

> Standalone vertical cyan-blue docking energy beam VFX for a 2.5D isometric
> sci-fi RTS, designed to connect a descending armored orbital module to a
> massive industrial Mars command base, narrow bright central energy column,
> soft transparent outer glow, subtle concentric energy rings, thin vertical
> light filaments, small contained particles, brighter connection points at
> the top and bottom, matching dark graphite, gray, cyan and restrained red
> industrial visual language of the attached building references, clean
> readable silhouette, centered effect, transparent RGBA background, isolated
> game-ready 2D visual effect, no object, no spacecraft, no building, no
> floor, no text, no UI, no shadow.

## Технические требования

- настоящий прозрачный alpha-канал;
- WebP или PNG RGBA;
- рекомендуемый canvas: `512×1024`;
- эффект целиком помещается в canvas;
- вертикальный центр совпадает с центром canvas;
- без обрезанных краёв свечения;
- без белого или чёрного фона;
- без встроенного модуля и базы;
- без падающей тени;
- края должны хорошо работать с additive/light blending;
- эффект должен быть пригоден для `Sprite2D`, `AnimationPlayer` и
  `GPUParticles2D`-композиции.

Это один статичный базовый слой эффекта, а не видео и не sprite sheet.
Динамику позже создадим в Godot масштабированием, прозрачностью, пульсацией и
движением отдельных колец.
