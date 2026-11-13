#!/usr/bin/env bash
set -uo pipefail
source /workspace/work/linux-build-recon/env.sh
probe_target="$1"
probe_output="$2"
probe_link="--start-group"
probe_args=(--import-path="$probe_target" --import-path="$CANGJIE_STDX_PATH/linux_x86_64_llvm/static")
for probe_dir in "$probe_target"/*; do
    if [[ -d "$probe_dir" ]]; then
        probe_args+=(-L "$probe_dir")
        for probe_lib in "$probe_dir"/*.a; do
            if [[ -f "$probe_lib" ]]; then probe_name="${probe_lib##*/}"; probe_name="${probe_name#lib}"; probe_link+=" $probe_lib"; fi
        done
    fi
done
for probe_lib in /workspace/work/overlay-implementation/source/native/*.a "$CANGJIE_STDX_PATH"/linux_x86_64_llvm/static/stdx/*.a; do probe_link+=" $probe_lib"; done
cjc -p round1/probe "${probe_args[@]}" --link-options "$probe_link --end-group" -o "round1/raw/$probe_output.bin" > "round1/raw/$probe_output.build.stdout" 2> "round1/raw/$probe_output.build.stderr"
probe_status=$?
printf '%s\n' "$probe_status" > "round1/raw/$probe_output.build.exit"
if [[ "$probe_status" = 0 ]]; then "round1/raw/$probe_output.bin" > "round1/raw/$probe_output.run.stdout" 2> "round1/raw/$probe_output.run.stderr"; printf '%s\n' "$?" > "round1/raw/$probe_output.run.exit"; fi
