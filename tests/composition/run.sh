#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
(cd tests/composition && cjpm build)
timeout 30s tests/composition/target/release/bin/main
