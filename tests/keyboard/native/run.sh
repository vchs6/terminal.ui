#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
output=${CJTUI_KEYBOARD_NATIVE_ARTIFACTS:-$(mktemp -d)}
mkdir -p "$output"
cc -std=c11 -Wall -Wextra -Werror -O2 "$here/pipe_probe.c" "$root/native/cjtui_terminal.c" -o "$output/pipe-probe"
cc -std=c11 -Wall -Wextra -Werror -O2 -fPIC -shared "$here/pipe_remap.c" -ldl -o "$output/pipe-remap.so"
cc -std=c11 -Wall -Wextra -Werror -O2 -fPIC -shared "$here/write_fault.c" -ldl -o "$output/write-fault.so"
"$output/pipe-probe" positive
"$output/pipe-probe" contract
if [[ "${1:-}" == "--pty" ]]; then
    (cd "$root/tests/keyboard/formal_device" && cjpm build)
    exec python3 "$root/tests/keyboard/formal_pty.py" --binary "$root/tests/keyboard/formal_device/target/release/bin/main" --output "$output/formal" --shim "$output/pipe-remap.so" --fault "$output/write-fault.so"
fi
