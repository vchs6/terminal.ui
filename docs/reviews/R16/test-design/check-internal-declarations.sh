#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/validation/sdk/cangjie/envsetup.sh
root=/workspace/work/glyph-tests
scratch=/workspace/work/glyph-tests-evidence/declaration-only
mkdir -p "$scratch"
cp -a "$root/src" "$root/native" "$root/.cjtui-build" "$root/build.cj" "$root/cjpm.toml" "$root/cangjie-repo.toml" "$scratch/"
cp "$root/tests/glyphs/internal/"*_test.cj "$scratch/src/"
cat > "$scratch/src/glyph_declaration_only.cj" <<'EOF_STUB'
package cjtui
// Declaration-only compile isolation. Never run. Never part of a test delivery.
class GlyphRenderPolicy {
    static func unicode(): GlyphRenderPolicy { throw Exception("declaration-only") }
    static func ascii(): GlyphRenderPolicy { throw Exception("declaration-only") }
    static func mapped(bitmap: Array<UInt8>): GlyphRenderPolicy { throw Exception("declaration-only") }
}
func projectTerminalGlyph(grapheme: String, width: Int64, policy: GlyphRenderPolicy): String {
    throw Exception("declaration-only")
}
func generatedEllipsis(policy: GlyphRenderPolicy, availableColumns: Int64, ambiguousWide!: Bool = false): String {
    throw Exception("declaration-only")
}
EOF_STUB
node --input-type=module - "$scratch/src/terminal_render_profile.cj" <<'EOF_NODE'
import fs from 'node:fs';
const path = process.argv[2];
fs.writeFileSync(path, fs.readFileSync(path, 'utf8').replace('noColorVideo!: Int64 = -1)',
    'noColorVideo!: Int64 = -1, glyphPolicy!: GlyphRenderPolicy = GlyphRenderPolicy.unicode())'));
EOF_NODE
cd "$scratch"
cjpm test --no-run --no-color
