from pathlib import Path
import json,re,hashlib
B=Path('/workspace/work/theme-execution');rows=[]
for family in ['gui','gui-glyph']:
 for p in sorted((B/'raw'/family).iterdir()):
  if not p.is_dir():continue
  before=json.loads((p/'terminal-before.json').read_text());after=json.loads((p/'terminal-after.json').read_text());assert after['exit']==0 and after['before']==after['after'];assert before['grid']=='25 80'
  if p.name.startswith('vte-'):text=(p/'native-0-range.txt').read_text();native='VTE actual widget text'
  else:
   text=re.sub(r'\x1b(?:\[[0-?]*[ -/]*[@-~]|#[0-9])','',(p/'native-grid.ansi').read_text());native='XTerm native print'
  lines=text.splitlines()
  if family=='gui':expected=['x','y'];actual=[s.rstrip(' ') for s in lines[:2]]
  else:expected=['','.','..','...','A...'] if p.name.endswith('Ascii') else ['','…','A…','AB…','ABC…'];actual=[s.rstrip(' ') for s in lines[:5]]
  assert actual==expected,(p.name,actual,expected)
  stats=json.loads((p/'trace-extraction.json').read_text());assert stats['pending']==0 and not stats['unparsedTarget']
  rows.append({'scene':family,'host':p.name,'expected_from':'frozen preset_frames.cj first3cols/2rows' if family=='gui' else 'frozen glyph-pty.mjs first5 independent expected rows at widths0..4','native':native,'native_rows':actual,'termios_equal':True,'exit':after['exit'],'png':str((p/'preset.png').relative_to(B)),'png_sha256':hashlib.sha256((p/'preset.png').read_bytes()).hexdigest(),'actual_term':before['TERM'],'utc':after['utcEnd']})
(B/'raw/gui-oracles.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2)+'\n');print('Verified',len(rows),'actual native viewport records and original PNGs')
