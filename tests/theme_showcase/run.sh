#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
node tests/theme_showcase/selftest.mjs
node tests/theme_showcase/preset-contract.mjs
node tests/theme_showcase/modal-close-oracle.mjs
node tests/theme_showcase/delivery.mjs
(cd examples/theme_showcase && cjpm build)
node tests/theme_showcase/smoke.mjs
node tests/theme_showcase/pty.mjs
node tests/theme_showcase/modal-keys.mjs
