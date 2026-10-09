# Base Bug — prompt for extracting animation frames

Use the attached walking video and the reference image.

Extract a clean loop of walking frames for Godot `AnimatedSprite2D`.

## Required result

- export transparent PNG frames only;
- exactly one complete bug per frame;
- preserve the original video order;
- use every frame of one complete walk cycle, exactly 24 evenly spaced frames from one complete walking cycle;
- if the video contains more frames, select the clearest evenly spaced 12 frames;
- identical square canvas for every frame;
- identical pixel dimensions, scale, center and pivot in every frame;
- the bug must remain in the same screen position;
- do not independently recenter or resize individual frames;
- preserve the horizontal top-down three-quarter view;
- preserve the head direction and body proportions;
- keep all visible legs and the complete body inside every frame;
- smooth anti-aliased edges and consistent colours;
- no frame interpolation that changes the anatomy.

## Background removal

Remove the chroma or background completely and create a true alpha channel. Remove floor, horizon, dust, smoke, cast shadow, reflections, outlines caused by the background and colour spill around the bug. Do not replace the background with a visible checkerboard; checkerboard is only a preview of transparency.

## Alignment

Use one fixed crop calculated from the whole video, not a separate crop per frame. Keep the same ground-contact point and center in all frames. If the bug moves slightly because of video instability, stabilize it while preserving the leg motion. Do not stabilize by changing the creature’s size or camera angle.

## Output naming and layout

Export sequential files:

```text
base_bug_walk_000.png
base_bug_walk_001.png
base_bug_walk_002.png
...
base_bug_walk_023.png
```

Do not create a spritesheet. Export only 24 individual lossless PNG frames. Do not include idle, attack or death frames.

## Quality checks

Before exporting, verify that:

- the first and last selected frames loop naturally;
- no selected frame is blurred or duplicated;
- the body does not flicker or morph;
- the legs remain attached to the body;
- no leg is cropped;
- the pivot is identical in all frames;
- alpha is transparent outside the bug;
- there are exactly 24 frames, numbered from `000` through `023`, all with identical dimensions.

## Negative instructions

Do not create new artwork, redesign the bug, mirror frames, rotate the bug, change its direction, change the camera, add perspective, add shadows, add a background, add text or UI, use JPEG, use a visible checkerboard, crop different frames differently, or combine frames from different walking cycles.