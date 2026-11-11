from pathlib import Path
import tarfile,hashlib,subprocess,json,shutil
B=Path('/workspace/work/glyph-execution');S=B/'source';A=S/'target/cjtui-0.0.0.cjp';D=B/'clean-extract';D.mkdir(exist_ok=False);members=[]
with tarfile.open(A) as t:
 for m in t.getmembers():
  assert m.isdir() or m.isfile(),m.name
  if not m.isfile():continue
  rel=m.name.split('/',1)[1];raw=t.extractfile(m).read();git=subprocess.check_output(['git','-C',str(S),'show','1f67e27358254e9daef637b5c2f5a93707ee7cef:'+rel]);assert raw==git,rel;members.append({'path':rel,'size':len(raw),'sha256':hashlib.sha256(raw).hexdigest()})
 t.extractall(D,filter='data')
assert len(members)==143,len(members)
product=D/'cjtui-0.0.0';consumer=B/'clean-api';shutil.copytree(S/'tests/glyphs/api/src',consumer/'src')
manifest=(S/'tests/glyphs/api/cjpm.toml').read_text();assert '"../../.."' in manifest
(consumer/'cjpm.toml').write_text(manifest.replace('"../../.."','"'+str(product)+'"'))
shutil.copytree('/workspace/work/validation/replay-dependencies/cache',B/'clean-cache',symlinks=True)
for p in [product,consumer]:(p/'cangjie-repo.toml').write_text('[repository.cache]\npath="/workspace/work/glyph-execution/clean-cache"\n[repository.home]\nregistry="http://127.0.0.1:18973"\n')
(B/'raw/package-members.json').write_text(json.dumps({'archive':str(A),'sha256':hashlib.sha256(A.read_bytes()).hexdigest(),'regularFiles':len(members),'allFixedProductBytesEqual':True,'members':members,'cleanConsumerOnlyManifestPathChange':True},indent=2));print('143 actual CJP regular member bytes equal fixed1f67; prepared clean extraction/API')
