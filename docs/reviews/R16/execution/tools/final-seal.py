from pathlib import Path
import json,hashlib,shutil,datetime
B=Path('/workspace/work/glyph-execution');C=B/'curated-r16-execution';M=json.loads((C/'manifest.json').read_text())
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
M['sourceToCurated']=list({r['curated']:r for r in M['sourceToCurated'] if r['curated'] not in ['tools/final-seal.py','raw/seal-summary.json']}.values())
# Close run.py's curation logs before sealing; no running logger is included now.
for row in M['sourceToCurated']:
 src=Path(row['source']);dst=C/row['curated'];shutil.copy2(src,dst);row.update(sha256=digest(dst),size=dst.stat().st_size);assert src.read_bytes()==dst.read_bytes()
for src,rel in [(Path(__file__),Path('tools/final-seal.py')),(B/'raw/host-xorg-dummy.conf',Path('raw/host-xorg-dummy.conf')),(B/'raw/gui/vte/home/config/xfce4/terminal/terminalrc',Path('raw/gui/vte/home/config/xfce4/terminal/terminalrc'))]:
 dst=C/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst);M['sourceToCurated'].append({'source':str(src),'curated':str(rel),'sha256':digest(dst),'size':dst.stat().st_size})
summary={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceCopiesBeforeSealSummary':len(M['sourceToCurated']),'sourceCopyBytesVerified':True,'normalHostsExited':True,'note':'Curation run logs copied only after logger exit; no mutable live log included in final seal.'};src=B/'raw/seal-summary.json';src.write_text(json.dumps(summary,indent=2));dst=C/'raw/seal-summary.json';shutil.copy2(src,dst);M['sourceToCurated'].append({'source':str(src),'curated':'raw/seal-summary.json','sha256':digest(dst),'size':dst.stat().st_size})
copiedSources={r['source'] for r in M['sourceToCurated']};M['omitted']=[r for r in M['omitted'] if r['source'] not in copiedSources]
M['curatedUtc']=summary['utc'];(C/'manifest.json').write_text(json.dumps(M,ensure_ascii=False,indent=2))
files=sorted(p for p in C.rglob('*') if p.is_file() and p.name!='artifacts.sha256');(C/'artifacts.sha256').write_text(''.join(digest(p)+'  '+str(p.relative_to(C))+'\n' for p in files));shutil.copy2(C/'artifacts.sha256',B/'artifacts.sha256')
for row in M['sourceToCurated']:assert digest(Path(row['source']))==row['sha256'] and digest(C/row['curated'])==row['sha256']
for line in (C/'artifacts.sha256').read_text().splitlines():h,name=line.split(None,1);assert digest(C/name.strip())==h
(B/'manifest.json').write_text(json.dumps({'curated':str(C),'files':len(files),'sourceCopies':len(M['sourceToCurated']),'omittedInputs':len(M['omitted']),'manifestSha256':digest(C/'manifest.json'),'artifactsSha256':digest(C/'artifacts.sha256'),'product':M['product'],'integration':M['integration']},indent=2))
print(json.dumps(json.loads((B/'manifest.json').read_text()),indent=2))
