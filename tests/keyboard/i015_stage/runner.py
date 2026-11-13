#!/usr/bin/env python3
"""One Keyboard-stage vector plus the existing cross-deadline control.
Reuse A's clock link seam and pass-through real-poll observer. No input decoder,
product clock setter, synthetic poll result or wall sleep used as idle proof.
"""
import argparse,datetime,errno,fcntl,hashlib,json,os,pty,re,select,signal,struct,subprocess,termios,time
from pathlib import Path
PREFIX=bytes.fromhex('1b5b3f32353b');TAIL=bytes.fromhex('312479')
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def attrs(fd):
 value=termios.tcgetattr(fd);value[-1]=[list(x) if isinstance(x,bytes) else x for x in value[-1]];return value

def run(binary,out,poll_library):
 out.mkdir(parents=True,exist_ok=False);clock=out/'clock';clock.write_text('1000\n');calls=out/'clock.calls';polls=out/'poll.calls';enters=out/'poll.enter'
 master,slave=pty.openpty();fcntl.ioctl(slave,termios.TIOCSWINSZ,struct.pack('HHHH',3,40,0,0));before=attrs(slave);raw=bytearray();sent=bytearray();events=[];child=None
 metadata={'case':'csi-real-idle-Keyboard','stage':'Keyboard','utc_start':utc(),'cwd':str(Path.cwd()),'argv':[str(binary)],'binary_pre_sha256':sha(binary),'before_termios':before,'events':events,'size':[40,3]}
 def pump():
  if select.select([master],[],[],.0005)[0]:
   try:raw.extend(os.read(master,65536))
   except OSError as e:
    if e.errno!=errno.EIO:raise
 def rows(path,count):
  if not path.exists():return []
  answer=[]
  for line in path.read_text().splitlines():
   try:value=list(map(int,line.split()))
   except ValueError:continue
   if len(value)==count:answer.append(value)
  return answer
 def wait(test,label,timeout=5):
  until=time.monotonic()+timeout
  while time.monotonic()<until:
   pump()
   if test():return
   if child.poll() is not None:raise RuntimeError('child exited before '+label)
  raise RuntimeError('fixture watchdog '+label)
 def set_clock(value):
  temp=clock.with_suffix('.next');temp.write_text(str(value)+'\n');temp.replace(clock);events.append({'clock':value,'monotonic_ns':time.monotonic_ns()})
 def send(data):
  at=time.monotonic_ns();sent.extend(data);os.write(master,data);events.append({'input_hex':data.hex(),'monotonic_ns':at});return at
 def next_poll_after_prefix(at,timeout):
  answer=[]
  def selected():
   nonlocal answer
   positive=[x for x in rows(polls,5) if x[1]>=at and x[3]==1 and x[4]&1]
   if len(positive)<6:return False
   end=positive[5][1]
   candidates=[x for x in rows(enters,2) if x[0]>=end and x[1]==timeout]
   if not candidates:return False
   answer=[positive[:6],candidates[0]];return True
  wait(selected,'six native byte-ready polls and following idle poll')
  proof={'six_byte_ready_polls':answer[0],'idle_poll_entry':answer[1]};events.append(proof);return answer[1][0]
 def completion(start,timeout):
  answer=[]
  def completed():
   nonlocal answer
   answer=[x for x in rows(polls,5) if x[0]==start and x[2]==timeout]
   return len(answer)==1
  wait(completed,'actual libc poll completion');return answer[0]
 def state(number):
  send(b's');p=out/f'state-{number}';wait(lambda:p.exists() and len(p.read_text().splitlines())==3,'public stage query')
  value=p.read_text();events.append({'public_state':number,'value':value,'monotonic_ns':time.monotonic_ns()});return value
 def terminal():os.setsid();fcntl.ioctl(slave,termios.TIOCSCTTY,0)
 try:
  env=dict(os.environ,TERM='xterm-256color',CJTUI_KEYBOARD_I015_OUTPUT=str(out),CJTUI_A_CLOCK_FILE=str(clock),CJTUI_A_CLOCK_TRACE=str(calls),CJTUI_A_POLL_TRACE=str(polls),CJTUI_A_POLL_ENTER=str(enters),LD_PRELOAD=str(poll_library))
  for name in ['CJTUI_A_HUP_ARM_FILE','CJTUI_A_HUP_TRACE','CJTUI_A_CLOCK_SCRIPT']:env.pop(name,None)
  metadata['env']={k:env[k] for k in ['TERM','CJTUI_KEYBOARD_I015_OUTPUT','CJTUI_A_CLOCK_FILE','CJTUI_A_CLOCK_TRACE','CJTUI_A_POLL_TRACE','CJTUI_A_POLL_ENTER','LD_PRELOAD']}
  with (out/'stderr').open('wb') as err:child=subprocess.Popen([str(binary)],stdin=slave,stdout=slave,stderr=err,env=env,preexec_fn=terminal)
  wait(lambda:b'\x1b[?25$p' in raw and b'K-I015-STAGE-READY' in raw and calls.exists() and len(calls.read_text().splitlines())>=2,'actual query/first frame/wrapped t0')
  set_clock(1100);first_sent=send(PREFIX);first_poll=next_poll_after_prefix(first_sent,100)
  set_clock(1201);switched=time.monotonic_ns();idle=completion(first_poll,100)
  assert idle[3:]==[0,0] and idle[1]-idle[0]>=100_000_000 and idle[0]<=switched<=idle[1],('real100ms idle proof',idle,switched)
  metadata['actual_100ms_idle']=idle
  wait(lambda:(out/'issues').exists(),'public IncompleteInput callback')
  assert (out/'issues').read_text()=='IncompleteInput@0;' and (out/'issue-cap').read_text()=='pending'
  send(TAIL);first=state(1);assert first=='pending\nIncompleteInput@0;\ntext:1|text:$|text:y|text:s|',first
  # Existing cross-deadline input, within the same pending probe ledger.
  set_clock(1580);second_sent=send(PREFIX);deadline_poll=next_poll_after_prefix(second_sent,20)
  set_clock(1600);deadline=completion(deadline_poll,20);assert deadline[3:]==[0,0] and deadline[1]-deadline[0]>=20_000_000,deadline
  set_clock(1610);tail_sent=send(TAIL);assert tail_sent-second_sent<100_000_000,'fixture cross-deadline tail exceeded real100ms idle'
  metadata['actual_deadline_poll']=deadline;metadata['cross_deadline_prefix_to_tail_ns']=tail_sent-second_sent
  second=state(2);assert second=='unknown-timeout\nIncompleteInput@0;\ntext:1|text:$|text:y|text:s|text:s|',second
  send(b'q');until=time.monotonic()+5
  while child.poll() is None and time.monotonic()<until:pump()
  assert child.poll() is not None,'actual native exit watchdog';pump();metadata.update(actual_binary_exit=child.returncode,after_termios=attrs(slave));assert child.returncode==0 and before==metadata['after_termios']
  assert bytes(raw).count(b'\x1b[?25$p')==1 and not re.search(rb'\x1b\[\?25[hlsr]',bytes(raw))
  assert b'\x1b[?2004h' in raw and b'\x1b[?2004l' in raw
  metadata['closed']=(out/'closed').read_text();assert metadata['closed']=='unknown-timeout\nIncompleteInput@0;\ntext:1|text:$|text:y|text:s|text:s|text:q|\ncleanup=1\nresources=0/0/0/0\n'
  metadata['result']='GREEN';return 0
 except BaseException as error:metadata.update(result='FAIL',error=repr(error));return 1
 finally:
  if child and child.poll() is None:os.killpg(child.pid,signal.SIGKILL);child.wait();metadata['forced']=True
  pump();metadata.setdefault('actual_binary_exit',child.returncode if child else None);metadata.setdefault('after_termios',attrs(slave));metadata.update(utc_end=utc(),binary_post_sha256=sha(binary));assert metadata['binary_pre_sha256']==metadata['binary_post_sha256']
  (out/'input.raw').write_bytes(sent);(out/'output.raw').write_bytes(raw);(out/'metadata.json').write_text(json.dumps(metadata,indent=2)+'\n');os.close(master);os.close(slave)

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--stage',choices=['Keyboard'],default='Keyboard');p.add_argument('--case',choices=['csi-real-idle-Keyboard'],default='csi-real-idle-Keyboard');p.add_argument('--binary',required=True,type=Path);p.add_argument('--output',required=True,type=Path);p.add_argument('--poll-library',required=True,type=Path);a=p.parse_args();raise SystemExit(run(a.binary.resolve(),a.output.resolve(),a.poll_library.resolve()))
