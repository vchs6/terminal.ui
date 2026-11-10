#!/usr/bin/env bash
set -euo pipefail
cd /workspace/work/layout-whole-review/repo
source /workspace/work/validation/sdk/cangjie/envsetup.sh
cjc --version
cjpm --version
git rev-parse HEAD HEAD^
test "$(git rev-parse HEAD)" = 425626a1b6556b16837cb0744d5a5f46ebd54814
test -z "$(git status --porcelain)"
git diff --check c502c9fe64422095d7a37e741d8756af3bbc9873 HEAD -- src tests examples docs/product
git diff --exit-code HEAD^ HEAD -- tests native cjpm.toml build.cj examples
git diff --exit-code c502c9fe64422095d7a37e741d8756af3bbc9873 HEAD -- native build.cj cjpm.toml tests/contract tests/coordinate-boundary tests/integration/pty.mjs tests/integration/fixture tests/native-session tests/native-smoke
node --check tests/integration/layout-pty.mjs
bash -n tests/run-slice.sh
node /workspace/work/layout-whole-review/structure-check.mjs
sha256sum /workspace/work/layout-whole-review/whole-technical-review.diff
printf 'PASS review structural, unchanged-scope, syntax and identity checks; exit=0\n'
