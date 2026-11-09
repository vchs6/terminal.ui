#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
case_dir=$(mktemp -d "${TMPDIR:-/tmp}/cjtui-native-session.XXXXXX")
trap 'rm -rf "$case_dir"' EXIT
# The actual product C is a separate translation unit; no product code is copied.
gcc -std=c11 -Wall -Wextra -Werror -pthread native/cjtui_terminal.c tests/native-session/session.c \
  -Wl,--wrap=isatty -Wl,--wrap=tcgetattr -Wl,--wrap=tcsetattr -Wl,--wrap=poll \
  -o "$case_dir/session"
if [ "$#" -eq 0 ]; then set -- owner setup-signal; fi
failed=0
for scenario in "$@"; do
  if timeout --signal=KILL 10s "$case_dir/session" "$scenario"; then
    :
  else
    result=$?
    echo "FAIL native-session $scenario: exit=$result (timeouts are failures)" >&2
    failed=1
  fi
done
exit "$failed"
