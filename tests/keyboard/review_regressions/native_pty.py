#!/usr/bin/env python3
"""One native issue-handler stop vector; actual PTY, no mocked decoder."""
import argparse,datetime,errno,fcntl,hashlib,json,os,pty,select,signal,struct,subprocess,termios,time
from pathlib import Path
PAYLOAD=b'\xe4x'
FAIL=b'FAIL K115 K115-05 diagnostic stop cancels same-byte retry and run returns normally'
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def attrs(fd):
 result=termios.tcgetattr(fd);result[-1]=[list(x) if isinstance(x,bytes) else x for x in result[-1]];return result

def run(binary,out):
 out.mkdir(parents=True,exist_ok=False);master,slave=pty.openpty();fcntl.ioctl(slave,termios.TIOCSWINSZ,struct.pack('HHHH',3,40,0,0));raw=bytearray();before=attrs(slave);sent=bytearray();child=None
 metadata={'utc_start':utc(),'cwd':str(Path.cwd()),'argv':[str(binary)],'binary_pre_sha256':sha(binary),'before_termios':before,'size':[40,3],'env':{'CJTUI_K115_CASE':'K115-05','CJTUI_K115_OUTPUT':str(out),'TERM':'xterm-256color'}}
 def pump():
  if select.select([master],[],[],.01)[0]:
   try:raw.extend(os.read(master,65536))
   except OSError as error:
    if error.errno!=errno.EIO:raise
 def terminal():os.setsid();fcntl.ioctl(slave,termios.TIOCSCTTY,0)
 try:
  with (out/'stderr').open('wb') as err:
   child=subprocess.Popen([str(binary)],stdin=slave,stdout=slave,stderr=err,env=dict(os.environ,**metadata['env']),preexec_fn=terminal)
   until=time.monotonic()+8
   while time.monotonic()<until:
    pump()
    if b'K115-ISSUE-STOP-READY' in raw and b'\x1b[?2004h' in raw and not termios.tcgetattr(slave)[3]&(termios.ICANON|termios.ECHO):break
    if child.poll() is not None:raise RuntimeError('native exited before actual raw-mode first frame')
   else:raise RuntimeError('fixture startup timeout')
   metadata['native_ready_wire_bytes']=len(raw);metadata['input_utc']=utc();sent.extend(PAYLOAD);os.write(master,PAYLOAD)
   until=time.monotonic()+8
   while child.poll() is None and time.monotonic()<until:pump()
   if child.poll() is None:metadata['classification']='fixture-timeout';raise RuntimeError('native watchdog: no behavioral RED inferred')
   pump();metadata.update(actual_binary_exit=child.returncode,after_termios=attrs(slave));assert before==metadata['after_termios'],'termios restoration control'
   assert b'\x1b[?2004l' in raw,'native mode cleanup control'
   summary=dict(line.split('=',1) for line in (out/'summary').read_text().splitlines());metadata['summary']=summary
   assert (out/'issue').read_text()=='InvalidUtf8@0;count=1' and summary['issues']=='1' and summary['cleanup']=='1' and summary['released']=='true','native path/cleanup controls'
   error=(out/'stderr').read_bytes()
   if child.returncode==1 and FAIL in error:metadata['classification']='actual-native-assertion-RED';return 1
   if child.returncode==0:
    assert summary['caught']=='false' and summary['x']=='0'
    metadata['classification']='actual-native-GREEN';return 0
   metadata['classification']='unexpected-native-failure';return 2
 except BaseException as error:metadata.setdefault('classification','fixture-or-postcondition-failure');metadata['error']=repr(error);return 2
 finally:
  if child and child.poll() is None:os.killpg(child.pid,signal.SIGKILL);child.wait();metadata['forced']=True
  pump();metadata.setdefault('actual_binary_exit',child.returncode if child else None);metadata.setdefault('after_termios',attrs(slave));metadata.update(utc_end=utc(),binary_post_sha256=sha(binary));assert metadata['binary_pre_sha256']==metadata['binary_post_sha256']
  (out/'input.raw').write_bytes(sent);(out/'output.raw').write_bytes(raw);(out/'metadata.json').write_text(json.dumps(metadata,indent=2)+'\n');os.close(master);os.close(slave)

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--binary',required=True,type=Path);p.add_argument('--output',required=True,type=Path);a=p.parse_args();raise SystemExit(run(a.binary.resolve(),a.output.resolve()))
