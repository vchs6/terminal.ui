#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/consumer"
# LANGUAGE_ONLY, compile-only static library. No binary execution.
cjpm build
