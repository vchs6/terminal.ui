import pathlib,os,stat,gzip,shutil,sys
b=pathlib.Path(__file__).resolve().parents[1];r=b/"guest-root"
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
