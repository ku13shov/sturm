# Base Bug — spritesheet generation prompt

## Reference

Use `base_bug.webp` as the strict visual reference. Preserve the same creature design, horizontal body orientation, head direction, proportions, rust-orange/dark-brown chitin palette, smooth painted rendering and transparent background.

## Main prompt

> Create a production-ready 2D spritesheet for a small alien Mars bug in a modern 2.5D sci-fi RTS. Use the attached base bug reference as a strict design reference. Preserve the exact recognizable creature: compact horizontal oval body, head and curved mandibles on the left, segmented rust-orange and dark-brown chitin, six short articulated insect legs, three legs on each side, and the same top-down three-quarter view. Do not redesign the creature and do not turn it into a different beetle or spider.
>
> Generate a single horizontal spritesheet containing 12 animation frames of one complete bug walking in place. Every frame must use the identical square canvas size, identical scale, identical pivot, identical center position and identical transparent background. The bug must never be cropped. Keep the body silhouette stable between frames. Animate only a believable alternating insect gait: front, middle and rear legs move in coordinated tripod groups, with intermediate planted, lifting, swinging and landing phases. At least two or three legs must remain planted in every frame. Add only a subtle natural body weight shift; do not squash, stretch, morph or rotate the body independently.
>
> The animation must read clearly at small in-game size. Keep all six legs visible and separated from each other. Use smooth full-colour painted HD rendering with anti-aliased edges, matte rust-brown chitin, restrained orange highlights and consistent lighting across all frames. This is a spritesheet, not a lineup of different bugs: all 12 cells depict the same individual bug in consecutive motion phases.

## Exact layout

- one horizontal row;
- exactly 12 cells;
- each cell square and identical;
- recommended cell size: 128×128 or 160×160;
- total width must equal cell width × 12;
- transparent alpha background;
- no padding differences between cells;
- same pivot and ground contact point in every cell;
- no frame may contain more or fewer than one bug;
- no text, labels, frame borders or guides.

## Motion phases

Use this sequence:

1. neutral contact pose;
2. left tripod begins lifting;
3. left tripod swings forward;
4. left tripod reaches forward;
5. left tripod plants;
6. body passes over the planted legs;
7. right tripod begins lifting;
8. right tripod swings forward;
9. right tripod reaches forward;
10. right tripod plants;
11. body passes over the planted legs;
12. return smoothly to the neutral contact pose.

Tripod groups:

- group A: front-left, middle-right, rear-left;
- group B: front-right, middle-left, rear-right.

## Consistency requirements

- Do not change camera angle between frames.
- Do not change lighting direction or colour grading.
- Do not change body length, width or shell segmentation.
- Do not make the bug face a new direction in any frame.
- Do not introduce motion blur.
- Do not animate the whole sprite by translating it inside the cell.
- Keep the feet close to the same ground plane.
- Keep the head, mandibles and shell sharply readable.
- Avoid overlapping legs that merge into an unreadable mass.

## Negative prompt

> pixel art, pixelated spritesheet, low-resolution pixel blocks, retro 8-bit, different bugs, multiple bugs per frame, lineup of separate bugs, inconsistent scale, inconsistent pivot, cropped legs, cropped body, changing camera angle, changing head direction, rotating whole creature, body morphing, squash and stretch, rubber limbs, extra legs, missing legs, spider, scorpion, beetle redesign, giant mandibles, mechanical parts, weapons, wings, tail, armor modules, background, Mars ground, rocks, dust, smoke, cast shadow, white background, checkerboard drawn into the image, text, labels, frame borders, guides, motion blur

## Godot preparation

The result must be directly usable as an `AnimatedSprite2D` spritesheet. Every frame must have the same canvas and pivot. The atlas must contain only the 12 walking frames. Do not add idle, attack or death frames to this sheet; those should be generated as separate animations with the same canvas, scale and pivot.
