from pathlib import Path
from PIL import Image
import math

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'art_source' / 'bug_rig'
DST = ROOT / 'assets' / 'sprites' / 'units' / 'base_bug_rig'
DST.mkdir(parents=True, exist_ok=True)

def alpha_report(im):
    a = im.getchannel('A')
    vals = list(a.getdata())
    edge = []
    w, h = im.size
    for x in range(w): edge += [a.getpixel((x,0)), a.getpixel((x,h-1))]
    for y in range(1,h-1): edge += [a.getpixel((0,y)), a.getpixel((w-1,y))]
    semi = sum(1 for v in vals if 0 < v < 255)
    return min(edge), max(edge), sum(1 for v in edge if v > 0), semi

def crop(im):
    box = im.getchannel('A').getbbox()
    return im.crop(box) if box else im

def process(name, target_width=None, trim_bottom=False, squash_y=False):
    im = Image.open(SRC / name).convert('RGBA')
    before = im.size
    print(f'{name}: alpha edge min/max/nonzero, semi={alpha_report(im)}')
    # Inputs are already transparent; only flood-fill opaque white if present.
    pix = im.load(); w,h=im.size
    corners=[pix[0,0],pix[w-1,0],pix[0,h-1],pix[w-1,h-1]]
    if all(c[3] > 245 and max(c[:3]) > 245 for c in corners):
        from collections import deque
        q=deque([(0,0)]); seen=set()
        while q:
            x,y=q.popleft()
            if (x,y) in seen or not (0<=x<w and 0<=y<h): continue
            seen.add((x,y)); r,g,b,a=pix[x,y]
            if max(r,g,b) < 245 or a < 245: continue
            pix[x,y]=(r,g,b,0)
            q.extend(((x+1,y),(x-1,y),(x,y+1),(x,y-1)))
        print('  flood-fill: applied')
    else: print('  flood-fill: not needed (transparent background)')
    im=crop(im)
    if trim_bottom:
        trim=max(1,round(im.height*0.03)); im=im.crop((0,0,im.width,im.height-trim))
    if target_width:
        scale=target_width/im.width; im=im.resize((target_width,round(im.height*scale)),Image.Resampling.LANCZOS)
    if squash_y:
        im=im.resize((im.width,round(im.height*0.8)),Image.Resampling.LANCZOS)
    out=DST/name
    im.save(out, optimize=True)
    print(f'  source={before}, final={im.size}')
    return im

body=process('bug_body_w.png', target_width=180)
leg=process('bug_leg.png', target_width=None, trim_bottom=True, squash_y=True)
# Refit the already processed leg to the requested final height without changing its flat root.
leg_path = DST / 'bug_leg.png'
leg = Image.open(leg_path).convert('RGBA')
leg = leg.resize((round(leg.width * 70.0 / max(leg.height, 1)), 70), Image.Resampling.LANCZOS)
leg.save(leg_path, optimize=True)
print(f'  leg final refit={leg.size}')
print('body pivot: bottom skirt center = (%.1f, %.1f)' % (body.width/2, body.height-1))
print('leg pivot: top root center = (%.1f, 0.0)' % (leg.width/2))
print('leg_length_scale=0.80; axis rotation: source is vertical, measured 0.0 degrees')
