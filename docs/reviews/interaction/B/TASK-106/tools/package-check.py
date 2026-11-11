from pathlib import Path,PurePosixPath
import hashlib,json,subprocess,tarfile
B=Path('/workspace/work/viewport-execution');R=B/'product';O=B/'raw/package';O.mkdir(exist_ok=True);a=R/'target/cjtui-0.0.0.cjp';records=[]
with tarfile.open(a,'r:gz') as t:
 files=[m for m in t.getmembers() if m.isfile()];assert all(m.isfile() or m.isdir() for m in t.getmembers())
 manifests=[m for m in files if len(PurePosixPath(m.name).parts)<=2 and m.name.endswith('cjpm.toml')];assert len(manifests)==1
 prefix=manifests[0].name[:-len('cjpm.toml')]
 for m in files:
  assert m.name.startswith(prefix) and not m.name.startswith('/') and '..' not in PurePosixPath(m.name).parts
  rel=m.name[len(prefix):];data=t.extractfile(m).read();expected=subprocess.check_output(['git','show','HEAD:'+rel],cwd=R);assert data==expected,rel
  assert not any(x in PurePosixPath(rel).parts for x in ['target','node_modules','cache','build-script-cache']);assert not rel.endswith(('.a','.o','.so','.cjo','.cjp'))
  records.append({'member':m.name,'git_path':rel,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'git_bytes_equal':True})
 (O/'member-inventory.json').write_text(json.dumps(records,indent=2)+'\n');(O/'package.json').write_text(json.dumps({'archive_sha256':hashlib.sha256(a.read_bytes()).hexdigest(),'bytes':a.stat().st_size,'members':len(records),'all_git_bytes_equal':True,'git':'62039552a26da295dcd710d7cfc40cb9e43ca5fd'},indent=2)+'\n')
 clean=B/'clean-consumer';(clean/'package').mkdir(parents=True,exist_ok=True);t.extractall(clean/'package',filter='data')
 library=clean/'package'/prefix.rstrip('/');(O/'library-path.txt').write_text(str(library)+'\n')
print('Final620',len(records),'members: all bytes equal fixed git; safe source-only extraction')
