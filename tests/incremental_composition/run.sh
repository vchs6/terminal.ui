#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
case "${1:-all}" in
  build) cjpm build ;;
  run) exec target/release/bin/main ;;
  all) cjpm build; exec target/release/bin/main ;;
  *) echo "usage: $0 {build|run|all}" >&2; exit 2 ;;
esac
