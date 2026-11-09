#!/usr/bin/env bash
set -u
base=/workspace/work/r7-independent-test
repo="$base/repo"
exec > >(tee "$base/execution.log") 2>&1
PS4='+ ${BASH_SOURCE}:${LINENO}: '
set -x
date -u '+%Y-%m-%dT%H:%M:%SZ'
git -C "$repo" rev-parse HEAD
git -C "$repo" status --short
sha256sum /workspace/work/validation/replay-dependencies/archives/unicode-0.1.0.cjp /workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
(cd "$repo/docs/reviews/R7/evidence/native" && sed '/  logs\//d' SHA256SUMS | sha256sum -c)
printf 'handoff_checksum_exit=%s\n' "$?"
source /workspace/work/validation/sdk/cangjie/envsetup.sh
printf 'sdk_source_exit=%s\n' "$?"
command -v cjc cjpm node gcc ar bash tar unzip rg sha256sum
cjc --version
cjpm --version
printf 'CANGJIE_HOME=%s\nPATH=%s\nLD_LIBRARY_PATH=%s\n' "${CANGJIE_HOME-}" "$PATH" "${LD_LIBRARY_PATH-}"
bash -x "$repo/docs/reviews/R7/evidence/native/run-native.sh" "$base/native-probe" /workspace/work/validation/replay-dependencies/archives/unicode-0.1.0.cjp /workspace/work/validation/replay-dependencies/UCD-17.0.0.zip > "$base/run-native.trace.log" 2>&1
native_status=$?
printf 'run_native_exit=%s\n' "$native_status"
if [[ "$native_status" == 0 ]]; then
 bash -x "$repo/docs/reviews/R7/evidence/native/run-transitive.sh" "$base/native-probe" /workspace/work/validation/replay-dependencies/archives/unicode-0.1.0.cjp > "$base/run-transitive.trace.log" 2>&1
 transitive_status=$?
 printf 'run_transitive_exit=%s\n' "$transitive_status"
fi
date -u '+%Y-%m-%dT%H:%M:%SZ'
