#!/usr/bin/env bash
set -euo pipefail
source /workspace/work/validation/sdk/cangjie/envsetup.sh
probe_dir=/workspace/work/linux-source-audit/probe
mkdir -p "$probe_dir/bin" "$probe_dir/logs"
cjc --version > "$probe_dir/logs/toolchain.log"
cjpm --version >> "$probe_dir/logs/toolchain.log"
cjc --compile-macro "$probe_dir/macros.cj" --output-dir "$probe_dir/bin" > "$probe_dir/logs/macros.compile.log" 2>&1
cjc "$probe_dir/base_library.cj" --output-type=staticlib -o "$probe_dir/bin/libauditbase.a" > "$probe_dir/logs/base_library.compile.log" 2>&1
cjc "$probe_dir/main.cj" --import-path "$probe_dir/bin" -o "$probe_dir/bin/main" > "$probe_dir/logs/main.compile.log" 2>&1
"$probe_dir/bin/main" > "$probe_dir/logs/main.run.log" 2>&1
for probe in subclass thread; do
    cjc "$probe_dir/$probe.cj" --import-path "$probe_dir/bin" -L "$probe_dir/bin" -lauditbase -o "$probe_dir/bin/$probe" > "$probe_dir/logs/$probe.compile.log" 2>&1
    timeout 10s "$probe_dir/bin/$probe" > "$probe_dir/logs/$probe.run.log" 2>&1
    cat "$probe_dir/logs/$probe.run.log"
done
if cjc "$probe_dir/base_init_negative.cj" --import-path "$probe_dir/bin" -o "$probe_dir/bin/base_init_negative" > "$probe_dir/logs/base_init_negative.compile.log" 2>&1; then
    echo 'FAIL open base constructor unexpectedly accepted this' >&2
    exit 1
fi
rg "this.*cannot be used as an expression in the constructor of open class" "$probe_dir/logs/base_init_negative.compile.log" >/dev/null
sha256sum "$probe_dir"/*.cj "$probe_dir/run.sh" > "$probe_dir/logs/source-sha256.txt"
cat "$probe_dir/logs/main.run.log"
