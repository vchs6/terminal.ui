#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
# Caller sources SDK 1.2.0 and selects an isolated CJPM cache/registry if needed.
cjpm build
timeout 60s target/release/bin/main
