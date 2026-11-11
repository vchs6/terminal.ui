from pathlib import Path
import shutil,subprocess
b=Path('/workspace/work/glyph-execution'); old=Path('/workspace/work/linux-vt-product-probe');g=b/'guest-root';g.mkdir(exist_ok=True)
# Reuse only independent host closure. Old apps replaced before packing.
for item in old.joinpath('guest-root').iterdir():
 if item.name in ['apps','evidence','init']:continue
 dest=g/item.name
 if item.is_dir():shutil.copytree(item,dest,symlinks=True,dirs_exist_ok=True)
 elif item.is_symlink():
  if not dest.exists():dest.symlink_to(item.readlink())
 else:shutil.copy2(item,dest)
(g/'apps').mkdir(exist_ok=True);(g/'evidence').mkdir(exist_ok=True)
s=(old/'probes/vt-product-supervisor.c').read_text()
s=s.replace('#include <linux/vt.h>','#include <linux/vt.h>\n#include <sys/stat.h>\n#include <sys/sysmacros.h>')
s=s.replace('struct utsname u;uname(&u);', '''struct stat st;fstat(1,&st);dprintf(logfd,"OBSERVER_ID uid=%u euid=%u stdout_tty=%s mode=%o dev=%u:%u\\n",getuid(),geteuid(),ttyname(1),st.st_mode,major(st.st_rdev),minor(st.st_rdev));
 struct utsname u;uname(&u);''')
s=s.replace('char app[128];snprintf(app,sizeof app,"/apps/%s",argv[1]);execl(','''char app[128];snprintf(app,sizeof app,"/apps/%s",strncmp(argv[1],"session",7)==0?"session":"glyph");
 if(strstr(argv[1],"uid1000")){if(setgid(1000)||setuid(1000)){perror("dropuid");_exit(126);}}
 dprintf(logfd,"PRODUCT_ID uid=%u euid=%u gid=%u stdout=%s scene=%s\\n",getuid(),geteuid(),getgid(),ttyname(1),argv[1]);
 if(strstr(argv[1],"deny")){setenv("VT_EXEC_TARGET",app,1);strcpy(app,"/deny-map");}
 execl(''')
s=s.replace('"trace=read,write,ioctl"','"trace=read,write,ioctl,newfstatat,fstat,openat,execve,prctl"')
(b/'tools/vt-supervisor.c').write_text(s)
subprocess.run(['gcc','-std=c11','-Wall','-Wextra','-Werror','-O2',str(b/'tools/vt-supervisor.c'),'-o',str(g/'vt-product-supervisor')],check=True)
shutil.copy2(old/'probes/font-map.c',b/'tools/font-map.c')
subprocess.run(['gcc','-std=c11','-Wall','-Wextra','-Werror','-O2',str(b/'tools/font-map.c'),'-o',str(g/'font-map')],check=True)
(g/'init').write_text('''#!/bin/sh
export PATH=/bin TERM=linux LD_LIBRARY_PATH=/lib/x86_64-linux-gnu LC_ALL=C.UTF-8
mount -t devtmpfs devtmpfs /dev
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mkdir -p /evidence
/bin/busybox chown 1000:1000 /dev/tty1 /evidence
cat /proc/cmdline >/evidence/boot-cmdline.txt
cat /sys/module/vt/parameters/default_utf8 >/evidence/vt-default-utf8.txt 2>/evidence/vt-default-utf8.err
scene=glyph-root-auto
for arg in $(cat /proc/cmdline); do case "$arg" in scene=*) scene=${arg#scene=};; esac; done
export CJTUI_GLYPH_REPORT=/evidence/profile.txt CJTUI_TERMINAL_EVIDENCE=/evidence
case "$scene" in *unicode*) export CJTUI_GLYPH_MODE=Unicode;; *ascii*) export CJTUI_GLYPH_MODE=Ascii;; esac
case "$scene" in session-wire) export CJTUI_SESSION_CASE=wire;; session-unknown-title) export CJTUI_SESSION_CASE=unknown-title;; esac
export CJTUI_SESSION_ROUTE=Direct CJTUI_SESSION_RESULTS=/evidence/results.tsv CJTUI_SESSION_NATIVE=/evidence/native.log CJTUI_SESSION_WIRE=/evidence/wire.bin CJTUI_SESSION_ALL_WIRE=/evidence/all-wire.bin
setsid sh -c 'exec /font-map </dev/tty1 >/dev/ttyS0 2>&1'
echo FONTMAP_EXIT=$? >/dev/ttyS0
setsid sh -c 'exec /vt-product-supervisor '"$scene"' </dev/tty1 >/dev/tty1 2>&1'
echo INIT_CHILD_EXIT=$? >/dev/ttyS0
echo EVIDENCE_TAR_BASE64_BEGIN >/dev/ttyS0
tar -C /evidence -cf - . | base64 >/dev/ttyS0
echo EVIDENCE_TAR_BASE64_END >/dev/ttyS0
sleep 1
poweroff -f
''');(g/'init').chmod(0o755)
print('Prepared own guest closure/harness; apps not packed yet')
