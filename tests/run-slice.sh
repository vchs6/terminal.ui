#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# The caller selects/sources SDK 1.2.0 and may configure an isolated CJPM cache.
cjc --version
cjpm --version
case "${1:-all}" in
  editing)
    bash tests/editing/run.sh
    for review_case in E120-I01 E120-I02 E120-I03 E120-I04; do
      TERM=dumb COLORTERM= CJTUI_EDITING_REVIEW_CASE="$review_case" timeout 90s tests/editing/target/release/bin/main </dev/null
    done
    ;;
  keyboard)
    tests/keyboard/run.sh --pty
    bash tests/keyboard/paste_argument/run.sh
    bash tests/keyboard/i015_stage/run.sh
    CJTUI_KEYBOARD_I015_PURE_CASE=malformed-drain bash tests/keyboard/i015_stage/run.sh --pure
    CJTUI_KEYBOARD_I015_PURE_CASE=alt-invalid-offset bash tests/keyboard/i015_stage/run.sh --pure
    for case_name in K115-01 K115-02 K115-03 K115-04 K115-R1-01; do
      CJTUI_K115_CASE="$case_name" bash tests/keyboard/review_regressions/run.sh
    done
    CJTUI_K115_CASE=K115-05 CJTUI_K115_ARTIFACTS="${CJTUI_K115_ARTIFACTS:-$(mktemp -d)/native}" bash tests/keyboard/review_regressions/run.sh
    ;;
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
  *) echo "usage: $0 [editing|keyboard|native-session|native-smoke|contract|coordinates|layout|decoration|layout-integration|application-lifecycle|integration|colors|colors-integration|capabilities|composition|runtime|resize-coherence|all]" >&2; exit 2 ;;
esac
