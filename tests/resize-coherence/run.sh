#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
gcc -std=c11 -Wall -Wextra -Werror -fPIC -O2 -c tests/resize-coherence/native/gates.c -o tests/resize-coherence/native/gates.o
gcc -std=c11 -Wall -Wextra -Werror -fPIC -O2 -c tests/resize-coherence/native/close_wrap.c -o tests/resize-coherence/native/close_wrap.o
ar rcs tests/resize-coherence/native/libresize_support.a tests/resize-coherence/native/gates.o tests/resize-coherence/native/close_wrap.o
(cd tests/resize-coherence && cjpm build)
if [ "${1:-}" = build ]; then exit 0; fi
node tests/resize-coherence/pty.mjs tests/resize-coherence/target/release/bin/main "$@"
