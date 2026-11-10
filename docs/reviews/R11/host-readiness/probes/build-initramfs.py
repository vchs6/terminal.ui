import pathlib,os,stat,gzip,shutil,sys
b=pathlib.Path(__file__).resolve().parents[1];r=b/'guest-root';r.mkdir(exist_ok=True)
for d in ['bin','dev','proc','sys','tmp']: (r/d).mkdir(exist_ok=True)
shutil.copy2(b/'hosts/debian/usr/bin/busybox',r/'bin/busybox')
for n in ['sh','mount','setsid','poweroff','sleep','echo','cat','stty','uname']:
 p=r/'bin'/n
 if not p.exists():p.symlink_to('busybox')
shutil.copy2(b/'probes/vt-probe',r/'vt-probe')
if '--keep-init' not in sys.argv: (r/'init').write_text('''#!/bin/sh
export PATH=/bin TERM=linux
mount -t devtmpfs devtmpfs /dev
mount -t proc proc /proc
mount -t sysfs sysfs /sys
setsid sh -c 'exec /vt-probe </dev/tty1 >/dev/tty1 2>&1'
echo INIT_CHILD_EXIT=$? >/dev/ttyS0
sleep 3
poweroff -f
''');(r/'init').chmod(0o755)
out=bytearray();ino=0
for p in sorted(r.rglob('*'))+[None]:
 ino+=1
 if p is None:name='TRAILER!!!';mode=0;data=b''
 else:
  name=str(p.relative_to(r));s=p.lstat();mode=s.st_mode;data=os.readlink(p).encode() if p.is_symlink() else (p.read_bytes() if p.is_file() else b'')
 nb=name.encode()+b'\0';fields=[ino,mode,0,0,1,0,len(data),0,0,0,0,len(nb),0]
 out+=b'070701'+b''.join(f'{x:08x}'.encode() for x in fields)+nb
 out+=b'\0'*(-len(out)%4);out+=data;out+=b'\0'*(-len(out)%4)
with open(b/'packages/vt-initramfs.cpio.gz','wb') as f:
 with gzip.GzipFile(fileobj=f,mode='wb',mtime=0) as g:g.write(out)
print('initramfs bytes',len(out))
