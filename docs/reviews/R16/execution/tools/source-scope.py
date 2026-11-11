from pathlib import Path
import subprocess as s,json,hashlib,datetime
B=Path('/workspace/work/glyph-execution');S=B/'source';review=Path('/workspace/work/glyph-review');data=json.loads((review/'reviewed-hashes.json').read_text());hashes={};checks=[]
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
for line in (review/'artifacts.sha256').read_text().splitlines():
 h,name=line.split(None,1);assert digest(review/name.strip())==h
for scope in ['product_files','contracts','official_tests']:
 for rel,h in data[scope].items():assert digest(S/rel)==h,(scope,rel)
 checks.append({'scope':scope,'files':len(data[scope]),'allBytesMatch095':True})
paths=s.check_output(['git','-C',str(S),'ls-files','src','native','build.cj','cjpm.toml','tests/glyphs','tests/runtime','tests/session_extensions','tests/native-session','tests/glyph_advance'],text=True).splitlines()
for rel in paths:hashes[rel]=digest(S/rel)
assert s.run(['git','-C',str(S),'diff','--exit-code','1f67e27358254e9daef637b5c2f5a93707ee7cef','HEAD','--','src','native','build.cj','cjpm.toml','docs/product','examples'],stdout=s.PIPE).returncode==0
assert (B/'host-consumer/src/main.cj').read_bytes()==(S/'tests/glyphs/session/src/main.cj').read_bytes()
reuse={
 'authority':'AGENTS11.1; independent095 raw evidence and verified fixed source; no author report/progress/selfassessment',
 'product':'1f67e27358254e9daef637b5c2f5a93707ee7cef','executionIntegration':'b3b24f896672336797cec009cfe0cd830a955aa7',
 'sourceChecks':checks,'regressions':[
 {'scope':'Session focused36 public/native/termios cases','evidence':'/workspace/work/glyph-review/reviewed-hashes.json:raw + checks[4]','basis':'095 verified same1f67 source, SDK/dependency/env, fixed native writer and Session state unchanged vs7681999; no product/test edits by096. Fresh actual kernel finite Session combination added here.'},
 {'scope':'runtime lifecycle/bind/cache/macros and12PTY恢复/故障','evidence':'/workspace/work/glyph-review/report.md evidence table + reviewed-hashes.json raw','basis':'same fixed source checked095 with glyph changes in place; no later product change. 096 fresh glyph cache/setter/public/internal and actual GUI/VT cover changed projection context again.'}],
 'reviewArtifactsSha256':digest(review/'artifacts.sha256'),'reviewChecksSha256':digest(review/'evidence-check.json'),
 'noColdRepeat':'No claim to rerun original830/S008 or fullrelease/allLinux. Old verified finite authority retained; relevant final-product host/build/glyph/native/package newly run by096.'}
(B/'raw/source-inventory.json').write_text(json.dumps(hashes,indent=2));(B/'raw/scope-and-reuse.json').write_text(json.dumps(reuse,indent=2));print('fixed product, official24 tests, contracts, same public host business source: bytes verified')
