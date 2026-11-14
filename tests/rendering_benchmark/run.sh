#!/usr/bin/env bash
set -euo pipefail

suite=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo=$(cd -- "$suite/../.." && pwd)
validator="$suite/target/release/bin/main"
observer="$suite/target/process_cost"

build_project() {
    local project=$1
    test -f "$project/cjpm.toml" || { echo "MISSING_PUBLIC_PROJECT $project" >&2; return 1; }
    (cd -- "$project" && cjpm build)
}

build_tests() {
    build_project "$suite"
    cc -std=c11 -O2 -Wall -Wextra -Werror "$suite/native/process_cost.c" -o "$observer"
}

build_public() {
    local product=$1 version=$2
    build_project "$product/benchmarks/rendering/workloads"
    build_project "$product/benchmarks/rendering/compat"
    if [[ $version == new ]]; then build_project "$product/benchmarks/rendering"; fi
}

# Smoke correctness is deliberately separate from later performance acceptance.
# Metadata must be supplied by the external fixed-artifact admission/execution job.
smoke() {
    local product=$1 version=$2 artifacts=$3 metadata=$4
    local executable diagnostic compat_hash diagnostic_hash scenario period geometry phase actions obligation width height run_id directory
    local status=0
    test -x "$validator" && test -x "$observer"
    test -f "$metadata"
    mkdir -- "$artifacts"
    executable="$product/benchmarks/rendering/compat/target/release/bin/main"
    compat_hash=$(sha256sum -- "$executable"); compat_hash=${compat_hash%% *}
    if [[ $version == new ]]; then
        diagnostic="$product/benchmarks/rendering/target/release/bin/main"
        diagnostic_hash=$(sha256sum -- "$diagnostic"); diagnostic_hash=${diagnostic_hash%% *}
        "$diagnostic" --help >"$artifacts/diagnostic-help.log" 2>&1 || status=1
    fi
    "$executable" --help >"$artifacts/compat-help.log" 2>&1 || status=1
    for width in 80 160; do
        height=$((width * 3 / 10))
        while IFS=, read -r scenario period geometry phase actions obligation; do
            [[ $scenario == scenario ]] && continue
            directory="$artifacts/$scenario-${width}x${height}"
            mkdir -- "$directory"
            run_id="$compat_hash-compat-$scenario-${width}x${height}-s143-w0-u$period-r0"
            local common=(--scenario "$scenario" --width "$width" --height "$height" --seed 143 --warmup 0 --updates "$period" --repetition 0)
            local command=("$executable" --mode correctness "${common[@]}" --run-id "$run_id" --csv "$directory/compat-samples.csv" --cells-csv "$directory/compat-cells.csv" --caret-csv "$directory/compat-caret.csv")
            printf '%q ' "${command[@]}" >"$directory/compat-command.txt"
            printf '\n' >>"$directory/compat-command.txt"
            if "$observer" "$run_id" "$directory/compat-process.csv" "${command[@]}" >"$directory/compat.log" 2>&1; then
                "$validator" process "$directory/compat-process.csv" "$run_id" >"$directory/compat-process-validation.log" 2>&1 || status=1
                "$validator" cells "$directory/compat-cells.csv" "$scenario" "$width" "$height" "$period" compat >"$directory/compat-cell-validation.log" 2>&1 || status=1
                "$validator" carets "$directory/compat-caret.csv" "$scenario" "$width" "$height" "$period" compat >"$directory/compat-caret-validation.log" 2>&1 || status=1
                "$validator" samples "$directory/compat-samples.csv" "$suite/sample_columns.csv" "$metadata" "$run_id" "$scenario" compat-correctness "$width" "$height" 0 >"$directory/compat-sample-validation.log" 2>&1 || status=1
            else status=1; fi
            if [[ $phase != correctness && $scenario != idle ]]; then
                run_id="$compat_hash-snapshot-$scenario-${width}x${height}-s143-w0-u$period-r0"
                command=("$executable" --mode snapshot-headless "${common[@]}" --run-id "$run_id" --csv "$directory/snapshot-samples.csv")
                printf '%q ' "${command[@]}" >"$directory/snapshot-command.txt"
                printf '\n' >>"$directory/snapshot-command.txt"
                if "$observer" "$run_id" "$directory/snapshot-process.csv" "${command[@]}" >"$directory/snapshot.log" 2>&1; then
                    "$validator" process "$directory/snapshot-process.csv" "$run_id" >"$directory/snapshot-process-validation.log" 2>&1 || status=1
                    "$validator" samples "$directory/snapshot-samples.csv" "$suite/sample_columns.csv" "$metadata" "$run_id" "$scenario" snapshot-headless "$width" "$height" 0 >"$directory/snapshot-sample-validation.log" 2>&1 || status=1
                else status=1; fi
            elif [[ $scenario == idle ]]; then
                if "$executable" --mode snapshot-headless "${common[@]}" --run-id "reject-$run_id" --csv "$directory/rejected-idle.csv" >"$directory/rejected-idle.log" 2>&1; then
                    echo "INVALID forced snapshot mislabeled normal idle" >>"$directory/rejected-idle.log"; status=1
                fi
                echo "REQUIRED_NORMAL_TTY_IDLE_NOT_EXECUTED" >"$directory/idle-coverage.txt"
            fi
            if [[ $version == new ]]; then
                run_id="$diagnostic_hash-diagnostic-$scenario-${width}x${height}-s143-w0-u$period-r0"
                command=("$diagnostic" --mode correctness "${common[@]}" --run-id "$run_id" --csv "$directory/diagnostic-samples.csv" --cells-csv "$directory/diagnostic-cells.csv" --caret-csv "$directory/diagnostic-caret.csv")
                printf '%q ' "${command[@]}" >"$directory/diagnostic-command.txt"
                printf '\n' >>"$directory/diagnostic-command.txt"
                if "$observer" "$run_id" "$directory/diagnostic-process.csv" "${command[@]}" >"$directory/diagnostic.log" 2>&1; then
                    "$validator" process "$directory/diagnostic-process.csv" "$run_id" >"$directory/diagnostic-process-validation.log" 2>&1 || status=1
                    "$validator" cells "$directory/diagnostic-cells.csv" "$scenario" "$width" "$height" "$period" diagnostic >"$directory/diagnostic-cell-validation.log" 2>&1 || status=1
                    "$validator" carets "$directory/diagnostic-caret.csv" "$scenario" "$width" "$height" "$period" diagnostic >"$directory/diagnostic-caret-validation.log" 2>&1 || status=1
                    "$validator" samples "$directory/diagnostic-samples.csv" "$suite/sample_columns.csv" "$metadata" "$run_id" "$scenario" correctness "$width" "$height" 0 >"$directory/diagnostic-sample-validation.log" 2>&1 || status=1
                else status=1; fi
                if [[ $geometry == stable && $phase != correctness ]]; then
                    local mode
                    for mode in m1-headless m2-headless; do
                        run_id="$diagnostic_hash-$mode-$scenario-${width}x${height}-s143-w0-u$period-r0"
                        command=("$diagnostic" --mode "$mode" "${common[@]}" --run-id "$run_id" --csv "$directory/$mode-samples.csv")
                        printf '%q ' "${command[@]}" >"$directory/$mode-command.txt"
                        printf '\n' >>"$directory/$mode-command.txt"
                        if "$observer" "$run_id" "$directory/$mode-process.csv" "${command[@]}" >"$directory/$mode.log" 2>&1; then
                            "$validator" process "$directory/$mode-process.csv" "$run_id" >"$directory/$mode-process-validation.log" 2>&1 || status=1
                            "$validator" samples "$directory/$mode-samples.csv" "$suite/sample_columns.csv" "$metadata" "$run_id" "$scenario" "$mode" "$width" "$height" 0 >"$directory/$mode-sample-validation.log" 2>&1 || status=1
                        else status=1; fi
                    done
                else
                    # A misleading successful timing must not silently replace a
                    # stateful workload by some easier geometry-independent one.
                    if "$diagnostic" --mode m1-headless "${common[@]}" --run-id "reject-$run_id" --csv "$directory/rejected.csv" >"$directory/rejected.log" 2>&1; then
                        echo "INVALID stateful m1-headless accepted: $scenario" >>"$directory/rejected.log"; status=1
                    fi
                fi
            fi
        done <"$suite/scenarios.csv"
    done
    # Test real CLI validation, not help/source strings.
    local label
    for label in unknown-mode unknown-scenario unknown-flag bad-width bad-height bad-seed bad-updates negative-warmup negative-repetition; do
        local extra=() cli_mode=snapshot-headless cli_scenario=leaf_color cli_width=80 cli_height=24 cli_seed=143 cli_updates=2 cli_warmup=0 cli_repetition=0
        case $label in
            unknown-mode) cli_mode=invalid ;;
            unknown-scenario) cli_scenario=invalid ;;
            unknown-flag) extra=(--not-a-benchmark-flag 1) ;;
            bad-width) cli_width=0 ;;
            bad-height) cli_height=-1 ;;
            bad-seed) cli_seed=invalid ;;
            bad-updates) cli_updates=0 ;;
            negative-warmup) cli_warmup=-1 ;;
            negative-repetition) cli_repetition=-1 ;;
        esac
        if "$executable" --mode "$cli_mode" --scenario "$cli_scenario" --width "$cli_width" --height "$cli_height" --seed "$cli_seed" --warmup "$cli_warmup" --updates "$cli_updates" --repetition "$cli_repetition" --run-id "reject-$label" --csv "$artifacts/$label.csv" "${extra[@]}" >"$artifacts/$label.log" 2>&1; then
            echo "INVALID malformed CLI accepted: $label" >>"$artifacts/$label.log"; status=1
        fi
    done
    return "$status"
}

case ${1:-} in
    build) build_tests; build_public "$repo" new ;;
    build-tests) build_tests ;;
    build-public)
        test "$#" -eq 3
        [[ $3 == old || $3 == new ]]
        build_public "$(realpath -- "$2")" "$3"
        ;;
    smoke)
        test "$#" -eq 5
        [[ $3 == old || $3 == new ]]
        smoke "$(realpath -- "$2")" "$3" "$(realpath -m -- "$4")" "$(realpath -- "$5")"
        ;;
    compare)
        test "$#" -eq 3
        status=0
        for width in 80 160; do
            height=$((width * 3 / 10))
            while IFS=, read -r scenario period rest; do
                [[ $scenario == scenario ]] && continue
                for kind in cells caret; do
                    command=compare-cells
                    [[ $kind == caret ]] && command=compare-carets
                    "$validator" "$command" "$2/$scenario-${width}x${height}/compat-$kind.csv" "$3/$scenario-${width}x${height}/compat-$kind.csv" "$scenario" "$width" "$height" "$period" || status=1
                done
            done <"$suite/scenarios.csv"
        done
        exit "$status"
        ;;
    validate) shift; exec "$validator" "$@" ;;
    *) echo "usage: run.sh build|build-tests|build-public PRODUCT old|new|smoke PRODUCT old|new NEW_ARTIFACT_DIR RUN_METADATA.csv|compare OLD_RESULTS NEW_RESULTS|validate ..." >&2; exit 2 ;;
esac
