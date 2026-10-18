#!/usr/bin/env bash
set -euo pipefail
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root_dir"
mode="${1:-slice}"
[[ "$mode" == slice || "$mode" == release ]] || { echo "Usage: check-product.sh [slice|release]" >&2; exit 2; }
find src -name '*.cj' -print -quit | grep -q . || { echo 'Product not implemented: no active Cangjie source' >&2; exit 1; }
cjc --version
cjpm --version
cjpm check
if [[ "$mode" == slice ]]; then
  cjpm build
  cjpm test
fi
# Check all projects actually introduced; future projects stay pending in the plan.
while IFS= read -r manifest; do
  project_dir="$(dirname "$manifest")"
  ( cd "$project_dir"; cjpm check; cjpm build; cjpm test )
done < <(find examples benchmarks -name cjpm.toml -not -path '*/target/*' | sort)
if [[ "$mode" == slice ]]; then
  echo 'Implemented slice checks complete; not a final product/release verification.'
  exit 0
fi
for project_dir in examples/minimal examples/composition benchmarks/rendering; do
  test -f "$project_dir/cjpm.toml" || { echo "Required final project missing: $project_dir" >&2; exit 1; }
  find "$project_dir/src" -name '*.cj' -print -quit | grep -q .
done
( cd benchmarks/rendering; cjpm bench )
# CJPM bundle performs its own build/test/lint checks; do not rerun them merely for another workflow label.
cjpm bundle
bundle_path="target/$(node --input-type=module -e "import{parse}from'smol-toml';import{readFileSync}from'node:fs';let p=parse(readFileSync('cjpm.toml','utf8')).package;console.log(p.name+'-'+p.version+'.cjp')")"
node scripts/check-bundle.mjs "$bundle_path"
clean_dir="$(mktemp -d)"
trap 'rm -rf "$clean_dir"' EXIT
tar -xzf "$bundle_path" -C "$clean_dir"
product_manifest="$(find "$clean_dir" -maxdepth 2 -name cjpm.toml -print -quit)"
product_dir="$(dirname "$product_manifest")"
( cd "$product_dir"; cjpm check; cjpm build )
for project_dir in examples/minimal examples/composition; do
  # Product docs must offer a deterministic noninteractive smoke mode before release.
  ( cd "$product_dir/$project_dir"; timeout 60s cjpm run -- --smoke )
done
( cd "$product_dir/benchmarks/rendering"; cjpm bench )
echo 'Release candidate verified locally; no publish/upload performed.'
