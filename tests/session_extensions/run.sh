#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../.." && pwd)
wrap=(--wrap=write --wrap=cjt_buffer_write --wrap=cjt_buffer_add --wrap=cjt_open --wrap=cjt_close --wrap=poll)
build_fixture() {
    gcc -std=c11 -Wall -Wextra -Werror -O2 -fPIC -c "$here/native/session_fault.c" -o "$here/native/session_fault.o"
    ar rcs "$here/native/libsession_fault.a" "$here/native/session_fault.o"
}
case "${1:-all}" in
    selftest)
        build_fixture
        args=(); for item in "${wrap[@]}"; do args+=("-Wl,$item"); done
        gcc -std=c11 -Wall -Wextra -Werror -O2 "$here/native/fixture_driver.c" "$root/native/cjtui_terminal.c" "$here/native/session_fault.c" "${args[@]}" -o "$here/native/fixture_driver"
        node "$here/selftest.mjs" "$here/native/fixture_driver"
        ;;
    build)
        build_fixture
        cd "$here"
        cjpm build
        ;;
    headless)
        "$0" build
        node "$here/run.mjs" "$here/target/release/bin/main" headless
        ;;
    all)
        "$0" selftest
        "$0" build
        node "$here/run.mjs" "$here/target/release/bin/main" all
        ;;
    run)
        shift
        node "$here/run.mjs" "${CJTUI_SESSION_BINARY:-$here/target/release/bin/main}" "$@"
        ;;
    host)
        shift
        node "$here/host-oracle.mjs" "$@"
        ;;
    *) echo "usage: $0 {selftest|build|headless|all|run [case]|host <manifest.json>}" >&2; exit 2 ;;
esac
