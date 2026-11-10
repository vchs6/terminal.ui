from pathlib import Path
from datetime import datetime,timezone
import os,subprocess,json
root=Path(__file__).resolve().parent
case=root/'sdk-early-check'; case.mkdir()
script=Path('/workspace/work/auto-harness-repair/tests/terminals/run.sh')
missing=case/'missing-fixture-bin'; assert not missing.exists()
env={**os.environ,'CJTUI_SDK_ENV':'/workspace/work/validation/sdk/cangjie/envsetup.sh','CJTUI_TERMINAL_HOST_ROOT':'/workspace/work/cross-terminal-recon','CJTUI_TERMINAL_CAPTURE_DIR':str(case/'capture'),'CJTUI_TERMINAL_FIXTURE_BIN':str(missing),'CJTUI_TERMINAL_SCENE':'fixture'}
command=[str(script)]
start=datetime.now(timezone.utc).isoformat()
result=subprocess.run(command,cwd='/workspace/work/auto-harness-repair',env=env,capture_output=True)
(case/'stdout.log').write_bytes(result.stdout); (case/'stderr.log').write_bytes(result.stderr)
(case/'result.json').write_text(json.dumps({'command':command,'cwd':'/workspace/work/auto-harness-repair','start_utc':start,'end_utc':datetime.now(timezone.utc).isoformat(),'environment':{key:env[key] for key in env if key.startswith('CJTUI_TERMINAL_') or key=='CJTUI_SDK_ENV'},'actual_exit':result.returncode,'expected_early_check':'fixture binary missing after SDK envsetup; no application or matrix starts'},indent=2)+'\n')
assert result.returncode==1
assert b'fixture binary missing' in result.stderr
assert b'Unsupported shell' not in result.stdout+result.stderr
print('PASS real direct shebang entry sources SDK 1.2.0 then exits 1 at controlled missing binary check')
print(result.stderr.decode(),end='')
