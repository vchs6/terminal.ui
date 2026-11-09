#!/usr/bin/env bash
# Isolated language probes only; no framework implementation.
set -euo pipefail
evidence_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
probe_work="${1:?Usage: run-language.sh ABSOLUTE_WORK_DIRECTORY}"
mkdir -p "$probe_work/sources" "$probe_work/bin" "$probe_work/logs"
cp "$evidence_dir"/language/sources/*.cj "$probe_work/sources/"
cjc --version > "$probe_work/logs/toolchain.log"
cjpm --version >> "$probe_work/logs/toolchain.log"
for probe in trailing binding plain_block; do
  cjc "$probe_work/sources/$probe.cj" -o "$probe_work/bin/$probe" > "$probe_work/logs/$probe.compile.log" 2>&1
  "$probe_work/bin/$probe" > "$probe_work/logs/$probe.run.log" 2>&1
  cat "$probe_work/logs/$probe.run.log"
done
for probe in negative mutable_capture_negative; do
  if cjc "$probe_work/sources/$probe.cj" -o "$probe_work/bin/$probe" > "$probe_work/logs/$probe.compile.log" 2>&1; then
    echo "FAIL: $probe unexpectedly compiled" >&2
    exit 1
  fi
  rg "$probe.cj:[0-9]+" "$probe_work/logs/$probe.compile.log" >/dev/null
  printf 'PASS expected compiler rejection with source location: %s\n' "$probe"
done
sha256sum "$probe_work"/sources/*.cj > "$probe_work/logs/source-sha256.txt"
