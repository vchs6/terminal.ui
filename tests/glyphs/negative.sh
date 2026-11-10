#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
scratch=$(mktemp -d "${TMPDIR:-/tmp}/glyph-readonly.XXXXXXXX")
trap 'rm -rf "$scratch"' EXIT
cjpm init --name glyph_readonly --path "$scratch" --type=executable
cat >> "$scratch/cjpm.toml" <<EOF_MANIFEST
cjtui = { path = "$root" }
EOF_MANIFEST
if [[ -f "$root/cangjie-repo.toml" ]]; then cp "$root/cangjie-repo.toml" "$scratch/"; fi
cp "$root/tests/glyphs/negative/write_capabilities.cj.txt" "$scratch/src/main.cj"
if (cd "$scratch" && cjpm build > compile.txt 2>&1); then
  cat "$scratch/compile.txt"; echo 'FAIL capabilities fields were writable' >&2; exit 1
fi
cat "$scratch/compile.txt"
if rg -q "undeclared.*TerminalGlyphCapabilities|no such package|failed to (resolve|download)" "$scratch/compile.txt"; then
  echo 'FAIL negative consumer blocked before immutability check' >&2; exit 1
fi
rg -q 'immutable|reassign|constant|cannot.*assign|left.*assign' "$scratch/compile.txt"
echo 'PASS public capabilities snapshot is immutable'
