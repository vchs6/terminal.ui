from pathlib import Path
import hashlib,json,subprocess,datetime
B=Path('/workspace/work/glyph-execution');S=B/'source'
def dig(p):return hashlib.sha256(p.read_bytes()).hexdigest()
inputs={}
for p in (B/'cache/repository/source/default').rglob('*'):
 if p.is_file() and not any(x in p.parts for x in ['target','.git']):inputs[str(p.relative_to(B))]=dig(p)
files=[B/'host-consumer/src/main.cj',B/'host-consumer/cjpm.toml',B/'host-consumer/target/release/bin/main',S/'tests/session_extensions/target/release/bin/main',B/'clean-api/target/release/bin/main',S/'target/cjtui-0.0.0.cjp',B/'packages/vt-final-product.cpio.gz',Path('/workspace/work/linux-console-hosts/packages/linux'),Path('/workspace/work/validation/sdk/cangjie/bin/cjc'),Path('/workspace/work/validation/sdk/cangjie/tools/bin/cjpm'),Path('/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip')]
for p in S.rglob('cangjie-repo.toml'):
 if 'node_modules' not in p.parts and 'target' not in p.parts:files.append(p)
for p in (S/'native').glob('*.a'):files.append(p)
for p in (B/'guest-root/lib/x86_64-linux-gnu').glob('*'):
 if p.is_file():files.append(p)
(B/'raw/fixed-inputs-and-binaries.json').write_text(json.dumps({'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'HEAD':subprocess.check_output(['git','-C',str(S),'rev-parse','HEAD'],text=True).strip(),'product':'1f67e27358254e9daef637b5c2f5a93707ee7cef','base':'7681999e501ca3a6d019648bca34528e6eaa990c','files':{str(p):{'sha256':dig(p),'size':p.stat().st_size} for p in files},'dependencySourceFiles':inputs,'omission':'Listed binaries/runtime/SDK/cache/source trees are input hashes only, not copied into curated artifacts.'},indent=2))
assert subprocess.run(['git','-C',str(S),'diff','--exit-code'],stdout=subprocess.PIPE).returncode==0
print('input hashes',len(files),'dependency file hashes',len(inputs),'tracked product/tests diff empty')
