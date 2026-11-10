#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../.." && pwd)
source /workspace/work/validation/sdk/cangjie/envsetup.sh
node "$here/oracle.mjs"
if [[ ${1:-} == --oracle ]]; then exit 0; fi

# Preparation gate. A missing prerequisite is an upstream BLOCKED result (77),
# never a product RED and never a substitute implementation inside tests.
missing=()
for symbol in Label Button Checkbox Radio Progress Canvas; do
    if ! rg -q "^public func ${symbol}\\(" "$root/src" -g '*.cj'; then missing+=("cjtui.${symbol}"); fi
done
for symbol in enabled focusable defaultAction visualStates; do
    if ! rg -q "public func ${symbol}\\(" "$root/src" -g '*.cj'; then missing+=("Component.${symbol}"); fi
done
if ! rg -q 'alt!:' "$root/src/key_event.cj"; then missing+=("KeyEvent.alt named constructor field"); fi
if ((${#missing[@]})); then
    printf 'BLOCKED upstream public API: %s\n' "${missing[@]}" >&2
    exit 77
fi

cd "$here"
cjpm build
TERM=dumb COLORTERM= timeout 90s "$here/target/release/bin/main" </dev/null
