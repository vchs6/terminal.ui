from pathlib import Path
import gzip,stat,json,hashlib
B=Path('/workspace/work/viewport-execution');source=Path('/workspace/work/glyph-execution/packages/vt-final-product.cpio.gz');dest=B/'packages/vt-viewport.cpio.gz';replacement={'init':(B/'tools/vt-init.sh',0o100755),'vt-product-supervisor':(B/'tools/vt-supervisor',0o100755),'apps/viewport-b':(B/'product/tests/interaction_b/target/release/bin/main',0o100755)};records=[];seen=set();offset=0
with gzip.open(source,'rb') as f,gzip.GzipFile(filename=str(dest),mode='wb',mtime=0) as out:
 def emit(name,mode,data):
  global offset
  nb=name.encode()+b'\0';fields=[len(records)+1,mode,0,0,1,0,len(data),0,0,0,0,len(nb),0];blob=b'070701'+b''.join(f'{x:08x}'.encode() for x in fields)+nb;blob+=b'\0'*(-len(blob)%4);blob+=data;blob+=b'\0'*(-len(data)%4);out.write(blob);records.append({'guest':name,'mode':oct(mode),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()})
 while True:
  header=f.read(110);assert header[:6]==b'070701';fields=[int(header[6+i*8:14+i*8],16) for i in range(13)];size,namesize=fields[6],fields[11];name=f.read(namesize)[:-1].decode();f.read(-(110+namesize)%4);data=f.read(size);f.read(-size%4)
  if name=='TRAILER!!!':break
  if name in ['apps/glyph','apps/session']:continue
  if name in replacement:p,mode=replacement[name];data=p.read_bytes();seen.add(name)
  else:mode=fields[1]
  emit(name,mode,data)
 for name,(p,mode) in replacement.items():
  if name not in seen:emit(name,mode,p.read_bytes())
 emit('TRAILER!!!',0,b'')
(B/'raw/staging/vt-initrd-members.json').write_text(json.dumps({'baseline_host_closure':str(source),'baseline_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'archive_sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'members':records},indent=2)+'\n');print('Packed current product in existing independent kernel closure',dest.stat().st_size)
