#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
node tests/composition/application/delivery.mjs
(cd examples/minimal && cjpm build)
(cd examples/composition && cjpm build)
node tests/composition/application/smoke.mjs
node tests/composition/application/pty.mjs
