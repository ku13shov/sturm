## Reference
use visual reference. Preserve the same bug design, horizontal body orientation, head direction, proportions, rust-orange and dark-brown chitin, smooth painted rendering and top-down three-quarter game view.
## Main prompt
> Locked sprite animation: keep the input image camera, framing, angle, scale and orientation absolutely unchanged; animate only the existing legs in place.
>
> This is an image-to-video animation task. Treat the attached image as a locked 2D game sprite, not as a 3D scene or a character turnaround. Generate a short seamless reference video of the exact same compact alien Mars bug shown in the attached image. Preserve the creature's horizontal oval body, head and curved mandibles on the left, rust-orange segmented shell, dark brown joints, compact proportions and fixed top-down three-quarter view. Do not redesign the insect and do not turn it into a different beetle, spider or scorpion.
>
> Animate a natural six-legged alternating-tripod walk in place. Tripod A is left-front, right-middle and left-rear; tripod B is right-front, left-middle and right-rear. One tripod lifts and swings its feet a short distance forward while the other stays planted; land the moving feet before smoothly switching support. The three legs move in a coordinated phase with slight natural timing offsets, not as rigid synchronized pieces. Articulate each leg at its existing joints and keep planted feet fixed on the ground. Never move all legs on one side together or lift all six at once. Use subtle weight transfer only; no sliding, skating, floating, bouncing or snapping. Preserve all six legs' attachment points, segments and silhouettes. Keep the bug in place and animate only legs in the existing image plane. Camera, shell, head, mandibles, body shape and direction remain unchanged.
>
> Create a clean production reference suitable for extracting PNG animation frames for a Godot AnimatedSprite2D. Keep the bug centered with a fixed scale and pivot; do not shift the framing to follow moving legs. The first and last poses must match closely to allow a seamless loop. Preserve the complete head and both curved mandibles in every frame: no part may disappear, become hidden, deform, detach or pass beyond the visible frame. Keep the entire silhouette, including all six feet at their farthest points of motion and the shadow, inside a strict safe area with at least 18% empty margin to every frame edge. Never crop, clip or let any part touch an edge. Keep the full animated silhouette, not just the body, to approximately 50–55% of the square frame height so the legs can move without leaving this safe area. Do not solve framing by shrinking or changing the bug during the animation.
>
> Use smooth full-colour modern 2.5D sci-fi RTS rendering: anti-aliased edges, matte rust-brown chitin, restrained orange highlights, stable neutral lighting and consistent material appearance. The animation must show clearly visible leg articulation at small game scale, without exaggerated cartoon motion.
## Critical first-line instruction
Use this sentence at the very beginning of the video prompt:
> Locked sprite animation: keep the input image camera, framing, angle, scale and orientation absolutely unchanged; animate only the existing legs in place.
Do not use words such as "cinematic", "turnaround", "3D", "orbit", "camera movement", "reveal", "side view" or "show the creature" without the explicit locked-camera restrictions above.
## Video settings
- static camera, fixed focal length;
- fixed scale and fixed center/pivot;
- bug fills approximately `55–60%` of the square frame height, with at least `12%` empty margin on every side;
- perfectly flat saturated chroma-green background, for example `#00FF00`, with no texture, gradient or horizon;
- add one soft, compact, dark neutral-brown contact shadow directly beneath the bug, centered on the bug's vertical axis with no directional offset. The light source is positioned directly above the bug, so the shadow is uniform and evenly distributed around the lower footprint of the body and legs, with no cast direction, fully contained inside the frame and clearly separated from the green background;
- shadow opacity approximately 35–50%, soft feathered edge, no hard outline and no shadow extending outside the bug's footprint by more than 10% of the bug width;
- no camera shake, zoom, pan or motion blur;
- motion begins and ends in the same neutral pose.
## Gait timing
Use one smooth, evenly paced loop. Keep motion small and readable; complete each tripod's swing and ground contact before the other tripod lifts. Use this sequence:
1. neutral contact pose;
2. left-front, right-middle and left-rear legs begin lifting;
3. lifted legs swing forward while the other tripod supports the body;
4. lifted feet approach the ground;
5. first tripod lands and becomes the support group;
6. weight transfers smoothly;
7. right-front, left-middle and right-rear legs lift;
8. second tripod swings forward;
9. second tripod lands;
10. return to the neutral contact pose.
Keep at least three legs visibly planted in every phase. Feet in the support group remain planted and do not slide while the opposite tripod swings. Do not move all legs on one side together. Avoid stiff pendulum motion: each leg bends at its joints and the front, middle and rear feet move with slight natural timing offsets.
## Background requirements
Use a perfectly uniform saturated chroma-green background, approximately `#00FF00`, that does not appear anywhere in the rust-orange, dark-brown or yellow bug. The background must be flat and removable: no floor texture, horizon, lighting gradient, dust, smoke, particles or additional objects. Keep the soft dark cast shadow visible beneath the bug; it must be rendered as part of the foreground subject/shadow layer, not as a background gradient. The shadow must remain fully inside the safe margins and must not be green. If true alpha video is supported, preserve the bug and its shadow with alpha; otherwise use the flat chroma-green background for later keying, taking care not to key out the dark shadow.
## Negative prompt
> camera movement, pan, tilt, orbit, zoom, side view, perspective change, reframing, changing scale or pivot, bug translation, whole-body rotation, body or head morphing, disappearing head, hidden or cropped mandibles, clipped silhouette, legs leaving the safe area, leg detachment, rigid whole-leg swinging, stiff synchronized motion, sliding or floating feet, foot skating, sudden snapping, missing or extra legs, flickering, unstable lighting, motion blur, ghosting, spider, scorpion, wings, tail, weapons, textured background, ground texture, horizon, dust, smoke, particles, directional shadow, angled shadow, offset shadow, long shadow, hard shadow, shadow outside frame, shadow touching frame edge, clipped legs, clipped mandibles, cropped body, text, UI, multiple bugs, pixel art
