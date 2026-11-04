import math, os, json
import numpy as np, cv2
from PIL import Image

LAY = '/home/claude/layers'
OUT = '/mnt/user-data/outputs/new_soldier'
os.makedirs(OUT, exist_ok=True)
W0, H0 = 424, 736
K = 3                       # 1/3 scale (exact)
IDLE_N, SHOT_N = 12, 8
# --- studio globals (point 5 of the brief)
A, T, L = 2.7, 2.2, 0.5
R, D = 6.5, 0.28

VIEWS = ['s', 'se', 'e', 'ne', 'n']
VW = {
 's':  dict(top=167, Y=335, FY=627, CX=212, HC=(213,145), AC=(203,308), mx=361, my=373, an=27,  hx=-1.5, hy=5.5,  ax=0,    ay=-3.5,  spk=[[213,145,12],[200,308,10],[110,235,5],[315,235,5]], behind=False),
 'se': dict(top=172, Y=336, FY=625, CX=208, HC=(204,133), AC=(195,301), mx=339, my=366, an=27,  hx=6.5,  hy=13.5, ax=10.5, ay=3.5,   spk=[[225,141,12],[195,301,10],[110,235,5],[300,235,5]], behind=False),
 'e':  dict(top=164, Y=331, FY=628, CX=182, HC=(184,142), AC=(240,312), mx=365, my=373, an=38,  hx=-1,   hy=1,    ax=-2,   ay=0,     spk=[[224,138,12],[240,312,10],[105,225,5],[205,225,5]], behind=False),
 'ne': dict(top=158, Y=328, FY=629, CX=195, HC=(190,136), AC=(213,328), mx=387, my=367, an=23,  hx=0,    hy=-1.5, ax=-1.5, ay=-3.5,  spk=[[124,235,12],[294,232,8],[350,355,10],[190,135,4]], behind=False),
 'n':  dict(top=157, Y=327, FY=627, CX=212, HC=(211,133), AC=(212,309), mx=285, my=195, an=-70, hx=0,    hy=-2,   ax=-1.5, ay=-10.5, spk=[[206,235,14],[349,235,6],[212,309,8],[211,133,4]], behind=True),
}
NAMES = ['body', 'head', 'arms']

def load(kind, v, k):
    im = np.array(Image.open(f'{LAY}/{kind}_{v.upper()}_{k}.png').convert('RGBA')).astype(np.float32) / 255.0
    im[..., :3] *= im[..., 3:4]            # premultiply
    return im

SRC = {v: {k: load('SRC', v, k) for k in NAMES} for v in VIEWS}
GL = {}
for v in VIEWS:
    GL[v] = {}
    for k in NAMES:
        GL[v][k] = load('GL', v, k)

def warp(img, M):
    return cv2.warpAffine(img, np.array(M, np.float32), (W0, H0), flags=cv2.INTER_LINEAR,
                          borderMode=cv2.BORDER_CONSTANT, borderValue=0)

def over(dst, src):
    return src + dst * (1.0 - src[..., 3:4])

def render_layers(layers, V, off_body, off_head, off_arms):
    """Same as studio bodyDraw + part()+part(): layers premultiplied."""
    Y, top = V['Y'], V['top']
    Ht = Y - top
    sx = off_body[0] / Ht
    kk = -off_body[1] / Ht
    body = layers['body']
    bottom = body.copy(); bottom[:Y] = 0
    topimg = body.copy(); topimg[Y + 1:] = 0
    out = bottom
    out = over(out, warp(topimg, [[1, -sx, sx * Y], [0, 1 + kk, -kk * Y]]))
    out = over(out, warp(layers['head'], [[1, 0, off_head[0]], [0, 1, off_head[1]]]))
    out = over(out, warp(layers['arms'], [[1, 0, off_arms[0]], [0, 1, off_arms[1]]]))
    return out

def render_glow(layers, V, off_body, off_head, off_arms):
    """Additive composite (studio uses 'lighter'): sum of premultiplied RGB, clipped."""
    Y, top = V['Y'], V['top']
    Ht = Y - top
    sx = off_body[0] / Ht
    kk = -off_body[1] / Ht
    body = layers['body']
    bottom = body.copy(); bottom[:Y] = 0
    topimg = body.copy(); topimg[Y + 1:] = 0
    acc = warp(bottom, [[1, 0, 0], [0, 1, 0]])[..., :3]
    acc = acc + warp(topimg, [[1, -sx, sx * Y], [0, 1 + kk, -kk * Y]])[..., :3]
    acc = acc + warp(layers['head'], [[1, 0, off_head[0]], [0, 1, off_head[1]]])[..., :3]
    acc = acc + warp(layers['arms'], [[1, 0, off_arms[0]], [0, 1, off_arms[1]]])[..., :3]
    return np.clip(acc, 0, 1)

def env(t, Dd):
    a = .04
    if t < 0 or t > Dd: return 0.0
    return t / a if t < a else (1 - (t - a) / (Dd - a)) ** 2

def pose(v, mode, i):
    """returns off_body, off_head, off_arms (dx,dy)"""
    V = VW[v]
    th = math.radians(V['an'])
    dx, dy = -math.cos(th), -math.sin(th)
    if mode == 'idle':
        t = i * T / IDLE_N
        w = lambda n: math.sin(2 * math.pi * t / T - n)
        bs, hs, as_ = w(0), w(L), w(.25)
        sy = A * bs
        ob = (0.0, sy)
        oh = (V['hx'], V['hy'] + sy + (hs - bs) * A * .4)
        oa = (V['ax'] + A * .3 * as_, V['ay'] + A * .9 * as_)
        return ob, oh, oa
    t = i * D / (SHOT_N - 1)
    e = env(t, D)
    ob = (dx * R * e * .35, dy * R * e * .35)
    oh = (V['hx'] + dx * R * e * .2, V['hy'] + dy * R * e * .2)
    oa = (V['ax'] + dx * R * e, V['ay'] + dy * R * e)
    return ob, oh, oa

# ---- render all frames at full res
frames = {}   # (mode, v) -> list of (color_premult, glow_rgb)
for mode, n in (('idle', IDLE_N), ('shot', SHOT_N)):
    for v in VIEWS:
        lst = []
        for i in range(n):
            ob, oh, oa = pose(v, mode, i)
            lst.append((render_layers(SRC[v], VW[v], ob, oh, oa), render_glow(GL[v], VW[v], ob, oh, oa)))
        frames[(mode, v)] = lst

# ---- common frame (union of extents relative to the anchor)
minx = miny = 1e9; maxx = maxy = -1e9
for (mode, v), lst in frames.items():
    V = VW[v]
    for col, gl in lst:
        m = (col[..., 3] > 0.01) | (gl.max(axis=2) > 0.02)
        ys, xs = np.nonzero(m)
        minx = min(minx, xs.min() - V['CX']); maxx = max(maxx, xs.max() + 1 - V['CX'])
        miny = min(miny, ys.min() - V['FY']); maxy = max(maxy, ys.max() + 1 - V['FY'])
hw = int(math.ceil(max(-minx, maxx) / K)) + 1
above = int(math.ceil(-miny / K)) + 1
below = int(math.ceil(max(maxy, 0) / K)) + 1
hw = -(-hw // 4) * 4            # frame width multiple of 8 (ASTC 8x8 blocks)
below += (-(above + below)) % 8  # frame height multiple of 8
FW, FH = hw * 2, above + below
print('union rel anchor', minx, maxx, miny, maxy, '-> frame', FW, FH, 'pivot', (hw, above))

def cut(img, V):
    x0 = V['CX'] - K * hw; y0 = V['FY'] - K * above
    w, h = K * FW, K * FH
    pad = np.zeros((h, w, img.shape[2]), np.float32)
    sx0, sy0 = max(x0, 0), max(y0, 0)
    sx1, sy1 = min(x0 + w, W0), min(y0 + h, H0)
    pad[sy0 - y0:sy1 - y0, sx0 - x0:sx1 - x0] = img[sy0:sy1, sx0:sx1]
    return cv2.resize(pad, (FW, FH), interpolation=cv2.INTER_AREA)

def to_straight_u8(prem):
    a = prem[..., 3:4]
    rgb = np.where(a > 1e-6, prem[..., :3] / np.maximum(a, 1e-6), 0)
    return (np.clip(np.concatenate([rgb, a], axis=2), 0, 1) * 255 + .5).astype(np.uint8)

def save_sheet(mode, n):
    col = np.zeros((FH * 5, FW * n, 4), np.uint8)
    gl = np.zeros((FH * 5, FW * n, 3), np.uint8)
    for r, v in enumerate(VIEWS):
        for i, (c, g) in enumerate(frames[(mode, v)]):
            col[r * FH:(r + 1) * FH, i * FW:(i + 1) * FW] = to_straight_u8(cut(c, VW[v]))
            gl[r * FH:(r + 1) * FH, i * FW:(i + 1) * FW] = (np.clip(cut(g, VW[v]), 0, 1) * 255 + .5).astype(np.uint8)
    Image.fromarray(col, 'RGBA').save(f'{OUT}/soldier_{mode}_5dir.webp', lossless=True, quality=100, method=6)
    Image.fromarray(gl, 'RGB').save(f'{OUT}/soldier_{mode}_5dir-mask.webp', lossless=True, quality=100, method=6)
    Image.fromarray(col, 'RGBA').save(f'/home/claude/prev_{mode}.png')
    print(mode, col.shape)

save_sheet('idle', IDLE_N)
save_sheet('shot', SHOT_N)

# ---- layers atlas for death fx
def crop_layer(img, is_glow):
    m = (img[..., 3] > 0.004) if not is_glow else (img[..., :3].max(axis=2) > 0.004)
    if not m.any(): return None
    ys, xs = np.nonzero(m)
    x0, x1 = (xs.min() // K) * K, -(-(xs.max() + 1) // K) * K
    y0, y1 = (ys.min() // K) * K, -(-(ys.max() + 1) // K) * K
    c = img[y0:y1, x0:x1]
    c = cv2.resize(c, ((x1 - x0) // K, (y1 - y0) // K), interpolation=cv2.INTER_AREA)
    return (x0, y0, c)

def pack(items, width=512):
    x = y = rowh = 0; out = {}
    for key, (x0, y0, c) in items:
        h, w = c.shape[:2]
        if x + w > width: x = 0; y += rowh; rowh = 0
        y = -(-y // 8) * 8
        out[key] = (x, y, w, h, x0, y0, c); x += -(-(w + 1) // 8) * 8; rowh = max(rowh, -(-(h + 1) // 8) * 8)
    return out, -(-(y + rowh) // 8) * 8

col_items, glow_items = [], []
for v in VIEWS:
    for k in NAMES:
        r = crop_layer(SRC[v][k], False)
        if r: col_items.append(((v, k), r))
        r = crop_layer(GL[v][k], True)
        if r: glow_items.append(((v, k), r))
cpk, ch = pack(col_items); gpk, gh = pack(glow_items)
cat = np.zeros((ch, 512, 4), np.uint8); gat = np.zeros((gh, 512, 3), np.uint8)
for (v, k), (x, y, w, h, x0, y0, c) in cpk.items(): cat[y:y + h, x:x + w] = to_straight_u8(c)
for (v, k), (x, y, w, h, x0, y0, c) in gpk.items(): gat[y:y + h, x:x + w] = (np.clip(c[..., :3], 0, 1) * 255 + .5).astype(np.uint8)
Image.fromarray(cat, 'RGBA').save(f'{OUT}/soldier_layers.webp', lossless=True, quality=100, method=6)
Image.fromarray(gat, 'RGB').save(f'{OUT}/soldier_layers-mask.webp', lossless=True, quality=100, method=6)
print('atlas', cat.shape, gat.shape)

# ---- data file (GDScript)
def v2(x, y): return f'Vector2({x}, {y})'
lines = []
lines.append('class_name SoldierSheetData')
lines.append('extends RefCounted')
lines.append('## Сгенерировано export_soldier.py из студии. Не править руками: данные листов нового солдата.')
lines.append('')
lines.append(f'const FRAME_SIZE: Vector2i = Vector2i({FW}, {FH})')
lines.append(f'const PIVOT: Vector2 = Vector2({hw}.0, {above}.0)')
lines.append(f'const IDLE_FRAMES: int = {IDLE_N}')
lines.append(f'const SHOT_FRAMES: int = {SHOT_N}')
lines.append(f'const IDLE_PERIOD: float = {T}')
lines.append(f'const SHOT_DURATION: float = {D}')
lines.append(f'## Масштаб листа относительно студийного холста (1/{K}).')
lines.append(f'const SHEET_SCALE: float = {1.0 / K:.6f}')
vis = (VW['s']['FY'] - 85) / K
lines.append(f'## Видимая высота солдата (ступни — макушка) в px листа, вид S.')
lines.append(f'const VISIBLE_HEIGHT_PX: float = {vis:.1f}')
lines.append('')
lines.append('## Порядок видов в листах: 0 S, 1 SE, 2 E, 3 NE, 4 N.')
lines.append('const ROW_OF_DIRECTION: Array[int] = [0, 1, 2, 3, 4, 3, 2, 1]')
lines.append('const FLIP_OF_DIRECTION: Array[bool] = [false, true, true, true, false, false, false, false]')
lines.append('')
lines.append('## Параметры видов в координатах студийного холста 424x736 (до масштаба листа).')
lines.append('## anchor = (CX, FY) точка опоры; muzzle = (mx, my) до сдвига рук; arms/head_shift = (ax, ay)/(hx, hy).')
lines.append('const VIEWS: Array[Dictionary] = [')
for v in VIEWS:
    V = VW[v]
    spk = ', '.join(f'[{a}, {b}, {c}]' for a, b, c in V['spk'])
    lines.append('\t{')
    lines.append(f'\t\t"name": "{v}", "behind": {str(V["behind"]).lower()}, "an": {V["an"]}.0,')
    lines.append(f'\t\t"anchor": {v2(V["CX"], V["FY"])}, "head_c": {v2(*V["HC"])}, "arms_c": {v2(*V["AC"])},')
    lines.append(f'\t\t"muzzle": {v2(V["mx"], V["my"])}, "head_shift": {v2(V["hx"], V["hy"])}, "arms_shift": {v2(V["ax"], V["ay"])},')
    lines.append(f'\t\t"sparks": [{spk}],')
    lines.append('\t},')
lines.append(']')
lines.append('')
def rect_block(name, pk):
    lines.append(f'## {name}: [view][layer] -> {{rect (в атласе), origin (левый верх в координатах холста)}}')
    lines.append(f'const {name}: Array[Dictionary] = [')
    for v in VIEWS:
        parts = []
        for k in NAMES:
            if (v, k) in pk:
                x, y, w, h, x0, y0, _ = pk[(v, k)]
                parts.append(f'"{k}": {{"rect": Rect2({x}, {y}, {w}, {h}), "origin": {v2(x0, y0)}}}')
        lines.append('\t{' + ', '.join(parts) + '},')
    lines.append(']')
rect_block('LAYERS', cpk)
lines.append('')
rect_block('GLOW_LAYERS', gpk)
open('/home/claude/soldier_sheet_data.gd', 'w').write('\n'.join(lines) + '\n')

# ---- .import files (same settings as the bug sheets: VRAM compressed, ASTC, no mipmaps)
IMPORT = '''[remap]

importer="texture"
type="CompressedTexture2D"
metadata={
"imported_formats": ["s3tc_bptc", "etc2_astc"],
"vram_texture": true
}

[deps]

source_file="res://assets/sprites/units/new_soldier/%s"

[params]

compress/mode=2
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
'''
for f in os.listdir(OUT):
    if f.endswith('.webp'):
        open(f'{OUT}/{f}.import', 'w').write(IMPORT % f)
print(sorted(os.listdir(OUT)))
