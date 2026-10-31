"""Original Campus Pixel glyphs; GPL-3.0-or-later. No external font dependency.

Regenerate the BMFont atlas with Python's standard library from the repo root:
python game/tools/generate_pixel_font.py
"""
from pathlib import Path
import struct
import unicodedata
import zlib

# Each hexadecimal row is a five-pixel mask. Lowercase has its own forms.
MASKS = {
    'A':'0E11111F111111','B':'1E11111E11111E','C':'0E11101010110E',
    'D':'1E11111111111E','E':'1F10101E10101F','F':'1F10101E101010',
    'G':'0E11101711110F','H':'1111111F111111','I':'0E04040404040E',
    'J':'0702020212120C','K':'11121418141211','L':'1010101010101F',
    'M':'111B1515111111','N':'11191513111111','O':'0E11111111110E',
    'P':'1E11111E101010','Q':'0E11111115120D','R':'1E11111E141211',
    'S':'0F10100E01011E','T':'1F040404040404','U':'1111111111110E',
    'V':'11111111110A04','W':'11111115151B11','X':'11110A040A1111',
    'Y':'11110A04040404','Z':'1F01020408101F',
    'a':'00000E010F110F','b':'1010161911111E','c':'00000E1110110E',
    'd':'01010D1311110F','e':'00000E111F100E','f':'0609081C080808',
    'g':'00000F110F010E','h':'10101619111111','i':'04000C0404040E',
    'j':'0200060202120C','k':'10101214181412','l':'0C04040404040E',
    'm':'00001A15151515','n':'00001619111111','o':'00000E1111110E',
    'p':'00001E111E1010','q':'00000F110F0101','r':'00001619101010',
    's':'00000F100E011E','t':'08081C08080906','u':'0000111111130D',
    'v':'00001111110A04','w':'0000111115150A','x':'0000110A040A11',
    'y':'000011110F010E','z':'00001F0204081F',
    '0':'0E11131519110E','1':'040C040404040E','2':'0E11010204081F',
    '3':'1E01010601011E','4':'02060A121F0202','5':'1F101E0101110E',
    '6':'0608101E11110E','7':'1F010204080808','8':'0E11110E11110E',
    '9':'0E11110F01020C',' ':'00000000000000','.':'00000000000C0C',
    ',':'00000000000C08',':':'000C0C000C0C00',';':'000C0C000C0C08',
    '!':'04040404040004','?':'0E110102040004','-':'0000001F000000',
    '_':'0000000000001F','+':'0004041F040400','=':'00001F001F0000',
    '/':'01010204081010','\\':'10100804020101','(':'02040808080402',
    ')':'08040202020408','[':'0E08080808080E',']':'0E02020202020E',
    '<':'01020408040201','>':'10080402040810','%':'19190204081313',
    '*':'000A041F040A00','#':'0A0A1F0A1F0A0A','|':'04040404040404',
    '"':'0A0A0000000000',"'":'04040000000000','·':'00000004000000',
    '→':'0004021F020400','←':'0004081F080400','↑':'040E1504040400',
    '↓':'00040404150E04','−':'0000001F000000','✓':'00000102140800',
    '✦':'00040E1F0E0400','◇':'00040A110A0400','▾':'0000001F0E0400',
    '…':'00000000001500','¡':'04000404040404','¿':'0400040810110E',
    '×':'0000110A040A11','²':'06010204070000','³':'06010201060000',
    '↻':'0E11031711110E','°':'06090600000000',
}


def glyphs():
    result = {ch: [0, 0] + [int(rows[i:i+2], 16) for i in range(0, 14, 2)]
              for ch, rows in MASKS.items()}
    for ch in 'áéíóúÁÉÍÓÚñÑüÜ':
        decomposed = unicodedata.normalize('NFD', ch)
        rows = result[decomposed[0]].copy()
        rows[:2] = [2, 4] if decomposed[1] == '\u0301' else ([10, 0] if decomposed[1] == '\u0308' else [10, 20])
        result[ch] = rows
    return result


def chunk(kind, data):
    return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind+data))


def generate():
    destination = Path(__file__).resolve().parents[1] / 'assets' / 'fonts'
    destination.mkdir(parents=True, exist_ok=True)
    chars = glyphs()
    width, height = 128, 160
    pixels = bytearray(width * height * 4)
    definitions = []
    for index, (character, rows) in enumerate(chars.items()):
        x, y = (index % 16) * 8, (index // 16) * 12
        for row, mask in enumerate(rows):
            for col in range(5):
                if mask & (1 << (4-col)):
                    offset = ((y+row)*width+x+col)*4
                    pixels[offset:offset+4] = b'\xff'*4
        definitions.append(f'char id={ord(character)} x={x} y={y} width=5 height=9 xoffset=0 yoffset=0 xadvance={4 if character == " " else 6} page=0 chnl=15')
    raw = b''.join(b'\0'+pixels[row*width*4:(row+1)*width*4] for row in range(height))
    png = b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0))+chunk(b'IDAT', zlib.compress(raw))+chunk(b'IEND', b'')
    (destination/'campus_pixel.png').write_bytes(png)
    header = ['info face="Campus Pixel" size=10 bold=0 italic=0 unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=1,1',
              f'common lineHeight=12 base=10 scaleW={width} scaleH={height} pages=1 packed=0',
              'page id=0 file="campus_pixel.png"', f'chars count={len(chars)}']
    (destination/'campus_pixel.fnt').write_text('\n'.join(header+definitions)+'\n', encoding='utf-8')
    print(f'Campus Pixel: {len(chars)} original glyphs generated.')


if __name__ == '__main__':
    generate()
