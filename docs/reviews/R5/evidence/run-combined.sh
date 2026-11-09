#!/usr/bin/env bash
# Joint consumer probe: reuse downloaded packages and existing native archive.
set -euo pipefail
evidence_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
probe_work="${1:?Usage: run-combined.sh ABSOLUTE_WORK_DIRECTORY CACHE_DIRECTORY NATIVE_LIB_DIRECTORY}"
probe_cache="${2:?Existing registry cache directory required}"
probe_native="${3:?Existing directory containing libunicodedata.a required}"
for directory in "$probe_work" "$probe_cache" "$probe_native"; do
  [[ "$directory" = /* ]] || { echo 'Use absolute paths' >&2; exit 1; }
done
test -f "$probe_native/libunicodedata.a"
test -d "$probe_cache/repository/source/default/unicode-0.1.0"
test -d "$probe_cache/repository/source/default/unicodewidth-0.1.113"
mkdir -p "$probe_work" "$probe_work/logs"
cp -R "$evidence_dir/dependency-probes/combined/." "$probe_work/"
# cjpm.lock is copied from CJPM-generated output, not synthesized here.
cat > "$probe_work/cangjie-repo.toml" <<CONFIG
[repository.cache]
path = "$probe_cache"
[repository.home]
registry = "https://pkg.cangjie-lang.cn/registry"
CONFIG
node - "$probe_work/cjpm.toml" "$probe_native" <<'JS'
const fs=require('fs');const [manifest,lib]=process.argv.slice(2);
fs.writeFileSync(manifest,fs.readFileSync(manifest,'utf8').replace('[dependencies]',`link-option = "-L${lib} -lunicodedata"\n[dependencies]`));
JS
{
  cjc --version; cjpm --version
  sha256sum "$probe_native/libunicodedata.a"
} > "$probe_work/logs/combined-environment.log"
(cd "$probe_work" && cjpm run --skip-script) > "$probe_work/logs/combined-run.log" 2>&1
cat "$probe_work/logs/combined-run.log"
