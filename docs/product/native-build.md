# Linux native build and Unicode

With Cangjie SDK/CJPM 1.2.0 on Linux x86_64, a normal `cjpm build` builds cjtui and its native Unicode data automatically, including when cjtui is a dependency of another package. The build requires Bash, curl, tar, unzip, SHA-256 utilities, flock, GCC and GNU ar; the SDK environment must be sourced first. The build uses the official unicode 0.1.0 package and Unicode 17.0.0 UCD archive, each verified by a fixed SHA-256 before use. Network access is needed on the first build unless inputs are already cached.

To use a local UCD archive, set `CJTUI_UCD_ARCHIVE` to its path before invoking CJPM. The archive must have SHA-256 `2066d1909b2ea93916ce092da1c0ee4808ea3ef8407c94b4f14f5b7eb263d28e`. The Unicode package is fetched from `https://pkg.cangjie-lang.cn/registry/pkg/unicode/0.1.0` and checked against `d810505f62b43417ce673fb9c811f740503d3df88665307557544eae6d073c4c`; UCD is fetched from `https://www.unicode.org/Public/17.0.0/ucd/UCD.zip` if no local archive is set. Failed downloads and checksums stop the build; hook details appear in CJPM's `build-script-cache/.../cjtui/bin/script-log`.

The generator and intermediate files live in `.cjtui-build`; the resulting `native/libunicodedata.a` is reproducible build output. These may be removed to force regeneration. `--skip-script` skips the required build hook. The build does not modify CJPM's shared dependency cache. The dependency license and attribution materials are retained in `third_party/licenses`.

`graphemeClusters` returns Unicode grapheme clusters, including an empty array for empty input. `displayWidth` uses unicodewidth, with `ambiguousWide: true` selecting its CJK ambiguous-width policy. These functions do not promise that every terminal renders every glyph identically.
