import ctypes, datetime, hashlib, json, os, pathlib, subprocess, time
B=pathlib.Path('/workspace/work/overlay-execution'); R=B/'environment'; R.mkdir(exist_ok=True)
def now(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def run(name, argv, env=None):
    start=now(); p=subprocess.run(argv,cwd=B,env=env,capture_output=True)
    (R/(name+'.stdout')).write_bytes(p.stdout); (R/(name+'.stderr')).write_bytes(p.stderr)
    (R/(name+'.json')).write_text(json.dumps(dict(argv=argv,cwd=str(B),utcStart=start,utcEnd=now(),exit=p.returncode),indent=2)+'\n')
    return p
env=os.environ.copy()
for k in ['DISPLAY','XAUTHORITY','DBUS_SESSION_BUS_ADDRESS','SESSION_MANAGER','GTK_MODULES','TMUX','STY']: env.pop(k,None)
env.update(DISPLAY=':199',LANG='C.UTF-8',LC_ALL='C.UTF-8')
def launch(name,argv,ee):
    p=subprocess.Popen(argv,cwd=B,env=ee,stdin=subprocess.DEVNULL,stdout=(R/(name+'.stdout')).open('wb'),stderr=(R/(name+'.stderr')).open('wb'),start_new_session=True)
    (R/(name+'.json')).write_text(json.dumps(dict(argv=argv,cwd=str(B),utcStart=now(),pid=p.pid,display=ee.get('DISPLAY'),state='launched; not exited'),indent=2)+'\n')
    return p
assert not os.path.exists('/tmp/.X11-unix/X199'), 'display occupied; do not replace'
xp=launch('xorg',['Xorg',':199','-config','/workspace/work/terminal.ui/docs/reviews/R16/execution/raw/host-xorg-dummy.conf','-nolisten','tcp','-noreset','-logfile',str(R/'Xorg.199.log')],env)
ready=False
for i in range(30):
    p=run('xdpyinfo',['xdpyinfo','-display',':199'],env)
    if p.returncode==0: ready=True; break
    if xp.poll() is not None: break
    time.sleep(.2)
assert ready, 'Xorg did not become ready'
xterm='/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm'
run('xterm-version',[xterm,'-version'],env)
run('xfce-version',['xfce4-terminal','--version'],env)
run('xorg-version',['Xorg','-version'],env)
run('host-packages',['dpkg-query','-W','-f=${Package} ${Version}\n','xfce4-terminal','libvte-2.91-0','xserver-xorg-core','xserver-xorg-video-dummy'],env)
run('kernel-file',['file','/workspace/work/linux-console-hosts/packages/linux'],env)
qe=env.copy(); qe['LD_LIBRARY_PATH']='/workspace/work/linux-console-hosts/hosts/debian/usr/lib/x86_64-linux-gnu'
run('qemu-version',['/workspace/work/linux-console-hosts/hosts/debian/usr/bin/qemu-system-x86_64','--version'],qe)
run('collector-links',['ldd','/workspace/work/viewport-execution/tools/vte-native-fullrows-module.so'],env)
run('disk',['df','-h','/workspace'],env)
lib=ctypes.CDLL('libvte-2.91.so.0'); version=[getattr(lib,'vte_get_'+x+'_version')() for x in ['major','minor','micro']]
(R/'vte-loaded-version.json').write_text(json.dumps(dict(utc=now(),cwd=str(B),method='ctypes.CDLL libvte-2.91.so.0; vte_get_{major,minor,micro}_version',version=version,exit=0),indent=2)+'\n')
shell=['/bin/bash','--noprofile','--norc']
hosts=[launch('xterm-shell',[xterm,'-geometry','80x24+20+20','-T','TASK111 environment only XTerm','-fa','DejaVu Sans Mono','-fs','16','-e',*shell],env),launch('vte-shell',['dbus-run-session','--','xfce4-terminal','--disable-server','--hide-menubar','--geometry=80x24+680+20','--title=TASK111 environment only VTE','--command','/bin/bash --noprofile --norc'],env)]
time.sleep(1)
run('window-tree',['xwininfo','-display',':199','-root','-tree'],env)
run('host-processes',['ps','-eo','pid,ppid,comm,args'],env)
paths=[xterm,'/usr/bin/xfce4-terminal','/usr/lib/x86_64-linux-gnu/libvte-2.91.so.0','/workspace/work/linux-console-hosts/packages/linux','/workspace/work/linux-console-hosts/hosts/debian/usr/bin/qemu-system-x86_64','/workspace/work/linux-console-hosts/hosts/debian/usr/share/seabios/bios-256k.bin','/workspace/work/linux-console-hosts/hosts/debian/usr/share/seabios/vgabios-stdvga.bin','/workspace/work/viewport-execution/tools/vte-native-fullrows-module.so','/workspace/work/viewport-execution/tools/vt-supervisor']
facts={p:dict(resolved=str(pathlib.Path(p).resolve()),bytes=pathlib.Path(p).stat().st_size,sha256=hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()) for p in paths}
(R/'files.json').write_text(json.dumps(facts,indent=2)+'\n')
(R/'process-state.json').write_text(json.dumps(dict(utc=now(),xorgPid=xp.pid,xorgExit=xp.poll(),hostLauncherPids=[p.pid for p in hosts],hostLauncherExit=[p.poll() for p in hosts],note='None means still running, not exit 0. No guest/product/suite executed.'),indent=2)+'\n')
print('Environment preparation collected:', R)
