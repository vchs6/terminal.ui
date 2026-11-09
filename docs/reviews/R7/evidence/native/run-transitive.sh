#!/usr/bin/env bash
# Run only after run-native.sh succeeds in this isolated directory.
# Usage: run-transitive.sh ISOLATED_RUN_DIRECTORY ORIGINAL_UNICODE_CJP
set -euo pipefail
probe_work=$(realpath "${1:?}"); cjp_input=$(realpath "${2:?}")
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[[ -f "$probe_work/logs/grapheme-conformance.log" && -f "$probe_work/unicode-0.1.0/lib/libunicodedata.a" ]] || { echo 'Complete run-native.sh first' >&2; exit 1; }
printf '%s  %s\n' d810505f62b43417ce673fb9c811f740503d3df88665307557544eae6d073c4c "$cjp_input" | sha256sum -c > "$probe_work/logs/transitive-input-checksum.log"
mkdir -p "$probe_work/middle/src"
cp "$script_dir/templates/middle-lib.cj" "$probe_work/middle/src/lib.cj"
cp "$script_dir/templates/consumer-middle.cj" "$probe_work/consumer/src/main.cj"
cat > "$probe_work/middle/cjpm.toml" <<'TOML'
[package]
cjc-version = "1.2.0"
name = "native_adapter"
version = "0.0.1"
src-dir = "src"
output-type = "static"
[dependencies]
unicode = { path = "../unicode-0.1.0" }
TOML
cat > "$probe_work/consumer/cjpm.toml" <<'TOML'
[package]
cjc-version = "1.2.0"
name = "native_probe"
version = "0.0.1"
src-dir = "src"
output-type = "executable"
[dependencies]
native_adapter = { path = "../middle" }
TOML
(cd "$probe_work/consumer" && cjpm run --build-args="-i" --verbose) > "$probe_work/logs/intermediate-ffi.log" 2>&1
# Preferred boundary: restore official unicode manifest; adapter owns native FFI.
tar -xOf "$cjp_input" unicode-0.1.0/cjpm.toml > "$probe_work/unicode-0.1.0/cjpm.toml"
printf '\n[ffi.c]\nunicodedata = { path = "../unicode-0.1.0/lib" }\n' >> "$probe_work/middle/cjpm.toml"
# A comment edit does not guarantee CJPM incremental invalidation. Build into a
# new empty target so an executable linked under the old FFI owner cannot run.
owner_target=$(mktemp -d "$probe_work/adapter-owned-target.XXXXXX")
[[ ! -e "$owner_target/release/bin/main" ]]
(
 printf 'Fresh adapter-owned build target: %s\n' "$owner_target"
 cd "$probe_work/consumer"
 cjpm run --target-dir="$owner_target" --verbose
) > "$probe_work/logs/adapter-owned-ffi-relink.log" 2>&1
[[ -x "$owner_target/release/bin/main" ]]
rg 'Compiling package.*native_probe.*-lunicodedata' "$probe_work/logs/adapter-owned-ffi-relink.log" >/dev/null
rg -F "$owner_target/release/bin/main" "$probe_work/logs/adapter-owned-ffi-relink.log" >/dev/null
printf 'PASS independent consumer -> static adapter -> official unicode; adapter owns native FFI\n'
