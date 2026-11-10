#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
(cd tests/interaction_b && cjpm build)
TERM=dumb COLORTERM= timeout 60s tests/interaction_b/target/release/bin/main </dev/null
