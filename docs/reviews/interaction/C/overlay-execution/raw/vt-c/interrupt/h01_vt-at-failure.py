"""After GO only: QEMU LinuxVT H01 five scenarios, native cells and PNG.
VM, never physical hardware. Input comes only from QMP or actual SIGINT request.
"""
import argparse,base64,hashlib,io,json,os,pathlib,re,socket,subprocess,tarfile,time
from host_supervisor import utc,publish
from trace_bytes import extract
MODES=['interrupt','prevent','escape','signal','callback-error'];TRACE='Cc;Tc;Tb;Cb;Td;Ca;|0|0'
def one(out,mode,initrd):
    out.mkdir(parents=True,exist_ok=False);host=pathlib.Path('/workspace/work/linux-console-hosts');env=os.environ.copy();env['LD_LIBRARY_PATH']=str(host/'hosts/debian/usr/lib/x86_64-linux-gnu')
    cmd=[str(host/'hosts/debian/usr/bin/qemu-system-x86_64'),'-accel','tcg','-cpu','max','-machine','pc','-m','512','-smp','1','-no-reboot','-nic','none','-L',str(host/'hosts/debian/usr/share/qemu'),'-bios',str(host/'hosts/debian/usr/share/seabios/bios-256k.bin'),'-device','VGA,romfile='+str(host/'hosts/debian/usr/share/seabios/vgabios-stdvga.bin'),'-vga','none','-display','none','-serial','file:'+str(out/'serial.log'),'-chardev','socket,id=probe,path='+str(out/'control.sock')+',server=on,wait=off','-serial','chardev:probe','-qmp','unix:'+str(out/'qmp.sock')+',server=on,wait=off','-kernel',str(host/'packages/linux'),'-initrd',str(initrd),'-append','console=tty0 console=ttyS0,115200 rdinit=/init nomodeset vga=normal loglevel=4 scene='+mode]
    publish(out/'launch.json',dict(argv=cmd,cwd=os.getcwd(),utc=utc(),initrd_sha256=hashlib.sha256(initrd.read_bytes()).hexdigest(),kernel_sha256=hashlib.sha256((host/'packages/linux').read_bytes()).hexdigest(),virtual_hardware=True))
    proc=subprocess.Popen(cmd,env=env,stdout=(out/'qemu.stdout').open('wb'),stderr=(out/'qemu.stderr').open('wb'));q=None;control=None;log=None
    serial=lambda:(out/'serial.log').read_text(errors='replace') if (out/'serial.log').exists() else ''
    def wait(fn,seconds=45,allow_exit=False):
        end=time.monotonic()+seconds
        while time.monotonic()<end:
            value=fn()
            if value:return value
            if proc.poll() is not None and not allow_exit:raise RuntimeError('guest ended before barrier')
            time.sleep(.02)
        raise TimeoutError('VM barrier')
    try:
        wait(lambda:(out/'qmp.sock').exists());q=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);q.settimeout(10);q.connect(str(out/'qmp.sock'));f=q.makefile('rwb',buffering=0);log=(out/'qmp.jsonl').open('w');sequence=0
        def receive():
            d=json.loads(f.readline());log.write(json.dumps(dict(receive=d,utc=utc()))+'\n');log.flush();return d
        def command(name,args=None):
            nonlocal sequence
            sequence+=1;d=dict(execute=name,id=sequence)
            if args:d['arguments']=args
            log.write(json.dumps(dict(send=d,utc=utc()))+'\n');log.flush();f.write((json.dumps(d)+'\n').encode())
            while True:
                result=receive()
                if result.get('id')==sequence:
                    if 'error' in result:raise RuntimeError(result)
                    return result
        receive();command('qmp_capabilities');command('query-version');command('query-kvm');wait(lambda:'PRODUCT_OUTPUT_READY' in serial())
        control=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM);control.connect(str(out/'control.sock'))
        def key(*keys):
            for down,order in [(True,keys),(False,reversed(keys))]:
                for name in order:command('input-send-event',dict(events=[dict(type='key',data=dict(down=down,key=dict(type='qcode',data=name)))]))
            time.sleep(.05)
        def ack(name,value):
            def check():
                control.sendall(b'p');return ('name='+name+' hex='+value.encode().hex()+'\n') in serial()
            return wait(check)
        def capture(name):
            previous=len(re.findall(r'phase=RUNNING path=/dev/vcsa1',serial()))
            control.sendall(b's');wait(lambda:len(re.findall(r'phase=RUNNING path=/dev/vcsa1',serial()))>previous)
            command('screendump',dict(filename=str(out/(name+'.png')),format='png'))
            matches=re.findall(r'GRID seq=(\d+) phase=RUNNING path=/dev/vcsa1 n=(\d+) hex=([0-9a-f]*)',serial());assert matches
            seq,n,data=matches[-1];raw=bytes.fromhex(data);assert raw[:2]==bytes([10,40]) and len(raw)==804
            publish(out/(name+'-native.json'),dict(seq=seq,vcsa_hex=data,cols=40,rows=10,cursor=list(raw[2:4]),note='Native evidence; frozen headless golden remains independent'))
        capture('base');key('m');ack('M','mounted');key('p');ack('P','mounted');key('c');ack('C','mounted');key('x');ack('trace',TRACE);capture('confirmation')
        if mode=='prevent':key('ctrl','c');ack('prevent','active');assert 'PRODUCT_EXIT=' not in serial();capture('prevented');key('q')
        elif mode=='escape':key('esc');ack('C-clean','once');key('s');ack('escape','Escape|true|true');capture('escaped-to-popup');key('q')
        elif mode=='signal':control.sendall(b'i')
        elif mode=='callback-error':key('shift','1')
        else:key('ctrl','c')
        wait(lambda:'EXIT_CAPTURE_BARRIER' in serial());command('screendump',dict(filename=str(out/'restored-session.png'),format='png'));control.sendall(b'e');wait(lambda:'EVIDENCE_TAR_BASE64_END' in serial(),allow_exit=True)
        rc=proc.wait(timeout=15);text=serial();assert rc==0 and 'PRODUCT_EXIT=0 raw_status=0' in text and 'termios_equal=1' in text and 'INIT_CHILD_EXIT=0' in text
        block=text.split('EVIDENCE_TAR_BASE64_BEGIN',1)[1].split('EVIDENCE_TAR_BASE64_END',1)[0];data=base64.b64decode(''.join(block.split()));(out/'guest-evidence.tar').write_bytes(data)
        with tarfile.open(fileobj=io.BytesIO(data)) as archive:archive.extractall(out/'evidence',filter='data')
        for n in ['C','P','M']:assert(out/'evidence'/(n+'-clean')).read_text()=='once'
        assert(out/'evidence/trace').read_text()==TRACE
        trace=(out/'evidence'/(mode+'.strace')).read_text();exec_line=re.search(r'^(\d+)\s+execve\(.*\\x2f\\x61\\x70\\x70\\x73\\x2f\\x6f\\x76\\x65\\x72\\x6c\\x61\\x79\\x2d\\x63',trace,re.M)
        assert exec_line, 'actual executable execve missing';pid=exec_line[1];actual_exit=re.search(r'^'+pid+r'\s+\+\+\+ exited with (\d+) \+\+\+$',trace,re.M);assert actual_exit and int(actual_exit[1])==0
        stdout,outstats=extract(trace);stdin,instats=extract(trace,0,'read');(out/'product-stdout.raw').write_bytes(stdout);(out/'product-stdin.raw').write_bytes(stdin);publish(out/'wire-extraction.json',dict(output=outstats,input=instats))
        assert(out/'evidence/termios-before.bin').read_bytes()==(out/'evidence/termios-after.bin').read_bytes()
        publish(out/'result.json',dict(mode=mode,qemu_exit=rc,tracer_exit=0,actual_product_pid=int(pid),product_exit=int(actual_exit[1]),termios_equal=True,virtual_hardware=True,utc=utc()))
    except BaseException as e:publish(out/'failure.json',dict(error=repr(e),utc=utc()));raise
    finally:
        if control:control.close()
        if q:q.close()
        if log:log.close()
        if proc.poll() is None:proc.terminate();proc.wait(timeout=10)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--go',type=pathlib.Path,required=True);p.add_argument('--initrd',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--mode',choices=MODES);a=p.parse_args();assert a.go.is_file()
    for mode in ([a.mode] if a.mode else MODES):one(a.output.resolve()/mode,mode,a.initrd.resolve())
