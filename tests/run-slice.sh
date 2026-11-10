#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# The caller selects/sources SDK 1.2.0 and may configure an isolated CJPM cache.
cjc --version
cjpm --version
case "${1:-all}" in
  native-session) tests/native-session/run.sh ;;
  native-smoke)
    (cd tests/native-smoke && cjpm build)
    tests/native-smoke/target/release/bin/main
    ;;
  contract)
    (cd tests/contract && cjpm build)
    tests/contract/target/release/bin/main
    ;;
  coordinates)
    (cd tests/coordinate-boundary && cjpm build)
    tests/coordinate-boundary/target/release/bin/main
    ;;
  layout)
    (cd tests/layout && cjpm build)
    timeout 30s tests/layout/target/release/bin/main
    ;;
  integration)
    (cd tests/integration/fixture && cjpm build)
    node tests/integration/pty.mjs "${SLICE_SESSION_BIN:-tests/integration/fixture/target/release/bin/main}"
    ;;
  all)
    "$0" native-session
    "$0" native-smoke
    "$0" contract
    "$0" coordinates
    "$0" integration
    "$0" layout
    ;;
  *) echo "usage: $0 [native-session|native-smoke|contract|coordinates|layout|integration|all]" >&2; exit 2 ;;
esac
