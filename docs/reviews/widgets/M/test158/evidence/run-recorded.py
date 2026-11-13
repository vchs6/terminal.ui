from pathlib import Path
import datetime, hashlib, json, os, subprocess, sys
root=Path('/workspace/work/widgets-composite-tests/final')
name=sys.argv[1]
cwd=Path(sys.argv[2])
command=sys.argv[3:]
log=root/'evidence'/f'{name}.log'
start=datetime.datetime.now(datetime.timezone.utc).isoformat()
with log.open('wb') as stream:
 result=subprocess.run(command,cwd=cwd,stdout=stream,stderr=subprocess.STDOUT)
record=dict(name=name,cwd=str(cwd),argv=command,started_utc=start,ended_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),exit=result.returncode,log=str(log),log_sha256=hashlib.sha256(log.read_bytes()).hexdigest(),environment=dict(SDK='/workspace/work/validation/sdk/cangjie',CANGJIE_STDX_PATH='/workspace/work/linux-build-recon/stdx-env',CJTUI_UCD_ARCHIVE='/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip',registry='https://pkg.cangjie-lang.cn/registry',cache='/workspace/work/viewport-tests/cache'))
(root/'evidence'/f'{name}.command.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps(record))
sys.exit(result.returncode)
