#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
case "${1:-prepare-check}" in
    prepare-check)
        bash -n "$here/run.sh"
        python "$here/prepare_check.py"
        ;;
    build|run)
        if [[ ${CJTUI_020_ROOT_GO:-} != 1 || ! -f ${CJTUI_020_ADMISSION:-} ]]; then
            echo 'PREPARATION ONLY: actual root GO/fixed admission manifest required' >&2
            exit 2
        fi
        if [[ $1 == build ]]; then
            mkdir -p "$here/native"
            gcc -std=c11 -Wall -Wextra -Werror -O2 -fPIC -c "$here/native/lifecycle_native.c" -o "$here/native/session_fault.o"
            ar rcs "$here/native/libsession_fault.a" "$here/native/session_fault.o"
            cd "$here"
            cjpm build
        else
            shift
            python "$here/driver.py" --binary "${CJTUI_020_BINARY:-$here/target/release/bin/main}" "$@"
        fi
        ;;
    *) echo "usage: $0 {prepare-check|build|run --output DIR [--case ID]}" >&2; exit 2 ;;
esac
