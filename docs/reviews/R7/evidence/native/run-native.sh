#!/usr/bin/env bash
# Isolated Linux x86_64 proof only. Source SDK1.2.0 envsetup.sh before running.
# Usage: run-native.sh NEW_ABSOLUTE_DIRECTORY UNICODE_CJP UCD_ZIP
set -euo pipefail
probe_work=${1:?}; cjp_input=$(realpath "${2:?}"); ucd_input=$(realpath "${3:?}")
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[[ "$probe_work" = /* && ! -e "$probe_work" ]] || { echo 'Use a new absolute scratch directory' >&2; exit 1; }
mkdir -p "$probe_work/logs" "$probe_work/consumer/src"
{
 cjc --version; cjpm --version; gcc --version | head -1; ar --version | head -1
 uname -srm; node --version
} > "$probe_work/logs/tools.log"
printf '%s  %s\n' d810505f62b43417ce673fb9c811f740503d3df88665307557544eae6d073c4c "$cjp_input" 2066d1909b2ea93916ce092da1c0ee4808ea3ef8407c94b4f14f5b7eb263d28e "$ucd_input" | sha256sum -c > "$probe_work/logs/input-checksums.log"
tar tf "$cjp_input" > "$probe_work/logs/archive-files.txt"
! rg '/build.cj$|/lib/.*\.(a|so)$' "$probe_work/logs/archive-files.txt"
tar xf "$cjp_input" -C "$probe_work"
native_root="$probe_work/unicode-0.1.0"
cp "$script_dir/templates/consumer-main.cj" "$probe_work/consumer/src/main.cj"
cat > "$probe_work/consumer/cjpm.toml" <<'TOML'
[package]
cjc-version = "1.2.0"
name = "native_probe"
version = "0.0.1"
src-dir = "src"
output-type = "executable"
[dependencies]
unicode = { path = "../unicode-0.1.0" }
TOML
if (cd "$probe_work/consumer" && cjpm build --verbose) > "$probe_work/logs/normal-build-clean.log" 2>&1; then
 echo 'Unexpected clean build success' >&2; exit 1
fi
rg 'undefined reference' "$probe_work/logs/normal-build-clean.log" >/dev/null
(cd "$native_root/generator" && cjpm build) > "$probe_work/logs/generator-build.log" 2>&1
mkdir -p "$native_root/unicodedata/UCD" "$native_root/unicodedata/memmap" "$native_root/lib"
unzip -q "$ucd_input" -d "$native_root/unicodedata/UCD"
"$native_root/generator/target/generate" "$native_root/unicodedata/UCD" "$native_root/unicodedata/memmap" > "$probe_work/logs/generator-run.log" 2>&1
(
 set -x
 cd "$native_root/unicodedata/src"
 gcc -fPIC -O2 -I../include -c library.c -o ../../lib/library.o
 gcc -fPIC -c data.S -o ../../lib/data.o
 ar rcs ../../lib/libunicodedata.a ../../lib/library.o ../../lib/data.o
 sha256sum ../memmap/*.bin ../../lib/libunicodedata.a
 nm -g --defined-only ../../lib/libunicodedata.a
) > "$probe_work/logs/native-build.log" 2>&1
# Explicit root-link diagnostic first; this is not a product packaging solution.
node - "$probe_work/consumer/cjpm.toml" "$native_root/lib" <<'JS'
const fs = require('node:fs');
const [manifest, lib] = process.argv.slice(2);
fs.writeFileSync(manifest, fs.readFileSync(manifest, 'utf8').replace('[dependencies]', `link-option = "-L${lib} -lunicodedata"\n[dependencies]`));
JS
(cd "$probe_work/consumer" && cjpm run --build-args="-i" --verbose) > "$probe_work/logs/consumer-native-link.log" 2>&1
# Minimal isolated dependency-manifest repair; official archive remains unmodified.
printf '\n[ffi.c]\nunicodedata = { path = "./lib" }\n' >> "$native_root/cjpm.toml"
node - "$probe_work/consumer/cjpm.toml" <<'JS'
const fs = require('node:fs');
const [manifest] = process.argv.slice(2);
fs.writeFileSync(manifest, fs.readFileSync(manifest, 'utf8').split('\n').filter(line => !line.startsWith('link-option =')).join('\n'));
JS
(cd "$probe_work/consumer" && cjpm run --build-args="-i" --verbose) > "$probe_work/logs/dependency-ffi-transitive.log" 2>&1
node "$script_dir/generate-conformance.mjs" "$native_root/unicodedata/UCD" "$probe_work/conformance" > "$probe_work/logs/generate-conformance.log"
(cd "$probe_work/conformance" && cjpm run --verbose) > "$probe_work/logs/grapheme-conformance.log" 2>&1
printf 'PASS isolated Linux native build, transitive FFI, Unicode17 GraphemeBreakTest; empty input still needs adapter\n'
