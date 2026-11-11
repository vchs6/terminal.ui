from pathlib import Path
import hashlib,json,shutil
B=Path('/workspace/work/glyph-execution');A=Path('/workspace/work/glyph-implementation');D=B/'raw/reused-prior';D.mkdir(exist_ok=True);review=Path('/workspace/work/glyph-review');data=json.loads((review/'reviewed-hashes.json').read_text());manifest=[]
# Exact095-listed raw only; never enumerate author workspace or follow source/report/progress.
names=['session-regression.log','runtime-current.log','regression-runtime.log','log-utc.txt','product-content-sha256.txt']+[n for n in data['raw'] if n.startswith('session-regression/')]
for name in names:
 raw=(A/name).read_bytes();h=hashlib.sha256(raw).hexdigest();assert h==data['raw'][name],name
 out=D/name;out.parent.mkdir(parents=True,exist_ok=True);out.write_bytes(raw);manifest.append({'original':str(A/name),'ownCopy':str(out.relative_to(B)),'sha256':h})
for line in (review/'artifacts.sha256').read_text().splitlines():
 h,n=line.split(None,1);assert hashlib.sha256((review/n.strip()).read_bytes()).hexdigest()==h
correction=(review/'handoff-correction.json').read_bytes();(D/'095-handoff-correction.json').write_bytes(correction)
(B/'raw/reuse-verified-manifest.json').write_text(json.dumps({'files':manifest,'reviewArtifactsSha256':hashlib.sha256((review/'artifacts.sha256').read_bytes()).hexdigest(),'correction':'raw/reused-prior/095-handoff-correction.json','scope':'exact095 raw 36Session/runtime focused regressions; no author source/report/progress accessed'},indent=2));print('Recomputed and copied exact095-listed raw',len(manifest),'files')
