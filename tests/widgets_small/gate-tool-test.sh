#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
artifacts=${CJTUI_WIDGET_TOOL_ARTIFACTS:-$(mktemp -d /tmp/widgets-small-gate.XXXXXX)}
mkdir -p "$artifacts"

# This is a tool-path negative control, valid only while the fixed base lacks
# Button. The list is never supplied to cjc/cjpm as a declaration or source.
if rg -q '^public func Button\(' "$root/src" -g '*.cj'; then
    printf 'tool negative control requires the preparation base without Button\n' >&2
    exit 64
fi
cat > "$artifacts/synthetic-gate-only.txt" <<'EOF'
# synthetic-gate-only
Canvas
Theme
ThemeRole
VisualStates
Component.enabled
Component.focusable
Component.defaultAction
Component.visualStates
Application.focusedNode
KeyEvent.ctrl
KeyEvent.alt
KeyEvent.shift
EOF

set +e
bash "$here/run.sh" --tool-gate-probe "$artifacts/synthetic-gate-only.txt" \
    > "$artifacts/compiler.stdout" 2> "$artifacts/compiler.stderr"
status=$?
set -e
printf '%s\n' "$status" > "$artifacts/compiler.exit"
if [[ $status -eq 0 || $status -eq 77 ]]; then
    printf 'tool probe did not reach expected compiler failure: exit %s\n' "$status" >&2
    exit 1
fi
rg -q '^TOOL_PROBE_ONLY:' "$artifacts/compiler.stderr"
rg -q '^UPSTREAM_SYMBOL_GATE_PASS:' "$artifacts/compiler.stderr"
rg -q '^TARGET_MISSING_EXPECTED_RED: cjtui.Button' "$artifacts/compiler.stderr"
rg -q "'Button' is not accessible in package 'cjtui'" "$artifacts/compiler.stderr"
rg -q 'failed to compile package .widgets_small_contract.' "$artifacts/compiler.stderr"
printf 'PASS gate-only tool path reached real CJPM compiler; target Button missing; raw=%s\n' "$artifacts"
