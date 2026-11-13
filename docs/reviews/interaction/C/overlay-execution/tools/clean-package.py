"""Compare every bundle file with fixed git source; stage clean public consumers."""
import hashlib,json,os,pathlib,re,subprocess,tarfile
B=pathlib.Path('/workspace/work/overlay-execution');P=B/'product';O=B/'raw/package';O.mkdir(parents=True,exist_ok=False);A=P/'target/cjtui-0.0.0.cjp';C=B/'clean-consumer'
sha=lambda data:hashlib.sha256(data).hexdigest()
records=[]
with tarfile.open(A,'r:gz') as archive:
    members=archive.getmembers();assert all(m.isfile() or m.isdir() for m in members)
    manifests=[m for m in members if m.isfile() and len(pathlib.PurePosixPath(m.name).parts)<=2 and m.name.endswith('cjpm.toml')];assert len(manifests)==1
    prefix=manifests[0].name[:-len('cjpm.toml')]
    for member in members:
        assert not member.name.startswith('/') and '..' not in pathlib.PurePosixPath(member.name).parts
        if not member.isfile():continue
        assert member.name.startswith(prefix);rel=member.name[len(prefix):];data=archive.extractfile(member).read();original=subprocess.check_output(['git','show','HEAD:'+rel],cwd=P);assert data==original,rel
        assert not any(x in pathlib.PurePosixPath(rel).parts for x in ['target','node_modules','cache','build-script-cache']);assert not rel.endswith(('.a','.o','.so','.cjo','.cjp'))
        records.append(dict(member=member.name,path=rel,bytes=len(data),sha256=sha(data),fixed_source_equal=True))
    (C/'package').mkdir(parents=True,exist_ok=False);archive.extractall(C/'package',filter='data')
library=C/'package'/prefix.rstrip('/');changes=[];sourcefiles=[]
for group in ['tests/interaction_c','examples/overlay']:
    paths=subprocess.check_output(['git','ls-files',group],cwd=P,text=True).splitlines()
    for rel in paths:
        path=C/rel;path.parent.mkdir(parents=True,exist_ok=True);original=(P/rel).read_bytes();data=original
        if path.name=='cjpm.toml':
            match=re.search(rb'cjtui = \{ path = "([^"]+)" \}',original);assert match
            old=match[1].decode();assert (P/pathlib.Path(rel).parent/old).resolve()==P
            replacement=os.path.relpath(library,path.parent)
            data=original[:match.start(1)]+replacement.encode()+original[match.end(1):];changes.append(dict(path=rel,original_sha256=sha(original),consumer_sha256=sha(data),diff='cjtui dependency path: '+old+' -> '+replacement))
        else:assert data==original
        path.write_bytes(data);path.chmod((P/rel).stat().st_mode & 0o777)
        sourcefiles.append(dict(path=rel,original_sha256=sha(original),consumer_sha256=sha(data),source_equal=data==original,manifest_path_only=(path.name=='cjpm.toml')))
for d in [library,*[x.parent for x in (C/'tests').rglob('cjpm.toml')],C/'examples/overlay']:(d/'cangjie-repo.toml').write_bytes((B/'cangjie-repo.toml').read_bytes())
(O/'member-inventory.json').write_text(json.dumps(records,indent=2)+'\n');(O/'package.json').write_text(json.dumps(dict(path=str(A),sha256=sha(A.read_bytes()),bytes=A.stat().st_size,members=len(records),all_fixed_source_equal=True,source=subprocess.check_output(['git','rev-parse','HEAD'],cwd=P,text=True).strip(),library=str(library)),indent=2)+'\n');(O/'consumer-source-comparison.json').write_text(json.dumps(dict(changes=changes,files=sourcefiles),indent=2)+'\n');print('Every',len(records),'bundle file equals fixed git; complete C consumer/example staged with manifest path only')
