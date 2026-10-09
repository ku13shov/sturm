"""Generate the 8 normalized beetle views from bug_sheet.png.
Run with Pillow available: python tools/make_bug_sprites.py.
The Godot project also keeps the same deterministic crop/placement rules in
scripts/make_bug_sprites.gd for environments without Pillow.
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/sprites/units/new_base_bug/bug_sheet.png"
OUTPUT = ROOT / "assets/generated"
VIEWS = [(26, 290, 315, 353), (361, 291, 341, 348), (712, 316, 344, 294), (1072, 294, 328, 308), (1423, 292, 322, 311)]
NAMES = ["s", "sw", "w", "nw", "n"]
TARGET_CONTENT_HEIGHT = 100
W_SCALE = 1.05
flip_source = {"SW": True}

# The source already has transparent corners and no flood-fill is applied.
def make_view(image, rect, mirror=False, scale_factor=1.0):
    crop = image.crop((rect[0], rect[1], rect[0] + rect[2], rect[1] + rect[3]))
    scale = TARGET_CONTENT_HEIGHT / crop.height * scale_factor
    size = (round(crop.width * scale), TARGET_CONTENT_HEIGHT)
    crop = crop.resize(size, Image.Resampling.LANCZOS)
    if mirror:
        crop = crop.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    canvas = Image.new("RGBA", (160, 140), (0, 0, 0, 0))
    canvas.alpha_composite(crop, ((160 - crop.width) // 2, 140 - crop.height))
    return canvas

source = Image.open(SOURCE).convert("RGBA")
OUTPUT.mkdir(parents=True, exist_ok=True)
requested = set(__import__("sys").argv[1:])
for index, name in enumerate(NAMES):
    if requested and name not in requested:
        continue
    make_view(source, VIEWS[index], mirror=flip_source.get(name, False), scale_factor=W_SCALE if name == "w" else 1.0).save(OUTPUT / f"bug_{index}_{name}.png")
# SE is the horizontal mirror of the corrected SW view; this is equivalent to mirroring the raw source once.
for index, name, source_index in [(5, "ne", 3), (6, "e", 2), (7, "se", 1)]:
    if requested and name not in requested:
        continue
    make_view(source, VIEWS[source_index], mirror=(name == "se"), scale_factor=W_SCALE if name == "e" else 1.0).save(OUTPUT / f"bug_{index}_{name}.png")
