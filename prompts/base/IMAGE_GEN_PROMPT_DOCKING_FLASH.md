# Docking Flash — image-generation prompt

## Референсы

Прикрепи актуальные ассеты презентации:

- `central_base_l1.webp`;
- `central_base_l2.webp`;
- `central_base_l3.webp`;
- `attached_ship_module.webp`;
- `docking_beam.webp`;
- `landing_dust.png`.

Все эти ассеты нужны для согласования палитры, масштаба, центра стыковки,
направления света и интенсивности VFX. Оригинальный `137.png` не прикрепляй:
он не нужен для генерации вспышки.

## Запрос

Создай отдельный 2D VFX-ассет **docking flash** — короткую яркую вспышку в
момент, когда `AttachedShipModule` окончательно фиксируется на центральной
базе. Это самостоятельный слой для размещения поверх docking beam и landing
mist в Godot-сцене.

Эффект должен выглядеть как контролируемая sci-fi энергетическая фиксация, а
не как взрыв:

- яркое cyan-white ядро в центре стыковки;
- короткие концентрические световые кольца;
- симметричные радиальные энергетические лепестки;
- несколько тонких электрических разрядов;
- небольшие частицы, расходящиеся наружу;
- лёгкое cyan-blue свечение по краям;
- минимальный красно-оранжевый оттенок от марсианской пыли;
- чистый, компактный и читаемый силуэт;
- эффект должен хорошо выглядеть на один-два кадра и при коротком fade.

Visual prompt:

> Standalone compact cyan-white docking connection flash VFX for a 2.5D
> isometric sci-fi RTS, a controlled burst of energy at the exact moment a
> heavy armored orbital module locks onto a Mars command base, bright cyan
> white central core, thin concentric rings, symmetrical radial energy petals,
> delicate electric arcs, small outward-moving particles, restrained blue glow,
> subtle warm dust-colored accents, matching the attached industrial base,
> docking module, beam and landing mist references, clean readable game VFX,
> transparent RGBA background, centered isolated effect, no explosion, no fire,
> no building, no ship, no beam column, no floor, no environment, no text, no
> UI, no hard shadow.

## Технические требования

- настоящий прозрачный alpha-канал;
- PNG или WebP RGBA;
- рекомендуемый canvas: `512×512`;
- компактный центрированный эффект;
- безопасный прозрачный отступ по краям;
- без обрезанных разрядов и частиц;
- без белого или чёрного фона;
- без встроенной базы, модуля или полного луча;
- без механических деталей;
- пригодно для additive/light blending;
- пригодно для `Sprite2D`, `AnimationPlayer` и короткого VFX-таймлайна.

Сгенерируй один статичный базовый слой, а не видео и не sprite sheet.
В Godot эффект будет показан через короткую анимацию масштаба, прозрачности и
поворота отдельных слоёв.
