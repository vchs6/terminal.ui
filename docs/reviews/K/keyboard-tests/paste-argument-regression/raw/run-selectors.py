from pathlib import Path
import datetime,hashlib,json,subprocess,sys
b=Path(__file__).resolve().parent.parent;raw=b/'raw';cwd=b/'replay/tests/keyboard/paste_argument';binary=cwd/'target/release/bin/main'
assert int((raw/'build.exit').read_text())==0
for name in ['c1-byte-budget','ctrl-text','paste-native']:
 def identity():
  return {'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'path':str(binary),'sha256':hashlib.sha256(binary.read_bytes()).hexdigest(),'size':binary.stat().st_size}
 before=identity();(raw/(name+'.bin-pre.json')).write_text(json.dumps(before,indent=2)+'\n')
 script=('export CJTUI_KEYBOARD_ARGUMENT_CASE='+name+'\nexec timeout 45s ./target/release/bin/main </dev/null') if name!='paste-native' else 'exec python3 pty.py --binary target/release/bin/main --output '+str(raw/'native-capture')
 subprocess.run([sys.executable,str(raw/'record.py'),name,str(cwd),script],cwd=b,check=True)
 after=identity();(raw/(name+'.bin-post.json')).write_text(json.dumps(after,indent=2)+'\n');assert before['sha256']==after['sha256']
 print(name,'actual_exit',(raw/(name+'.exit')).read_text().strip(),'bin_sha256',before['sha256'])
