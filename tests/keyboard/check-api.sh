#!/usr/bin/env bash
# Run only after the positive decoder consumer builds and runs. Otherwise a
# missing whole product API could falsely satisfy these compile rejections.
set -euo pipefail
root=$(cd "$(dirname "$0")/../.." && pwd)
output=${CJTUI_KEYBOARD_API_ARTIFACTS:-$(mktemp -d)}
mkdir -p "$output"
for test_case in batch-constructor diagnostic-constructor events-setter diagnostics-setter; do
    project="$output/$test_case"
    cjpm init --name keyboard_negative --type=executable --path "$project"
    sed -i 's/version = "1.0.0"/version = "0.0.0"/' "$project/cjpm.toml"
    cp "$root/tests/keyboard/api-negative/$test_case.cj.txt" "$project/src/main.cj"
    printf '\n[dependencies.cjtui]\npath = "%s"\n' "$root" >> "$project/cjpm.toml"
    if [[ -f "$root/cangjie-repo.toml" ]]; then cp "$root/cangjie-repo.toml" "$project/"; fi
    if (cd "$project" && cjpm build > build.stdout 2> build.stderr); then
        printf 'FAIL public API unexpectedly admits %s\n' "$test_case" >&2
        exit 1
    fi
    # Require a type/visibility diagnostic; an infrastructure error is not RED.
    if ! rg -qi 'not accessible|not visible|private|inaccessible|no matching|cannot assign|cannot be assigned|immutable|setter|not assignable|no.*constructor' "$project/build.stderr"; then
        cat "$project/build.stderr" >&2
        printf 'FAIL unclassified rejection %s\n' "$test_case" >&2
        exit 1
    fi
    printf 'PASS closed API rejection %s (see %s)\n' "$test_case" "$project/build.stderr"
done
