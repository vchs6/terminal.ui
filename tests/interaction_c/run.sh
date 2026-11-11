#!/usr/bin/env bash
set -euo pipefail
task_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$task_dir/../.." && pwd)

build_and_execute() {
    local project=$1
    (
        cd -- "$project"
        cjpm build
        # Direct binary status is authoritative. Never use cjpm run.
        TERM=dumb COLORTERM= timeout 45s ./target/release/bin/main </dev/null
    )
}

case "${1:-formal}" in
    api-probe)
        printf '%s\n' 'PREPARATION_ONLY normal public consumer build; C behavior UNEXECUTED; not B107 acceptance'
        (cd -- "$task_dir" && cjpm build)
        exit $?
        ;;
    fixture-controls)
        python3 "$task_dir/pty_driver.py" --self-test
        exit $?
        ;;
    baseline)
        printf '%s\n' 'BASELINE_ONLY: existing API; not overlay/product admission'
        build_and_execute "$task_dir/baseline"
        exit $?
        ;;
    formal|preparation|device) ;;
    *) printf '%s\n' 'usage: bash tests/interaction_c/run.sh [formal|preparation|baseline|api-probe|fixture-controls|device]' >&2; exit 64 ;;
esac

# Freeze is deliberately closed while real accepted upstream inputs and the
# remaining executable fixtures are absent. No environment variable bypass.
blocked=0
rows=0
while IFS=$'\t' read -r gate status source_sha evidence; do
    [[ "$gate" == gate ]] && continue
    [[ -z "$gate" ]] && continue
    rows=$((rows + 1))
    if [[ "$status" != ACCEPTED || ! "$source_sha" =~ ^[0-9a-f]{40}$ ]]; then
        printf 'BLOCKED %s: %s; %s\n' "$gate" "$status" "$evidence" >&2
        blocked=1
        continue
    fi
    if ! git -C "$repo_dir" cat-file -e "$source_sha^{commit}" 2>/dev/null ||
        ! git -C "$repo_dir" merge-base --is-ancestor "$source_sha" HEAD; then
        printf 'BLOCKED %s: accepted source is not in this source history\n' "$gate" >&2
        blocked=1
    fi
    if [[ ! -f "$evidence" ]]; then
        printf 'BLOCKED %s: missing fixed evidence %s\n' "$gate" "$evidence" >&2
        blocked=1
    fi
done < "$task_dir/admission.tsv"
if [[ "$rows" != 8 || "$blocked" != 0 ]]; then
    printf '%s\n' 'PREPARATION_ONLY: no overlay build or execution attempted; exit 77' >&2
    exit 77
fi
if [[ "${1:-formal}" == preparation ]]; then
    printf '%s\n' 'Actual admission data is present; use formal for ordinary build/direct binary.'
    exit 0
fi
if [[ "${1:-formal}" == device ]]; then
    (cd -- "$task_dir" && cjpm build)
    python3 "$task_dir/pty_driver.py" --binary "$task_dir/target/release/bin/main" --output "${CJTUI_OVERLAY_EVIDENCE:?set output evidence directory}"
else
    build_and_execute "$task_dir"
fi
