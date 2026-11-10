#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
# A rejected write is meaningful only after the complete public glyph API and
# all diagnostic field reads compile through a normal cross-package consumer.
if ! (cd "$root/tests/glyphs/api" && cjpm build); then
  echo 'BLOCKED readonly check: positive glyph API consumer did not compile' >&2
  exit 2
fi
scratch=$(mktemp -d "${TMPDIR:-/tmp}/glyph-readonly.XXXXXXXX")
trap 'rm -rf "$scratch"' EXIT
cjpm init --name glyph_readonly --path "$scratch" --type=executable
cat >> "$scratch/cjpm.toml" <<EOF_MANIFEST
cjtui = { path = "$root" }
EOF_MANIFEST
if [[ -f "$root/cangjie-repo.toml" ]]; then cp "$root/cangjie-repo.toml" "$scratch/"; fi
# Preserve the old combined fixture, then require an independent rejection for
# each field through a mutable local struct copy. Immutable parameters alone
# reject even public var fields and cannot prove the field itself is readonly.
for fixture in "$root/tests/glyphs/negative/"*.cj.txt; do
  name=$(basename "$fixture" .cj.txt)
  cp "$fixture" "$scratch/src/main.cj"
  if (cd "$scratch" && cjpm build > "compile-$name.txt" 2>&1); then
    cat "$scratch/compile-$name.txt"; echo "FAIL writable capability field: $name" >&2; exit 1
  fi
  cat "$scratch/compile-$name.txt"
  if rg -q "undeclared.*TerminalGlyphCapabilities|no such package|failed to (resolve|download)" "$scratch/compile-$name.txt"; then
    echo "FAIL negative consumer blocked before immutability check: $name" >&2; exit 1
  fi
  rg -q 'immutable|reassign|constant|cannot.*assign|left.*assign' "$scratch/compile-$name.txt"
done
echo 'PASS public capabilities snapshot is immutable'
