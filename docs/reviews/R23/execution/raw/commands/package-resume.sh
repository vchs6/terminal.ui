#!/usr/bin/env bash
set -euo pipefail
base=/workspace/work/glyph-advance-execution
src=$base/source
. /workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
package_root=$(cat "$base/package-root.txt")
cd "$package_root"
"$base/raw/commands/run.sh" 07-packaged-root-build cjpm build
"$base/raw/commands/run.sh" 08-packaged-root-check cjpm check
cd "$base/packaged-consumer"
"$base/raw/commands/run.sh" 09-packaged-public-build cjpm build
mkdir "$base/packaged-consumer-files"
CJTUI_ADVANCE_FILES=$base/packaged-consumer-files "$base/raw/commands/run.sh" 10-packaged-public-direct target/release/bin/main
cd "$package_root/examples/rich-text"
"$base/raw/commands/run.sh" 11-packaged-rich-build cjpm build
"$base/raw/commands/run.sh" 12-packaged-rich-smoke target/release/bin/main --smoke
cd "$src"
set +e
"$base/raw/commands/run.sh" 13-known-whole-boundary node scripts/check-bundle.mjs target/cjtui-0.0.0.cjp
