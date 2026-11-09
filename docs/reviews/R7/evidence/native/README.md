# Unicode 0.1.0 Linux native dependency investigation

This is isolated investigation, not cjtui implementation or upstream integration. No product repository or historical dependency cache was modified. All success claims below are developer evidence; independent test execution and verification remain required by the user.

## Reproduce in a new directory

Prerequisites: Linux x86_64, SDK/CJPM1.2.0, Bash, Node, tar, unzip, gcc, GNU ar, rg, sha256sum. The SDK must already be sourced. CMake is not required by this validated minimal path.

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
bash run-native.sh /absolute/new-native-probe \
  /workspace/work/validation/replay-dependencies/archives/unicode-0.1.0.cjp \
  /workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
bash run-transitive.sh /absolute/new-native-probe \
  /workspace/work/validation/replay-dependencies/archives/unicode-0.1.0.cjp
```

Input bytes are checked before extraction. The source cjp and UCD zip may be independently downloaded from `https://pkg.cangjie-lang.cn/registry/pkg/unicode/0.1.0` and `https://www.unicode.org/Public/17.0.0/ucd/UCD.zip`; the scripts accept their local filenames and never change either input.

`run-native.sh` requires a nonexistent output directory. It records an expected clean normal-build failure, builds the shipped generator, generates all seven native tables from pinned UCD17, compiles the shipped C/ASM without editing them, proves explicit consumer linking, then proves a corrected isolated dependency manifest can propagate FFI. It finally runs all 766 official GraphemeBreakTest17 vectors, comparing every boundary and output code point. The official file has no empty-input case; a separate raw-library probe records the known one-empty-cluster behavior. Node emits test source from official expected boundaries and does not implement segmentation.

`run-transitive.sh` continues in that disposable directory. It proves consumer -> static adapter -> unicode FFI propagation, then restores the exact official unicode manifest and moves `[ffi.c]` ownership to the adapter. It creates a new empty target directory and performs a normal build there, recording the compiler's native link option and the new executable path. No consumer link option is needed. The consumer uses the adapter's public function and does not import unicode directly.

The original script tried to force an incremental relink by appending a comment. Independent execution showed that CJPM can reuse the old executable, correctly failing the script's compile-line assertion. A controlled developer probe reproduced this when the changed file's timestamp was preserved. The corrected owner stage relies on an empty target and retains the compiler/link assertions; comment edits and incremental cache invalidation are no longer acceptance evidence.

## Findings and recommendation

The official cjp contains no `build.cj` and no native archive. Its `package.link-option = "-Llib -lunicodedata"` is not propagated into a downstream executable's link command. A clean normal `cjpm build --verbose` fails with undefined `getCodepointProperty`, `getDecompSequence`, `getCombinSequences`, and `free_utf16array`; this is not caused by the old investigation's `--skip-script` flag. Restoring normal script execution cannot create a script that was not packaged.

CJPM1.2.0 recognizes `build.cj` next to `cjpm.toml`, with `pre-build` and `post-build` passed as the first argument. Dependency hooks run during downstream build/test. `--skip-script` bypasses all hooks. An isolated marker hook confirmed this actual SDK behavior; the official source has no hook. Official reference: https://cj-docs.gitcode.com/zh/1.2.0/tools/source_zh_cn/cmd-tools/cjpm_manual.html#构建脚本 .

Minimal repair in an upstream/package copy is `[ffi.c] unicodedata = { path = "./lib" }`, after generating `lib/libunicodedata.a`; `unicode-ffi.patch` records that manifest-only change. This is an isolated repair, not a claim that the official archive works unchanged.

The preferred cjtui integration boundary can instead preserve unicode's official manifest and give cjtui itself ownership of `[ffi.c] unicodedata = { path = "<its generated native directory>" }`. The tested static-adapter case proves this declaration reaches an independent consumer. A future normal-build hook should run the checksum-locked native pipeline in cjtui's own isolated build directory and supply that FFI path; avoid mutating CJPM's shared source cache. The actual product hook, clean cjp bundle lifecycle, download/cache contract, error reporting, and independent acceptance are still unimplemented and unverified. `run-native.sh` is evidence for that pipeline, not the product hook itself.

The shipped CMake route is not the minimal verified route: there is no top-level CMakeLists in the cjp, the native CMake assumes a prebuilt generator, the fresh UCD custom command sets its not-yet-created working directory before its mkdir command, FORCE_GEN calls misspelled `add_custom_traget`, and ASM `.incbin` paths depend on the build working directory. These are static findings; this host has no CMake and no actual CMake execution is claimed. The shipped native README also describes options/install rules absent from its CMake file. Do not silently present that README as a validated recipe.

## Existing results and limits

Developer logs in `logs/`: normal build failed as expected; original generator/native build/explicit link passed; FFI propagation passed directly and through a static adapter; adapter-owned FFI with official unicode manifest passed after an actual relink; all 766 GraphemeBreakTest17 vectors passed. Empty input still requires an adapter that directly returns an empty result (or filters empty clusters). No new Unicode algorithm or copied table was added to the product.

Unicode17 full normalization conformance, other native targets, CMake repair, license text/attribution completeness, final product build hook, and clean source-artifact consumption remain unresolved. NFD has representative coverage only. This evidence applies only to Linux x86_64 SDK1.2.0 and the pinned sources. It does not prove all Unicode behaviors or real terminal rendering.

The parent repository should retain only the small handoff scripts/templates/patch/index/logs it needs; do not commit downloaded third-party source, UCD files, generated test data, object files, archives, SDK, or probe binaries.
