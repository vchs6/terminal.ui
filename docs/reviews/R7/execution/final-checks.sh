#!/usr/bin/env bash
set -euxo pipefail
base=/workspace/work/r7-independent-test
repo="$base/repo"
probe="$base/native-probe"
git -C "$repo" diff --exit-code
git -C "$repo" status --porcelain
sha256sum /workspace/work/validation/replay-dependencies/archives/unicode-0.1.0.cjp /workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
for file in unicode-0.1.0/cjpm.toml unicode-0.1.0/unicodedata/src/library.c unicode-0.1.0/unicodedata/src/data.S; do
 tar -xOf /workspace/work/validation/replay-dependencies/archives/unicode-0.1.0.cjp "$file" | cmp - "$probe/$file"
 printf 'official_bytes_match=%s\n' "$file"
done
sha256sum "$probe/conformance/src/main.cj" "$probe/unicode-0.1.0/unicodedata/UCD/auxiliary/GraphemeBreakTest.txt"
stat -c '%y %n' "$probe/consumer/src/main.cj" "$probe/consumer/target/release/bin/main"
rg 'Compiling package.*native_probe' "$probe/logs/consumer-native-link.log" "$probe/logs/dependency-ffi-transitive.log" "$probe/logs/intermediate-ffi.log" > "$base/ffi-link-lines.log"
cat "$base/ffi-link-lines.log"
