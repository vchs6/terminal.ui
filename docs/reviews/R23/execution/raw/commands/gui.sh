#!/usr/bin/env bash
set -euo pipefail
base=/workspace/work/glyph-advance-execution
cd "$base/source"
. /workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
export CJTUI_ADVANCE_GUI_KEY=$base/gui-key
package_root=$(cat "$base/package-root.txt")
while test ! -f "$base/raw/12-packaged-rich-smoke/exit"; do sleep .2; done
test "$(cat "$base/raw/12-packaged-rich-smoke/exit")" = 0
test "$(cat "$base/raw/10-packaged-public-direct/exit")" = 0
mkdir "$base/gui"
for scene in rich heart basic8 truecolor; do
 kind=vs16
 unset CJTUI_ADVANCE_COLOR CJTUI_ADVANCE_HOST CJTUI_ADVANCE_FIXTURE_DIR
 if test "$scene" = rich; then
  kind=zwj
  export CJTUI_TERMINAL_EXAMPLE_BIN=$package_root/examples/rich-text/target/release/bin/main
 else
  export CJTUI_ADVANCE_HOST=1
  export CJTUI_ADVANCE_FIXTURE_DIR=$base/packaged-consumer
  export CJTUI_TERMINAL_EXAMPLE_BIN=$base/packaged-consumer/target/release/bin/main
  if test "$scene" != heart; then export CJTUI_ADVANCE_COLOR=$scene; fi
 fi
 export CJTUI_TERMINAL_CAPTURE_DIR=$base/gui/$scene
 "$base/raw/commands/run.sh" "20-$scene-capture" bash tests/glyph_advance/physical/capture.sh xterm-default xfce-vte
 "$base/raw/commands/run.sh" "21-$scene-verify" python3 tests/glyph_advance/physical/verify_capture.py --captures "$base/gui/$scene" --kind "$kind"
 "$base/raw/commands/run.sh" "22-$scene-replay" python3 tests/glyph_advance/physical/replay.py --captures "$base/gui/$scene" --kind "$kind" --out "$base/gui/$scene-dsr"
 "$base/raw/commands/run.sh" "23-$scene-dsr-verify" python3 tests/glyph_advance/physical/verify_replay.py --replay "$base/gui/$scene-dsr" --kind "$kind"
done
