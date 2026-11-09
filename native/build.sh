#!/usr/bin/env bash
# Build the official Unicode native data in an isolated package-local directory.
set -euo pipefail
root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cache="$root/.cjtui-build"
mkdir -p "$cache" "$root/native"
exec 9>"$cache/native.lock"
flock 9
unicode_sha=d810505f62b43417ce673fb9c811f740503d3df88665307557544eae6d073c4c
ucd_sha=2066d1909b2ea93916ce092da1c0ee4808ea3ef8407c94b4f14f5b7eb263d28e
verify() { printf '%s  %s\n' "$1" "$2" | sha256sum -c; }
fetch() { curl --fail --location --retry 2 --output "$2.tmp" "$1" && mv "$2.tmp" "$2"; }
archive="$cache/unicode-0.1.0.cjp"
if [[ ! -f "$archive" ]]; then
    fetch https://pkg.cangjie-lang.cn/registry/pkg/unicode/0.1.0 "$archive"
fi
verify "$unicode_sha" "$archive"
if [[ -n "${CJTUI_UCD_ARCHIVE:-}" ]]; then
    ucd=$(realpath "$CJTUI_UCD_ARCHIVE")
else
    ucd="$cache/UCD-17.0.0.zip"
    if [[ ! -f "$ucd" ]]; then
        fetch https://www.unicode.org/Public/17.0.0/ucd/UCD.zip "$ucd"
    fi
fi
verify "$ucd_sha" "$ucd"
gcc -fPIC -O2 -c "$root/native/cjtui_terminal.c" -o "$cache/cjtui_terminal.o"
ar rcs "$root/native/libcjtui_terminal.a" "$cache/cjtui_terminal.o"
if [[ -f "$root/native/libunicodedata.a" && -f "$cache/native-ready" ]] && (cd "$root" && sha256sum -c "$cache/native-ready"); then
    exit 0
fi
work=$(mktemp -d "$cache/native.XXXXXXXX")
trap 'rm -rf "$work"' EXIT
tar xf "$archive" -C "$work"
unicode="$work/unicode-0.1.0"
(cd "$unicode/generator" && cjpm build)
mkdir -p "$unicode/unicodedata/UCD" "$unicode/unicodedata/memmap"
unzip -q "$ucd" -d "$unicode/unicodedata/UCD"
"$unicode/generator/target/generate" "$unicode/unicodedata/UCD" "$unicode/unicodedata/memmap"
(
    cd "$unicode/unicodedata/src"
    gcc -fPIC -O2 -I../include -c library.c -o "$work/library.o"
    gcc -fPIC -c data.S -o "$work/data.o"
)
ar rcs "$work/libunicodedata.a" "$work/library.o" "$work/data.o"
mv "$work/libunicodedata.a" "$root/native/libunicodedata.a"
(cd "$root" && sha256sum native/libunicodedata.a) > "$cache/native-ready"
