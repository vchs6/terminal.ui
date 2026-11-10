#!/usr/bin/python3
"""Native XFCE Save Contents experiment on a new, private Xorg and D-Bus."""
import datetime, hashlib, json, os, pathlib, re, shlex, shutil, subprocess as s, tempfile, time
from xtest import Keyboard

B=pathlib.Path(__file__).resolve().parent.parent
R=B/'raw'/os.environ.get('VTE_RECON_RUN','attempt1'); R.mkdir(exist_ok=False)
mode=os.environ.get('VTE_RECON_MODE','save')
def utc():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def write(name,v):(R/name).write_text(json.dumps(v,ensure_ascii=False,indent=2))
def run(argv,check=True):
    out=s.run(argv,env=e,stdout=s.PIPE,stderr=s.STDOUT,text=True)
    if check and out.returncode:raise RuntimeError(out.stdout)
    return out.stdout
def wait(fn,seconds=15):
    deadline=time.monotonic()+seconds
    while time.monotonic()<deadline:
        value=fn()
        if value:return value
        time.sleep(.05)
    raise RuntimeError('timeout waiting for private fixture')

home=pathlib.Path(tempfile.mkdtemp(prefix='vte-grid-'))
runtime=home/'runtime';runtime.mkdir(mode=0o700)
cfg=home/'config/xfce4/terminal';cfg.mkdir(parents=True)
(cfg/'accels.scm').write_text('(gtk_accel_path "<Actions>/terminal-window/save-contents" "F6")\n')
(cfg/'terminalrc').write_text('[Configuration]\nFontName=DejaVu Sans Mono 12\nMiscAlwaysShowTabs=FALSE\nMiscMenubarDefault=TRUE\nMiscToolbarDefault=FALSE\n')
for source in ['accels.scm','terminalrc']:shutil.copyfile(cfg/source,R/source)
e=os.environ.copy()
for key in ['DISPLAY','XAUTHORITY','DBUS_SESSION_BUS_ADDRESS','SESSION_MANAGER','GTK_MODULES']:e.pop(key,None)
e.update({'HOME':str(home),'XDG_CONFIG_HOME':str(home/'config'),'XDG_CACHE_HOME':str(home/'cache'),
          'XDG_RUNTIME_DIR':str(runtime),'LC_ALL':'C.UTF-8','LANG':'C.UTF-8','NO_AT_BRIDGE':'1'})
module_meta={}
if mode=='module':
    module=home/'native-module.so'
    compile_argv=['gcc','-Wall','-Wextra','-Werror','-Wno-misleading-indentation','-fPIC','-shared',str(B/'scripts/native-module.c'),'-o',str(module),'-ldl']
    compile_result=s.run(compile_argv,stdout=s.PIPE,stderr=s.STDOUT,text=True)
    (R/'compile.log').write_text(compile_result.stdout);assert compile_result.returncode==0
    module_meta={'compileArgv':compile_argv,'compileExitCode':compile_result.returncode,'moduleSha256':hashlib.sha256(module.read_bytes()).hexdigest(),'sourceSha256':hashlib.sha256((B/'scripts/native-module.c').read_bytes()).hexdigest()}
    e.update({'GTK_MODULES':str(module),'VTE_NATIVE_CAPTURE_DIR':str(R)})
for source in (B/'scripts').glob('*'):
    if source.is_file():shutil.copyfile(source,R/('source-'+source.name))
shutil.copyfile('/workspace/work/session-extension-recon/probes/xorg-dummy.conf',R/'xorg-dummy.conf')
readfd,writefd=os.pipe()
number=next(n for n in range(181,201) if not os.path.lexists('/tmp/.X11-unix/X%d'%n) and not os.path.lexists('/tmp/.X%d-lock'%n))
xargv=['Xorg',':%d'%number,'-displayfd',str(writefd),'-config',str(R/'xorg-dummy.conf'),'-nolisten','tcp','-noreset','-logfile',str(R/'xorg.log')]
xp=s.Popen(xargv,env=e,pass_fds=(writefd,),stdout=(R/'xorg.stdout').open('wb'),stderr=s.STDOUT)
os.close(writefd);hp=None;start=utc();status={'utcStart':start,'xorgPid':xp.pid,'xorgArgv':xargv,'privateHome':str(home),'mode':mode,'nativeModule':module_meta}
try:
    import select
    assert select.select([readfd],[],[],15)[0],'Xorg display allocation timed out'
    display=':'+os.read(readfd,32).decode().strip();os.close(readfd)
    assert re.fullmatch(r':\d+',display),display
    e['DISPLAY']=display;os.environ['DISPLAY']=display
    status['display']=display
    wait(lambda:run(['xdpyinfo'],False).startswith('name of display:'))
    (R/'xdpyinfo.txt').write_text(run(['xdpyinfo']))
    rec=['script','--quiet','--flush','--return','--log-out',str(R/'outer-ansi.bin'),'--command',shlex.join(['/usr/bin/python3',str(B/'scripts/scene.py'),str(R)])]
    argv=['dbus-run-session','--','xfce4-terminal','--disable-server','--geometry=100x28+20+20','--initial-title=VTE_NATIVE_GRID_OWNED','--dynamic-title-mode=replace','--command='+shlex.join(rec)]
    status.update({'hostArgv':argv,'env':{key:e[key] for key in ['DISPLAY','HOME','XDG_CONFIG_HOME','XDG_CACHE_HOME','XDG_RUNTIME_DIR','LC_ALL','NO_AT_BRIDGE','GTK_MODULES','VTE_NATIVE_CAPTURE_DIR'] if key in e}})
    write('launch.json',status)
    hp=s.Popen(argv,env=e,cwd=home,start_new_session=True,stdout=(R/'host.stdout').open('wb'),stderr=(R/'host.stderr').open('wb'))
    wait(lambda:(R/'child.json').exists())
    tree=run(['xwininfo','-root','-tree']);(R/'initial-tree.txt').write_text(tree)
    win=re.search(r'(0x[0-9a-f]+) "VTE_NATIVE_GRID_OWNED"',tree).group(1)
    status['windowId']=win
    (R/'initial-window.txt').write_text(run(['xwininfo','-id',win,'-all']))
    (R/'initial-xprop.txt').write_text(run(['xprop','-id',win,'_NET_WM_PID','WM_NAME','_NET_WM_NAME','WM_CLASS']))
    pid=int(re.search(r'= (\d+)',run(['xprop','-id',win,'_NET_WM_PID'])).group(1))
    status['terminalPid']=pid
    (R/'terminal-maps.txt').write_text(pathlib.Path('/proc/%d/maps'%pid).read_text())
    k=Keyboard();phases=[]
    for index,name in enumerate(['normal','alternate','restored','scrollback']):
        write('command-%d.json'%index,{'phase':name,'utc':utc()})
        wait(lambda:(R/('ack-%d.json'%index)).exists());time.sleep(.3)
        stamp=utc();png=R/(name+'.png')
        capture=['import','-window',win,str(png)];run(capture)
        (R/(name+'-window.txt')).write_text(run(['xwininfo','-id',win,'-all']))
        if mode in ['module','baseline']:
            props_before=run(['xprop','-id',win,'WM_NAME','_NET_WM_NAME','_NET_WM_ICON'])
            owner_before=k.clipboard_owner()
            if mode=='module':
                (R/'native-request').write_text(str(index))
                wait(lambda:(R/('native-%d-meta.json'%index)).exists())
            run(['import','-window',win,str(R/(name+'-after-read.png'))])
            props_after=run(['xprop','-id',win,'WM_NAME','_NET_WM_NAME','_NET_WM_ICON'])
            (R/(name+'-xprop-before.txt')).write_text(props_before)
            (R/(name+'-xprop-after.txt')).write_text(props_after)
            phases.append({'phase':name,'utc':stamp,'windowId':win,'source':'actual VteTerminal native API' if mode=='module' else 'uninstrumented baseline',
                           'nativeMeta':'native-%d-meta.json'%index if mode=='module' else None,
                           'captureCommand':shlex.join(capture),'png':name+'.png','pngSha256':hashlib.sha256(png.read_bytes()).hexdigest(),
                           'pngUnchangedAcrossRead':png.read_bytes()==(R/(name+'-after-read.png')).read_bytes(),'propertiesUnchangedAcrossRead':props_before==props_after,
                           'privateClipboardOwnerBefore':owner_before,'privateClipboardOwnerAfter':k.clipboard_owner(),'clipboardContentRead':False})
            continue
        k.focus(win);k.chord('F6');time.sleep(.25)
        dialogtree=run(['xwininfo','-root','-tree']);(R/(name+'-dialog-tree.txt')).write_text(dialogtree)
        dialog=re.search(r'(0x[0-9a-f]+) "Save contents\.\.\."',dialogtree)
        if not dialog:
            run(['import','-window','root',str(R/(name+'-save-failure.png'))]);raise RuntimeError('native Save contents dialog not found')
        k.focus(dialog.group(1));k.chord('Alt_L','n');k.chord('Control_L','a')
        # Relative basename in private HOME, then move the actual native export unchanged.
        filename='native-'+name+'.txt';k.text(filename)
        geom=run(['xwininfo','-id',dialog.group(1)])
        (R/(name+'-dialog-window.txt')).write_text(geom)
        def field(label):return int(re.search(label+r':\s*(-?\d+)',geom).group(1))
        k.click(field('Absolute upper-left X')+field('Width')-50,field('Absolute upper-left Y')+field('Height')-24)
        try:wait(lambda:(home/filename).exists())
        except RuntimeError:
            run(['import','-window','root',str(R/(name+'-post-save-failure.png'))])
            (R/(name+'-post-save-tree.txt')).write_text(run(['xwininfo','-root','-tree']))
            raise
        shutil.copyfile(home/filename,R/(name+'-native.txt'))
        phases.append({'phase':name,'utc':stamp,'windowId':win,'nativeExport':name+'-native.txt',
                       'source':'XFCE Terminal Save contents action -> vte_terminal_write_contents_sync',
                       'captureCommand':shlex.join(capture),'png':name+'.png','pngSha256':hashlib.sha256(png.read_bytes()).hexdigest()})
    write('phases.json',phases)
    write('exit-command.json',{'utc':utc()})
    status['hostExitCode']=hp.wait(timeout=12)
    status['childExit']=json.loads((R/'exit.json').read_text())
except BaseException as error:
    status['error']=repr(error)
    raise
finally:
    if hp and hp.poll() is None:
        # Terminate only this fixture's freshly created process group.
        import signal
        os.killpg(hp.pid,signal.SIGTERM)
        try:hp.wait(timeout=5)
        except s.TimeoutExpired:os.killpg(hp.pid,signal.SIGKILL);hp.wait(timeout=5)
    if xp.poll() is None:xp.terminate()
    status['xorgExitCode']=xp.wait(timeout=5)
    status['utcEnd']=utc();status['privateHomeRemoved']=False
    effective=home/'config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml'
    if effective.exists():shutil.copyfile(effective,R/'effective-xfconf.xml')
    shutil.rmtree(home);status['privateHomeRemoved']=not home.exists()
    status['displaySocketRemoved']=not pathlib.Path('/tmp/.X11-unix/X'+status.get('display',':?')[1:]).exists()
    write('status.json',status)
