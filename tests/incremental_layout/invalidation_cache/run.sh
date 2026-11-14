#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
cjpm build
exec target/release/bin/main
