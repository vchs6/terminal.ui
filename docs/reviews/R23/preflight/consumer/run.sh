#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/validation/sdk/cangjie/envsetup.sh
root=/workspace/work/glyph-advance-preflight
product=/workspace/work/rich-text-execution/clean-product/cjtui-0.0.0
cjc -v > "$root/raw/sdk-version.txt"
args=()
for d in "$product"/target/release/*/; do
  args+=(--import-path "$d" -L "$d")
done
libraries="--start-group"
for library in "$product"/target/release/*/lib*.a "$product"/native/lib*.a; do
  libraries+=" $library"
done
libraries+=" --end-group"
args+=(--link-options "$libraries")
printf '%q ' cjc "${args[@]}" "$root/consumer/main.cj" -o "$root/consumer/probe" > "$root/raw/compile-command.txt"
printf '\n' >> "$root/raw/compile-command.txt"
cjc "${args[@]}" "$root/consumer/main.cj" -o "$root/consumer/probe"
"$root/consumer/probe" > "$root/raw/scalar-widths.tsv"
