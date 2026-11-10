from pathlib import Path
from datetime import datetime, timezone
import json,subprocess,sys,time
name,cwd,*command=sys.argv[1:]
root=Path(__file__).resolve().parent
out=root/name
out.mkdir()
started=datetime.now(timezone.utc).isoformat()
actual=['bash','-c','set -e; source /workspace/work/validation/sdk/cangjie/envsetup.sh; export CJTUI_UCD_ARCHIVE=/workspace/work/validation/UCD-17.0.0.zip; exec "$@"','sdk-run',*command]
with (out/'stdout.log').open('wb') as stdout,(out/'stderr.log').open('wb') as stderr:
    result=subprocess.run(actual,cwd=cwd,stdout=stdout,stderr=stderr)
metadata={'command':command,'actual_argv':actual,'cwd':cwd,'started_at_utc':started,'finished_at_utc':datetime.now(timezone.utc).isoformat(),'exit_code':result.returncode,'scope':'Current reproduction on fixed historical code, not recovered historical log'}
(out/'result.json').write_text(json.dumps(metadata,indent=2)+'\n')
print(json.dumps(metadata),flush=True)
