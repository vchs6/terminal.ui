#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/validation/sdk/cangjie/envsetup.sh
supplement_dir=/workspace/work/linux-source-audit/supplement
mkdir -p "$supplement_dir/bin" "$supplement_dir/raw"
cjc --version > "$supplement_dir/raw/toolchain.log"
cjpm --version >> "$supplement_dir/raw/toolchain.log"
cjc --compile-macro "$supplement_dir/component_macros.cj" --output-dir "$supplement_dir/bin" > "$supplement_dir/raw/component-macros.compile.log" 2>&1
cjc "$supplement_dir/base_library.cj" --output-type=staticlib -o "$supplement_dir/bin/libauditsupplement.a" > "$supplement_dir/raw/base-library.compile.log" 2>&1
cjc "$supplement_dir/constructors.cj" --import-path "$supplement_dir/bin" -L "$supplement_dir/bin" -lauditsupplement -o "$supplement_dir/bin/constructors" > "$supplement_dir/raw/constructors.compile.log" 2>&1
timeout 10s "$supplement_dir/bin/constructors" > "$supplement_dir/raw/constructors.run.log" 2>&1
cjc "$supplement_dir/native_early_return.cj" -o "$supplement_dir/bin/native_early_return" > "$supplement_dir/raw/native-early-return.compile.log" 2>&1
timeout 10s "$supplement_dir/bin/native_early_return" > "$supplement_dir/raw/native-early-return.run.log" 2>&1
if cjc "$supplement_dir/macro_early_return.cj" --import-path "$supplement_dir/bin" -L "$supplement_dir/bin" -lauditsupplement -o "$supplement_dir/bin/macro_early_return" > "$supplement_dir/raw/macro-early-return.compile.log" 2>&1; then
    echo 'FAIL macro early-return diagnostic expected' >&2
    exit 1
fi
rg 'AUDIT_INIT_RETURN' "$supplement_dir/raw/macro-early-return.compile.log" >/dev/null
rg 'macro_early_return.cj:[0-9]+' "$supplement_dir/raw/macro-early-return.compile.log" >/dev/null
cjc "$supplement_dir/weak_ref.cj" -o "$supplement_dir/bin/weak_ref" > "$supplement_dir/raw/weak-ref.compile.log" 2>&1
timeout 10s "$supplement_dir/bin/weak_ref" > "$supplement_dir/raw/weak-ref.run.log" 2>&1
sha256sum "$supplement_dir"/*.cj "$supplement_dir/run.sh" > "$supplement_dir/raw/source-sha256.txt"
cat "$supplement_dir/raw/constructors.run.log" "$supplement_dir/raw/weak-ref.run.log"
