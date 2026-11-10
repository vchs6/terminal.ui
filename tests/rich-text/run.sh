#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
(cd tests/rich-text && cjpm build)
TERM=dumb COLORTERM= timeout 60s tests/rich-text/target/release/bin/main </dev/null
