from pathlib import Path

lines = Path('/workspace/work/color-api-recon/logs/output.txt').read_text().splitlines()
values = dict(line.split('|', 1) for line in lines)
checked = 0

def check(label, expected):
    global checked
    actual = bytes(int(x) for x in values[label].split(',') if x)
    assert actual == expected.encode('ascii'), (label, actual, expected)
    checked += 1

names = ['Black', 'Red', 'Green', 'Yellow', 'Blue', 'Magenta', 'Cyan', 'White',
         'BrightBlack', 'BrightRed', 'BrightGreen', 'BrightYellow', 'BrightBlue',
         'BrightMagenta', 'BrightCyan', 'BrightWhite', 'Default']
codes = list(range(30, 38)) + list(range(90, 98)) + [39]
for name, code in zip(names, codes):
    check('fg.' + name, f'\x1b[{code}m')
    check('bg.' + name, f'\x1b[{code + 10}m')
for i in range(256):
    check(f'fg.index.{i}', f'\x1b[38;5;{i}m')
    check(f'bg.index.{i}', f'\x1b[48;5;{i}m')
for r, g, b in [(0, 0, 0), (255, 255, 255), (1, 128, 254), (255, 0, 128)]:
    name = f'#{r:02x}{g:02x}{b:02x}'
    check('fg.rgb.' + name, f'\x1b[38;2;{r};{g};{b}m')
    check('bg.rgb.' + name, f'\x1b[48;2;{r};{g};{b}m')
for name, setcode, resetcode in [('Bold', 1, 21), ('Dim', 2, 22), ('Italic', 3, 23),
                                  ('UnderLine', 4, 24), ('Reverse', 7, 27), ('StrikeThrough', 9, 29)]:
    check('set.' + name, f'\x1b[{setcode}m')
    check('reset.' + name, f'\x1b[{resetcode}m')
for label, sgr in [('reset.all', '0'), ('reset.fg', '39'), ('reset.bg', '49'),
                   ('reset.colors', '39;49'), ('set.both', '104;38;2;1;2;3')]:
    check(label, '\x1b[' + sgr + 'm')
assert values['syntax.index.eq'] == 'true'
assert values['syntax.rgb.eq'] == 'true'
assert values['syntax.rgb.ne'] == 'true'
assert values['syntax.rgb.payload'] == '0,128,255'
print(f'{checked} exact ANSI byte assertions passed; 4 enum syntax/runtime assertions passed')
print(f'{len(lines)} total records; converter diagnostic records retained without asserting their correctness')
