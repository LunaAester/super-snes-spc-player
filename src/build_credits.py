"""Conventional 2bpp conversion of Luna's original artwork; no image generation."""
from pathlib import Path
from PIL import Image
import struct
import json
import numpy as np
B=Path(__file__).resolve().parent
im=Image.open(B/'logo_reference.png').convert('RGB')
im.thumbnail((208,96),Image.Resampling.BOX)
canvas=Image.new('RGB',(208,96),'white')
canvas.paste(im,((208-im.width)//2,(96-im.height)//2))
bg=(6,12,24)
colors=[(bg,(224,248,255),(64,208,240),bg),
        (bg,(255,48,40),(92,8,8),bg),
        (bg,(255,144,8),(104,48,0),bg),
        (bg,(96,120,255),(32,48,120),bg),
        (bg,(40,216,16),(0,56,0),bg),
        (bg,(255,248,192),(255,200,72),bg),
        (bg,(168,184,200),(80,112,136),bg),
        (bg,(255,216,240),(240,112,192),bg)]
def rgb(c):return (c[0]>>3)|((c[1]>>3)<<5)|((c[2]>>3)<<10)
palette=b''.join(struct.pack('<4H',*(rgb(c) for c in p)) for p in colors)
font=(B/'font.bin').read_bytes()
tiles=[];lookup={};screen=bytearray(2048)
for ty in range(12):
    for tx in range(26):
        a=np.asarray(canvas.crop((tx*8,ty*8,tx*8+8,ty*8+8))).astype(float)
        opaque=a.min(axis=2)<246
        best=None
        for p in range(1,5):
            cs=np.asarray(colors[p][:3],float)
            dist=((a[:,:,None,:]-cs)**2).sum(axis=3)
            indices=dist.argmin(axis=2)
            indices[~opaque]=0
            error=(dist.min(axis=2)*opaque).sum()
            if best is None or error<best[0]:best=(error,p,indices)
        _,pal,pixels=best
        tile=bytes(v for row in pixels for v in
                   (sum((int(p)&1)<<(7-x) for x,p in enumerate(row)),
                    sum(((int(p)>>1)&1)<<(7-x) for x,p in enumerate(row))))
        if tile not in lookup:lookup[tile]=136+len(tiles);tiles.append(tile)
        struct.pack_into('<H',screen,2*((ty+1)*32+tx+3),lookup[tile]|(pal<<10))
def line(row,text,pal=0):
    assert len(text)<=30,(row,text)
    col=(32-len(text))//2
    for i,c in enumerate(text):struct.pack_into('<H',screen,2*(row*32+col+i),ord(c)-32|(pal<<10))
for row,text,pal in [(14,'Super SNES SPC Player!',0),(15,'Public Ver.1.1',5),
                     (16,'Dev Ver.1.3.1-E',6),(18,'Project & original logo: Luna',0),
                     (19,'Made with ChatGPT support.',0),
                     (20,'No generative AI was used',6),
                     (21,"to create this edition's",6),(22,'graphics.*',6),
                     (24,'Font: Mega Man X / Capcom',0),
                     (25,'Sheet ripped by QuadFactor',6),(27,'B BACK   START+X CREDITS',5)]:line(row,text,pal)
(B/'credits_tiles.bin').write_bytes(b''.join(tiles))
(B/'credits_map.bin').write_bytes(screen)
(B/'credits_palette.bin').write_bytes(palette)
print('Credits:',len(tiles),'native tiles; original user artwork')

