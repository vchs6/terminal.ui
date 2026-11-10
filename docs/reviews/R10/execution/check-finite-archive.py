import json,pathlib,sys,tarfile
base=pathlib.Path('/workspace/work/auto-final-execution'); a=json.loads((base/'raw/stage-a-archive-audit.log').read_text())
entries=a['entries']; assert len(entries)==62
assert all(x['sha256']==x['source_sha256'] for x in entries), 'source mismatch'
with tarfile.open(base/'stage-a-cjtui-0.0.0.cjp') as tar:
 for m in tar.getmembers():
  assert m.isfile() or m.isdir(), 'special file'
  assert not m.name.startswith('/') and '..' not in pathlib.PurePosixPath(m.name).parts
paths={'/'.join(x['entry'].split('/')[1:]) for x in entries}
for f in ['cjpm.toml','build.cj','native/build.sh','native/cjtui_terminal.c','native/cjtui_capabilities.c','docs/product/README.md','examples/minimal/cjpm.toml','examples/layout/cjpm.toml','examples/colors/cjpm.toml','LICENSE','NOTICE']:
 assert f in paths, f
assert all(not any(p in ['target','node_modules','cache','build-script-cache'] for p in pathlib.PurePosixPath(x).parts) for x in paths)
d=a['declarations']; root=d['cjpm.toml']; assert root['dependencies']=={'ansies':{'version':'1.3.113'},'unicode':{'version':'0.1.0'},'unicodewidth':{'version':'0.1.113'}}
assert root['ffi']['c']=={n:{'path':'./native'} for n in ['unicodedata','cjtui_terminal','cjtui_capabilities']}
for name in ['minimal','layout','colors']:
 assert d['examples/'+name+'/cjpm.toml']['dependencies']=={'cjtui':{'path':'../..'}}
print('PASS finite implemented archive: 62 original source files; expected central dependency tables, 3 native FFI declarations, and internal example paths. Full release checker remains independently failed for missing composition; benchmark is also absent.')
