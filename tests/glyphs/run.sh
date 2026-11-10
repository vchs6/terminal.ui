#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
mode=${1:-all}
build_consumer() {
  (cd "$root/tests/glyphs/$1" && cjpm build)
  if [[ "$1" != session ]]; then "$root/tests/glyphs/$1/target/release/bin/main"; fi
}
internal() (
  # Real production sources + legal package-local @Test files, never source edits.
  scratch=$(mktemp -d "${TMPDIR:-/tmp}/cjtui-glyph-internal.XXXXXXXX")
  trap 'rm -rf "$scratch"' EXIT
  cp -a "$root/src" "$root/native" "$root/cjpm.toml" "$root/build.cj" "$scratch/"
  if [[ -d "$root/.cjtui-build" ]]; then cp -a "$root/.cjtui-build" "$scratch/"; fi
  if [[ -f "$root/cangjie-repo.toml" ]]; then cp "$root/cangjie-repo.toml" "$scratch/"; fi
  cp "$root/tests/glyphs/internal/"*_test.cj "$scratch/src/"
  (cd "$scratch" && cjpm test --no-color)
)
session() {
  local native="$root/tests/glyphs/session/native"
  gcc -std=c11 -Wall -Wextra -Werror -fPIC -O2 -c "$native/glyph_syscall_wrap.c" -o "$native/glyph_syscall_wrap.o"
  ar rcs "$native/libglyph_syscall_wrap.a" "$native/glyph_syscall_wrap.o"
  build_consumer session
  node "$root/tests/glyphs/pty.mjs"
}
case "$mode" in
  api|public|rich) build_consumer "$mode" ;;
  negative) "$root/tests/glyphs/negative.sh" ;;
  internal) internal ;;
  session) session ;;
  all)
    export CJTUI_GLYPH_FILES=${CJTUI_GLYPH_FILES:-$(mktemp -d "${TMPDIR:-/tmp}/cjtui-glyph-files.XXXXXXXX")}
    build_consumer api
    build_consumer public
    "$root/tests/glyphs/negative.sh"
    internal
    build_consumer rich
    session
    ;;
  *) echo "usage: $0 [api|public|negative|internal|rich|session|all]" >&2; exit 2 ;;
esac
