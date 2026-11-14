#!/usr/bin/env bash
set -euo pipefail

# External acceptance facility, not a packaged/runtime dependency. Run only after
# fixed D142/artifacts and root GO. Never reads a development product checkout.
test "$#" -eq 3 || { echo 'usage: consume.sh OLD_M1.cjp NEW_M2.cjp NEW_DIRECTORY' >&2; exit 2; }
suite=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
old_archive=$(realpath -- "$1")
new_archive=$(realpath -- "$2")
out=$(realpath -m -- "$3")
mkdir -- "$out"
sha256sum -- "$old_archive" "$new_archive" >"$out/archive-sha256.txt"

unpack() {
    local archive=$1 directory=$2 member
    mkdir -- "$directory"
    tar -tzf "$archive" >"$directory/members.txt"
    while IFS= read -r member; do
        case /$member/ in
            //*|*/../*) echo "unsafe archive path: $member" >&2; return 1 ;;
        esac
    done <"$directory/members.txt"
    # Fixed ordinary CJPM source archives should contain regular files/directories.
    tar -tvzf "$archive" >"$directory/member-types.txt"
    if rg -q '^[^d-]' "$directory/member-types.txt"; then
        echo 'unexpected archive link/special member; inspect actual package' >&2; return 1
    fi
    tar --no-same-owner --no-same-permissions -xzf "$archive" -C "$directory"
}

product_root() {
    local directory=$1 manifest root= count=0
    for manifest in "$directory/cjpm.toml" "$directory"/*/cjpm.toml; do
        if [[ -f $manifest ]]; then root=${manifest%/cjpm.toml}; count=$((count + 1)); fi
    done
    [[ $count -eq 1 ]] || { echo 'ambiguous/missing ordinary package root' >&2; return 1; }
    printf '%s\n' "$root"
}

unpack "$old_archive" "$out/old"
unpack "$new_archive" "$out/new"
old_product=$(product_root "$out/old")
new_product=$(product_root "$out/new")
for project in "$new_product/benchmarks/rendering" "$new_product/benchmarks/rendering/compat" "$new_product/benchmarks/rendering/workloads"; do
    test -f "$project/cjpm.toml"
    rg --files "$project/src" -g '*.cj' >"$out/$(basename -- "$project")-sources.txt"
    test -s "$out/$(basename -- "$project")-sources.txt"
done

# M012: the old frozen functional package may legitimately predate benchmarks.
# Transfer only the identical final public compat/workloads source projects.
old_common="$old_product/benchmarks/rendering"
mkdir -p -- "$old_common"
for project in compat workloads; do
    if [[ -e $old_common/$project ]]; then
        echo "unexpected preexisting old benchmark project: $project; inspect before transfer" >&2; exit 1
    fi
    cp -a -- "$new_product/benchmarks/rendering/$project" "$old_common/$project"
done
(
    cd -- "$new_product/benchmarks/rendering"
    rg --files -0 compat/src workloads/src -g '*.cj' | sort -z | xargs -0 sha256sum
) >"$out/common-new-sha256.txt"
(
    cd -- "$old_common"
    rg --files -0 compat/src workloads/src -g '*.cj' | sort -z | xargs -0 sha256sum
) >"$out/common-old-sha256.txt"
cmp -- "$out/common-old-sha256.txt" "$out/common-new-sha256.txt"

# Normal builds prove old compilation without new diagnostics and actual package
# delivery. No private links, skip flags, compiler overrides or cache edits.
bash "$suite/run.sh" build-public "$old_product" old >"$out/old-build.log" 2>&1
bash "$suite/run.sh" build-public "$new_product" new >"$out/new-build.log" 2>&1
printf '%s\n' "$old_product" >"$out/old-product.txt"
printf '%s\n' "$new_product" >"$out/new-product.txt"
echo "BUILT_PUBLIC_PROJECTS; smoke/correctness and same-source old/new compare still required"
