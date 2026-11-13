from pathlib import Path
import hashlib,json,subprocess,tomllib,datetime
b=Path(__file__).resolve().parent.parent;r=b/'replay';s=b/'source';raw=b/'raw'
h=lambda data:hashlib.sha256(data).hexdigest();git=lambda cwd,*args:subprocess.check_output(['git',*args],cwd=cwd)
j=json.loads((raw/'prehash.json').read_text());build=json.loads((raw/'prehash-build.json').read_text());post={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'inputs_sha256':{},'external_dependencies_sdk_sha256':{}}
assert git(r,'rev-parse','HEAD').decode().strip()==j['fixed_product']
assert git(s,'rev-parse','HEAD').decode().strip()==j['test_base']
for p,w in j['inputs_sha256'].items():
 post['inputs_sha256'][p]=h((r/p).read_bytes())
 if p!='tests/interaction_c/cjpm.lock':assert post['inputs_sha256'][p]==w,p
 if p.endswith('.cj'):assert post['inputs_sha256'][p]==build['inputs_sha256'][p],p
assert tomllib.loads((raw/'prebuild-cjpm.lock').read_text())==tomllib.loads((r/'tests/interaction_c/cjpm.lock').read_text())
for p,w in j['external_dependencies_sdk_sha256'].items():
 post['external_dependencies_sdk_sha256'][p]=h(Path(p).read_bytes());assert post['external_dependencies_sdk_sha256'][p]==w,p
tracked=set(git(r,'ls-tree','-r','--name-only',j['fixed_product']).decode().splitlines());product=[p for p in j['inputs_sha256'] if not p.startswith('tests/') and p in tracked]
for p in product:assert h(git(r,'show',j['fixed_product']+':'+p))==j['inputs_sha256'][p],p
new=['tests/interaction_c/src/native_caret_fixture.cj','tests/interaction_c/native_caret_pty.py'];tests=git(s,'ls-files','tests/interaction_c','tests/interaction_b').decode().splitlines()+new
for p in tests:assert (s/p).read_bytes()==(r/p).read_bytes(),p
oldpaths=git(s,'ls-tree','-r','--name-only',j['test_base'],'tests/interaction_c','tests/interaction_b').decode().splitlines()
for p in oldpaths:
 baseline=git(s,'show',j['test_base']+':'+p);current=(s/p).read_bytes()
 if p=='tests/interaction_c/README.md':assert current.startswith(baseline)
 elif p=='tests/interaction_c/src/main.cj':assert current.decode().replace('    if(getVariable("CJTUI_OVERLAY_NATIVE_CARET").isSome()){return nativeCaretOverlayFixture()}\n','',1).encode()==baseline
 else:assert current==baseline,p
meta=json.loads((raw/'controlled-visible-final/metadata.json').read_text());binary=r/'tests/interaction_c/target/release/bin/main';current=h(binary.read_bytes());pre=json.loads((raw/'binary-pre.json').read_text());assert pre['sha256']==meta['binary_pre_sha256']==meta['binary_post_sha256']==current
assert meta['product_exit']==0 and meta.get('forced') is None and meta['before_termios']==meta['after_termios'] and meta['result']=='PASS'
assert set(meta['states'])=={'base','covered','restored'}
for stage,state in meta['states'].items():assert state['cursorStatus']==state['savedCursorStatus']=='original-visible'
assert int((raw/'build.exit').read_text())==int((raw/'native-caret-row-fence.exit').read_text())==0
post['binary']={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'path':str(binary),'sha256':current,'size':binary.stat().st_size};post['h01_native_fixture_sha256']=h((s/'tests/interaction_c/src/native_fixture.cj').read_bytes());(raw/'posthash.json').write_text(json.dumps(post,indent=2)+'\n')
subprocess.run(['git','diff','--check'],cwd=s,check=True)
print(f'PASS {len(j["inputs_sha256"])} current repo inputs pre/post; {len(j["external_dependencies_sdk_sha256"])} dependency/SDK files; {len(product)} fixed product tracked inputs')
print(f'PASS {len(tests)} source/replay B/C test files identical; compiled Cj bytes unchanged since normal build; all H01 five-mode source/oracles and prior tests unchanged')
print('PASS actual native run0, logical visible/hidden/restored, actual paint before later query barriers, known mode hide/show/CUP and original-visible restoration wire, exact termios, resource release')
print('PASS real executable hash immediately pre/post native run: '+current)
print('LIMIT controlled plain PTY is not real-host physical cursor/PNG proof; Unknown capability remains unmanaged, no forced25 output permitted')
