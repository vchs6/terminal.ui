#!/usr/bin/env bash
set -euo pipefail
task_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
mkdir -p "$scratch/bin"
# This sentinel is never a product stub. If called, the negative control fails.
cat > "$scratch/bin/cjpm" <<'SENTINEL'
#!/usr/bin/env bash
printf 'UNEXPECTED_BUILD\n' >> "$OVERLAY_GATE_SENTINEL"
exit 95
SENTINEL
chmod +x "$scratch/bin/cjpm"
for mode in formal preparation; do
    set +e
    OVERLAY_GATE_SENTINEL="$scratch/invoked" PATH="$scratch/bin:$PATH" \
        bash "$task_dir/run.sh" "$mode" > "$scratch/$mode.stdout" 2> "$scratch/$mode.stderr"
    observed=$?
    set -e
    [[ "$observed" == 77 ]]
    [[ ! -e "$scratch/invoked" ]]
    [[ $(rg -c '^BLOCKED ' "$scratch/$mode.stderr") == 8 ]]
    printf 'TOOLS_ONLY %s rejects missing actual inputs with77, builds0\n' "$mode"
done
set +e
bash "$task_dir/run.sh" invalid > "$scratch/invalid.stdout" 2> "$scratch/invalid.stderr"
observed=$?
set -e
[[ "$observed" == 64 ]]
printf '%s\n' 'TOOLS_ONLY invalid mode rejects64; not overlay product/PTY/host PASS'
