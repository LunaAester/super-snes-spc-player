"""Native SNES 2bpp HUD; Latin glyphs extracted from the supplied font sheet."""
from pathlib import Path
import json
import struct
from PIL import Image

B = Path(__file__).resolve().parent
sheet = Image.open(B / 'megaman_x_font.png').convert('RGB')
assert sheet.size == (304, 185)
glyphs, sources = {}, {}

def extract(character, column, row):
    tile = []
    for y in range(8):
        line = []
        for x in range(8):
            color = sheet.getpixel((4 + 9*column + x, 4 + 9*row + y))
            line.append({(208,224,240):1, (80,224,248):2}.get(color, 3))
        tile.append(line)
    glyphs[character] = tile
    sources[character] = [4 + 9*column, 4 + 9*row, 8, 8]

for n, c in enumerate('ABCDEFGHIJKLMNOPQRSTUVWXYZ'): extract(c,n,0)
for n, c in enumerate('abcdefghijklmnopqrstuvwxyz'): extract(c,n,1)
for n, c in enumerate('0123456789'): extract(c,n,2)
for c, n in {'!':0,'"':1,'#':2,'(':3,')':4,'%':5,',':6,'.':7,'/':8,
             ':':9,';':10,"'":11,'`':12,'<':13,'>':14,'?':15,'[':16,
             ']':18,'^':19,'_':20,'-':21,'=':22}.items(): extract(c,n,3)

def bitmap(rows): return [[int(c) for c in row] for row in rows]
def fallback(c, rows):
    glyphs[c] = [[(1 if y < 3 else 2) if p=='1' else 3 for p in row]
                 for y,row in enumerate(rows)]

fallback(' ', ['00000000']*8)
fallback('+', ['00000000','00010000','00010000','01111100','00010000','00010000','00000000','00000000'])
fallback('*', ['00000000','01010100','00111000','01111100','00111000','01010100','00000000','00000000'])
fallback('~', ['00000000','00000000','00100100','01011000','00000000','00000000','00000000','00000000'])
fallback('\\', ['01000000','00100000','00010000','00001000','00000100','00000010','00000000','00000000'])
fallback('|', ['00010000']*7+['00000000'])
fallback('$', ['00010000','00111100','01010000','00111000','00010100','01111000','00010000','00000000'])
fallback('&', ['00110000','01001000','00110000','01010100','01001000','00110100','00000000','00000000'])
fallback('@', ['00111000','01000100','01011100','01010100','01011000','01000000','00111100','00000000'])
fallback('{', ['00011000','00100000','00100000','01000000','00100000','00100000','00011000','00000000'])
fallback('}', ['00110000','00001000','00001000','00000100','00001000','00001000','00110000','00000000'])

tiles = [glyphs.get(chr(code),glyphs['?']) for code in range(32,128)]
tl = bitmap(['00000000','00022222','00233333','02333333','02333333','02333333','02333333','02333333'])
tiles += [tl, [r[::-1] for r in tl], tl[::-1], [r[::-1] for r in tl[::-1]],
          bitmap(['00000000','22222222','33333333','00000000','00000000','00000000','00000000','00000000']),
          bitmap(['02300000']*8),
          # Left half of a 14px LED; right half uses hardware horizontal flip.
          bitmap(['33333333','33111111','32222222','32222222','32222222','32222222','33322222','33333333']),
          bitmap(['33333333','33222222','33233333','33233333','33233333','33233333','33222222','33333333']),
          bitmap(['33333333','32223333','32112223','32111123','32111123','32111123','32222223','33333333']),
          bitmap(['33322133','33322223','33323323','33323323','32223323','32123223','32233323','33333333']),
          bitmap(['33333333','32333333','32233333','32223333','32222333','32223333','32233333','33333333']),
          bitmap(['33333333']*8),
          bitmap(['33333333','33333333','33333333','31111111','31111111','33333333','33333333','33333333']),
          bitmap(['33333333','33333333','11111111','22222222','22222222','33333333','33333333','33333333']),
          bitmap(['33333333','33333333','22222222','33333333','22222222','33333333','33333333','33333333']),
          bitmap(['33333333','33333333','33322333','33211233','33211233','33322333','33333333','33333333']),
          bitmap(['33333333','33322333','33211233','33211233','33322333','33333333','33333333','33333333']),
          bitmap(['33333333','33222333','32111233','32111233','33222333','33333333','33333333','33333333'])]
# Two 3-pixel segments in each 8-pixel tile, with an independent peak marker.
assert len(tiles)<=118
tiles += [glyphs[' ']] * (118 - len(tiles))
for upper in range(3):
    for lower in range(3):
        tile=[[3]*8 for _ in range(8)]
        for base,state in [(0,upper),(4,lower)]:
            for y in (1,2):
                for x in range(1,8):tile[base+y][x]=0 if state==0 else (1 if state==2 or y==1 else 2)
        tiles.append(tile)
tiles += [glyphs[' ']] * (128 - len(tiles))
# The trace is a signed OUTX sample plotted as a horizontal hold, eight levels.
for level in range(8):
    tile=[[3]*8 for _ in range(8)]
    for x in range(7):tile[level][x]=1 if x%2==0 else 2
    tiles.append(tile)


def encode(tile):
    data = bytearray()
    for row in tile:
        data += bytes([sum((p&1)<<(7-x) for x,p in enumerate(row)),
                       sum(((p>>1)&1)<<(7-x) for x,p in enumerate(row))])
    return data
(B/'font.bin').write_bytes(b''.join(encode(t) for t in tiles))
(B/'font_sources.json').write_text(json.dumps({'sheet':'megaman_x_font.png',
    'credit':'Mega Man X / Capcom; sheet ripped by QuadFactor; supplied by user',
    'glyph_rectangles':sources,'supplemental':list(' +*~\\|$&@{}')},indent=2))

def rgb(r,g,b): return (r>>3)|((g>>3)<<5)|((b>>3)<<10)
bg, panel = rgb(6,12,24), rgb(12,24,40)
palettes = [
    (bg,rgb(216,232,248),rgb(96,184,224),panel),
    (bg,rgb(224,248,255),rgb(64,208,240),panel),
    (bg,rgb(144,168,192),rgb(88,120,152),panel),
    (bg,rgb(255,248,192),rgb(255,200,72),rgb(40,48,72)),
    (bg,rgb(200,255,216),rgb(64,232,120),rgb(12,40,32)),
    (bg,rgb(255,248,184),rgb(255,192,48),rgb(48,36,24)),
    (bg,rgb(255,216,240),rgb(240,112,192),panel),
    (bg,rgb(72,96,120),rgb(40,64,88),panel)]
(B/'palette.bin').write_bytes(b''.join(struct.pack('<4H',*p) for p in palettes))

def screen(lines,boxes=()):
    data = bytearray(2048)
    def put(r,c,t,a=0,flip=0): struct.pack_into('<H',data,2*(r*32+c),t|(a<<10)|flip)
    def text(r,c,s,a=0):
        assert c+len(s)<=31,(r,s)
        for i,char in enumerate(s.upper()): put(r,c+i,ord(char)-32,a)
    def box(y,x,w,h,a=1):
        for r in range(y+1,y+h-1):
            for c in range(x+1,x+w-1): put(r,c,107)
        for n,t in enumerate((96,97,98,99)):
            put(y+(h-1 if n>=2 else 0),x+(w-1 if n%2 else 0),t,a)
        for c in range(x+1,x+w-1): put(y,c,100,a);put(y+h-1,c,100,a,0x8000)
        for r in range(y+1,y+h-1): put(r,x,101,a);put(r,x+w-1,101,a,0x4000)
    box(0,1,30,4)
    text(1,2,'SUPER SNES SPC PLAYER!',1)
    text(2,2,'V1.1',2);text(2,12,'MICROSD',0);text(2,25,'LUNA',6)
    for i,a in enumerate((6,1,5,4)): put(1,26+i,112,a)
    for b in boxes: box(*b)
    for row,col,string,attr in lines: text(row,col,string,attr)
    return data,put,text

data,put,text = screen([
    (4,2,'FOLDER:  ROOT',0),(6,2,'LIBRARY',1),(6,19,'SPC',5),
    (6,25,'L  R',1),(18,2,'STOP',2),(18,23,'READY',2),
    (20,2,'VOLUME:',1),(21,2,'TEMPO:',6),(22,2,'AUDIO:',1),
    (24,1,'A PLAY  B BACK      L/R TRACK',0),
    (25,1,'Y+<> TEMPO  X+UP/DOWN VOLUME',2),
    (26,1,'SEL+B MONO/ST   SEL+A STOP',2),
    (27,1,'SEL+START VIEW  SEL+L/R INFO',2)],[(5,1,23,13),(5,24,7,13),(19,1,30,5)])
for row,cols,a in [(24,[1],4),(24,[9],5),(24,[22,23,24],1),(25,[1,2,3,4],6),
                   (25,list(range(13,22)),1),
                   (26,[1,2,3,4,5],5),(26,[16,17,18,19,20],4)]:
    for col in cols:
        val=struct.unpack_from('<H',data,2*(row*32+col))[0]
        put(row,col,val&1023,a)
for col in range(17,29): put(20,col,110,7)
for col in range(17,24): put(21,col,110,7)
text(21,25,'Y<>',2)
(B/'screen.bin').write_bytes(data)
data,put,text=screen([(8,6,'LOADING SPC...',1),(14,14,'000%',4),
                 (16,3,'MICROSD -> RAM -> SPC700',2)],[(6,1,30,13)])
for col in range(3,29):put(12,col,109,7)
(B/'loading.bin').write_bytes(data)
data,_,_=screen([(5,3,'UNABLE TO COMPLETE',6),(9,2,'REG CFG/STS:',0),
    (10,2,'APU:',0),(12,2,'SD CMD/R1:',0),(13,2,'LBA:',0),(14,2,'PHASE/RECOV:',0),
    (15,2,'ARG / CRC:',0),(16,2,'APU STEP/BYTE:',0),(18,2,'TAKE A FULL SCREEN PHOTO',2),
    (23,2,'B BACK / RETRY',0)],[(4,1,30,16)])
(B/'error.bin').write_bytes(data)
print('HUD: 128 native 2bpp tiles; long titles; 20 stereo LEDs per channel')
