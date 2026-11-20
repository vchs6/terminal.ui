#!/usr/bin/env python3
"""Take before/after read-only evidence; caller performs only outer X11 resize."""
import json,os,pathlib,re,subprocess as S,sys,time
assert os.environ.get('C008_ROOT_ACTUAL_GO')=='1'
pid=int(os.environ['C008_SSH_CLIENT_PID']);session=pathlib.Path(os.environ['C008_REMOTE_SHARED_RECORDING'])
def tty(name):
 s=(session/name).read_text();m=re.search(r'^tty=(/dev/pts/\d+)$',s,re.M);assert m;return m[1]
def size(args):return S.run(args,check=True,capture_output=True,text=True).stdout.strip()
reader=str(pathlib.Path(__file__).with_name('ssh-dimensions.sh'))
fd=pathlib.Path('/proc')/str(pid)/'fd/0';local=os.readlink(fd);stat=(pathlib.Path('/proc')/str(pid)/'stat').read_text()
result={'utc_ns':time.time_ns(),'label':sys.argv[1],'ssh_client_pid':pid,'ssh_process_stat':stat,'local_fd0':local,
 'local_ssh_tty_size':size(['stty','-F',str(fd),'size']),
 'remote_ssh_allocated_tty':tty('outer-state.txt'),'remote_app_tty':tty('inner-state.txt'),
 'remote_ssh_allocated_size':size(['bash',reader,tty('outer-state.txt')]),'remote_app_size':size(['bash',reader,tty('inner-state.txt')]),
 'mutations':'none; queries only'}
print(json.dumps(result,indent=2))
