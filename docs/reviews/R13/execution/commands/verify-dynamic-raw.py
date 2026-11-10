from pathlib import Path
import json,re,hashlib
base=Path('/workspace/work/dynamic-execution/evidence/gui-dynamic')
title='r: reverse   e: empty/refill   i: insert manual   v: toggle   q: quit'
desc='Declared and manual children share one sequence'
stages=[('initial',[title,desc,'A','B','C']),('hidden',[title,'A','B','C']),('inserted',[title,'A','manual','B','C']),('reordered',[title,'C','manual','B','A']),('emptied',[title,'manual']),('refilled',[title,'manual','D','E']),('shown',[title,desc,'manual','D','E']),('resized',[title,desc,'manual','D','E'])]
results=[]
for profile in ['xterm-default','xfce-vte']:
 d=base/profile/'q'; grid={};row=0;col=0;ver=[]
 metadata=json.loads((d/'metadata.json').read_text())
 for stage,want in stages:
  raw=(d/f'example-{stage}.raw').read_bytes();data=raw.decode('utf8');i=0
  width,height=(120,34) if stage=='resized' else (100,28)
  while i<len(data):
   if data[i]=='\x1b':
    m=re.match(r'\x1b\[([0-?]*)([ -/]*)([@-~])',data[i:]);assert m,(profile,stage,'unsupported escape',repr(data[i:i+30]))
    params,_,cmd=m.groups();ns=[int(x or '0') for x in params.split(';')] if not params.startswith('?') else []
    if cmd in ['H','f']:row=(ns[0] or 1)-1;col=(ns[1] or 1)-1 if len(ns)>1 else 0
    elif cmd=='J' and ns and ns[0]==2:grid={}
    elif cmd=='K':
     for key in list(grid):
      if key[0]==row and key[1]>=col:del grid[key]
    else:assert cmd in ['m','h','l'],(profile,stage,'unsupported CSI',m.group())
    i+=len(m.group());continue
   c=data[i]
   if c=='\r':col=0
   elif c=='\n':row+=1
   elif c>=' ':grid[row,col]=c;col+=1
   i+=1
  actual=[''.join(grid.get((r,c),' ') for c in range(width)) for r in range(height)]
  expected=[line.ljust(width) for line in want]+[' '*width]*(height-len(want))
  (d/f'example-{stage}-full-grid.txt').write_text('\n'.join(actual)+'\n')
  (d/f'example-{stage}-expected-grid.txt').write_text('\n'.join(expected)+'\n')
  assert actual==expected,(profile,stage,[(i,a.rstrip(),e.rstrip()) for i,(a,e) in enumerate(zip(actual,expected)) if a!=e])
  ver.append(dict(stage=stage,width=width,height=height,full_grid_equal=True,raw_sha256=hashlib.sha256(raw).hexdigest()))
 for which in ['inner','outer']:
  state=(d/f'{which}-tty.txt').read_text();fields=dict(line.split('=',1) for line in state.splitlines() if '=' in line)
  assert fields['ready_size']=='28 100' and fields['exit_size']=='34 120',fields
  assert fields['ready_termios']==fields['exit_termios'] and fields['exit_status']=='0',fields
 (d/'dynamic-state-verification.json').write_text(json.dumps(ver,indent=2)+'\n');results.append(dict(profile=profile,stages=ver,restoration=True,exit=0))
print(json.dumps(results,indent=2))
