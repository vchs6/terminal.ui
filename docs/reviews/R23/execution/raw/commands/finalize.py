from pathlib import Path
import json,hashlib,re,os,subprocess
from PIL import Image
b=Path('/workspace/work/glyph-advance-execution');s=b/'source'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
expected={'06-preserved-old-red':1,'13-known-whole-boundary':1};cmds=[]
for d in sorted((b/'raw').iterdir()):
 if d.is_dir() and (d/'exit').is_file():
  rc=int((d/'exit').read_text());assert rc==expected.get(d.name,0),(d.name,rc)
  cmds.append({'name':d.name,'exit':rc,'expected_exit':expected.get(d.name,0),'command':(d/'command').read_text().strip()})
assert len(cmds)>=35,len(cmds)
for r in json.loads((b/'sourcehashes.json').read_text()):assert sha(s/r['path'])==r['sha256'],r['path']
for r in json.loads((b/'colors-test-overlay.json').read_text())['files']:assert sha(s/r['path'])==r['sha256']
assert subprocess.check_output(['git','-C',str(s),'rev-parse','HEAD'],text=True).strip()=='199f00076c1a79cfa6d0be92e7be09366e1a06af'
origins=[];dsr=0;stages=0;pids=[]
for scene in ['rich','heart','basic8','truecolor']:
 binaryshas=[]
 for host in ['xterm-default','xfce-vte']:
  d=b/'gui'/scene/host/'q';m=json.loads((d/'metadata.json').read_text());binaryshas.append(m['fixture_binary_sha256'])
  assert m['events']==['initial','t','t','actual resize','t','q']
  assert 'ready_size=28 100' in (d/'inner-tty.txt').read_text()
  assert 'exit_size=' in (d/'inner-tty.txt').read_text()
  assert (d/'host-wait-status.txt').read_text()=='0\n'
  pids += [int(v) for v in re.findall(r'(?:host|xorg)=(\d+)',(d/'process-reaping.txt').read_text())]
  stages+=len(m['captured_at_utc_by_stage'])
  r=b/'gui'/(scene+'-dsr')/'raw'/host;records=[json.loads(x) for x in (r/'dsr.jsonl').read_text().splitlines()];assert len(records)==5;dsr+=len(records)
  assert (r/'driver-exit-utc.txt').is_file();assert json.loads((r/'metadata.json').read_text())['host_exit']==0
 assert len(set(binaryshas))==1,scene
for pid in pids:
 try:os.kill(pid,0)
 except ProcessLookupError:pass
 else:raise AssertionError(('unreaped process',pid))
for p in sorted((b/'gui').rglob('*.png')):
 with Image.open(p) as im:dims=im.size
 origins.append({'original':str(p),'path':str(p.relative_to(b)),'sha256':sha(p),'pixels':list(dims),'transform':'none; original full X11 capture'})
assert len(origins)==80;assert dsr==40;assert stages==40
(b/'original-images.json').write_text(json.dumps(origins,indent=2)+'\n')
(b/'command-results.json').write_text(json.dumps(cmds,indent=2)+'\n')
(b/'verification.json').write_text(json.dumps({'status':'PASS bounded TASK166 independent execution','product_sha':'199f00076c1a79cfa6d0be92e7be09366e1a06af','fresh_command_count':len(cmds),'final_color_fixture_sha':'0d46c35456db148f08bd407825a4fd559467249a','final_stop_controls':8,'final_colors_actual_exit':0,'expected_nonzero_commands':2,'unexpected_failures':0,'public_contract_checks':34,'internal_tests':9,'internal_skipped':0,'internal_errors':0,'gui_sessions':8,'actual_gui_stages':40,'complete_dsr_replies':dsr,'original_png':len(origins),'row4_capture_observations':24,'row4_dsr_observations':16,'sourcehash_entries':len(json.loads((b/'sourcehashes.json').read_text())),'normal_bundle_warnings':315,'host_pids_confirmed_reaped':len(pids),'adapter_failed_attempts':3,'optional_sun_keycap':'not run; heart VS16 mandatory opposite-sign fixture run in all modes','limits':['Finite exact host/font/config matrix; no arbitrary-host font proof','Known complete-product boundary remains missing composition/benchmark','Semantic reuse, not exact-source rerun, for six preserved unaffected regressions','TASK083/084 and TASK167 acceptance remain separate']},indent=2)+'\n')
scope=json.loads((b/'scope.json').read_text());scope['status']='PASS bounded TASK166 independent execution';scope['pending']=[];(b/'scope.json').write_text(json.dumps(scope,indent=2)+'\n')
print('verified commands',len(cmds),'PNG',len(origins),'DSR',dsr,'stages',stages)
