#!/usr/bin/env bash
set -uo pipefail
source /workspace/work/frame-execution/environment.sh
base=/workspace/work/frame-execution
cap=$base/capture.sh
cd "$base/repo"
"$cap" full-bundle-check node scripts/check-bundle.mjs target/cjtui-0.0.0.cjp
"$cap" package-audit node "$base/package-audit.mjs"
mkdir -p "$base/unpacked"
"$cap" package-extract tar -xzf target/cjtui-0.0.0.cjp -C "$base/unpacked"
manifest=$(find "$base/unpacked" -maxdepth 2 -name cjpm.toml -print -quit)
product=$(dirname "$manifest")
"$base/prepare-configs.sh" "$product"
cd "$product"
"$cap" unpacked-build cjpm build
"$cap" unpacked-check cjpm check
mkdir -p "$base/public-consumer/tests/composition"
cp -a "$base/repo/tests/composition/src" "$base/public-consumer/tests/composition/"
cp "$base/repo/tests/composition/verify-files.mjs" "$base/repo/tests/composition/run.sh" "$base/repo/tests/composition/cjpm.toml" "$base/public-consumer/tests/composition/"
node --input-type=module - "$base/public-consumer/tests/composition/cjpm.toml" "$product" <<'JS'
import {readFileSync,writeFileSync} from 'node:fs';
const [p,dep]=process.argv.slice(2);const s=readFileSync(p,'utf8');if(!s.includes('path = "../.."'))throw Error('unexpected manifest');writeFileSync(p,s.replace('path = "../.."','path = "'+dep+'"'));
JS
"$base/prepare-configs.sh" "$base/public-consumer"
diff -ru "$base/repo/tests/composition/src" "$base/public-consumer/tests/composition/src" > "$base/raw/public-consumer-source.diff"
diff -u "$base/repo/tests/composition/cjpm.toml" "$base/public-consumer/tests/composition/cjpm.toml" > "$base/raw/public-consumer-manifest.diff"
cmp "$base/repo/tests/composition/verify-files.mjs" "$base/public-consumer/tests/composition/verify-files.mjs"
cmp "$base/repo/tests/composition/run.sh" "$base/public-consumer/tests/composition/run.sh"
cd "$base/public-consumer"
PS4='+previous_exit=$? command: ' "$cap" public-consumer bash -x tests/composition/run.sh
