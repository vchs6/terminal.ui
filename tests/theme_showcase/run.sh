#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
node tests/theme_showcase/selftest.mjs
node tests/theme_showcase/delivery.mjs
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CANGJIE_STDX_PATH=/workspace/work/linux-build-recon/stdx-env
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
(cd examples/theme_showcase && cjpm build)
node tests/theme_showcase/smoke.mjs
node tests/theme_showcase/pty.mjs
