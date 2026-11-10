from pathlib import Path
import json,re
base=Path('/workspace/work/runtime-execution/evidence/gui-reactive')
results=[]
for profile in ['xterm-default','xfce-vte']:
 d=base/profile/'interrupt'; grid={};row=0;col=0
 stages=[('initial',0),('increment-one',1),('increment-two',2),('resized',3)]
 for stage,want in stages:
  data=(d/f'example-{stage}.raw').read_bytes().decode('utf8',errors='replace')
  i=0
  while i<len(data):
   if data[i]=='\x1b':
    m=re.match(r'\x1b\[([0-?]*)([ -/]*)([@-~])',data[i:])
    if m:
     params,_,cmd=m.groups(); ns=[int(x or '0') for x in params.split(';')] if not params.startswith('?') else []
     if cmd in ['H','f']:
      row=(ns[0] or 1)-1;col=(ns[1] or 1)-1 if len(ns)>1 else 0
     elif cmd=='J' and ns and ns[0]==2:grid={}
     elif cmd=='K':
      for key in list(grid):
       if key[0]==row and key[1]>=col:del grid[key]
     i+=len(m.group());continue
    # CSI is expected to be complete at stage capture barriers.
    raise AssertionError(f'unrecognized ESC {data[i:i+30]!r}')
   c=data[i]
   if c=='\r':col=0
   elif c=='\n':row+=1
   elif c>=' ':grid[row,col]=c;col+=1
   i+=1
  line=''.join(grid.get((0,c),' ') for c in range(30)).rstrip()
  assert line==f'Count: {want}',(profile,stage,line,want)
  results.append(dict(profile=profile,stage=stage,row0=line))
 (d/'reactive-state-verification.json').write_text(json.dumps(results[-4:],indent=2)+'\n')
print(json.dumps(results,indent=2))
