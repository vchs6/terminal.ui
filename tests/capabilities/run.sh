#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p generated-terminfo session/native
tic -x -o generated-terminfo fixture/terminfo.src
gcc -std=c11 -Wall -Wextra -Werror -fPIC -O2 -c session/native/capability_test_native.c -o session/native/capability_test_native.o
ar rcs session/native/libcapability_test_native.a session/native/capability_test_native.o
cjpm build
./target/release/bin/main
(cd session && cjpm build)
node pty.mjs
