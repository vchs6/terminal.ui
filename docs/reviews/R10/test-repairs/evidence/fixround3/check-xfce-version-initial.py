from pathlib import Path
from datetime import datetime,timezone
import os,subprocess,json,time,shutil
root=Path(__file__).resolve().parent
case=root/'xfce-version'; case.mkdir()
number=next(n for n in range(219,240) if not Path(f'/tmp/.X{n}-lock').exists() and not Path(f'/tmp/.X11-unix/X{n}').exists())
display=f':{number}'
command=['Xorg',display,'-config','/workspace/work/cross-terminal-recon/probes/xorg-dummy.conf','-nolisten','tcp','-noreset','-logfile',str(case/'xorg.log')]
records=[]
with (case/'xorg.stdout').open('wb') as out:
 process=subprocess.Popen(command,stdout=out,stderr=subprocess.STDOUT)
 try:
  env={**os.environ,'DISPLAY':display}
  deadline=time.monotonic()+15
  while True:
   ready=subprocess.run(['xdpyinfo'],env=env,capture_output=True)
   if ready.returncode==0: break
   assert process.poll() is None,'Xorg exited before readiness'
   assert time.monotonic()<deadline,'Xorg readiness timeout'
   time.sleep(.1)
  (case/'xdpyinfo.stdout').write_bytes(ready.stdout); (case/'xdpyinfo.stderr').write_bytes(ready.stderr)
  binary=shutil.which('xfce4-terminal'); assert binary
  for option in ['-version','--version']:
   start=datetime.now(timezone.utc).isoformat()
   result=subprocess.run([binary,option],env=env,capture_output=True,timeout=10)
   label='single-dash' if option=='-version' else 'double-dash'
   (case/(label+'.stdout')).write_bytes(result.stdout); (case/(label+'.stderr')).write_bytes(result.stderr)
   records.append({'command':[binary,option],'DISPLAY':display,'start_utc':start,'end_utc':datetime.now(timezone.utc).isoformat(),'actual_exit':result.returncode})
   assert result.returncode==0,(option,result.stderr.decode())
   assert b'Xfce Terminal 1.1.4' in result.stdout+result.stderr,(option,result.stdout,result.stderr)
  (case/'result.json').write_text(json.dumps({'xorg_command':command,'queries':records,'scope':'Real installed XFCE version query on fresh actual Xorg; no application, scene or matrix run'},indent=2)+'\n')
  print('PASS actual XFCE -version and --version with DISPLAY='+display+' each exit 0')
  print((case/'double-dash.stdout').read_text())
 finally:
  process.terminate()
  try: process.wait(timeout=5)
  except subprocess.TimeoutExpired: process.kill(); process.wait()
