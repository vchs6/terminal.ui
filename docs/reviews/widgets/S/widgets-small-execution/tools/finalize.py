from pathlib import Path
import json,hashlib,datetime,subprocess,platform,os,re,shutil
B=Path('/workspace/work/widgets-small-execution');raw=B/'raw';product=B/'clean/cjtui-0.0.0';fixed='1df1325f7b51777d8adab62f950c936051aa5876';out=raw/'final-verification';out.mkdir(exist_ok=False)
required=['normal-build','normal-bundle','package-audit-command','clean-full-runner','clean-example-build','gui-xterm-example','gui-vte-example','gui-xterm-normal','gui-vte-normal','vt-pack','vt-normal','vt-example'];phases=[]
for name in required:
 p=raw/name/'command.json';d=json.loads(p.read_text());assert d['exit']==0,(name,d);phases.append(d)
audit=json.loads((raw/'package-audit/manifest.json').read_text());assert len(audit['members'])==253
for m in audit['members']:
 p=product/Path(m['path']).relative_to('cjtui-0.0.0');assert hashlib.sha256(p.read_bytes()).hexdigest()==m['sha256'],str(p)
bind=json.loads((raw/'package-consumer-bindings/binding.json').read_text())
for m in bind['public_test_source_files']:assert hashlib.sha256((product/m['path']).read_bytes()).hexdigest()==m['sha256'],m['path']
binaries={}
for name,rel in [('prerequisite','tests/widgets_small/prerequisite/target/release/bin/main'),('headless','tests/widgets_small/target/release/bin/main'),('device','tests/widgets_small/device/target/release/bin/main'),('example','examples/widgets_small/target/release/bin/main')]:
 p=product/rel;binaries[name]=dict(path=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
negative=[]
for name in ['checkbox','radio']:
 p=product/'tests/widgets_small/target'/('negative-'+name+'.log');text=p.read_text();assert 'Bool' in text and 'return code is 1' in text and not re.search('cannot import|not accessible',text);dest=out/p.name;shutil.copyfile(p,dest);negative.append(dict(name=name,compiler_exit=1,classification='Expected forbidden Bool overload rejection; exit validated by unchanged normal runner, not failure.',original=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
pty=[]
for mode,code in [('normal',0),('callback-failure',21),('getter-failure',22)]:
 p=raw/'clean-full-runner/artifacts'/mode/'metadata.json';d=json.loads(p.read_text());assert d['exit']==code and d['result']=='PASS' and d['before_stty']==d['after_stty'];assert d['summary']['resources']=='0/0/0/0' and d['summary']['cleanups']=='1';pty.append(d)
hosts=[];pngs=[]
for host in ['xterm','vte','vt']:
 for mode in ['example','normal']:
  p=raw/('host-'+host+'-'+mode);r=json.loads((p/'result.json').read_text());terminal=r.get('terminal',r);assert terminal['product_exit']==0 and terminal['termios_equal']
  if host!='vt':assert terminal['tracer_exit']==0
  else:assert r['qemu_exit']==0
  if mode=='normal':assert r['summary']==dict(clicks='1',boxRequests='1',checked='true',radioRequests='1',selected='true',cleanups='1',resources='0/0/0/0')
  frames=[]
  for frame in sorted(p.glob('*-vcsa.bin')):
   v=frame.read_bytes();rows,cols=v[:2];frames.append(dict(path=str(frame),rows=rows,columns=cols,visible_rows=[v[4+i*cols*2:4+(i+1)*cols*2:2].decode('ascii',errors='replace') for i in range(min(6,rows))]))
  identity=json.loads((p/'host-identity.json').read_text()) if host!='vt' else [x for x in (p/'serial.log').read_text().splitlines() if x.startswith(('KERNEL','TTY=','PRODUCT_ID','VT_RESIZE','RESTORE'))]
  hosts.append(dict(host=host,mode=mode,result=r,host_identity=identity,launch=json.loads((p/'launch.json').read_text()),actual_guest_or_TTY_input_hex=(p/'input.raw').read_bytes().hex(),native_cells=frames))
  for f in sorted(p.glob('*.png')):pngs.append(dict(path=str(f),sha256=hashlib.sha256(f.read_bytes()).hexdigest(),bytes=f.stat().st_size))
assert len(pngs)==50,len(pngs)
assert subprocess.run(['git','-C',str(B/'source'),'diff','--quiet',fixed]).returncode==0
# Verify prior E evidence remains intact; no product re-execution.
e=Path('/workspace/work/editing-execution');ei=json.loads((e/'final-index.json').read_text())
for rel,sha in ei['phase_manifests'].items():
 p=e/rel;assert hashlib.sha256(p.read_bytes()).hexdigest()==sha
 for child,m in json.loads(p.read_text())['files'].items():assert hashlib.sha256((p.parent/child).read_bytes()).hexdigest()==m['sha256']
record=dict(fixed_source=fixed,new_required_phases=phases,binaries=binaries,negative_compilers=negative,PTY=pty,actual_hosts=hosts,original_PNGs=pngs,source_and_frozen_test_files_unchanged=True,prior_E38_indices_and_bound_raw_unchanged=True,coverage_limits=['New actual S native data is ASCII only; Unicode/disabled/explicit/custom palette S evidence is frozen headless + source155, not inferred from E host results.','E backend mechanism reuse is scoped to byte-unchanged native/glyph/theme/runtime paths; actual S all-state/Unicode/four-theme integrated showcase remains027/041.','Progress measure closure proof remains source155; native callback/getter first-error tests are actual PTY, not three-host diversity proof.','B-M01→024, T087→023; fullLinux, M, parent019/020/027/030 and release remain open.'],UTC=datetime.datetime.now(datetime.timezone.utc).isoformat())
(out/'verification.json').write_text(json.dumps(record,indent=2)+'\n')
lines=[
'# TASK156 independent finite S execution',
'Status: required finite execution completed at fixed '+fixed+'; acceptance remains TASK157.',
'Own normal cjpm build0 and mandatory cjpm bundle0; no skip flags, no author target/SDK/cache/VM-image copies.',
'Package SHA256 '+audit['archive_sha256']+';253 safe regular source-equal archive files; no stale whole checker PASS.',
'Clean unpacked public package +36 byte-unchanged frozen test inputs; canonical test tree714a7fdf97d368574815cbf16e7430ac744f647c verified.',
'Unchanged frozen bundle-run.py→widgets_small/run.sh executed once: prerequisite/direct/headless0,3PTY goldens,2 Bool-constructor compiler rejections; wrapper0.',
'Actual PTY normal/callback/getter exits0/21/22 as frozen; sentinel first error retained, cleanup1, resources0/0/0/0, exact stty and paired native-mode restore.',
'Both forbidden Bool constructors produce compiler1 solely type mismatch; original full compiler outputs retained. Intentional target-red.sh was not run.',
'Clean unchanged documented examples/widgets_small built0 and ran directly in all3 actual host implementations; Tab/Enter/Space/q path unchanged.',
'Actual XTerm398/VTE0.80.1/QEMU10.0.13+Linux6.12.107 kernel tty1: unchanged example and frozen normal device each direct0, exact termios restoration.',
'Each actual device host: Enter button1; HT+Space checkbox1/true; HT+Enter Radio1/true; already-selected Space adds0; cleanup1/resources0.',
'All3 hosts: native resize60×12→50×10, classic focus/selected/controlled checkbox/progress captures before exit;50 original PNGs plus true raw input/output and exit.',
'GUI uses actual XTEST→host PTY; VT uses QMP emulated keyboard→kernel VT and native vcsa readback. VM is not physical console; changed TERM is not host diversity.',
'S03 Unicode captions/disabled/explicit/custom palette proven by frozen headless S tests and source155; new native S captions are ASCII, so those states are not claimed native-verified.',
'Byte-unchanged E native/glyph/theme/runtime projection mechanism may be reused with explicit impact proof; E images are not new S Unicode screenshots.',
'Actual S all-state/Unicode/four-theme integrated showcase gaps stay027/041; no new Cj business fixture or self-authored oracle.',
'Progress measure must not read fraction: proof belongs source155; new native outputs do not establish measure readsets. LEGACY-PROP-001 exercised by frozen public suite.',
'AGENTS11.1 reuse:36 supplied raw hashes verified, only7 S factory/helper source additions; no repeated dirty suite/wrapper/full lint.',
'Final verification:12 new required phases0,253 delivered+36 consumer files unchanged,4 own binary SHA bindings,3PTY and6 host runs; no unexpected execution failures.',
'All E38 sealed indices/bound raw verified unchanged; K/E/C originals untouched; no cleanup, main/product/test/spec edits or new packages.',
'Evidence: final-index.json; raw/*/phase-index.json immutable; raw/final-verification/verification.json carries hosts/versions/config/TERM/dimensions/UTC/commands/true exits/PNG/raw/bin/source hashes.',
'Boundary: finite S only; B-M01→024/T087→023, full Linux/M/parent019/020/027/030/release remain open.'
]
assert len(lines)<=25;(B/'report.md').write_text('\n'.join(lines)+'\n')
indices={}
for d in sorted(raw.iterdir()):
 if not d.is_dir():continue
 p=d/'phase-index.json';assert not p.exists();files={str(f.relative_to(d)):dict(bytes=f.stat().st_size,sha256=hashlib.sha256(f.read_bytes()).hexdigest()) for f in sorted(d.rglob('*')) if f.is_file() and not f.is_symlink()};p.write_text(json.dumps(dict(task=156,phase=d.name,fixed_source=fixed,sealedUTC=datetime.datetime.now(datetime.timezone.utc).isoformat(),files=files),indent=2)+'\n');indices[str(p.relative_to(B))]=hashlib.sha256(p.read_bytes()).hexdigest()
 for f in d.rglob('*'):
  if f.is_file() and not f.is_symlink():f.chmod(0o444)
files={}
for root in [B/'tools']:
 for p in root.rglob('*'):
  if p.is_file():files[str(p.relative_to(B))]=dict(bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
for p in [B/'report.md',B/'READY.md',B/'prepare.json',B/'env.sh',B/'cangjie-repo.toml',B/'widgets-small-vt.cpio.gz',B/'widgets-small-vt.cpio.members.json',B/'source/target/cjtui-0.0.0.cjp']:
 files[str(p.relative_to(B))]=dict(bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
index=dict(task=156,status='FINITE_EXECUTION_COMPLETE_WITH_RECORDED_NATIVE_COVERAGE_LIMITS',fixed_source=fixed,report='report.md',UTC=datetime.datetime.now(datetime.timezone.utc).isoformat(),phase_manifests=indices,files=files,acceptance_owner=157,scope='Finite S only; native ASCII evidence + separate headless/style/Unicode proofs; full Linux/M/027/041 not closed.')
p=B/'final-index.json';assert not p.exists();p.write_text(json.dumps(index,indent=2)+'\n');p.chmod(0o444);(B/'report.md').chmod(0o444)
for rel,sha in indices.items():
 p=B/rel;assert hashlib.sha256(p.read_bytes()).hexdigest()==sha
 for child,row in json.loads(p.read_text())['files'].items():assert hashlib.sha256((p.parent/child).read_bytes()).hexdigest()==row['sha256']
for rel,row in files.items():assert hashlib.sha256((B/rel).read_bytes()).hexdigest()==row['sha256']
print('VERIFIED',len(indices),'sealed phases;',len(pngs),'originalPNGs;',len(lines),'report lines')
print('INDEX_SHA256',hashlib.sha256((B/'final-index.json').read_bytes()).hexdigest());print('REPORT_SHA256',hashlib.sha256((B/'report.md').read_bytes()).hexdigest())
