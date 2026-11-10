from pathlib import Path
import hashlib,json,subprocess,tarfile,re,datetime
O=Path('/workspace/work/dynamic-acceptance'); E=Path('/workspace/work/dynamic-execution'); A=E/'r13-execution-draft'; S=E/'source'; reviewed={}; results={}
def read(p):
 p=Path(p); b=p.read_bytes(); reviewed[str(p)]=hashlib.sha256(b).hexdigest(); return b
def h(p):return hashlib.sha256(read(p)).hexdigest()
def strict(p):
 def unique(pairs):
  d={}
  for k,v in pairs:
   assert k not in d,(str(p),k)
   d[k]=v
  return d
 return json.loads(read(p),object_pairs_hook=unique,parse_constant=lambda x: (_ for _ in ()).throw(ValueError(x)))
def git(*args):return subprocess.check_output(['git','-C',str(S),*args])
def manifest(p,root):
 lines=read(p).decode().splitlines(); paths=[]
 for line in lines:
  digest,name=line.split(None,1);name=name.lstrip('* ');q=Path(name);q=q if q.is_absolute() else root/q
  assert h(q)==digest,(str(p),str(q)); paths.append(q)
 return paths
files=manifest(A/'artifacts.sha256',A)
actual={p for p in A.rglob('*') if p.is_file() and p.name!='artifacts.sha256'}
assert set(files)==actual
results['execution_manifest']={'hashed_files':len(files),'total_with_manifest':len(actual)+1,'all_originals_equal':True}
for p in files:
 rel=p.relative_to(A)
 if str(rel).startswith(('evidence/','commands/')):assert read(p)==read(E/rel),str(rel)
 assert not read(p).startswith(b'\x7fELF'),str(rel)
results['strict_json_files']=sum(1 for p in files if p.suffix=='.json' and strict(p) is not None)
assert git('rev-parse','HEAD').decode().strip()=='216b2ab5f2315f4be19467b7e49f4047aec78ab9'
inv=strict(E/'evidence/source-inventory.json')
for p,digest in inv.items():assert h(S/p)==digest,p
assert not git('diff','HEAD','--')
for p in ['src','native','build.cj','cjpm.toml','examples/dynamic']:
 assert not git('diff','216b2ab5f2315f4be19467b7e49f4047aec78ab9','5de716f','--',p),p
for entry in strict(E/'evidence/fixed-content-proof.json'):
 assert not git('diff','--name-only',entry['baseline'],'HEAD','--',*entry['paths']),entry
results['fixed_source']={'head':git('rev-parse','HEAD').decode().strip(),'inventory_files':len(inv),'tracked_diff_empty':True,'integrated_main_scope_equal':True}
for entry in strict(E/'evidence/executed-binaries.json'):assert h(entry['path'])==entry['sha256']
results['binary_hashes']=9
bundle=strict(E/'evidence/bundle-sha256.json');assert h(bundle['path'])==bundle['sha256']
clean=Path((E/'clean-product-path').read_text().strip()); compared=[]
with tarfile.open(bundle['path']) as t:
 members=[m for m in t.getmembers() if m.isfile()]
 for m in members:
  rel=Path(m.name).relative_to('cjtui-0.0.0')
  assert not any(x in rel.parts for x in ['target','node_modules','cache']),str(rel)
  data=t.extractfile(m).read();assert not data.startswith(b'\x7fELF')
  if str(rel).startswith(('src/','native/','examples/dynamic/')) or str(rel) in ['build.cj','cjpm.toml']:
   assert data==read(S/rel)==read(clean/rel),str(rel);compared.append(str(rel))
results['bundle']={'sha256':bundle['sha256'],'file_entries':len(members),'source_build_example_compared':len(compared),'paths':compared}
commands=strict(E/'evidence/command-results.json')
for label,code in commands.items():
 d=E/'evidence'/label
 assert int(read(d/'exit'))==code
 for p in ['command','cwd','start','end','stdout','stderr']:read(d/p)
 assert read(d/'start')<=read(d/'end')
results['commands']=commands
counts={}
for label in ['dynamic-direct','clean-dynamic-direct','core-direct','macro-positive-direct','layout','decoration']:
 out=read(E/'evidence'/label/'stdout').decode();assert 'FAIL:' not in out
 counts[label]=len(re.findall(r'^PASS:',out,re.M))
assert counts=={'dynamic-direct':34,'clean-dynamic-direct':34,'core-direct':255,'macro-positive-direct':16,'layout':114,'decoration':59},counts
results['raw_pass_lines']=counts
for entry in strict(E/'evidence/runtime-pty-summary.json'):
 d=next((E/'evidence').glob('cjtui-runtime-pty-*'))/entry['mode'];r=strict(d/'result.json')
 assert r['code']==entry['code'] and r['signal'] is None
 assert read(d/'before')==read(d/'after')
 assert read(d/'close-record.txt').decode()==entry['close_record']
 assert entry['close_record'].count('real_result=0')==1
 read(d/'session.raw')
results['pty_cases']=12
# Independent complete-grid replay from cumulative ordered ANSI stage deltas.
title='r: reverse   e: empty/refill   i: insert manual   v: toggle   q: quit';desc='Declared and manual children share one sequence'
stages=[('initial',[title,desc,'A','B','C']),('hidden',[title,'A','B','C']),('inserted',[title,'A','manual','B','C']),('reordered',[title,'C','manual','B','A']),('emptied',[title,'manual']),('refilled',[title,'manual','D','E']),('shown',[title,desc,'manual','D','E']),('resized',[title,desc,'manual','D','E'])]
hosts=[];metadata_mismatches=[]
for profile in ['xterm-default','xfce-vte']:
 d=E/'evidence/gui-dynamic'/profile/'q';meta=strict(d/'metadata.json')
 assert meta['source_commit']==results['fixed_source']['head']
 assert meta['fixture_source_sha256']==h(S/'examples/dynamic/src/main.cj')
 assert meta['fixture_binary_sha256']==h(S/'examples/dynamic/target/release/bin/main')
 for name,digest in meta['artifacts'].items():
  actual=h(d/name)
  if actual!=digest:metadata_mismatches.append({'profile':profile,'artifact':name,'metadata_sha256':digest,'actual_sha256':actual})
 grid={};row=col=0
 for stage,lines in stages:
  data=read(d/f'example-{stage}.raw').decode();i=0
  while i<len(data):
   if data[i]=='\x1b':
    m=re.match(r'\x1b\[([0-?]*)([ -/]*)([@-~])',data[i:]);assert m
    p,_,cmd=m.groups();n=[] if p.startswith('?') else [int(x or 0) for x in p.split(';')]
    if cmd in ['H','f']:row=(n[0] or 1)-1;col=((n[1] or 1) if len(n)>1 else 1)-1
    elif cmd=='J' and n==[2]:grid={}
    elif cmd=='K':grid={k:v for k,v in grid.items() if not(k[0]==row and k[1]>=col)}
    else:assert cmd in ['m','h','l'],m.group()
    i+=len(m.group());continue
   c=data[i];i+=1
   if c=='\r':col=0
   elif c=='\n':row+=1
   elif c>=' ':grid[row,col]=c;col+=1
  w,ht=(120,34) if stage=='resized' else (100,28)
  got=[''.join(grid.get((y,x),' ') for x in range(w)) for y in range(ht)]
  want=[x.ljust(w) for x in lines]+[' '*w]*(ht-len(lines));assert got==want,(profile,stage)
  assert '\n'.join(got)+'\n'==read(d/f'example-{stage}-full-grid.txt').decode()
  assert read(d/f'example-{stage}.png').startswith(b'\x89PNG\r\n\x1a\n')
 for side in ['inner','outer']:
  fields=dict(x.split('=',1) for x in read(d/f'{side}-tty.txt').decode().splitlines() if '=' in x)
  assert fields['ready_termios']==fields['exit_termios'] and fields['exit_status']=='0'
  assert fields['ready_size']=='28 100' and fields['exit_size']=='34 120'
 assert read(d/'host-wait-status.txt').strip()==b'0'
 hosts.append({'profile':profile,'version':meta['host_version'],'stages':8,'full_grids_equal':True,'exact_termios':True,'host_exit':0,'utc':meta['captured_at_utc']})
results['gui']=hosts;results['metadata_mismatches']=metadata_mismatches
neg=[]
for line in read(S/'tests/runtime/macros/negative/cases.tsv').decode().splitlines():
 name,loc,pattern=line.split('\t');d=E/'evidence/reuse/macro-negative15/artifacts';code=int(read(d/f'{name}.exit'));diag=read(d/f'{name}.diagnostics').decode()
 assert code!=0 and loc in diag and re.search(pattern,diag,re.I);neg.append(name)
assert len(neg)==15;results['reused_macro_negative15']=neg
assert int(read(E/'evidence/reuse/r12-regressions-exit'))==1
results['historical_regression_aggregate_exit']=1
red=Path('/workspace/work/dynamic-regression-tests/raw');r=strict(red/'consumer-red.json');assert r['actual_exit']==1
out=read(red/'consumer-red.stdout').decode();assert out.count('FAIL: manual-nested')==1 and out.count('FAIL: replacement-nested')==1
assert out.count('active-parent:children=1')==3
fresh=read(E/'evidence/dynamic-direct/stdout').decode();assert 'old:stopped,root:stopped,' in fresh and 'old-text:stopped,old-row:stopped,root:stopped,' in fresh
results['dyn_f001']={'old_actual_exit':1,'two_formal_reds':True,'new_actual_exit':0,'cleanup_traces_correct':True}
results['utc']=datetime.datetime.now(datetime.timezone.utc).isoformat()
(O/'raw/integrity-semantic-audit.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
(O/'reviewed-hashes.json').write_text(json.dumps(reviewed,indent=2)+'\n')
print(json.dumps(results,ensure_ascii=False,indent=2))
