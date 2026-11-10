from pathlib import Path
import re, sys
root=Path(sys.argv[1])/'src'
expected={
 'Color':'style/color.cj','Style':'style/style.cj','BorderStyle':'style/border_style.cj',
 'Rect':'geometry/rect.cj','Frame':'frame.cj','Cell':'cell.cj','Component':'component.cj',
 'Alignment':'alignment.cj','LayoutNode':'layout_node.cj','KeyEvent':'key_event.cj',
 'InputDecoder':'input_decoder.cj','Application':'application.cj'}
errors=[]; found={}
for path in sorted(root.rglob('*.cj')):
 text=path.read_text(); rel=path.relative_to(root).as_posix()
 types=re.findall(r'^\s*(?:public\s+|internal\s+|private\s+)?(?:class|struct|interface|enum)\s+(\w+)', text, re.M)
 if len(types)>1: errors.append(f'{rel}: mixed types {types}')
 if not re.fullmatch(r'[a-z][a-z0-9_]*\.cj',path.name): errors.append(f'{rel}: file name')
 want='cjtui'+(''.join('.'+p for p in path.relative_to(root).parts[:-1]))
 if re.search(r'^package\s+(\w[\w.]*)',text,re.M).group(1)!=want: errors.append(f'{rel}: package')
 for name in types:
  if name in found: errors.append(f'duplicate {name}')
  found[name]=rel
for name,path in expected.items():
 if found.get(name)!=path: errors.append(f'{name}: {found.get(name)} != {path}')
if not (root/'text/unicode.cj').is_file(): errors.append('text/unicode.cj missing')
print('\n'.join(errors) if errors else 'PASS: one type per lower_snake file; exact D026 type/package map; text adapter present')
sys.exit(bool(errors))
