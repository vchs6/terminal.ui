#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/validation/sdk/cangjie/envsetup.sh
root=/workspace/work/terminal-width-recon
product=/workspace/work/rich-text-execution/clean-product/cjtui-0.0.0
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
printf '%q ' cjc "${args[@]}" "$root/source/product_width_probe.cj" -o "$root/source/product_width_probe" > "$root/commands/product-width-command.txt"
printf '\n' >> "$root/commands/product-width-command.txt"
cjc "${args[@]}" "$root/source/product_width_probe.cj" -o "$root/source/product_width_probe"
"$root/source/product_width_probe" > "$root/raw/product-width.tsv"
