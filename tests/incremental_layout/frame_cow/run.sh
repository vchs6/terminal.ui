#!/usr/bin/env bash
set -euo pipefail
case "${1:-cow}" in
    baseline|cow) mode="${1:-cow}" ;;
    *) printf 'usage: %s [baseline|cow]\n' "$0" >&2; exit 2 ;;
esac
cd "$(dirname "$0")"
cjpm build
# Resource containment only; no elapsed-time or heap-byte performance threshold.
ulimit -v 16777216
exec target/release/bin/main "$mode"
