"""Convert the original supplied artwork to native SNES 4bpp tiles and maps."""
from pathlib import Path
from PIL import Image
import struct,json
B=Path(__file__).resolve().parent
im=Image.open(B/'logo_reference.png').convert('RGBA')
# Remove only the white paper background before conventional pixel scaling.
data=list(im.getdata())
im.putdata([(r,g,b,0 if min(r,g,b)>246 else a) for r,g,b,a in data])
box=im.getchannel('A').point(lambda a:255 if a>=128 else 0).getbbox()
im=im.crop(box);im.thumbnail((240,152),Image.Resampling.BOX)
canvas=Image.new('RGBA',(240,152));canvas.alpha_composite(im,((240-im.width)//2,(152-im.height)//2))
fixed=[(255,24,24),(64,0,0),(255,136,0),(120,48,0),
       (80,104,255),(30,43,128),(0,208,0),(0,48,0),
       (248,248,232),(168,176,184),(8,12,16),(208,8,8),
       (224,104,0),(48,72,208),(0,152,0)]
pal=[v for color in fixed for v in color]
palette_image=Image.new('P',(1,1));palette_image.putpalette(pal+pal[-3:]*(256-15))
rgb=canvas.convert('RGB').quantize(palette=palette_image,dither=Image.Dither.NONE)
pixels=list(rgb.get_flattened_data());alpha=list(canvas.getchannel('A').get_flattened_data())
pixels=[v+1 if a>=128 else 0 for v,a in zip(pixels,alpha)]
def encode(tile):
 out=bytearray()
 for bit in (0,2):
  for row in tile:
   out+=bytes(sum(((p>>(bit+k))&1)<<(7-x) for x,p in enumerate(row)) for k in (0,1))
 return bytes(out)
tiles=[encode([[0]*8 for _ in range(8)])];lookup={tiles[0]:0};logo=bytearray(2048)
for ty in range(19):
 for tx in range(30):
  tile=encode([[pixels[(ty*8+y)*240+tx*8+x] for x in range(8)] for y in range(8)])
  if tile not in lookup:lookup[tile]=len(tiles);tiles.append(tile)
  struct.pack_into('<H',logo,2*((ty+5)*32+tx+1),lookup[tile])
fontbase=len(tiles);font=(B/'font.bin').read_bytes()
for t in range(96):
 tile=[[((font[t*16+y*2]>>(7-x))&1)|(((font[t*16+y*2+1]>>(7-x))&1)<<1) for x in range(8)] for y in range(8)]
 tile=[[0 if p==3 else p for p in row] for row in tile];tiles.append(encode(tile))
name=bytearray(2048)
def text(m,row,s):
 col=(32-len(s))//2
 for x,c in enumerate(s):struct.pack_into('<H',m,2*(row*32+col+x),fontbase+ord(c)-32|0x400)
text(logo,25,'Ver.1.1')
def snes(c):return (c[0]>>3)|((c[1]>>3)<<5)|((c[2]>>3)<<10)
colors=[(6,12,24)]+[tuple(pal[i:i+3]) for i in range(0,45,3)]+[(6,12,24),(224,240,255),(96,216,248)]+[(6,12,24)]*13
palette=b''.join(struct.pack('<H',snes(c)) for c in colors)
(B/'intro_tiles.bin').write_bytes(b''.join(tiles));(B/'intro_palette.bin').write_bytes(palette)
(B/'intro_name.bin').write_bytes(name);(B/'intro_logo.bin').write_bytes(logo)
preview=Image.new('RGB',(256,224),colors[0])
for y in range(152):
 for x in range(240):preview.putpixel((x+8,y+40),colors[pixels[y*240+x]])
preview.resize((768,672),Image.Resampling.NEAREST).save(B/'logo_native_preview.png')
assert len(tiles)<768 and len(palette)==64
(B/'intro_art.json').write_text(json.dumps(dict(original_size=im.size,tile_count=len(tiles),logo_font_base=fontbase,mode='SNES Mode 1, BG1 4bpp, 2 palettes'),indent=2))
print('Intro graphics:',len(tiles),'4bpp tiles')
