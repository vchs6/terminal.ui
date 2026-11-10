from pathlib import Path
import re,json,hashlib
b=Path('/workspace/work/glyph-advance-execution');observations=[]
csi=re.compile(rb'\x1b\[[0-?]*[ -/]*[@-~]')
cup=re.compile(rb'\x1b\[([0-9]+);([0-9]+)H')
for scene in ['rich','heart','basic8','truecolor']:
 for host in ['xterm-default','xfce-vte']:
  d=b/'gui'/scene/host/'q'
  for stage,columns in [('initial',100),('green',100),('red',100),('resized',120),('resized-green',120)]:
   raw=(d/f'example-{stage}.raw').read_bytes();ms=list(cup.finditer(raw));rows=[]
   for i,m in enumerate(ms):
    payload=raw[m.end():ms[i+1].start() if i+1<len(ms) else len(raw)]
    rows.append((int(m[1]),int(m[2]),csi.sub(b'',payload).decode()))
   full=stage in ['initial','resized'];expected=[]
   if full:
    texts=([('Rich text — t: toggle style, q: quit',36),('ANSI styles remain structured',29),('e\u0301 and 界 ??',11),('ANSI styles remain structured',29)] if scene=='rich' else [('Advance compatibility — t: toggle, q: quit',42),('A 界 e\u0301 👩 💻 🇨🇳',15),('??Z',3),('ANSI styles remain structured',29)])
    # Literal columns are specified by the formal fixture; no library width model.
    for n,(txt,width) in enumerate(texts,1):expected.append((n,1,txt+' '*(columns-width)))
    assert rows[:4]==expected,(scene,host,stage,rows[:4],expected)
    for n,col,text in rows[4:]:assert col==1 and text==' '*columns,(scene,host,stage,n,col,repr(text))
   else:
    txt,width=('e\u0301 and 界 ??',11) if scene=='rich' else ('??Z',3)
    assert rows==[(3,1,txt+' '*(columns-width))],(scene,host,stage,rows)
   sgr=[m.group().decode('ascii') for m in re.finditer(rb'\x1b\[[0-9;]*m',raw)]
   # Check changing row foreground explicitly; full structured rows retained verbatim.
   green=stage in ['green','resized-green']
   color=32 if green else 31
   assert any(re.search(r'(?:\[|;)'+str(color)+r'(?:;|m)',s) for s in sgr),(scene,host,stage,sgr)
   fg=str(color)
   if scene=='rich':
    rgb='37' if host=='xterm-default' else '38;2;80;180;255'
    codes=['0','0',rgb,'1','0','0',fg,'0','3','0','0','33','1','0','33','0','0'] if full else ['0','0',fg,'0','3','0','0']
   else:codes=['0','0',fg,'0','0']
   assert sgr==['\x1b['+code+'m' for code in codes],(scene,host,stage,sgr,codes)
   observations.append({'scene':scene,'host':host,'stage':stage,'columns':columns,'complete_rows':len(rows),'exact_text_and_padding':True,'sgr':sgr,'raw_sha256':hashlib.sha256(raw).hexdigest()})
(b/'scene-bytes-audit.json').write_text(json.dumps({'status':'PASS','scope':'Literal complete row bytes/padding and SGR; physical oracle remains actual DSR plus unmodified PNG, not this audit','observations':observations},ensure_ascii=False,indent=2)+'\n')
print('PASS literal full rows and delta content/styles:',len(observations),'stage observations')
