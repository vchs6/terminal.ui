#!/usr/bin/env python3
"""Frozen K003/F003/K004 real-pipe/real-TTY vectors. No byte decoder/model.
read/poll interposition only changes the FD to a genuine pipe; return values,
POLLIN|HUP, buffered tail and read0 come from the OS. termios stays a real TTY.
All Keyboard behavior remains UNEXECUTED until the actual K public API exists.
"""
import argparse,datetime,errno,fcntl,hashlib,json,os,pty,re,select,signal,struct,subprocess,time
from pathlib import Path
START=b'\x1b[200~';END=b'\x1b[201~';QUERY=b'\x1b[?25$p'
MODES=['stream-two','focus','hide','disable','unmount','remount','modal','no-target','scroll','diag-begin','diag-context','issue-stop','issue-throws','eof-input','eof-paste','fair-normal','fair-paste','fair-drain','cancel-paste','cancel-drain','signal-paste','signal-drain','protocol-reply','fault-init-zero','fault-init-partial','fault-cleanup-zero','fault-cleanup-partial']
MUTATIONS=['focus','hide','disable','unmount','remount','modal','no-target','scroll']
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def attrs(fd):
 value=__import__('termios').tcgetattr(fd);value[-1]=[list(x) if isinstance(x,bytes) else x for x in value[-1]];return value

def run(binary,base,mode,shim,fault):
 out=base/mode;out.mkdir(parents=True,exist_ok=False);master,slave=pty.openpty();fcntl.ioctl(slave,__import__('termios').TIOCSWINSZ,struct.pack('HHHH',5,40,0,0));before=attrs(slave)
 reader,writer=os.pipe();os.mkfifo(out/'release.fifo');raw=bytearray();sent=bytearray();events=[];closed=False
 env=dict(os.environ,TERM='xterm-256color',LD_PRELOAD=str(shim),CJTUI_KEYBOARD_PIPE_FD=str(reader),CJTUI_KEYBOARD_PIPE_TRACE=str(out/'native.trace'),CJTUI_KEYBOARD_FORMAL_OUTPUT=str(out),CJTUI_KEYBOARD_FORMAL_MODE=mode)
 if mode.startswith('fault-'):
  _,boundary,action=mode.split('-');env.update(LD_PRELOAD=str(fault)+':'+str(shim),CJTUI_KEYBOARD_WRITE_BOUNDARY=boundary,CJTUI_KEYBOARD_WRITE_MODE=action,CJTUI_KEYBOARD_WRITE_TRACE=str(out/'write.trace'))
 def terminal():os.setsid();fcntl.ioctl(slave,__import__('termios').TIOCSCTTY,0)
 metadata={'mode':mode,'utc_start':utc(),'argv':[str(binary)],'cwd':str(Path.cwd()),'binary_pre_sha256':sha(binary),'before_termios':before,'events':events,'input_route':'actual OSpipe read/poll only; isatty/TCGETS/TCSETS/size remain true PTY'}
 with (out/'stderr').open('wb') as err:child=subprocess.Popen([str(binary)],stdin=slave,stdout=slave,stderr=err,pass_fds=(reader,),env=env,preexec_fn=terminal)
 def pump():
  if select.select([master],[],[],.01)[0]:
   try:raw.extend(os.read(master,65536))
   except OSError as e:
    if e.errno!=errno.EIO:raise
 def wait(test,label):
  until=time.monotonic()+10
  while time.monotonic()<until:
   pump()
   if test():return
   if child.poll() is not None:raise AssertionError('child exited before '+label)
  raise AssertionError('watchdog '+label)
 def text(name):
  p=out/name
  return p.read_text() if p.is_file() else ''
 def write(data):
  nonlocal sent
  assert not closed;sent.extend(data);events.append({'pipe_write_hex':data.hex(),'monotonic_ns':time.monotonic_ns()});view=memoryview(data)
  while view:view=view[os.write(writer,view):]
 def trace():return text('native.trace').splitlines()
 def idle(after=0):
  amount=len(sent)
  wait(lambda:any('poll ' in row and 'actual_result=0 ' in row and f'total={amount} ' in row for row in trace()[after:]),'actual empty-pipe native poll after consumed prefix')
  events.append({'real_empty_pipe_poll_after_bytes':amount,'trace_lines':len(trace()),'monotonic_ns':time.monotonic_ns()})
 def mutate(stopping=False):
  (out/'mutate').write_text('post requested only after real prefix consumption\n');wait(lambda:bool(text('mutated')),'actual UI mutation post')
  if not stopping:idle(len(trace()))
 def end_input():
  nonlocal closed
  os.close(writer);closed=True;events.append({'real_pipe_writer_closed':True,'monotonic_ns':time.monotonic_ns()})
 try:
  if mode.startswith('fault-init'):
   pass
  else:
   wait(lambda:QUERY in raw and b'\x1b[1;1H' in raw,'real query+first native frame');idle()
   if mode in MUTATIONS:
    write(START+b'x');idle();mutate();write(END+b'q')
   elif mode=='stream-two':write(b'b'+START+b'x'+END+b'a'+START+b'y'+END+b'q')
   elif mode in ['diag-begin','diag-context']:write(b'\x1b[99~'+START+b'x'+END+b'q')
   elif mode in ['issue-stop','issue-throws']:write(b'\x1b[99~'+START+b'NEVER'+END)
   elif mode.startswith('eof-'):
    write(b'\x1b[12' if mode=='eof-input' else START+b'xy');end_input()
   elif mode.startswith('fair-'):
    write(b'x');wait(lambda:text('gate')=='first-x','first callback gate')
    burst=b'x'*8192 if mode=='fair-normal' else START+b'a'*5000
    write(burst)
    with (out/'release.fifo').open('w') as gate:gate.write('release')
    wait(lambda:bool(text('post-at')),'queued post progresses');assert 1<=int(text('post-at'))<=4096
    if mode!='fair-normal':idle();mutate();assert text('pending-post')=='ran';write(END)
    write(b'q')
   elif mode.startswith(('cancel-','signal-')):
    write(START+(b'xxxxx' if mode.endswith('drain') else b'x'));idle()
    if mode.startswith('cancel-'):mutate(True)
    else:os.kill(child.pid,signal.SIGINT if mode.endswith('paste') else signal.SIGTERM)
   elif mode=='protocol-reply':write(b'\x1b[?25;1$yq')
   elif mode.startswith('fault-cleanup'):write(b'q')
  until=time.monotonic()+10
  while child.poll() is None and time.monotonic()<until:pump()
  assert child.poll() is not None,'actual product direct exit timeout';pump();metadata.update(exit=child.returncode,after_termios=attrs(slave));assert child.returncode==0 and before==metadata['after_termios'];assert text('returned')=='normal'
  summary=dict(line.split('=',1) for line in text('summary').splitlines());metadata['summary']=summary;assert summary['resources']=='0/0/0/0'
  assert summary['interrupts']=='0','paste/signal must not become UI interrupt'
  want_paste='';want_issues=''
  if mode=='stream-two':want_paste='B:x;A:y;'
  elif mode in ['focus','scroll']:want_paste='A:x;'
  elif mode in ['hide','disable','unmount','remount','modal','no-target']:want_issues='PasteTargetUnavailable@0;'
  elif mode in ['diag-begin','diag-context']:want_paste='B:x;';want_issues='UnsupportedSequence@0;'
  elif mode in ['issue-stop','issue-throws']:want_issues='UnsupportedSequence@0;'
  elif mode=='eof-input':want_issues='IncompleteInput@0;'
  elif mode=='eof-paste':want_issues='IncompletePaste@0;'
  elif mode=='fair-paste':want_paste='A:'+'a'*5000+';'
  elif mode=='fair-drain':want_issues='PasteTooLarge@1;'
  elif mode in ['cancel-drain','signal-drain']:want_issues='PasteTooLarge@0;'
  assert summary['paste']==want_paste,(mode,summary['paste'][:100],want_paste[:100]);assert summary['issues']==want_issues,(mode,summary['issues'],want_issues)
  if mode in ['hide','disable','unmount','remount','modal','no-target']:assert summary['appPaste']==summary['legacyPaste']=='0'
  if mode=='fair-normal':assert summary['textCount']=='8193'
  if mode.startswith('eof-'):
   assert text('eof-callback')=='active/committed/post-accepted' and summary['postRan']=='false' and summary['keys']=='';assert b'EOF_COMMITTED' not in raw
   assert any('read ' in row and 'actual_result=0 ' in row for row in trace()),'EOF must be real OSread0'
  if mode=='protocol-reply':assert summary['keys']=='text:q;'
  if mode in ['issue-stop','issue-throws']:assert summary['keys']==''
  if mode=='diag-context':assert text('issue-context')=='ok'
  if mode.startswith('fault-'):
   rows=text('write.trace').splitlines();hits=[i for i,x in enumerate(rows) if x.startswith(('zero ','partial '))];assert len(hits)==1 and text('error')
   if mode.endswith('partial'):
    assert 'result=1 ' in rows[hits[0]] and rows[hits[0]+1].startswith('partial-fatal ')
    assert all(int(re.search(r'result=(-?\d+)',x)[1])<=0 for x in rows[hits[0]+1:]),'unsafe leaked later stdout'
   metadata['mode_restoration']='expected write failure; display mode restoration insufficient, native termios restored'
  else:
   assert bytes(raw).count(b'\x1b[?2004h')==1 and bytes(raw).count(b'\x1b[?2004l')==1
  if mode!='protocol-reply':assert not re.search(rb'\x1b\[\?25[hlsr]',bytes(raw)),'Pending/Unknown must not manage25'
  metadata['result']='PASS'
 except BaseException as error:metadata.update(result='FAIL',error=repr(error));raise
 finally:
  if child.poll() is None:os.killpg(child.pid,signal.SIGKILL);child.wait();metadata['forced']=True
  pump();metadata.setdefault('exit',child.returncode);metadata.setdefault('after_termios',attrs(slave));metadata.update(utc_end=utc(),binary_post_sha256=sha(binary));assert metadata['binary_pre_sha256']==metadata['binary_post_sha256']
  (out/'input.raw').write_bytes(sent);(out/'output.raw').write_bytes(raw);(out/'metadata.json').write_text(json.dumps(metadata,indent=2)+'\n')
  if not closed:os.close(writer)
  os.close(reader);os.close(master);os.close(slave)
 print('PASS formal native',mode)

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--binary',required=True,type=Path);p.add_argument('--output',required=True,type=Path);p.add_argument('--shim',required=True,type=Path);p.add_argument('--fault',required=True,type=Path);p.add_argument('modes',nargs='*');a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 for mode in a.modes or MODES:
  assert mode in MODES,mode
  run(a.binary.resolve(),a.output.resolve(),mode,a.shim.resolve(),a.fault.resolve())
