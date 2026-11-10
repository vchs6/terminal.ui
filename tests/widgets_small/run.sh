#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
source /workspace/work/validation/sdk/cangjie/envsetup.sh
node "$here/oracle.mjs"
if [[ ${1:-} == --oracle ]]; then exit 0; fi

# Only prerequisite APIs gate admission to the compiler. Widget factories are
# the target of TASK-153's RED and must never be a prerequisite here.
upstream=(Canvas Theme ThemeRole VisualStates Component.enabled Component.focusable
    Component.defaultAction Component.visualStates Application.focusedNode
    KeyEvent.ctrl KeyEvent.alt KeyEvent.shift)
gate_only_file=""
if [[ ${1:-} == --tool-gate-probe ]]; then
    gate_only_file=${2:?expected synthetic gate-only list path}
    if [[ ! -f $gate_only_file ]] || [[ $(head -n 1 "$gate_only_file") != '# synthetic-gate-only' ]]; then
        printf 'invalid synthetic gate-only list\n' >&2
        exit 64
    fi
    printf 'TOOL_PROBE_ONLY: synthetic symbol list is not accepted upstream source\n' >&2
elif [[ $# -ne 0 ]]; then
    printf 'usage: %s [--oracle | --tool-gate-probe LIST]\n' "$0" >&2
    exit 64
fi

missing_upstream=()
for symbol in "${upstream[@]}"; do
    if [[ -n $gate_only_file ]]; then
        rg -Fxq "$symbol" "$gate_only_file" || missing_upstream+=("$symbol")
    else
        case "$symbol" in
            Canvas) pattern='^public func Canvas\(' ;;
            Theme|ThemeRole|VisualStates) pattern="^public (class|struct|enum) ${symbol}\\b" ;;
            Component.*) pattern="public func ${symbol#Component.}\\(" ;;
            Application.*) pattern="public func ${symbol#Application.}\\(" ;;
            KeyEvent.*) pattern="${symbol#KeyEvent.}!:" ;;
        esac
        rg -q "$pattern" "$root/src" -g '*.cj' || missing_upstream+=("$symbol")
    fi
done
if ((${#missing_upstream[@]})); then
    printf 'BLOCKED missing upstream prerequisite: %s\n' "${missing_upstream[@]}" >&2
    exit 77
fi
printf 'UPSTREAM_SYMBOL_GATE_PASS: compiler may now diagnose target widgets\n' >&2
for symbol in Label Button Checkbox Radio Progress; do
    if ! rg -q "^public func ${symbol}\\(" "$root/src" -g '*.cj'; then
        printf 'TARGET_MISSING_EXPECTED_RED: cjtui.%s (continuing to CJPM)\n' "$symbol" >&2
    fi
done

cd "$here"
cjpm build
TERM=dumb COLORTERM= timeout 90s "$here/target/release/bin/main" </dev/null
