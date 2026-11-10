#!/usr/bin/env bash
set -euo pipefail
cd /workspace/work/cursor-i015-preflight
set -x
date -u +%Y-%m-%dT%H:%M:%SZ
uname -srmo
gcc --version
getconf GNU_LIBC_VERSION
gcc -std=c11 -Wall -Wextra -Wconversion -Werror -pedantic -fPIC -O2 -c source/monotonic_abi.c -o raw/monotonic_abi.o
gcc -std=c11 -Wall -Wextra -Werror -pedantic source/link_consumer.c raw/monotonic_abi.o -o raw/monotonic-link-only
nm -g raw/monotonic_abi.o
file raw/monotonic-link-only
