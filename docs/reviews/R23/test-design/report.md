# TASK163 independent formal test / physical RED handoff

TASK163 has a fixed test-only deliverable and actual physical RED. It does not
claim a product fix or a new-source GUI PASS. TASK164 may consume the formal tests
subject to root's integration/admission decision.

- BASE product: `91c22f82adcd2412d9509b9872ff63450ba81af9`.
- Final contract: `1113ba186bc0ff72fd4c6c91a0e17fc3f19c69c5`, design A001–A008.
- Test-only commit: **`614d0a2f0e33e54ecc07bd783eaeb0b9957ca557`**.
- Independent checkout: `/workspace/work/glyph-advance-tests/source`.
- Formal entry: `tests/glyph_advance/run.sh`; complete instructions in its README.
- Manifest SHA256: `37dde6bf38f220d9188379a06a233e138bf7161acb8a754b8b14cb7194fbcfeb` for `tests/glyph_advance/artifacts.sha256`.
- Machine summary: [summary.json](summary.json); incremental [progress.md](progress.md).

This is an execution task against the admitted fixed contract. I did not edit
product, old tests, specifications, main checkout or run-slice scripts; I did
not communicate with the product author or create subagents. The role assignment
was Sol/high; serving identity is not externally authenticated here. Skills
actually read/applied: TDD, verification-before-completion, cloud environment
runtime, and the read-only Cangjie coding skill/search_docs. using-superpowers
was read and its dispatched-subagent exemption applies. The existing approved
OpenSpec task/contract was consumed, not recreated. AGENTS14 organization and
AGENTS11.1 evidence reuse apply.

## Scope and source provenance

[Source provenance](raw/source-provenance.json) verifies every tracked product
file under `src`, `native`, `build.cj` and `cjpm.toml` against fixed91 Git blobs.
All those product bytes are also identical to the final1113 contract commit.
The unmodified rich example source is SHA256
`dff0d2bca92115d1d2c2f1d9c8412e2cb94d95844ec33c5af6037144437fb8b3`.
Its original083 executable is still present and verified as
`589ee5424b0abfed5a91bc2c7526a288441e98e8ac048b9f33d60a56841cf048`.
The new public consumer executable is independently built from fixed91 and has
SHA256 `fae174356a8975f4c2d134011911ffae0c2d72836d54ca15b523545b0e2261f7`;
its source SHA256 is recorded in provenance and both actual GUI host records.
No ELF, cache, source checkout, SDK or repository Markdown snapshot is committed.
The 240 committed files all belong to `tests/glyph_advance/`; 239 artifact entries
exclude the manifest itself. Existing product and rich/Frame/Unicode/color
assertions are unchanged. The generated root `cjpm.lock` remains untracked in the
independent checkout and was not integrated; an evidence copy is outside Git at
[dependency-lock.toml](raw/dependency-lock.toml).

CJC/CJPM actually report 1.2.0, target x86_64-unknown-linux-gnu. Environment source:
`/workspace/work/validation/sdk/cangjie/envsetup.sh`; UCD17 archive:
`/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip`; exact hashes are
in provenance. Root and public consumer each received ignored normal CJPM config
using an own cache `/workspace/work/glyph-advance-tests/cache`, copied read-only
from `/workspace/work/validation/replay-dependencies/cache`, and existing relay
`http://127.0.0.1:18973`. No relay was created and no dependency/FFI rescue flags
or public test setters were added. Actual locked dependency versions are the
existing ansies1.3.113/unicode0.1.0/unicodewidth0.1.113 and their normal transitive
packages. [Dependency source hashes](raw/dependency-source-hashes.json) records113
normal-cache source/configuration files without compiled artifacts.

## Formal expectations and package results

The public consumer has **34 executed PASS checks**: literal canonical widths
and single grapheme counts for ten samples, unchanged Frame text/head columns,
exact default Unicode ANSI bytes, rich reactive/headless logical cells/styles,
and exact `writeAnsi`/`writePlainText` file bytes. `cjpm build` is followed by the
actual executable; no `cjpm run` exit masking or declaration-only run is used.

The package-local suite has **nine declared @Test groups**, including 20 literal
projection rows. It covers A003 preservation of ASCII/CJK/e+0301/single emoji/flag,
ZWJ/VS16/keycap whole-cluster `??`, all policies' zero/negative width behavior,
bounded excess/equal sums and helper widths above two; A004 full/diff canonical
columns, both directions of wide fallback versus two width1 question cells,
grouped styles, projected color equality, visible supported attributes, each
baseline's policy, equal-output policy switches, dimension changes, clipping,
real Frame budget, stored ambiguous-wide width, and zero-area extreme empty axes.
Device factory checks include all five color modes and unchanged capability
facts; snapshot/default profile checks retain offline Unicode. The helper's
large-width cases use a real bounded Frame extent and bounded strings. They do
not pretend that a multi-grapheme helper input is a reachable single Frame head,
or that bounded runtime cases exhaust unreachable Int64 addition overflow;
checked/saturating arithmetic remains an explicit source-review obligation.

The temporary source-copy/CJPM approach is the normal G010 same-package pattern:
actual product sources plus private tests are copied into scratch, tested, and
removed; real product visibility and files remain unchanged. A 10s per-case
limit prevents an enormous zero-width-height traversal from hanging indefinitely.

| Command / scope | Actual exit | Observation |
|---|---:|---|
| `cjpm build`, own fixed91 root | 0 | Normal old product build succeeds |
| `bash tests/glyph_advance/run.sh public` | 0 | Build plus actual binary, 34 PASS checks |
| `bash tests/glyph_advance/run.sh existing-device` | 1 | One test compiles and executes; offline assertion passes, device byte assertion fails |
| `CJTUI_ADVANCE_ALL_ERRORS=1 bash tests/glyph_advance/run.sh internal` | 1 | 24 expected missing-private-API compiler diagnostics, all printed |
| `bash tests/glyph_advance/run.sh fixture-controls` | 0 | 12 genuine control observations validated |
| `bash tests/glyph_advance/run.sh physical-old` | 1 | 16 actual old physical observations fail unchanged-row/position acceptance |
| Fresh original083-byte replay, actual two hosts | 0 driver / 1 oracle | Four ZWJ physical observations fail |
| New public VS16 actual GUI t/t/resize/t/q, two hosts | 0 driver | Normal application/host exits and exact restoration |
| Fresh public VS16-byte replay, actual two hosts | 0 driver / 1 oracle | Four suffix-position observations fail |

The existing-only device test uses only old private APIs, so its RED is an
executed expected-versus-actual assertion rather than missing API compilation.
The current check helper throws an exception named `FAIL`; CJPM labels it
**ERROR:1, PASSED:0, FAILED:0**, not a compiler or harness crash. Its first failing
mode is Monochrome; later modes in the loop are planned cases, not claimed as
executed old checks.

The complete private suite separately reports exactly: 11 undeclared
`projectTerminalGlyph`, six unknown named `glyphPolicy`, four undeclared
`GlyphRenderPolicy`, and three missing profile `glyphPolicy` fields. There are no
other compiler diagnostics. This API compile RED is not the physical RED and
does not establish new-source test GREEN. CJC's all-error diagnostic option was
applied only to the scratch manifest. Logs/argv/cwd/UTC/exits are in
[old-root-build](raw/old-root-build/execution.json),
[old-public-final](raw/old-public-final/execution.json),
[old-existing-device](raw/old-existing-device/execution.json) and
[old-internal-final](raw/old-internal-final/execution.json), with adjacent raw
stdout/stderr. The first public attempts had test-authoring setup errors (a
duplicate generated dependencies table, then a captured mutable local); those
logs remain under `raw/old-public` and `raw/old-public-retry`. They were corrected
before the actual 34-check successful run and are not product RED evidence.

## Real-host evidence and controls

The formal fixtures preserve **220 byte-identical original artifacts**, including
**70 complete original real-host PNGs** and **136 complete raw DSR replies**.
`physical/fixtures/origins.json` names each original path and SHA256. The base
116 DSR / 34 PNG recon record and original083's ten stage PNGs are independently
reused against unchanged source/config/scope. The fresh adapters add 20 DSR / 12
replay PNGs and the new public VS16 GUI's 14 PNGs (ten stage captures plus four
before/after-resize originals). No cropped, repainted, rescaled or reconstructed
image is presented as an original.

The oracle compares all row-four pixels at the actual frozen host cell geometry
(and extends the row to the actual resized window width). It validates each
complete DSR against raw input, input/output offsets and preceding query. It
never invokes pyte, wcwidth, product displayWidth, or another ANSI/grid model as
a physical oracle.

Both actual hosts are XTerm398 and XFCE4 Terminal1.1.4/VTE0.80.1, original
Monospace/font/geometry/locale configuration, Xorg dummy config and empty per-run
XDG state; exact versions, argv/config, dimensions, TERM/COLORTERM, PNG capture
UTC, native input/output, original/raw/restored termios and real exits are
retained in the fixtures and external raw directories. No production protocol,
DSR routing, clock, or advanced terminal mode changes were added.

The original R14T083001 remains observable on both hosts. The eight original
native green/red observations end at **4;3**, and original row four loses its
first two cells; six original083 green/red/post-resize-green PNG observations
also fail unchanged-row acceptance. Two original native VS16 suffix observations
end at **15;3**, versus literal expected **15;4**. These are the base oracle's 16
failures. Genuine causal controls accept CJK replacement and padding-minus-two
(eight observations ending at3;100 with row four unchanged) and reject deleting
only ZWJ (four observations still4;3 with corrupted row four). They prove the
oracle distinguishes safe and unsafe physical observations; these fixture
transformations are not product fixes or formal expected-value adjustments.

The fresh ZWJ driver replayed original083 bytes on the two real hosts and
reproduced **3;14** at the prefix boundary versus required **3;12**, then **4;3**
versus3;100 and changed row-four pixels, for both green and red. The new public
VS16 app independently exercised the opposite sign of error with no ZWJ on its
changed row. Both actual GUI sessions completed initial/t/t/resize/t/q with
successful exits/restoration. Replaying those actual captured bytes gives
**3;2** before suffix `Z` versus required **3;3**, four physical failures. Its
final3;100 and unchanged row four alone would misleadingly appear safe; the
prefix DSR catches the one-column under-advance. ASCII/CJK/combining/single
emoji/flag remain in the fixture's public row two and original initial bytes.

[Host driver invocations](raw/host-driver-invocations.json) record the exact CLI,
cwd, relevant environment, actual exit and retained host/capture UTC. Wrapper
start/end timestamps were not originally retained for those tool-invoked host
drivers, so the file accurately identifies host-metadata brackets or screenshot
capture UTC instead of inventing wrapper timestamps. Per-host actual argv,
start/end/capture UTC and restoration are preserved. The original083 binary hash
and new public executable/source hashes above establish the product-byte
lineage; native probe binaries are development artifacts with hashes recorded
in each host metadata and reproducible source, not committed ELF.

## Verification, handoff and limits

[Final verification](raw/final-verification.json) records fresh focused checks:
fixture integrity/control0; immutable old physical oracle1; both fresh-replay
fixture oracles1; public capture oracle1; shell syntax0; Python compilation0;
and native probe `cc -O2 -Wall -Wextra -Werror` compilation0. The committed
239-entry manifest and every one of the220 original fixture hashes were also
verified. The product/source relationship did not change, so the successful old
normal root build and public direct run are reused without cold full-suite
repetition. `git diff --check` flags 14 original window-dump EOF blank lines;
those raw bytes must remain intact. Excluding immutable fixtures, the source/test
diff whitespace check exits0.

Root can integrate the test-only commit, then admit a fresh independent164.
TASK164 owns product implementation and must not rewrite these literal expected
values to fit its code. TASK166 must build the fixed candidate, execute public
and all package tests, affected normal Frame/color/runtime/packaging paths, and
use the documented actual example and public VS16 GUI/DSR drivers against the
new source, including relevant explicit color overrides. A frozen old fixture
oracle intentionally stays RED and must not be treated as a new-product PASS.
The README supplies complete actual-host commands and distinct `verify_capture`
and `verify_replay` gates; the full real application session is separate from
native replay of its byte stream.

No claim is made that bounded scalar sums prove arbitrary fonts/Unicode/hosts,
that TASK094's future GlyphMode/nativeVT/marker APIs are implemented, or that
R14T083001 is fixed. New-product compilation, runtime/GUI GREEN and final
acceptance remain164/166/167 work. The independent actual old physical RED and
fixed formal tests required to start164 are delivered.
