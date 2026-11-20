"""Owned app identity capture/termination only; PID reuse never grants ownership."""
import json,os,pathlib,signal,sys,time
assert os.environ.get('C008_ROOT_ACTUAL_GO')=='1'
def identity(pid):
 root=pathlib.Path('/proc')/str(pid);stat=(root/'stat').read_text();return {'pid':pid,'startTicks':stat.rsplit(')',1)[1].split()[19],'uid':root.stat().st_uid,'exe':str((root/'exe').resolve()),'utcNs':time.time_ns()}
if sys.argv[1]=='terminate':
 row=json.loads(pathlib.Path(sys.argv[2]).read_text());current=identity(row['pid']);assert current['uid']==os.getuid()==row['uid'] and current['startTicks']==row['startTicks'],'owned process identity changed'
 os.kill(row['pid'],signal.SIGTERM)
else:pathlib.Path(sys.argv[2]).write_text(json.dumps(identity(int(sys.argv[1])),indent=2)+'\n')
