#!/usr/bin/env bash
set -euo pipefail
task_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$task_dir/../.." && pwd)
mode=${1:-formal}
if [[ "$mode" == self-test ]]; then
    python3 "$task_dir/oracle.py" --self-test
    python3 "$task_dir/pty_selftest.py"
    exit 0
fi
if [[ "$mode" != formal ]]; then
    printf 'usage: bash tests/widgets_composite/run.sh [formal|self-test]\n' >&2
    exit 64
fi
missing=0
for source in menu_entry.cj split_axis.cj horizontal_menu.cj popup_menu.cj status_bar.cj split_pane.cj; do
    if [[ ! -f "$repo_dir/src/$source" ]]; then
        printf 'BLOCKED missing product source: src/%s\n' "$source" >&2
        missing=1
    fi
done
if [[ ! -f "$task_dir/admission.json" ]]; then
    printf 'BLOCKED missing fixed accepted admission.json (158/159 prerequisites)\n' >&2
    missing=1
fi
if [[ "$missing" != 0 ]]; then
    printf 'PREPARATION_ONLY; no target build or execution attempted; exit 77\n' >&2
    exit 77
fi
if ! python3 "$task_dir/check_admission.py" "$task_dir/admission.json" "$repo_dir"; then
    printf 'BLOCKED admission not fixed and accepted; exit 77\n' >&2
    exit 77
fi
(
    cd -- "$task_dir"
    cjpm build
    TERM=dumb COLORTERM= timeout 45s ./target/release/bin/main </dev/null
)
