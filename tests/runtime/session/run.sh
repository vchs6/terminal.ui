#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
gcc -std=c11 -Wall -Wextra -Werror -fPIC -O2 -c tests/runtime/session/native/close_wrap.c -o tests/runtime/session/native/close_wrap.o
ar rcs tests/runtime/session/native/libruntime_close.a tests/runtime/session/native/close_wrap.o
(cd tests/runtime/session && cjpm build)
node tests/runtime/session/pty.mjs tests/runtime/session/target/release/bin/main "$@"
