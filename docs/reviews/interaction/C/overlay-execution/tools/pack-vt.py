"""After GO only: stream retained B host closure, replacing all product apps.
No SDK copy and no VM disk; records every output member and exact source hash.
"""
import argparse,gzip,hashlib,json,pathlib
def pack(binary,dest,supervisor):
    base=pathlib.Path('/workspace/work/viewport-execution/packages/vt-viewport.cpio.gz');tools=pathlib.Path(__file__).parent
    replacement={'init':tools/'vt-init.sh','vt-product-supervisor':supervisor,'apps/overlay-c':binary};records=[];seen=set()
    assert not dest.exists()
    with gzip.open(base,'rb') as inp,gzip.GzipFile(filename=str(dest),mode='wb',mtime=0) as out:
        def emit(name,mode,data):
            nb=name.encode()+b'\0';fields=[len(records)+1,mode,0,0,1,0,len(data),0,0,0,0,len(nb),0];blob=b'070701'+b''.join(f'{x:08x}'.encode() for x in fields)+nb;blob+=b'\0'*(-len(blob)%4);blob+=data;blob+=b'\0'*(-len(data)%4);out.write(blob);records.append(dict(guest=name,bytes=len(data),sha256=hashlib.sha256(data).hexdigest()))
        while True:
            header=inp.read(110);assert header[:6]==b'070701';f=[int(header[6+i*8:14+i*8],16) for i in range(13)];size,nsize=f[6],f[11];name=inp.read(nsize)[:-1].decode();inp.read(-(110+nsize)%4);data=inp.read(size);inp.read(-size%4)
            if name=='TRAILER!!!':break
            if name.startswith('apps/') and name!='apps/overlay-c':continue
            mode=f[1]
            if name in replacement:data=replacement[name].read_bytes();mode=0o100755;seen.add(name)
            emit(name,mode,data)
        for name,path in replacement.items():
            if name not in seen:emit(name,0o100755,path.read_bytes())
        emit('TRAILER!!!',0,b'')
    dest.with_suffix('.members.json').write_text(json.dumps(dict(base=str(base),base_sha256=hashlib.sha256(base.read_bytes()).hexdigest(),archive_sha256=hashlib.sha256(dest.read_bytes()).hexdigest(),members=records),indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--go',type=pathlib.Path,required=True);p.add_argument('--binary',type=pathlib.Path,required=True);p.add_argument('--supervisor',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert a.go.is_file();pack(a.binary.resolve(),a.output.resolve(),a.supervisor.resolve())
