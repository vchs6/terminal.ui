#!/usr/bin/env bash
# Isolated dependency evaluation. Does not alter the product or upstream sources.
set -euo pipefail
evidence_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
probe_work="${1:?Usage: run-dependencies.sh ABSOLUTE_WORK_DIRECTORY}"
[[ "$probe_work" = /* ]] || { echo 'Use an absolute work directory' >&2; exit 1; }
mkdir -p "$probe_work" "$probe_work/logs" "$probe_work/archives" "$probe_work/cache"
cp -R "$evidence_dir/dependency-probes/." "$probe_work/"
{
  cjc --version; cjpm --version; gcc --version | head -1; ar --version | head -1
  node --version; uname -srm
} > "$probe_work/logs/tools.log"
registry_url='https://pkg.cangjie-lang.cn/registry'
# The inherited managed proxy is not handled by this CJPM client. Opt in only there.
if [[ "${USE_CURL_REGISTRY_RELAY:-0}" = 1 ]]; then
  node "$evidence_dir/registry-relay.mjs" > "$probe_work/logs/registry-relay.log" 2>&1 &
  relay_pid=$!
  trap 'kill "$relay_pid" 2>/dev/null || true' EXIT
  registry_url="http://127.0.0.1:${PROBE_RELAY_PORT:-18768}"
  # Readiness is checked, rather than assuming the child started immediately.
  for attempt in {1..100}; do
    if rg 'registry relay ready' "$probe_work/logs/registry-relay.log" >/dev/null; then break; fi
    sleep 0.05
  done
  rg 'registry relay ready' "$probe_work/logs/registry-relay.log" >/dev/null
fi
for probe in ansies unicode unicodewidth; do
  cat > "$probe_work/$probe/cangjie-repo.toml" <<CONFIG
[repository.cache]
path = "$probe_work/cache"
[repository.home]
registry = "$registry_url"
CONFIG
  (cd "$probe_work/$probe" && cjpm update --skip-script) > "$probe_work/logs/$probe-update.log" 2>&1
done
for package in ansies/1.3.113 unicode/0.1.0 unicodewidth/0.1.113 bitarray/0.1.0; do
  curl -fsSL --max-time 60 "https://pkg.cangjie-lang.cn/registry/pkg/$package" -o "$probe_work/archives/${package/\//-}.cjp"
done
cat > "$probe_work/archives/checksums.txt" <<'HASHES'
396ead6ab841eddd12b196fb657848587c4514a435c536146810ee5675344940  ansies-1.3.113.cjp
d810505f62b43417ce673fb9c811f740503d3df88665307557544eae6d073c4c  unicode-0.1.0.cjp
6fa20716cc224c4d774ca83e5a20ebaa1f86b52ac495cff392655dc2b34eea94  unicodewidth-0.1.113.cjp
3c5d7f12e9a1ce68295fb547f0892016911e1cef54218343102a2101ece4d01c  bitarray-0.1.0.cjp
HASHES
(cd "$probe_work/archives" && sha256sum --check checksums.txt) > "$probe_work/logs/package-checksums.log"
for probe in ansies unicodewidth; do
  (cd "$probe_work/$probe" && cjpm run --skip-script) > "$probe_work/logs/$probe-run.log" 2>&1
  cat "$probe_work/logs/$probe-run.log"
done
# Record the unmodified consumer's linkage limitation before the manual native setup.
if (cd "$probe_work/unicode" && cjpm run --skip-script) > "$probe_work/logs/unicode-clean-link.log" 2>&1; then
  echo 'Unicode dependency unexpectedly links cleanly; investigate before reusing this baseline' >&2
  exit 1
fi
rg 'undefined reference' "$probe_work/logs/unicode-clean-link.log" >/dev/null
native_root="$probe_work/cache/repository/source/default/unicode-0.1.0"
(cd "$native_root/generator" && cjpm build --skip-script) > "$probe_work/logs/unicode-generator-build.log" 2>&1
curl -fsSL --max-time 60 'https://www.unicode.org/Public/17.0.0/ucd/UCD.zip' -o "$probe_work/UCD-17.0.0.zip"
printf '%s  %s\n' '2066d1909b2ea93916ce092da1c0ee4808ea3ef8407c94b4f14f5b7eb263d28e' "$probe_work/UCD-17.0.0.zip" | sha256sum --check > "$probe_work/logs/ucd-checksum.log"
mkdir -p "$native_root/unicodedata/UCD" "$native_root/unicodedata/memmap" "$native_root/lib"
unzip -q "$probe_work/UCD-17.0.0.zip" -d "$native_root/unicodedata/UCD"
"$native_root/generator/target/generate" "$native_root/unicodedata/UCD" "$native_root/unicodedata/memmap" > "$probe_work/logs/unicode-generator-run.log" 2>&1
# Same shipped C/ASM inputs as its CMake target. No cmake is installed in this host.
(cd "$native_root/unicodedata/src" && \
 gcc -fPIC -O2 -I../include -c library.c -o ../../lib/library.o && \
 gcc -fPIC -c data.S -o ../../lib/data.o && \
 ar rcs ../../lib/libunicodedata.a ../../lib/library.o ../../lib/data.o) > "$probe_work/logs/unicode-native-build.log" 2>&1
# The consumer must explicitly link the native archive; this is probe-only setup.
node - "$probe_work/unicode/cjpm.toml" "$native_root/lib" <<'JS'
const fs=require('fs');const [manifest,lib]=process.argv.slice(2);
const source=fs.readFileSync(manifest,'utf8');
fs.writeFileSync(manifest,source.replace('[dependencies]',`link-option = "-L${lib} -lunicodedata"\n[dependencies]`));
JS
(cd "$probe_work/unicode" && cjpm run --skip-script) > "$probe_work/logs/unicode-cases.log" 2>&1
cat "$probe_work/logs/unicode-cases.log"
printf '%s\n' 'Dependency probe finished; this is not product integration or terminal validation.'
