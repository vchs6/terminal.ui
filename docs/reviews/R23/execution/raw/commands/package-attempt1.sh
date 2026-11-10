#!/usr/bin/env bash
set -euo pipefail
base=/workspace/work/glyph-advance-execution
src=$base/source
. /workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
cd "$src"
test "$(cat "$base/raw/05-normal-bundle/exit")" = 0
mkdir "$base/package"
sha256sum target/cjtui-0.0.0.cjp > "$base/package-archive.sha256"
tar -xzf target/cjtui-0.0.0.cjp -C "$base/package"
cp -a /workspace/work/validation/replay-dependencies/cache "$base/clean-cache"
mkdir "$base/packaged-consumer"
cp -a tests/glyph_advance/public/src tests/glyph_advance/public/cjpm.toml "$base/packaged-consumer/"
python3 - <<'PY'
from pathlib import Path
import hashlib,json
b=Path('/workspace/work/glyph-advance-execution');s=b/'source'; p=b/'package/cjtui'
if not p.is_dir():
 candidates=list((b/'package').glob('*/cjpm.toml')); assert len(candidates)==1;p=candidates[0].parent
(b/'package-root.txt').write_text(str(p)+'\n')
config='[repository.cache]\npath = "'+str(b/'clean-cache')+'"\n[repository.home]\nregistry = "http://127.0.0.1:18973"\nversion = 0\n'
for manifest in p.rglob('cjpm.toml'):manifest.with_name('cangjie-repo.toml').write_text(config)
c=b/'packaged-consumer';(c/'cangjie-repo.toml').write_text(config)
m=c/'cjpm.toml';old=m.read_text();new=old.replace('path = "../../.."','path = "'+str(p)+'"'); assert old!=new;m.write_text(new)
rows=[]
for prefix in ['src','native','docs/product','examples/rich-text']:
 for f in sorted((s/prefix).rglob('*')):
  if f.is_file() and not any(x in f.relative_to(s).parts for x in ['target','build-script-cache']) and f.name not in ['cangjie-repo.toml','cjpm.lock']:
   q=p/f.relative_to(s);a=hashlib.sha256(f.read_bytes()).hexdigest();z=hashlib.sha256(q.read_bytes()).hexdigest() if q.is_file() else None
   rows.append({'path':str(f.relative_to(s)),'source_sha256':a,'package_sha256':z,'equal':a==z})
assert all(x['equal'] for x in rows)
for f in (s/'tests/glyph_advance/public/src').rglob('*'):
 if f.is_file(): assert f.read_bytes()==(c/'src'/f.relative_to(s/'tests/glyph_advance/public/src')).read_bytes()
(b/'package-byte-comparison.json').write_text(json.dumps({'status':'PASS','files':rows,'public_consumer_source_exact':True,'consumer_manifest_only_path_changed':True},indent=2)+'\n')
PY
package_root=$(cat "$base/package-root.txt")
cd "$package_root"
"$base/raw/commands/run.sh" 07-packaged-root-build cjpm build
"$base/raw/commands/run.sh" 08-packaged-root-check cjpm check
cd "$base/packaged-consumer"
"$base/raw/commands/run.sh" 09-packaged-public-build cjpm build
mkdir "$base/packaged-consumer-files"
CJTUI_ADVANCE_FILES=$base/packaged-consumer-files "$base/raw/commands/run.sh" 10-packaged-public-direct target/release/bin/main
cd "$package_root/examples/rich-text"
"$base/raw/commands/run.sh" 11-packaged-rich-build cjpm build
"$base/raw/commands/run.sh" 12-packaged-rich-smoke target/release/bin/main --smoke
cd "$src"
set +e
"$base/raw/commands/run.sh" 13-known-whole-boundary node scripts/check-bundle.mjs target/cjtui-0.0.0.cjp
