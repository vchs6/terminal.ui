#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
case "${1:-core}" in
  core)
    (cd tests/runtime && cjpm build)
    TERM=dumb COLORTERM= timeout 45s tests/runtime/target/release/bin/main </dev/null
    ;;
  *) echo "usage: $0 [core]" >&2; exit 2 ;;
esac
