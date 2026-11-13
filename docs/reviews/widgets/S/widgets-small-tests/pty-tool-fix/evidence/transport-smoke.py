"""TOOL ONLY: exercise OS PTY/controlling-terminal/FD/kill mechanics, no product."""
import ast,errno,fcntl,hashlib,json,os,pathlib,runpy,select,signal,struct,subprocess,sys,termios,time,types
base=pathlib.Path('/workspace/work/widgets-small-tests/pty-tool-fix');ev=base/'evidence';fixture=base/'source/tests/widgets_small/pty.py'
namespace=runpy.run_path(str(fixture),run_name='tool_import_surface')
assert 'pty' not in namespace and namespace['os'].openpty is os.openpty
surface={name:{'module':value.__name__,'origin':getattr(value,'__file__','<built-in>')} for name,value in namespace.items() if isinstance(value,types.ModuleType)}
(ev/'import-surface.json').write_text(json.dumps({'python':sys.version,'fixture':str(fixture),'stdlib_modules':surface,'driver_run_invoked':False},indent=2)+'\n')

def control(mode):
    output=ev/('tool-only-'+mode);output.mkdir(exist_ok=False)
    master,slave=namespace['os'].openpty()
    fcntl.ioctl(slave,termios.TIOCSWINSZ,struct.pack('HHHH',6,40,0,0))
    before=subprocess.check_output(['stty','-g'],stdin=slave).decode().strip();raw=bytearray();sent=b''
    def terminal():
        os.setsid();fcntl.ioctl(slave,termios.TIOCSCTTY,0)
    helper=ev/'transport-helper.py'
    with (output/'stderr.raw').open('wb') as err:
        child=subprocess.Popen([sys.executable,str(helper)],stdin=slave,stdout=slave,stderr=err,preexec_fn=terminal)
    metadata={'classification':'TOOL_ONLY_NONPRODUCT','mode':mode,'argv':[sys.executable,str(helper)],'cwd':str(pathlib.Path.cwd()),'helper_sha256':hashlib.sha256(helper.read_bytes()).hexdigest(),'before_stty':before,'winsize':list(struct.unpack('HHHH',fcntl.ioctl(slave,termios.TIOCGWINSZ,b'\0'*8)))}
    def pump():
        if select.select([master],[],[],0.02)[0]:
            try:raw.extend(os.read(master,65536))
            except OSError as error:
                if error.errno!=errno.EIO:raise
    def until(test):
        deadline=time.monotonic()+5
        while time.monotonic()<deadline:
            pump()
            if test():return
        raise AssertionError('tool-only transport watchdog')
    try:
        until(lambda:b'TOOL_ONLY_READY' in raw)
        if mode=='normal':
            sent=b'transport-control\n';view=memoryview(sent)
            while view:view=view[os.write(master,view):]
            until(lambda:child.poll() is not None);pump()
            assert child.returncode==0 and b'TOOL_ONLY_ACK:transport-control' in raw
        else:
            os.killpg(child.pid,signal.SIGKILL);child.wait(timeout=5);pump()
            assert child.returncode==-signal.SIGKILL
        metadata.update(exit=child.returncode,after_stty=subprocess.check_output(['stty','-g'],stdin=slave).decode().strip())
        assert metadata['after_stty']==before
        assert metadata['winsize']==[6,40,0,0]
        metadata['result']='TOOL_ONLY_PASS'
    except BaseException as error:
        metadata.update(result='TOOL_ONLY_FAIL',error=repr(error));raise
    finally:
        if child.poll() is None:os.killpg(child.pid,signal.SIGKILL);child.wait(timeout=5)
        (output/'input.raw').write_bytes(sent);(output/'output.raw').write_bytes(raw);(output/'metadata.json').write_text(json.dumps(metadata,indent=2)+'\n')
        os.close(master);os.close(slave)
        for fd in [master,slave]:
            try:os.fstat(fd)
            except OSError as error:assert error.errno==errno.EBADF
            else:raise AssertionError('tool-only FD leak')
    print('TOOL_ONLY_TRANSPORT_PASS',mode)

control('normal');control('forced-termination')
