from pathlib import Path
import shutil,subprocess,os,re,hashlib,json,gzip,stat
b=Path('/workspace/work/glyph-execution');r=b/'guest-root'
apps={'glyph':b/'host-consumer/target/release/bin/main','session':b/'source/tests/session_extensions/target/release/bin/main'}
manifest=[]
def cp(src,dest):
 target=r/str(dest).lstrip('/');target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,target);manifest.append({'source':str(src),'guest':str(dest),'sha256':hashlib.sha256(target.read_bytes()).hexdigest()})
for name,app in apps.items():
 cp(app,'/apps/'+name)
 out=subprocess.check_output(['ldd',str(app)],text=True)
 for line in out.splitlines():
  m=re.search(r'(?:=> )?(/\S+)',line)
  if m:
   p=Path(m[1]);cp(p,'/lib/x86_64-linux-gnu/'+p.name if '/workspace/' in str(p) else str(p))
(b/'raw/guest-copy-manifest.json').write_text(json.dumps(manifest,indent=2))
# Deployment permissions only: cpio uses uid0; SDK/CJPM outputs are host0700.
for entry in r.rglob('*'):
 if entry.is_symlink():continue
 mode=entry.stat().st_mode & 0o7777
 entry.chmod(mode | (0o055 if entry.is_dir() or mode & 0o100 else 0o044))
(r/'tmp').chmod(0o1777)

out=bytearray();ino=0;inventory=[]
for p in sorted(r.rglob('*'))+[None]:
 ino+=1
 if p is None:name='TRAILER!!!';mode=0;data=b''
 else:
  name=str(p.relative_to(r));ss=p.lstat();mode=ss.st_mode;data=os.readlink(p).encode() if p.is_symlink() else (p.read_bytes() if p.is_file() else b'')
  inventory.append({'guest':name,'mode':oct(mode),'size':len(data),'sha256':hashlib.sha256(data).hexdigest()})
 nb=name.encode()+b'\0';fields=[ino,mode,0,0,1,0,len(data),0,0,0,0,len(nb),0]
 out+=b'070701'+b''.join(f'{x:08x}'.encode() for x in fields)+nb;out+=b'\0'*(-len(out)%4);out+=data;out+=b'\0'*(-len(out)%4)
(b/'packages').mkdir(exist_ok=True)
with open(b/'packages/vt-final-product.cpio.gz','wb') as f:
 with gzip.GzipFile(fileobj=f,mode='wb',mtime=0) as g:g.write(out)
(b/'raw/guest-file-manifest.json').write_text(json.dumps(inventory,indent=2));print('pack bytes',len(out),'compressed', (b/'packages/vt-final-product.cpio.gz').stat().st_size)
