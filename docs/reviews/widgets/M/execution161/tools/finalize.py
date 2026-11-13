from pathlib import Path
import json,hashlib,datetime,subprocess,re,platform,os,ctypes
from business import EXPECTED_FOCUS,EXPECTED_SUMMARY
B=Path('/workspace/work/widgets-composite-execution');raw=B/'raw';product=B/'clean/cjtui-0.0.0';fixed='6e3f26aaaeee9442fde91ce31d720a841eeda473';out=raw/'final-verification';out.mkdir(exist_ok=False)
required=['normal-build','normal-bundle','package-audit-command','clean-full-runner','clean-example-build','gui-xterm-example','gui-vte-example','gui-xterm-normal','gui-vte-normal','vt-pack','vt-normal','vt-example'];phases=[]
for name in required:
 d=json.loads((raw/name/'command.json').read_text());assert d['exit']==0,(name,d);phases.append(d)
audit=json.loads((raw/'package-audit/manifest.json').read_text());assert len(audit['members'])==263
for m in audit['members']:
 p=product/Path(m['path']).relative_to('cjtui-0.0.0');assert hashlib.sha256(p.read_bytes()).hexdigest()==m['sha256'],str(p)
for m in audit['external_frozen_inputs']:assert hashlib.sha256((product/m['path']).read_bytes()).hexdigest()==m['sha256'],m['path']
assert len(audit['external_frozen_inputs'])==30
binaries={}
for name,rel in [('prerequisite','tests/widgets_composite/prerequisite/target/release/bin/main'),('headless','tests/widgets_composite/target/release/bin/main'),('device','tests/widgets_composite/device/target/release/bin/main'),('example','examples/widgets_composition/target/release/bin/main')]:
 p=product/rel;binaries[name]=dict(path=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
PTY=[]
for mode,code in [('normal',0),('callback-failure',21),('getter-failure',22)]:
 p=raw/'clean-full-runner/artifacts'/mode/'metadata.json';d=json.loads(p.read_text());assert d['exit']==code and d['result']=='PASS' and d['before_termios']==d['after_termios'];assert d['summary']['resources']=='0/0/0/0' and d['summary']['cleanups']=='1'
 assert d['mode_oracle']==dict(query_count=1,valid_input_reports=0,mode25_hlsr=[0,0,0,0],alternate1049_hl=[0,0],paste2004_hl=[1,1],reply_fixture='unanswered; Pending/Unknown wire policy')
 if mode=='normal':assert d['focus_trace']==EXPECTED_FOCUS and d['summary']==EXPECTED_SUMMARY
 else:assert ('M_NATIVE_CALLBACK_SENTINEL' if code==21 else 'M_NATIVE_GETTER_SENTINEL') in (p.parent/'error').read_text()
 PTY.append(d)
hosts=[];pngs=[];selected=['host-xterm-normal/chosen-popup-still-open.png','host-vte-normal/nested-modal.png','host-vt-normal/latest-model-layer.png']
for host in ['xterm','vte','vt']:
 for mode in ['normal','example']:
  p=raw/('host-'+host+'-'+mode);r=json.loads((p/'result.json').read_text());terminal=r.get('terminal',r);assert terminal['product_exit']==0 and terminal['termios_equal']
  if host!='vt':assert terminal['tracer_exit']==0 and terminal['known_original_mode_restored'];identity=json.loads((p/'host-identity.json').read_text())
  else:assert r['qemu_exit']==0;identity=[x for x in (p/'serial.log').read_text().splitlines() if x.startswith(('KERNEL','TTY=','PRODUCT_ID','VT_RESIZE','EXTERNAL_MODE25','RESTORE'))]
  if mode=='normal':
   assert r['summary']==EXPECTED_SUMMARY;focus=(p/('evidence/focus' if host=='vt' else 'focus')).read_text();assert focus==';'.join(EXPECTED_FOCUS)+';'
  frames=[]
  for f in sorted(p.glob('*-vcsa.bin')):
   v=f.read_bytes();rows,cols=v[:2];frames.append(dict(path=str(f),rows=rows,columns=cols,visible_rows=[v[4+i*cols*2:4+(i+1)*cols*2:2].decode('ascii',errors='replace') for i in range(min(12,rows))]))
  hosts.append(dict(host=host,mode=mode,result=r,identity=identity,launch=json.loads((p/'launch.json').read_text()),actual_read_bytes_sha256=hashlib.sha256((p/'input.raw').read_bytes()).hexdigest(),actual_output_bytes_sha256=hashlib.sha256((p/'output.raw').read_bytes()).hexdigest(),native_cells=frames))
  for f in sorted(p.glob('*.png')):
   rel=str(f.relative_to(raw));pngs.append(dict(path=str(f),relative_to_raw=rel,bytes=f.stat().st_size,sha256=hashlib.sha256(f.read_bytes()).hexdigest(),selected_settled_three_host=rel in selected,basis='Original X11/QMP capture after actual frozen file fence or native frame progress; no redraw.'))
assert len(pngs)==65 and sum(x['selected_settled_three_host'] for x in pngs)==3
(out/'original-png-catalogue.json').write_text(json.dumps(dict(all_original_PNGs=pngs,selected_settled_three_host=selected,scope='Selection is a navigation aid; raw23focus/4choice/device assertions are the functional evidence.'),indent=2)+'\n')
review=Path('/workspace/work/widgets-composite-review/index.json');assert hashlib.sha256(review.read_bytes()).hexdigest()=='da8bf5213acd6c01d3b216b0de3a321abf8eebad6207ba70d11cd6590741482e'
assert subprocess.run(['git','-C',str(B/'source'),'diff','--quiet',fixed]).returncode==0
preserved=[]
for base in [Path('/workspace/work/widgets-small-execution'),Path('/workspace/work/editing-execution')]:
 idx=base/'final-index.json';d=json.loads(idx.read_text())
 for rel,sha in d['phase_manifests'].items():
  p=base/rel;assert hashlib.sha256(p.read_bytes()).hexdigest()==sha
  for child,m in json.loads(p.read_text())['files'].items():assert hashlib.sha256((p.parent/child).read_bytes()).hexdigest()==m['sha256']
 preserved.append(dict(index=str(idx),sha256=hashlib.sha256(idx.read_bytes()).hexdigest(),bound_raw_unchanged=True))
lib=ctypes.CDLL('libvte-2.91.so.0');environment=dict(OS=Path('/etc/os-release').read_text(),uname=list(platform.uname()),ABI='x86_64-unknown-linux-gnu',uid=os.getuid(),SDK='Cangjie/CJPM1.2.0 (same supplied/hash-bound toolchain)',stdx='1.2.0-beta.02.1',loaded_VTE=[getattr(lib,'vte_get_'+x+'_version')() for x in ['major','minor','micro']],config=(B/'cangjie-repo.toml').read_text(),UCD_sha256=hashlib.sha256(Path('/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip').read_bytes()).hexdigest())
record=dict(task=161,fixed_source=fixed,product_commit='6f7d6feeb18b714d10300505d02e163d97b6c68a',independent_test_revision='ad100b79956de30fe65c6d561f11be67186821d5',test_tree='ff16e53ffe8156950088fd3c7d4654f972c830cc',review_index=dict(path=str(review),sha256=hashlib.sha256(review.read_bytes()).hexdigest()),new_required_phases=phases,binaries=binaries,PTY=PTY,actual_hosts=hosts,environment=environment,preserved_prior_evidence=preserved,known_T087='Supplied historical whole-checker exit1 themes/light.toml allowlist mismatch retained. Not repeated or labelled passed; own mandatory normal bundle0 and exact-source clean consumer independent.',coverage_limits='New actual M fixture/example ASCII/Classic only; disabledB/X skip exercised. Explicit palette/literalUnicode remain headless/source proof; all-four-theme/all-component027/041/physical-console/fullLinux later. Kernel mode25 original visibility Unknown, no fake report or external mode force.',UTC=datetime.datetime.now(datetime.timezone.utc).isoformat())
(out/'verification.json').write_text(json.dumps(record,indent=2)+'\n')
lines=[
'# TASK161 independent finite M execution',
'Execution status: prescribed finite M commands completed at source '+fixed+'; acceptance remains162.',
'Product6f7d6fee; testsad100b79956de30fe65c6d561f11be67186821d5/treeff16e53ffe8156950088fd3c7d4654f972c830cc; reviewda8bf521 hash independently bound.',
'Own normal cjpm build0 and mandatory cjpm bundle0, no skip flags. CJP SHA256 '+audit['archive_sha256']+'.',
'Safe archive audit263 files, byte-equal fixed source including current product README; fresh unpacked package plus30 unchanged frozen public test inputs.',
'One clean widgets_composite/run.sh formal0: accepted prerequisite inclS42modifier replay0, full headless M01–M05/S02 consumer0, device+3realPTY modes.',
'Frozen PTY normal/callback/getter direct exits0/21/22; first-error sentinel retained, cleanup1/resources0/0/0/0/exact termios; native mode pairing checked.',
'Artificial no-reply PTY oracle alone requires1mode25query/0mode25controls/0alt1049/pair2004; no invented restore bytes or fake replies.',
'Clean unchanged documented widgets_composition example build0; direct actual example runs0 in XTerm398, XFCE1.1.4/VTE0.80.1, QEMU10.0.13/kernel6.12.107 tty1.',
'Frozen normal device also ran0 in each actual host: exact23focus trace,4choices h:a;h:a;p:r;p:p;, NEW model, explicit-close/Escape/nestedmodal/Tab semantics.',
'Each native fixture cleanup1/resources0; every example/device direct exit0 and exact termios restoration; all6 routes resized60×12→50×10.',
'Actual XTerm/VTE natural mode25 replies1→1 with product25l/25h restoration; real-host Known evidence kept separate from artificial Unknown policy.',
'Kernel VT actual before/after queries got no reply; product emitted no25controls. Original physical visibility remains Unknown, never forced/faked; VM is not physical hardware.',
'Real GUI AltSpace/host paste and kernel keymap input retained as actual read bytes. VT ShiftInsert is not proof of terminal clipboard/bracketed paste support.',
'65 original PNGs/raw preserved; selected settled3host images and full hashes: raw/final-verification/original-png-catalogue.json; native vcsa independently retained.',
'New native ASCII/Classic M data includes disabledB/X navigation skips and modal/shared-model projection; explicit palette/literalUnicode are separate headless/source proofs.',
'No borrowed S/E PNG as new M evidence, no new Cj fixture, no oracle weakening/capability override/redrawn screenshot. Full four-theme/all-component native027/041 remains later.',
'ReuseAGENTS11: only8 added M source files, existing S/runtime/layout/native/theme/keyboard unchanged; acceptedS156 and supplied85raw hashes bound, no duplicate old suites/lint.',
'Final verification:12 new required phases0,263 delivered+30 test files unchanged,4 own binary SHA bindings; prior S/E sealed indices/bound raw unchanged.',
'Known supplied T087 whole-checker exit1 themes/light.toml mismatch retained separately; final023 owns it. Normal bundle/clean consumer0 does not label checker passed.',
'Final evidence: immutable raw/*/phase-index.json and final-index.json; verification.json carries source/test/config/version/cwd/command/true exit/host/mode/bin/PNG bindings.',
'No unexpected product execution failures, source/test/spec/main edits, cleanup or SDK/cache/VM-image copies. All previous K/E/S originals protected.',
'Boundary: finite M execution only;162 judges sufficiency. B-M01→024, T087→023, parent019/020/027/030, fullLinux/041/release remain open.'
]
assert len(lines)<=25;(B/'report.md').write_text('\n'.join(lines)+'\n')
indices={}
for d in sorted(raw.iterdir()):
 if not d.is_dir():continue
 p=d/'phase-index.json';assert not p.exists();files={str(f.relative_to(d)):dict(bytes=f.stat().st_size,sha256=hashlib.sha256(f.read_bytes()).hexdigest()) for f in sorted(d.rglob('*')) if f.is_file() and not f.is_symlink()};p.write_text(json.dumps(dict(task=161,phase=d.name,fixed_source=fixed,sealedUTC=datetime.datetime.now(datetime.timezone.utc).isoformat(),files=files),indent=2)+'\n');indices[str(p.relative_to(B))]=hashlib.sha256(p.read_bytes()).hexdigest()
 for f in d.rglob('*'):
  if f.is_file() and not f.is_symlink():f.chmod(0o444)
files={}
for p in (B/'tools').rglob('*'):
 if p.is_file():files[str(p.relative_to(B))]=dict(bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
for p in [B/'report.md',B/'prepare.md',B/'planned-manifest.json',B/'env.sh',B/'cangjie-repo.toml',B/'widgets-composite-vt.cpio.gz',B/'widgets-composite-vt.cpio.members.json',B/'source/target/cjtui-0.0.0.cjp']:
 files[str(p.relative_to(B))]=dict(bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
index=dict(task=161,status='PRESCRIBED_FINITE_EXECUTION_COMPLETE_WITH_RECORDED_HOST_LIMITS',fixed_source=fixed,test_revision=record['independent_test_revision'],test_tree=record['test_tree'],report='report.md',UTC=datetime.datetime.now(datetime.timezone.utc).isoformat(),phase_manifests=indices,files=files,acceptance_owner=162,scope='Finite M execution only; native actual Known/Unknown kept separate;027/041/fullLinux/023/024 remain open.')
p=B/'final-index.json';assert not p.exists();p.write_text(json.dumps(index,indent=2)+'\n');p.chmod(0o444);(B/'report.md').chmod(0o444)
for rel,sha in indices.items():
 p=B/rel;assert hashlib.sha256(p.read_bytes()).hexdigest()==sha
 for child,row in json.loads(p.read_text())['files'].items():assert hashlib.sha256((p.parent/child).read_bytes()).hexdigest()==row['sha256']
for rel,row in files.items():assert hashlib.sha256((B/rel).read_bytes()).hexdigest()==row['sha256']
print('VERIFIED',len(indices),'sealed phases;',len(pngs),'originalPNGs;',len(lines),'report lines');print('INDEX_SHA256',hashlib.sha256((B/'final-index.json').read_bytes()).hexdigest());print('REPORT_SHA256',hashlib.sha256((B/'report.md').read_bytes()).hexdigest())
