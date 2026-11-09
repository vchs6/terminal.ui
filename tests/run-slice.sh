#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# The caller selects/sources SDK 1.2.0 and may configure an isolated CJPM cache.
cjc --version
cjpm --version
case "${1:-all}" in
  native-smoke) (cd tests/native-smoke && cjpm run) ;;
  contract) (cd tests/contract && cjpm run) ;;
  integration)
    (cd tests/integration/fixture && cjpm build)
    node tests/integration/pty.mjs "${SLICE_SESSION_BIN:-tests/integration/fixture/target/release/bin/main}"
    ;;
  all)
    "$0" native-smoke
    "$0" contract
    "$0" integration
    ;;
  *) echo "usage: $0 [native-smoke|contract|integration|all]" >&2; exit 2 ;;
esac
