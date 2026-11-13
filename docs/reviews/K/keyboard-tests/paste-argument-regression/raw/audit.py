from pathlib import Path
import hashlib,json,subprocess,datetime
b=Path(__file__).resolve().parent.parent;s=b/'source';r=b/'replay';raw=b/'raw';h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();git=lambda cwd,*a:subprocess.check_output(['git',*a],cwd=cwd)
j=json.loads((raw/'prehash.json').read_text());initial=json.loads((raw/'prehash-initial-driver.json').read_text());post={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'inputs_sha256':{},'external_dependencies_sdk_sha256':{}}
assert git(r,'rev-parse','HEAD').decode().strip()==j['fixed_product']
for name,w in j['inputs_sha256'].items():
 post['inputs_sha256'][name]=h(r/name);assert post['inputs_sha256'][name]==w,name
 if name.endswith('.cj'):assert w==initial['inputs_sha256'][name],name
for name,w in j['external_dependencies_sdk_sha256'].items():post['external_dependencies_sdk_sha256'][name]=h(Path(name));assert post['external_dependencies_sdk_sha256'][name]==w,name
tracked=set(git(r,'ls-tree','-r','--name-only',j['fixed_product']).decode().splitlines());product=[name for name in j['inputs_sha256'] if not name.startswith('tests/') and name in tracked]
for name in product:assert hashlib.sha256(git(r,'show',j['fixed_product']+':'+name)).hexdigest()==j['inputs_sha256'][name],name
files=git(s,'ls-files','--cached','--others','--exclude-standard','tests/keyboard/paste_argument').decode().splitlines()
for name in files:assert (s/name).read_bytes()==(r/name).read_bytes(),name
for name in git(s,'ls-tree','-r','--name-only',j['test_base'],'tests/keyboard').decode().splitlines():assert (s/name).read_bytes()==git(s,'show',j['test_base']+':'+name),name
binary=r/'tests/keyboard/paste_argument/target/release/bin/main';binary_hash=h(binary)
for name in ['c1-byte-budget','ctrl-text','paste-native-final']:
 before=json.loads((raw/(name+'.bin-pre.json')).read_text());after=json.loads((raw/(name+'.bin-post.json')).read_text());assert before['sha256']==after['sha256']==binary_hash
 assert int((raw/(name+'.exit')).read_text())==1
 assert b'FAIL K-ARG' in (raw/(name+'.stderr')).read_bytes() if name!='paste-native-final' else b'FAIL K-ARG' in (raw/'native-capture-final/stderr').read_bytes()
meta=json.loads((raw/'native-capture-final/metadata.json').read_text());assert meta['classification']=='actual-native-assertion-RED' and meta['actual_binary_exit']==1 and not meta.get('forced')
assert meta['before_termios']==meta['after_termios'] and meta['binary_pre_sha256']==meta['binary_post_sha256']==binary_hash
assert meta['summary']['pastes']=='1' and meta['summary']['cleanup']=='1' and meta['summary']['released']=='true'
assert int((raw/'build.exit').read_text())==0
assert h(Path('/workspace/work/keyboard-tests/final/raw/handoff-index.json'))=='19fcadf7a86eb479cc72ee733f2c73c8d689ef902616e97694b0b7e761685354'
post.update(binary_sha256=binary_hash,test_files_sha256={name:h(s/name) for name in files},product_inputs=len(product));(raw/'posthash.json').write_text(json.dumps(post,indent=2)+'\n')
subprocess.run(['git','diff','--check'],cwd=s,check=True)
print(f'PASS full actual K API build0 and three independent actual assertion RED1; {len(files)} new public test files identical source/replay')
print(f'PASS {len(j["inputs_sha256"])} current pre/post inputs, {len(product)} fixed-product tracked inputs, {len(j["external_dependencies_sdk_sha256"])} dependency/SDK files unchanged')
print('PASS all compiled Cj bytes unchanged across driver rename; first two valid selector results reused; all prior keyboard tests and immutable113 handoff untouched')
print('PASS real native valid paste entered1; wrong final exception session inactive; no forced exit; cleanup1/resources0 and exact termios restored')
print('BINARY_SHA256 '+binary_hash)
