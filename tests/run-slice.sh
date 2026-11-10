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
  decoration)
    (cd tests/decoration && cjpm build)
    timeout 30s tests/decoration/target/release/bin/main
    ;;
  colors)
    (cd tests/colors && cjpm build)
    timeout 30s tests/colors/target/release/bin/main
    ;;
  colors-integration)
    (cd tests/colors/session && cjpm build)
    (cd examples/colors && cjpm build)
    node tests/colors/pty.mjs
    ;;
  capabilities) tests/capabilities/run.sh ;;
  composition) tests/composition/run.sh ;;
  runtime) tests/runtime/run.sh ;;
  resize-coherence) tests/resize-coherence/run.sh ;;
  layout-integration)
    (cd examples/layout && cjpm build)
    node tests/integration/layout-pty.mjs "${LAYOUT_SESSION_BIN:-examples/layout/target/release/bin/main}"
    ;;
  application-lifecycle) tests/application-lifecycle/run.sh ;;
  integration)
    tests/integration/fixture/build.sh
    node tests/integration/pty.mjs "${SLICE_SESSION_BIN:-tests/integration/fixture/target/release/bin/main}"
    ;;
  all)
    "$0" native-session
    "$0" native-smoke
    "$0" contract
    "$0" coordinates
    "$0" integration
    "$0" layout
    "$0" decoration
    "$0" layout-integration
    "$0" application-lifecycle
    "$0" colors
    "$0" colors-integration
    "$0" capabilities
    "$0" composition
    "$0" runtime
    "$0" resize-coherence
    ;;
  *) echo "usage: $0 [native-session|native-smoke|contract|coordinates|layout|decoration|layout-integration|application-lifecycle|integration|colors|colors-integration|capabilities|composition|runtime|resize-coherence|all]" >&2; exit 2 ;;
esac
