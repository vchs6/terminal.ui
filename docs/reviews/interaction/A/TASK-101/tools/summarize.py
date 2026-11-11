from pathlib import Path
import json,re,hashlib,sys,subprocess,datetime
B=Path('/workspace/work/interaction-execution');R=B/'product';O=B/'raw/identity';O.mkdir(exist_ok=True);h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();sys.path.insert(0,str(B/'tools'));from trace_bytes import extract
text=(B/'raw/matrix/stdout').read_text();m=json.loads(text[text.index('{\n  "executed"'):]);assert len(m['executed'])==87 and len(m['explicitly_not_executed'])==7 and all(x['result']=='PASS' for x in m['executed'])
rev=json.loads((B/'raw/review/detail/review-regressions/results.json').read_text());assert len(rev)==15 and all(x['exit']==0 for x in rev)
assert (R/'tests/interaction_a/fixtures/vectors.json').read_bytes()==subprocess.check_output(['git','show','76b8dd1:tests/interaction_a/fixtures/vectors.json'],cwd=R)
(O/'case-summary.json').write_text(json.dumps({'matrix87':m,'review15':rev,'duplicate_observations':'12 review headless variants are also called by normal headless; observations kept separate, not summed as unique cases','unchanged_original94_vectors':True},indent=2)+'\n')
stages=['initial','tab','caret-only','logical-hidden'];want=[('A','0,0,true'),('B','0,1,true'),('A','2,0,true'),('A','0,0,false')];hosts=[];PNGs=[]
def signals(trace,p):
 lines=[line for line in trace.splitlines() if re.search(r'rt_sigaction\((SIGWINCH|SIGINT|SIGTERM)',line)];(p/'signals-observed.txt').write_text('\n'.join(lines)+'\n');result={}
 for sig in ['SIGWINCH','SIGINT','SIGTERM']:
  calls=[line for line in lines if 'rt_sigaction('+sig+',' in line];assert len(calls)>=2
  before=re.search(r'\}, \{sa_handler=([^,}]+), sa_mask=([^]]*\])',calls[0]);after=re.search(r'rt_sigaction\('+sig+r', \{sa_handler=([^,}]+), sa_mask=([^]]*\])',calls[-1]);assert before and after and before.groups()==after.groups(),calls
  result[sig]={'before_handler':before[1],'after_handler':after[1],'mask':before[2],'restored':True}
 return result
for base,host,initial in [('gui-hosts2','xterm','visible'),('gui-hosts2','xterm','hidden'),('gui-hosts2','vte','visible'),('gui-hosts3','vte','hidden')]:
 p=B/'raw'/base/(host+'-'+initial);meta=json.loads((p/'terminal-after.json').read_text());assert meta['exit']==0 and meta['before']==meta['after'];assert meta['original_query']['reply_hex']==meta['restored_query']['reply_hex'];trace=(p/'product.strace').read_text();wire,stats=extract(trace);assert not stats['pending'] and not stats['unparsedTarget'];assert wire.count(b'\x1b[?25$p')==1 and wire.count(b'AAAA')==1 and wire.count(b'BBBB')==1 and b'\x1b[1;3H' in wire
 for ix,stage in enumerate(stages):
  state=(p/(stage+'-state.txt')).read_text().splitlines();assert state[0]=='original-'+initial and tuple(state[1:3])==want[ix]
  if host=='vte':
   native=json.loads((p/f'native-{ix}-meta.json').read_text());position=(native['cursorCol'],native['cursorRow']);assert position==[(0,0),(0,1),(2,0),(2,0)][ix];lines=(p/f'native-{ix}-range.txt').read_text().splitlines()
  else:lines=re.sub(r'\x1b(?:\[[0-?]*[ -/]*[@-~]|#[0-9])','',(p/(stage+'-native.ansi')).read_text()).splitlines()
  assert [x.rstrip(' ') for x in lines[:2]]==['AAAA','BBBB']
 for png in p.glob('*.png'):PNGs.append({'path':str(png.relative_to(B)),'sha256':h(png)})
 hosts.append({'host':host,'initial':initial,'path':str(p.relative_to(B)),'exit':0,'termios':True,'original_mode_query_restored':True,'once_product_query':True,'body_drawn_once_caret_only_CUP':True,'signals':signals(trace,p),'native_grid_literal':True})
for initial in ['visible','hidden']:
 p=B/'raw/vt-hosts2'/initial;result=json.loads((p/'result.json').read_text());assert result['qemuExit']==0 and result['productExit']==0 and result['termiosEqual'];trace=(p/'evidence'/f'{initial}.strace').read_text();wire,stats=extract(trace);assert not stats['pending'] and not stats['unparsedTarget'];assert wire.count(b'\x1b[?25$p')==1 and wire.count(b'AAAA')==1 and wire.count(b'BBBB')==1 and b'\x1b[1;3H' in wire;assert not any(v in wire for v in [b'\x1b[?25h',b'\x1b[?25l',b'\x1b[?25s',b'\x1b[?25r']);(p/'product-stdout.raw').write_bytes(wire)
 for ix,stage in enumerate(stages):
  state=(p/(stage+'-state.txt')).read_text().splitlines();assert state[0]=='unknown-timeout' and tuple(state[1:3])==want[ix]
  grid=json.loads((p/(stage+'-native-grids.json')).read_text());v=bytes.fromhex(next(x['hex'] for x in grid if x['path']=='/dev/vcsa1'));assert tuple(v[:2])==(25,80) and tuple(v[2:4])==[(0,0),(0,1),(2,0),(2,0)][ix];assert v[4::2]==b'AAAA'+b' '*76+b'BBBB'+b' '*76+b' '*(80*23)
 for png in p.glob('*.png'):PNGs.append({'path':str(png.relative_to(B)),'sha256':h(png)})
 serial=p/'vt-serial.log';raw=serial.read_bytes();marker=raw.index(b'EVIDENCE_TAR_BASE64_BEGIN');(p/'serial-native-prefix.txt').write_bytes(raw[:marker]);(p/'serial-original-identity.json').write_text(json.dumps({'path':str(serial.relative_to(B)),'sha256':h(serial),'bytes':len(raw),'native_prefix_end_offset':marker,'omission_from_curated':'base64 repeats extracted pure evidence; full original retained here'},indent=2)+'\n')
 hosts.append({'host':'Linux6.12.107 tty1 onQEMU TCG','initial':initial,'path':str(p.relative_to(B)),'exit':0,'uid':1000,'termios':True,'query1_Unknown_no_mode25_writes':True,'complete_native_grid_and_physical_cursor_fenced':True,'signals':signals(trace,p),'keyboard_limit':'default guest keymap sent HT for ShiftTab; CSI Z/Backtab independently verified on realXTerm/VTE and formalPTY'})
(O/'physical-host-summary.json').write_text(json.dumps({'hosts':hosts,'original_successful_PNGs':PNGs,'PNG_count':len(PNGs),'first_unfenced_VT_not_used_as_native_cursor_oracle':True},indent=2)+'\n')
assert subprocess.check_output(['git','status','--short'],cwd=R,text=True)==''
print('Verified87+7boundary/15review; six actual host-state runs; physical oracles and signals; originalPNGs',len(PNGs))
