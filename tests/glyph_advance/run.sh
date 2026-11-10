#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
mode=${1:-all}
public() (
  cd "$root/tests/glyph_advance/public"
  cjpm build
  files=$(mktemp -d "${TMPDIR:-/tmp}/cjtui-advance-files.XXXXXXXX")
  trap 'rm -rf "$files"' EXIT
  CJTUI_ADVANCE_FILES="$files" target/release/bin/main
)
internal() (
  subset=${1:-all}
  scratch=$(mktemp -d "${TMPDIR:-/tmp}/cjtui-advance-internal.XXXXXXXX")
  trap 'rm -rf "$scratch"' EXIT
  cp -a "$root/src" "$root/native" "$root/cjpm.toml" "$root/build.cj" "$scratch/"
  if [[ -d "$root/.cjtui-build" ]]; then cp -a "$root/.cjtui-build" "$scratch/"; fi
  if [[ ${CJTUI_ADVANCE_ALL_ERRORS:-0} == 1 ]]; then
    sed -i 's/^  compile-option = ""/  compile-option = "--error-count-limit all"/' "$scratch/cjpm.toml"
  fi
  # Use the caller's own normal CJPM cache/config; never mutate real product sources.
  if [[ -f "$root/cangjie-repo.toml" ]]; then cp "$root/cangjie-repo.toml" "$scratch/"; fi
  if [[ "$subset" == existing ]]; then
    cp "$root/tests/glyph_advance/internal/advance_assert.cj" "$root/tests/glyph_advance/internal/advance_existing_device_test.cj" "$scratch/src/"
  else
    cp "$root/tests/glyph_advance/internal/"*.cj "$scratch/src/"
  fi
  (cd "$scratch" && cjpm test --no-color --timeout-each=10s)
)
case "$mode" in
 public) public;;
 internal) internal;;
 existing-device) internal existing;;
 physical-old) python3 "$root/tests/glyph_advance/physical/oracle.py" --fixtures "$root/tests/glyph_advance/physical/fixtures" --expect preserved;;
 fixture-controls) python3 "$root/tests/glyph_advance/physical/oracle.py" --fixtures "$root/tests/glyph_advance/physical/fixtures" --self-test;;
 all) public; internal; python3 "$root/tests/glyph_advance/physical/oracle.py" --fixtures "$root/tests/glyph_advance/physical/fixtures" --self-test;;
 *) echo "usage: $0 [all|public|internal|existing-device|physical-old|fixture-controls]" >&2; exit 2;;
esac
