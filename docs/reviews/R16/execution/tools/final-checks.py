from pathlib import Path
from PIL import Image
import json,re,hashlib,struct,os,subprocess
B=Path('/workspace/work/glyph-execution');results={'ppmPng':[],'hosts':[],'actualSourceChecks':[]};hashes={}
for scene in (B/'raw/vt').iterdir():
 if not scene.is_dir():continue
 meta=json.loads((scene/'result.json').read_text());results['hosts'].append({'scene':scene.name,**meta})
 trace=next((scene/'evidence').glob('*.strace')).read_text();assert not any(x in trace for x in ['PIO_UNIMAP','PIO_FONT','KDFONTOP','KDSETMODE'])
 assert b'\x1b%' not in (scene/'stdout-raw.ansi').read_bytes()
 for ppm in scene.glob('*.ppm'):
  png=ppm.with_suffix('.png');a=Image.open(ppm).convert('RGB');c=Image.open(png).convert('RGB');assert a.size==(720,400) and a.tobytes()==c.tobytes()
  results['ppmPng'].append({'ppm':str(ppm.relative_to(B)),'png':str(png.relative_to(B)),'rgbEqual':True,'size':list(a.size)})
 pid=meta['qemuPid'];proc=Path(f'/proc/{pid}');assert not proc.exists(),f'owned QEMU pid still exists {pid}'
# all exact tracked source bytes remain fixed, both clean package and public consumer.
for item in json.loads((B/'raw/package-members.json').read_text())['members']:
 p=B/'clean-extract/cjtui-0.0.0'/item['path'];assert hashlib.sha256(p.read_bytes()).hexdigest()==item['sha256']
assert (B/'clean-api/src/main.cj').read_bytes()==(B/'source/tests/glyphs/api/src/main.cj').read_bytes()
for line in (B/'raw/reused-prior/product-content-sha256.txt').read_text().splitlines():
 h,name=line.split(None,1);name=name.strip()
 if name.startswith(('src/','native/')):
  assert hashlib.sha256((B/'source'/name).read_bytes()).hexdigest()==h;results['actualSourceChecks'].append(name)
for host in ['xterm','vte']:
 p=B/'raw/gui'/host
 meta=json.loads((p/'terminal-after.json').read_text());assert meta['before']==meta['after'] and meta['exit']==0
summary=json.loads((B/'raw/gui/summary.json').read_text());assert summary['xorgExit']==0 and not Path(f"/proc/{summary['xorgPid']}").exists();assert not os.path.lexists('/tmp/.X11-unix/X196')
for root in [B/'raw/gui',B/'raw/vt']:
 for p in root.rglob('*'):
  if p.is_file():hashes[str(p.relative_to(B))]={'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'size':p.stat().st_size}
results['normalHostCount']=len(results['hosts'])+len(summary['runs']);results['pngCount']=sum(1 for x in hashes if x.endswith('.png'));results['postExitFiles']=hashes
(B/'raw/host-artifacts-after-exit.json').write_text(json.dumps(results,indent=2));print('PASS final checks',len(results['ppmPng']),'lossless QMP image pairs;',results['pngCount'],'actual PNGs;',results['normalHostCount'],'normal host runs; clean143/source relations; owned QEMU/Xorg reaped')
