#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/validation/sdk/cangjie/envsetup.sh
names_dir=/workspace/work/linux-source-audit/names
mkdir -p "$names_dir/bin" "$names_dir/raw"
cjc --version > "$names_dir/raw/toolchain.log"
cjc "$names_dir/base.cj" --output-type=staticlib -o "$names_dir/bin/libauditnames.a" > "$names_dir/raw/base.compile.log" 2>&1
cjc --compile-macro "$names_dir/macros.cj" --import-path "$names_dir/bin" --output-dir "$names_dir/bin" > "$names_dir/raw/macros.compile.log" 2>&1
cjc --compile-macro "$names_dir/namespace_macros.cj" --import-path "$names_dir/bin" --output-dir "$names_dir/bin" > "$names_dir/raw/namespace-macros.compile.log" 2>&1
for consumer in dual_wildcard normal shadow; do
    cjc "$names_dir/$consumer.cj" --import-path "$names_dir/bin" -L "$names_dir/bin" -lauditnames -o "$names_dir/bin/$consumer" > "$names_dir/raw/$consumer.compile.log" 2>&1
    timeout 10s "$names_dir/bin/$consumer" > "$names_dir/raw/$consumer.run.log" 2>&1
    cat "$names_dir/raw/$consumer.run.log"
done
if cjc "$names_dir/wildcard_qualified_negative.cj" --import-path "$names_dir/bin" -L "$names_dir/bin" -lauditnames -o "$names_dir/bin/wildcard_qualified_negative" > "$names_dir/raw/wildcard-qualified-negative.compile.log" 2>&1; then
    echo 'FAIL missing namespace import unexpectedly compiled' >&2
    exit 1
fi
rg "undeclared type name 'auditnames'" "$names_dir/raw/wildcard-qualified-negative.compile.log" >/dev/null
sha256sum "$names_dir"/*.cj "$names_dir/run.sh" > "$names_dir/raw/source-sha256.txt"
