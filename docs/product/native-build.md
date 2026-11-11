# Linux native build and Unicode

With Cangjie SDK/CJPM 1.2.0 on Linux x86_64, a normal `cjpm build` builds cjtui and its native Unicode data automatically, including when cjtui is a dependency of another package. The build requires Bash, curl, tar, unzip, SHA-256 utilities, flock, GCC and GNU ar; the SDK environment must be sourced first. The build uses the official unicode 0.1.0 package and Unicode 17.0.0 UCD archive, each verified by a fixed SHA-256 before use. Network access is needed on the first build unless inputs are already cached.

To use a local UCD archive, set `CJTUI_UCD_ARCHIVE` to its path before invoking CJPM. The archive must have SHA-256 `2066d1909b2ea93916ce092da1c0ee4808ea3ef8407c94b4f14f5b7eb263d28e`. The Unicode package is fetched from `https://pkg.cangjie-lang.cn/registry/pkg/unicode/0.1.0` and checked against `d810505f62b43417ce673fb9c811f740503d3df88665307557544eae6d073c4c`; UCD is fetched from `https://www.unicode.org/Public/17.0.0/ucd/UCD.zip` if no local archive is set. Failed downloads and checksums stop the build; hook details appear in CJPM's `build-script-cache/.../cjtui/bin/script-log`.

The generator and intermediate files live in `.cjtui-build`; the resulting `native/libunicodedata.a` is reproducible build output. These may be removed to force regeneration. `--skip-script` skips the required build hook. The build does not modify CJPM's shared dependency cache. The dependency license and attribution materials are retained in `third_party/licenses`.

`graphemeClusters` returns Unicode grapheme clusters, including an empty array for empty input. `displayWidth` uses unicodewidth, with `ambiguousWide: true` selecting its CJK ambiguous-width policy. These functions do not promise that every terminal renders every glyph identically.

## TOML and stdx prerequisite

Theme parsing uses the normal central-registry dependency `cangjie_toml` 0.2.3 and the official Cangjie stdx 1.2.0-beta.02.1 release for SDK 1.2.0. Install the official Linux x86_64 stdx archive in a user-owned directory. Its SHA-256 is `0d35811d84a770315c6fa2d1090a10568b3f7c763a1d1d54a1433b324f76afc0`; obtain it from [the official release](https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.2.0-beta.02.1/cangjie-stdx-linux-x64-1.2.0-beta.02.1.zip).

The published TOML package expects the stdx binary directory at `${CANGJIE_STDX_PATH}/linux_x86_64_llvm/static/stdx`. The official archive places `static/stdx` directly in its extracted directory. For example, after extracting it under a user-owned path, create a directory for the compatibility layout and a symlink named `linux_x86_64_llvm` to the extracted directory; set `CANGJIE_STDX_PATH` to that parent directory before `cjpm build`. The product manifest declares this normal transitive binary dependency. The SDK environment must also be sourced as above. No absolute installation path is embedded in the product manifest.

The TOML package's MIT license and the official stdx license are preserved under `third_party/licenses`. The stdx release also includes its upstream open-source software notice.
