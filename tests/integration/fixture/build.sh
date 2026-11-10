#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
gcc -std=c11 -Wall -Wextra -Werror -fPIC -O2 -c tests/integration/fixture/native/close_wrap.c -o tests/integration/fixture/native/close_wrap.o
ar rcs tests/integration/fixture/native/libintegration_close.a tests/integration/fixture/native/close_wrap.o
(cd tests/integration/fixture && cjpm build)
