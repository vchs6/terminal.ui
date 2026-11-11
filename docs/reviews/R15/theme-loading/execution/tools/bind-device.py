from pathlib import Path
import hashlib,json,os,subprocess
B=Path('/workspace/work/theme-load-execution');O=B/'raw/device-pty-bound';O.mkdir(parents=True,exist_ok=True)
files=[B/'device-observation/src/main.cj',B/'device-observation/cjpm.toml',B/'device-observation/native/session_fault.c',B/'device-observation/native/libsession_fault.a',B/'device-observation/target/release/bin/main',B/'tools/device-pty.py',B/'env.sh',B/'device-observation/cangjie-repo.toml']
def snapshot():return {str(p.relative_to(B)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
pre=snapshot();(O/'pre-driver-binary.json').write_text(json.dumps(pre,indent=2)+'\n');env=os.environ.copy();env['TASK091_DEVICE_LOGS']=str(O/'detail');r=subprocess.run(['python3',str(B/'tools/device-pty.py')],env=env);post=snapshot();(O/'post-driver-binary.json').write_text(json.dumps(post,indent=2)+'\n');assert pre==post;raise SystemExit(r.returncode)
