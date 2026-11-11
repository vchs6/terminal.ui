import datetime,json,os,pathlib,selectors,shlex,subprocess,time
B=pathlib.Path('/workspace/work/theme-load-execution');D=pathlib.Path(os.environ.get('TASK091_DEVICE_LOGS',str(B/'raw/device-pty/detail')));D.mkdir(parents=True,exist_ok=True);binary=B/'device-observation/target/release/bin/main';wrapper=D/'session.sh'
wrapper.write_text('#!/bin/sh\nstty rows 3 cols 20\ndate -u +%FT%TZ > "$2/utc-before"\nstty size > "$2/grid"\nstty -g > "$2/before"\ntty > "$2/tty"\n"$1"\nstatus=$?\nstty -g > "$2/after"\necho "$status" > "$2/exit"\ndate -u +%FT%TZ > "$2/utc-after"\nexit "$status"\n')
env=os.environ.copy();env.update(TERM='dumb',COLORTERM='',TASK091_DEVICE_DIR=str(D),CJTUI_SESSION_NATIVE=str(D/'native.tsv'),CJTUI_SESSION_ALL_WIRE=str(D/'armed-write.raw'))
cmd=['script','-q','-e','-f','-c',shlex.join(['sh',str(wrapper),str(binary),str(D)]),'/dev/null'];(D/'launch.json').write_text(json.dumps({'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'argv':cmd,'env':{k:env[k] for k in ['TERM','COLORTERM','TASK091_DEVICE_DIR','CJTUI_SESSION_NATIVE','CJTUI_SESSION_ALL_WIRE']}},indent=2)+'\n')
p=subprocess.Popen(cmd,env=env,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE);selector=selectors.DefaultSelector();selector.register(p.stdout,selectors.EVENT_READ,'stdout');selector.register(p.stderr,selectors.EVENT_READ,'stderr');raw={'stdout':bytearray(),'stderr':bytearray()};sent=False;deadline=time.monotonic()+30;failure=None
try:
 while selector.get_map():
  left=deadline-time.monotonic()
  if left<=0:raise TimeoutError('device observation did not terminate after actual EIO')
  for key,_ in selector.select(left):
   data=os.read(key.fileobj.fileno(),65536)
   if not data:selector.unregister(key.fileobj);continue
   raw[key.data].extend(data)
   if not sent and b'TASK091_BASE' in raw['stdout']:
    p.stdin.write(b't');p.stdin.flush();sent=True
 p.wait(timeout=max(.1,deadline-time.monotonic()));assert p.returncode==0,p.returncode
 assert sent;assert (D/'before').read_text().strip()==(D/'after').read_text().strip()
 native=(D/'native.tsv').read_text();assert 'fault\t1\t4\n' in native,native
 assert all(f'signal-restored\t{s}\t1\n' in native for s in [28,2,15]),native
 report=(D/'after.txt').read_text();assert 'terminal write failed' in report and 'name=Accepted\n' in report and 'revision=1\n' in report and 'applied=1\n' in report
 (D/'result.json').write_text(json.dumps({'passed':True,'exit':p.returncode,'actual_partial_write_before_EIO':4,'Applied_and_ThemeInfo_preserved':True,'termios_restored':True,'signal_handlers_restored':True,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat()},indent=2)+'\n')
except BaseException as err:
 failure=repr(err);(D/'failure.json').write_text(json.dumps({'error':failure},indent=2)+'\n');raise
finally:
 if p.poll() is None:p.kill();out,err=p.communicate();raw['stdout'].extend(out);raw['stderr'].extend(err)
 for name,data in raw.items():(D/(name+'.raw')).write_bytes(data)
 selector.close()
print('ActualPTY partialwrite EIO after accepted Theme: history preserved, restore verified')
