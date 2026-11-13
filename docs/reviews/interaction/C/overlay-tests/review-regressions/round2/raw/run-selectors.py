from pathlib import Path
import datetime,hashlib,json,subprocess,sys
b=Path(__file__).resolve().parent.parent;raw=b/'raw';binary=b/'replay/tests/interaction_c/target/release/bin/main'
assert int((raw/'build.exit').read_text())==0
for name in ['R1-I01','R1-I02']:
 def identity():
  stat=binary.stat()
  return {'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'path':str(binary),'sha256':hashlib.sha256(binary.read_bytes()).hexdigest(),'size':stat.st_size,'mtime_ns':stat.st_mtime_ns}
 before=identity();(raw/(name+'.bin-pre.json')).write_text(json.dumps(before,indent=2)+'\n')
 subprocess.run([sys.executable,str(raw/'record.py'),name,'export CJTUI_OVERLAY_REVIEW_R2='+name+'\nexec timeout 45s ./target/release/bin/main </dev/null'],cwd=b,check=True)
 after=identity();(raw/(name+'.bin-post.json')).write_text(json.dumps(after,indent=2)+'\n')
 assert before['sha256']==after['sha256']
 print(name,'binary_before_after',before['sha256'],'actual_exit',(raw/(name+'.exit')).read_text().strip())
