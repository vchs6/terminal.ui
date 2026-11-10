#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
case "${1:-all}" in
  core)
    (cd tests/runtime && cjpm build)
    TERM=dumb COLORTERM= timeout 45s tests/runtime/target/release/bin/main </dev/null
    ;;
  macros) tests/runtime/macros/run.sh ;;
  session) tests/runtime/session/run.sh ;;
  all)
    "$0" core
    "$0" macros
    "$0" session
    ;;
  *) echo "usage: $0 [core|macros|session|all]" >&2; exit 2 ;;
esac
