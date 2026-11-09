#!/usr/bin/env bash
set -euxo pipefail
base=/workspace/work/r7-independent-test
repo="$base/repo"
original="$base/native-probe"
probe="$base/retest-native-probe"
evidence=docs/reviews/R7/evidence/native
date -u '+%Y-%m-%dT%H:%M:%SZ'
git -C "$repo" rev-parse HEAD
git -C "$repo" status --porcelain
# Prove unchanged test/native source generation scope before reuse.
git -C "$repo" diff --exit-code 9a5c7034d245a053ff4614c3b7f594689a5b1389 e2c122de616207c9e5166a9c89416233b8b81268 -- "$evidence/run-native.sh" "$evidence/generate-conformance.mjs" "$evidence/templates"
sha256sum "$repo/$evidence/run-native.sh" "$repo/$evidence/run-transitive.sh" "$repo/$evidence/generate-conformance.mjs" "$repo/$evidence/templates/"* /workspace/work/validation/replay-dependencies/archives/unicode-0.1.0.cjp /workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
[[ ! -e "$probe" ]]
mkdir -p "$probe/logs" "$probe/consumer/src"
# Reuse only this independent execution role's unchanged source/native outputs.
cp -a "$original/unicode-0.1.0" "$probe/unicode-0.1.0"
cp "$original/logs/grapheme-conformance.log" "$probe/logs/grapheme-conformance.log"
# Restore run-native completion state; never inherit failed adapter-owned state.
tar -xOf /workspace/work/validation/replay-dependencies/archives/unicode-0.1.0.cjp unicode-0.1.0/cjpm.toml > "$probe/unicode-0.1.0/cjpm.toml"
printf '\n[ffi.c]\nunicodedata = { path = "./lib" }\n' >> "$probe/unicode-0.1.0/cjpm.toml"
cp "$repo/$evidence/templates/consumer-main.cj" "$probe/consumer/src/main.cj"
cat > "$probe/consumer/cjpm.toml" <<'TOML'
[package]
cjc-version = "1.2.0"
name = "native_probe"
version = "0.0.1"
src-dir = "src"
output-type = "executable"
[dependencies]
unicode = { path = "../unicode-0.1.0" }
TOML
cat "$probe/unicode-0.1.0/cjpm.toml" "$probe/consumer/cjpm.toml"
[[ ! -e "$probe/middle" && ! -e "$probe/consumer/target" ]]
sha256sum "$original/unicode-0.1.0/lib/libunicodedata.a" "$probe/unicode-0.1.0/lib/libunicodedata.a"
cmp "$original/unicode-0.1.0/lib/libunicodedata.a" "$probe/unicode-0.1.0/lib/libunicodedata.a"
source /workspace/work/validation/sdk/cangjie/envsetup.sh
cjc --version
cjpm --version
printf 'CANGJIE_HOME=%s\nLD_LIBRARY_PATH=%s\n' "$CANGJIE_HOME" "$LD_LIBRARY_PATH"
set +e
bash -x "$repo/$evidence/run-transitive.sh" "$probe" /workspace/work/validation/replay-dependencies/archives/unicode-0.1.0.cjp > "$base/retest-run-transitive.trace.log" 2>&1
status=$?
set -e
printf 'run_transitive_exit=%s\n' "$status"
date -u '+%Y-%m-%dT%H:%M:%SZ'
exit "$status"
