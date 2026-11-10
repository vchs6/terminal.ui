#!/usr/bin/env bash
# Isolated control of the admission-to-CJPM path. Synthetic rows test the gate
# only; their existence NEVER establishes actual upstream acceptance or target RED.
set -euo pipefail
task_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$task_dir/../.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT

if [[ -f "$repo_dir/src/menu_entry.cj" ]]; then
    printf 'CONTROL_NOT_APPLICABLE: target source is present\n' >&2
    exit 77
fi

# The checker is fed a synthetic all-accepted manifest in scratch. The
# existence/ancestry rules are genuine, while the acceptance claims are not.
head_sha=$(git -C "$repo_dir" rev-parse HEAD)
python3 - "$scratch/admission.json" "$scratch/evidence" "$head_sha" <<'PY'
import json
import sys
from pathlib import Path

from_path, evidence, sha = sys.argv[1:]
Path(evidence).write_text("GATE_NEGATIVE_CONTROL_ONLY\n", encoding="utf-8")
names = ("runtime080", "rich084", "theme088", "glyph097", "interaction_a102",
         "viewport107", "overlay112", "keyboard117", "small157")
Path(from_path).write_text(json.dumps({name: {"status": "accepted", "sha": sha,
                                         "evidence": evidence} for name in names}), encoding="utf-8")
PY
python3 "$task_dir/check_admission.py" "$scratch/admission.json" "$repo_dir"
printf 'GATE_CONTROL_ACCEPTED_SYNTHETIC; invoking real cjpm build on unmodified public consumer\n'
set +e
(
    cd -- "$task_dir"
    timeout 300s cjpm build
) > "$scratch/build.stdout" 2> "$scratch/build.stderr"
build_status=$?
set -e
cat "$scratch/build.stdout"
cat "$scratch/build.stderr" >&2
printf 'GATE_CONTROL_CJPM_EXIT=%s\n' "$build_status"
if [[ "$build_status" == 124 ]]; then
    printf 'GATE_CONTROL_INCONCLUSIVE: build timeout\n' >&2
    exit 2
fi
if [[ "$build_status" == 0 ]]; then
    printf 'GATE_CONTROL_INCONCLUSIVE: target was unexpectedly buildable\n' >&2
    exit 2
fi
# A compiler diagnostic about the missing widget is evidence that the gate
# actually reached normal consumer compilation; other failures are inconclusive.
if rg -q 'MenuEntry|HorizontalMenu|PopupMenu|StatusBar|SplitPane' "$scratch/build.stderr" "$scratch/build.stdout"; then
    printf 'GATE_CONTROL_REACHED_TARGET_COMPILER_DIAGNOSTIC\n'
    exit 0
fi
printf 'GATE_CONTROL_INCONCLUSIVE: failure before missing widget diagnostic\n' >&2
exit 2
