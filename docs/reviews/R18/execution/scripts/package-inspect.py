import pathlib,tarfile,hashlib,json,subprocess,datetime,shutil
B=pathlib.Path('/workspace/work/session-extension-execution');S=B/'source';archive=S/'target/cjtui-0.0.0.cjp'
H=lambda b:hashlib.sha256(b).hexdigest()
out={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'archive':str(archive),'archiveSha256':H(archive.read_bytes()),'sourceCommit':'83094ca92acab37ed0a38042e2e40ead55049f41','members':[]}
with tarfile.open(archive) as t:
 for m in t.getmembers():
  assert m.isdir() or m.isfile(),m.name
  rel=pathlib.PurePosixPath(m.name);assert not rel.is_absolute() and '..' not in rel.parts
  if not m.isfile():continue
  path=str(pathlib.PurePosixPath(*rel.parts[1:]));data=t.extractfile(m).read()
  fixed=subprocess.check_output(['git','show',out['sourceCommit']+':'+path],cwd=S)
  out['members'].append({'member':m.name,'sourcePath':path,'size':len(data),'sha256':H(data),'fixedBlobSha256':H(fixed),'equal':data==fixed})
 assert all(x['equal'] for x in out['members'])
 dest=B/'clean-extract';dest.mkdir(exist_ok=False);t.extractall(dest,filter='data')
actual={x['sourcePath'] for x in out['members']}
out['trackedSourceOmissions']=[]
for p in subprocess.check_output(['git','ls-tree','-r','--name-only',out['sourceCommit'],'--','src','native','examples','benchmarks','docs/product','third_party/licenses'],cwd=S,text=True).splitlines():
 if p not in actual:out['trackedSourceOmissions'].append({'path':p,'reason':'empty directory placeholder' if p.endswith('/.gitkeep') else 'outside bundle actual source manifest; needs assessment'})
assert all(x['path'].endswith('/.gitkeep') for x in out['trackedSourceOmissions'])
(B/'scope/package-members.json').write_text(json.dumps(out,indent=2))
for folder,label in [(dest/'cjtui-0.0.0','clean-root'),(dest/'cjtui-0.0.0/examples/session','clean-session')]:
 cache=B/('cache-'+label);shutil.copytree('/workspace/work/validation/replay-dependencies/cache',cache)
 (folder/'cangjie-repo.toml').write_text('[repository.cache]\npath = "'+str(cache)+'"\n[repository.home]\nregistry = "http://127.0.0.1:18973"\n')
print(json.dumps({'members':len(out['members']),'equal':True,'omissions':out['trackedSourceOmissions'],'cjpSha256':out['archiveSha256']}))
