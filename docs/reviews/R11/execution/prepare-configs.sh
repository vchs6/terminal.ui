#!/usr/bin/env bash
set -euo pipefail
root=${1:?project root required}
find "$root" -name cjpm.toml -not -path '*/target/*' -not -path '*/.git/*' -not -path '*/docs/reviews/*' -not -path '*/third_party/*' -print0 |
while IFS= read -r -d '' manifest; do
  cat > "$(dirname "$manifest")/cangjie-repo.toml" <<'CONFIG'
[repository.cache]
path = "/workspace/work/frame-execution/cache"
[repository.home]
registry = "http://127.0.0.1:18973"
CONFIG
done
