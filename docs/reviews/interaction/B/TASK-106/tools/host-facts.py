from pathlib import Path
import ctypes,subprocess as s,json,hashlib,datetime
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();lib=ctypes.CDLL('libvte-2.91.so.0');version=[getattr(lib,'vte_get_'+x+'_version')() for x in ['major','minor','micro']];cmd=['dpkg-query','-W','-f=${Package} ${Version}\n','xfce4-terminal','libvte-2.91-0'];q=s.run(cmd,capture_output=True,text=True);d={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'actual_loaded_vte_version':version,'package_command':{'argv':cmd,'exit':q.returncode,'stdout':q.stdout,'stderr':q.stderr},'binaries':{}}
for value in ['/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm',s.check_output(['which','xfce4-terminal'],text=True).strip(),'/usr/lib/x86_64-linux-gnu/libvte-2.91.so.0','/workspace/work/terminal.ui/docs/reviews/R16/execution/raw/host-xorg-dummy.conf',s.check_output(['fc-match','-f','%{file}','DejaVu Sans Mono'],text=True).strip()]:
 p=Path(value);d['binaries'][str(p)]={'resolved':str(p.resolve()),'sha256':h(p),'bytes':p.stat().st_size}
print(json.dumps(d,indent=2))
