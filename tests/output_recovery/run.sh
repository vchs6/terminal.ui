#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
case "${1:-all}" in
  build)
    gcc -std=c11 -Wall -Wextra -Werror -O2 -fPIC -c "$here/native/output_fault.c" -o "$here/native/output_fault.o"
    ar rcs "$here/native/liboutput_fault.a" "$here/native/output_fault.o"
    cd "$here"
    cjpm build
    ;;
  run) shift; node "$here/run.mjs" "${CJTUI_RECOVERY_BINARY:-$here/target/release/bin/main}" "$@" ;;
  all) "$0" build; "$0" run ;;
  *) echo "usage: $0 {build|run|all}" >&2; exit 2 ;;
esac
