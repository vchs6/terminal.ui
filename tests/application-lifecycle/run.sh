#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
# SDK 1.2.0 cjc forwards this consumer's --wrap to the native linker.
# Native archives are test-local and are never patched into product sources/cache.
gcc -std=c11 -Wall -Wextra -Werror -fPIC -O2 -c tests/application-lifecycle/native/close_wrap.c -o tests/application-lifecycle/native/close_wrap.o
ar rcs tests/application-lifecycle/native/liblifecycle_close.a tests/application-lifecycle/native/close_wrap.o
(cd tests/application-lifecycle && cjpm build)
node tests/application-lifecycle/pty.mjs tests/application-lifecycle/target/release/bin/main "$@"
