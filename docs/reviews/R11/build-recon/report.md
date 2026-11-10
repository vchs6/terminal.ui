# Linux CJPM macro + TOML dependency recon

Date: 2026-11-10 UTC. Scope: isolated build/dependency evidence, no product implementation or formal tests. Main repository reference `31a7017e6bb522e3f4bcabd2f01abe1d81ea2170`; main manifest was not edited. Read its AGENTS.md and theme-config.md. SDK and CJPM both 1.2.0, x86_64-unknown-linux-gnu cjnative.

## Results

1. **Normal CJPM static library + macro subpackage works automatically.** No custom compiler options or build hook are necessary on this SDK. Ordinary external path consumer imports both `macro_lib.*` and `macro_lib.macros.*` and runs `@Twice(21)` successfully. Source bundle contains macro source; a separate fresh consumer of the extracted bundle builds and runs successfully.
2. **Central registry `cangjie_toml = 0.2.3` is usable with SDK 1.2.0 and official stdx 1.2.0-beta.02.1.** Public parse APIs handle the TOML shapes needed for typed variable records, reference records, styles, nested component states and reset records. Public parse errors include key path, reason, line/column and source range. No TOML parser implementation or source patch was needed.
3. TOML requires explicit official stdx installation/environment setup. It is not an SDK-only dependency. The package's published Linux path template uses an older directory layout; the successful environment uses a directory symlink to the unchanged official release. This is a concrete environment requirement for later integration and distribution.

## Reproduction and retained evidence

All build/parse commands are in `commands.jsonl`, each with cwd, exact command, UTC and process exit. `probe-run.py` sources the SDK for each command and writes merged stdout/stderr to `raw/<name>.log`. `sourcehash.json` contains SHA256 for probe source, final manifests, extracted package source, registry TOML source, source bundle, official stdx archive, relay and environment setup. Source identity is content-based because this directory is an independent probe, not a main-repository change.

Relevant recorded commands:

| Name | Exit | Meaning |
|---|---:|---|
| init | 1 | Unsupported positional directory to cjpm init; corrected with documented `--path` |
| init-path | 0 | Both modules initialized with SDK cjpm init |
| macro-subpackage | 0 | Initial explicit package compile-option proof |
| macro-auto | 0 | Consumer clean/run after removing all macro compile-option configuration |
| macro-bundle | 1 | Packaging rejects missing README; no macro failure |
| macro-bundle-readme | 0 | Normal cjpm bundle source distribution |
| macro-bundle-consumer | 0 | Fresh consumer imports extracted source package; no target/lock copied |
| registry-toml-index | 22 | No package named toml at central index |
| registry-toml4cj-index | 22 | No package named toml4cj at central index |
| registry-cangjie-toml-index | 0 | Exact central version metadata |
| toml-fetch-build | 1 | Missing CANGJIE_STDX_PATH directory, retained original diagnostic |
| stdx-plan / stdx-install | 0 | Official matching stdx selected/downloaded/configured by CangjieSkills |
| toml-stdx-build | 0 | Clean SDK1.2 build with unchanged central package source |
| toml-public-parse | 0 | Positive parse/data extraction + three negative diagnostics |
| frozen-environment | 0 | Exact SDK, relay liveness, bundle contents and runtime link resolution |

## Macro layout and build boundary

`macro_lib/cjpm.toml` is a normal `output-type = "static"` SDK-generated manifest with empty compile-option. `macro_lib/src/lib.cj` is an ordinary public function. `macro_lib/src/macros/twice.cj` declares `macro package macro_lib.macros` and a public macro with `std.ast.Tokens` input/output. `macro_consumer/cjpm.toml` has only this dependency:

```toml
[dependencies]
macro_lib = { path = "../macro_lib" }
```

Consumer source imports the public runtime and macro packages and prints `answer=42; macro=42`. In `raw/macro-auto.log` CJPM itself invokes `cjc --compile-macro` for the macro subpackage and supplies its generated directory when compiling the consumer. There are no consumer flags, manually compiled macro libraries, outside build products or build.cj scripts.

`cjpm bundle --skip-test --skip-lint -V` builds and creates `macro_lib/target/macro_lib-1.0.0.cjp`, a gzip tar source archive containing only source, manifest and README. `unpacked/macro_lib-1.0.0` was extracted from this archive. `bundle_consumer` was copied without target or lock and its dependency changed to that extracted path. Its run compiles both library packages into its own target and prints the same successful output. The frozen bundle and final manifest contain no explicit macro flags. Skipped formal tests/lint are explicit: this is a build packaging probe, not a product release qualification.

This validates normal macro distribution/build mechanics only. It does not establish Component/State/Bind AST transformations, re-export convenience, runtime state semantics or language editor support; those belong to the independent language probes.

## TOML package and SDK compatibility

Central source package: `cangjie_toml`, version `0.2.3`, advertised cjc-version `1.1.0`, no source dependencies. Index sha256sum `297998b23b08f2a43bb6821765c8991b3a078ceb31649068e777db8cb8a5f398`. Exact fetched index is retained at `cache/repository/index/default/ca/ng/cangjie_toml`; exact fetched source is retained at `cache/repository/source/default/cangjie_toml-0.2.3`, and all its files are hashed. Registry source was neither edited nor replaced. `toml_probe/cjpm.lock` freezes 0.2.3.

Official stdx selected by fixed CangjieSkills `277f2e1234ca5217496966887243c679653887a8`:

- Version `1.2.0-beta.02.1` (the skill's SDK1.2 mapping).
- URL `https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.2.0-beta.02.1/cangjie-stdx-linux-x64-1.2.0-beta.02.1.zip`.
- Archive SHA256 `0d35811d84a770315c6fa2d1090a10568b3f7c763a1d1d54a1433b324f76afc0`.
- Install `stdx/cangjie-stdx-linux-x64-1.2.0-beta.02.1`; binary root `static/stdx`.
- Probe manifest has normal target bin-dependencies path to that static stdx. The published TOML package also expects `${CANGJIE_STDX_PATH}/linux_x86_64_llvm/static/stdx`; `stdx-env/linux_x86_64_llvm` is a symlink to the install. `source env.sh` sets SDK plus CANGJIE_STDX_PATH. No private compiler flag is used.

The SDK-only knowledge search did not expose a TOML std/stdx API; this probe selects the central registry implementation rather than inferring an unavailable standard parser. The old `toml4cj` repository readme describes deprecated pre-1.0 partial Boolean/integer/string decoding and is not the tested choice.

### Public APIs exercised

Imports:

```cangjie
import cangjie_toml.cangjie_toml.*
import cangjie_toml.cangjie_toml.parser.*
import stdx.serialization.serialization.*
```

- `DataModel.fromToml(input: String): DataModel` uses TOML 1.0 syntax. `DataModelStruct.get` plus public `deserialize` APIs extract typed values.
- `Parser(input)`; `parse(): Unit`; public `result`, `keyInfo: HashMap<String, KeyInfo>`, `orderedKeys` and `implicitKeys` expose structured parse metadata.
- `ParseException` has public `err`, `position`, `lastKey`, and message.
- `Position` has public `line`, `start`, `len`, `col`; `withCol(input.toRuneArray())` computes a column for successful `keyInfo` metadata. `start`/`len` are Rune indices/ranges, not UTF-8 byte offsets. `keyInfo` positions identify a value token; this probe does not claim a complete key-declaration source span.

Observed output from the unchanged final probe source:

```text
positive typed/ref/style/state/reset=true
metadata styles.emphasis.bold: line=8 col=8 start=164 len=4
negative duplicate: line=3 col=1 start=19 len=4 key=text.bold; toml: at line 3, col 1, last key 'text.bold': key 'text.bold' has already been defined
negative syntax: line=2 col=22 start=28 len=1 key=text.foreground.ref; toml: at line 2, col 22, last key 'text.foreground.ref': expected value but got '}' instead
negative unterminated: line=1 col=13 start=12 len=1 key=name; toml: at line 1, col 13, last key 'name': strings cannot contain newline characters
```

These are syntax/data-shape probes only. Unknown theme keys, ref/type consistency, range checks, duplicate semantic definitions, explicit reset interpretation, transactional replacement and retained previous theme require product schema validation. The chosen upstream parser provides the parse tree and usable diagnostics; no evidence here authorizes claiming complete TOML compliance beyond exercised cases. The probe binary links static stdx serialization and ordinary SDK/system libraries; `ldd` after sourcing SDK resolves all libraries and shows no JavaScript runtime.

## Reusable relay and isolated cache

Relay script `/workspace/work/linux-build-recon/registry-relay.mjs` is the existing reviewed registry adapter copied unchanged from main evidence. It invokes curl to `https://pkg.cangjie-lang.cn/registry` with inherited proxy/CA trust and forwards only GET `/index/...` or `/pkg/...`. Current independent listener `127.0.0.1:18973` is live (PTY session 15874), started as:

```bash
PROBE_RELAY_PORT=18973 node /workspace/work/linux-build-recon/registry-relay.mjs
```

Later roles can use this relay with **their own** private cache and ignored `cangjie-repo.toml`:

```toml
[repository.cache]
path = "/absolute/path/to/role-private-cache"
[repository.home]
registry = "http://127.0.0.1:18973"
version = 0
```

This recon copied the readonly seed cache once and fetched TOML into that copy. No shared cache or shared relay was changed. `.gitignore` excludes cache, official SDK extension binary directories, targets, locks and per-machine registry config. The network environment was inspected through cloud runtime skill: current observations ready, unrestricted policy enforced; curl inherited provided proxy and CA settings.

The original shared 18972 listener stopped responding during initial discovery; its process was not killed or modified by this task. New 18973 listener is an external development fetch adapter only and is not a product runtime dependency. Stop it only when later roles no longer need it.

## Additional clean CJP consumer proof and user setup

Compatibility scope is **Linux x86_64, glibc, cjnative SDK1.2.0 only**. This executor reports glibc 2.41. No cross-CPU or other-platform compatibility is implied.

`toml_lib` is an independent thin static-library probe returning a parsed String; it is not a proposed theme implementation. It declares only central TOML and normal public target bin-dependencies:

```toml
[dependencies]
cangjie_toml = { version = "0.2.3" }
[target.x86_64-unknown-linux-gnu.bin-dependencies]
path-option = ["${CANGJIE_STDX_PATH}/linux_x86_64_llvm/static/stdx"]
```

`toml-lib-bundle` exit 0 builds and bundles this library. `unpacked/toml_lib-1.0.0` comes from that source .cjp. `toml_bundle_consumer` was initialized anew, with no target/lock copied; its only dependency is ordinary `toml_lib = { path = "../unpacked/toml_lib-1.0.0" }`. Its private `cache-bundle` was copied from the original seed before TOML was fetched, so it fetched central TOML independently. `toml-bundle-consumer` exit 0 compiles all dependencies into the new target and prints `bundle-name=fresh-cjp`. The consumer manifest does not contain any stdx/compiler/link flags; normal transitive bin-dependency metadata and the declared SDK/stdx environment suffice. The bundle contains source, README and manifest, with no binary artifacts or per-machine registry configuration.

The extra `linux_x86_64_llvm` directory is required because central `cangjie_toml 0.2.3` publishes that exact CANGJIE_STDX_PATH expansion in its Linux manifest. The current official 1.2 stdx archive instead has `static/stdx` directly below its installation. A parent layout symlink reconciles those two existing layouts, without modifying upstream source or archive content.

Normal Linux user setup can use any writable directory, represented below as a task-specific `toml_sdk_root` (no system install required). Commands assume the already selected SDK and downloaded official ZIP with the URL/hash recorded above:

```bash
source /path/to/cangjie/envsetup.sh
# Option A: use the existing fixed CangjieSkills helper; no manifest editing is needed for transitive consumers.
python3 /path/to/CangjieSkills/scripts/setup_stdx.py \
  --project /path/to/consumer \
  --destination /path/to/user-owned/stdx \
  --linkage static --no-configure
# Its recorded official SDK1.2 install is:
# /path/to/user-owned/stdx/cangjie-stdx-linux-x64-1.2.0-beta.02.1
# Make the published package's expected layout explicit:
mkdir -p /path/to/user-owned/stdx-env
ln -s /path/to/user-owned/stdx/cangjie-stdx-linux-x64-1.2.0-beta.02.1 \
  /path/to/user-owned/stdx-env/linux_x86_64_llvm
export CANGJIE_STDX_PATH=/path/to/user-owned/stdx-env
cd /path/to/consumer
cjpm run
```

Option B is to verify/download and extract that exact official ZIP directly, then create the same parent layout and set CANGJIE_STDX_PATH. The helper performs download, extraction and install metadata recording; it is development convenience, not a mandatory product dependency. For direct application code that imports stdx, add the same public target bin-dependencies declaration shown above. For a consumer using only the wrapper library API, the successful fresh CJP consumer proves the transitive declaration suffices.

This session's reusable environment is `source /workspace/work/linux-build-recon/env.sh`, with official binaries at `/workspace/work/linux-build-recon/stdx/cangjie-stdx-linux-x64-1.2.0-beta.02.1/static/stdx`. Later independent roles may reuse these readonly official binaries while retaining their own dependency cache and target. Their product-facing build instructions should declare SDK + stdx + CANGJIE_STDX_PATH and the layout requirement explicitly.
