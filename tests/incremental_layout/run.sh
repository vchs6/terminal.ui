#!/usr/bin/env bash
set -euo pipefail
case "${1:-baseline}" in
    baseline) consumer=baseline ;;
    statistics) consumer=statistics ;;
    *) printf 'usage: %s [baseline|statistics]\n' "$0" >&2; exit 2 ;;
esac
cd "$(dirname "$0")/$consumer"
cjpm build
exec target/release/bin/main
