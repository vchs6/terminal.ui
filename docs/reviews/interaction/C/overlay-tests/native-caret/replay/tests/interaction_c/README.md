# Generic overlay test PREPARATION (TASK108)

**PREPARATION/BLOCKED. Not a complete TASK108, TASK109 admission, product RED,
product PASS, native PASS or host PASS.** Independent test-only scope is
`tests/interaction_c/` plus its evidence. Product/spec/main and old tests are
unchanged. No standard Modal/Menu wrapper, mouse, Scrollbar or window manager.

Frozen starting source: `27f9c8c01dd4caf92dc2389a2f386231fce6464b`.
Authority: `openspec/changes/implement-public-interaction/design.md`, C with
intersecting I001–I015; tasks TASK108.S1–S4/C-01–C-05, plus its three specs. The
separate I014/I015/F007 reviews are design evidence only. Actual dependency
acceptance/source and interface-map are still missing from this test handoff.
Older accepted runtime/Rich work may exist elsewhere; this role has not received
their fixed accepting hashes and does not replace root's acceptance record.

Source consumers deliberately use normal public `cjtui.*`, Component subclass
build, Column/Canvas, NodeRef, Application and exact formal C options/handles.
`SettingsPanel` is one class in its own file, reused as distinct ordinary/layer
instances with one business Observable. There are no private nodes/hooks, extra
renderer, cloned business model or product repairs. No declaration stub is run.
Prepared source is syntax-formatted but **not type-compiled or executed against
actual A/B/C**. All source and recipe status is enumerated in case-matrix.md.
golden.md records manually derived literal grids, trace, focus and identity.
native-host-recipe.md explicitly separates future real evidence and infrastructure
negative controls. Recipe-only vectors must be finished before a formal freeze.

Source SDK1.2 environment, then use the ordinary entry:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
bash tests/interaction_c/run.sh preparation
# Current expected status: 77; prints every actual-source/test-freeze blocker.
bash tests/interaction_c/run.sh
# Current expected status: 77, with NO overlay build/execution.

# Separate existing-public-API sanity only, already available at the base:
bash tests/interaction_c/run.sh baseline
# Internally: cd tests/interaction_c/baseline; cjpm build
# TERM=dumb COLORTERM= timeout 45s ./target/release/bin/main </dev/null
# Expected direct status: 0. Does not use any overlay API or prove C behavior.
```

Own ignored `cangjie-repo.toml` is needed in root, this consumer and baseline,
using an own writable cache seeded read-only from
`/workspace/work/validation/replay-dependencies/cache` and existing registry
`http://127.0.0.1:18973`. No SDK, relay or product dependency is added. Tests do not
modify the seed. Current role's cache is `/workspace/work/overlay-tests/cache`.

When root supplies actual accepted inputs and public signature mapping, this
same test role resumes: finish recipe sources through those public APIs, compile
normally, retain baseline GREEN and actual missing-C RED/error classification,
freeze test-only commit/manifest. Only then update admission.tsv with accepted
source commits present in the tested history and actual fixed evidence paths.
`TEST_FREEZE` remains PREPARATION until that work is done. There is no environment
bypass. Root must not mark all rows accepted just to run these prepared sources.
With real inputs frozen, formal entry internally runs:

```sh
cd tests/interaction_c
cjpm build
TERM=dumb COLORTERM= timeout 45s ./target/release/bin/main </dev/null
```

Compiler/linker errors, nonzero actual binary exits, timeouts and missing binary
are failures. Missing accepted upstream APIs before that barrier are BLOCKED,
not target overlay RED. Declaration-only compile can prove SDK language shape
only, must use separate isolated paths, and must never be run as product.
`cjfmt` may report syntax errors while returning0: both stdout/stderr must be
checked; formatting alone never proves type correctness.

Tools-only gate negative control: `bash tests/interaction_c/gate-selftest.sh`.
It confirms both entry modes return77 without invoking a sentinel compiler,
and invalid mode returns64. It does not build or execute any product stub and
cannot establish overlay/native/host results.

## Current final preparation

The preceding text is the preserved historical preparation statement; its old
unresolved-input list is superseded for this new snapshot by
[final-preparation.md](final-preparation.md). The original admission table is
still closed: B107 acceptance/formal108/109 are pending. C behavior is entirely
UNEXECUTED. The new sources complete the original recipe scopes through public
consumers; missing C declarations still prevent full product type checking.
No declaration stub substitutes for those missing APIs.

After sourcing SDK1.2 and the shared stdx/UCD environment:

```sh
bash tests/interaction_c/run.sh baseline          # ordinary build + direct0
bash tests/interaction_c/run.sh api-probe         # ordinary build: missing C API RED
bash tests/interaction_c/run.sh fixture-controls  # tools-only negative controls
bash tests/interaction_c/gate-selftest.sh         # closed admission; no product build
```

`main.cj` invokes all headless C groups once C exists. `CJTUI_OVERLAY_NATIVE`
selects the real public native consumer for the driver, not a gate bypass.
Future admitted `device` requires `CJTUI_OVERLAY_EVIDENCE`, builds normally, then
runs `pty_driver.py`. It imports the established B PTY recorder utilities;
readiness requires raw mode, the genuine mode25 query and the first literal
BASE-OVERLAY-READY frame. Mount files and final trace files are callback barriers.
Missing binary/acknowledgement, timeout, nonzero child status, altered trace,
missing cleanup or termios difference fails. No sleep infers a committed layer.

## Formal TASK108 admission after accepted B107

`admission.current.tsv/json` is the current eight-gate test admission. The old
`admission.tsv` and earlier preparation records stay historical. ACCEPTED here
means prerequisites and test freeze, not C product behavior. The current JSON
binds accepted620/integrated9cf and frozen b134 consumer code, the original
preparation/declaration manifests and remaining scope limits.

The entry automatically prefers the current table; invalid current data is a
hard77, with no fallback or environment override. Only absence selects the old
closed table. Every required gate must occur once, have ACCEPTED/full commit
SHA/actual HEAD ancestry/existing evidence. Relative evidence resolves from the
repository root, independently of the caller's current directory.
`preparation` now validates the current admission and returns0 without compiling.
Default/formal still uses normal `cjpm build`, then direct binary only on build0.
Before C implementation, the existing actual missing-C compiler RED applies;
C behavior remains UNEXECUTED. `gate-selftest.sh` exercises accepted metadata,
rejection cases, legacy fallback and nonzero-compiler/no-binary boundaries using
tools-only sentinels in an isolated small Git fixture, never a C implementation.


## Targeted pure-export / active-turn regressions

Compile normally with `cd tests/interaction_c && cjpm build`, then run each
actual binary independently from the repository root:

```sh
CJTUI_OVERLAY_REGRESSION=pure-export timeout 45s tests/interaction_c/target/release/bin/main
CJTUI_OVERLAY_REGRESSION=open-turn timeout 45s tests/interaction_c/target/release/bin/main
```

Expected0 once those contracts are implemented; nonzero is an assertion/build
failure, never skipped. Default formal consumer also invokes both new cases.
No old oracle or guard precedence is changed. X01 uses a legal batch ensure
followed by an outer-boundary export, not forbidden render reentry in batch.

## TASK110 review regression supplement (C-I01–C-I10)

The added public assertions are in `src/review_regressions.cj`. Build once with
`cd tests/interaction_c && cjpm build`; run every selector independently from
that directory so an earlier assertion cannot hide another finding:

```sh
for id in C-I01 C-I02 C-I03 C-I04 C-I05 C-I06 C-I07 C-I08 C-I09 C-I10; do
  CJTUI_OVERLAY_REVIEW="$id" timeout 45s ./target/release/bin/main </dev/null
done
```

Each selector expects status 0 after its contract is implemented; a nonzero
assertion is a failure, never a skip. The default consumer also invokes all ten.
I02 observes both If and ForEach retirement before asserting; I03 records hidden
and disabled states before asserting. I10 performs its first two pure exports
without any preceding Application.snapshot, then checks resized exports after
an actual committed application frame. All expected pictures are hand derived
in golden.md. No old assertion or oracle is changed.

I09 follows the explicit diagnostic ruling for this supplement: Passive is not
a keyboard target; reject dispatch with existing `InvalidProperty`, with zero
owner handler calls, after a normal NonModal positive control.
I05 asserts failed theme transaction, Old identity, live session and unchanged
usable zero-area picture. Prohibiting user measure/draw during candidate
preflight remains a source-review responsibility: normal snapshot itself may
legitimately call those callbacks, so total calls across snapshots are not a
valid zero-call oracle. Full Unit C/native/package acceptance is separate.

## Round2 narrow fix-delta regressions

`src/round2_review_regressions.cj` appends only R1-I01 and R1-I02. Build normally
once (`cd tests/interaction_c && cjpm build`), then run each actual selector
independently in that directory:

```sh
CJTUI_OVERLAY_REVIEW_R2=R1-I01 timeout 45s ./target/release/bin/main </dev/null
CJTUI_OVERLAY_REVIEW_R2=R1-I02 timeout 45s ./target/release/bin/main </dev/null
```

Expected direct status is0 after the contracts are satisfied; nonzero is a real
failure, never skipped. Default formal entry also appends both cases. R1-I01
first proves ordinary deletion still follows A's NEXT successor, then checks
owned-modal closure uses C.4's nearest surviving ancestor FIRST priority.
R1-I02 independently checks both default and explicit root host against literal
`B P  ` on the actual5×1 frame with a fixed1×1 ordinary root. Existing oracles
and prior selector bodies are unchanged. Print-only review probes are concrete
reproduction material, not asserting RED or acceptance evidence.

## C03 native caret occlusion supplement (one vector)

`CJTUI_OVERLAY_NATIVE_CARET=opaque` selects `native_caret_fixture.cj` before
other entries, independently of the unchanged H01 `CJTUI_OVERLAY_NATIVE` modes.
Use normal `cd tests/interaction_c && cjpm build`; the final native executable
is the same public consumer binary. In an actual terminal of at least8×3:

```sh
mkdir -p /absolute/output-directory
CJTUI_OVERLAY_NATIVE_CARET=opaque CJTUI_OVERLAY_CARET_OUTPUT=/absolute/output-directory ./tests/interaction_c/target/release/bin/main
```

| Stage | Input | Hand-derived body8×3 / logical caret |
|---|---|---|
| base | after first paint, `s` | `ABCDEFGH` / `ijklmnop` / `QRSTUVWX`; visible owner=base at(3,1) |
| covered | `o`, observe paint, then `s` | `ABCDEFGH` / `ij   nop` / `QRSTUVWX`; canonical hidden owner=None at(0,0) |
| restored | `c`, observe paint, then `s` | original three rows; original base caret(3,1) visible again |
| exit | after restored query, `q` | actual process exits0, all resources0, base cleanup once, termios restored |

The ordinary Canvas body is fixed8×3 with a non-root explicit overlayHost;
Passive centered3×1 opaque spaces cover columns2..4 of its middle row without
changing logical focus. No native selector prints or hand-writes terminal
ANSI. `s` only reads public `caretSnapshot` and immutable `terminalCapabilities`
from the previously completed frame. `Application.snapshot/render` cannot be
reentered from run callbacks. `action-*` files only acknowledge queued
commands: they are never paint fences. Collectors must first observe actual
painted rows, then send the separate `s` key and await its complete `state-*`
file; the single native UI loop completes the preceding writer transaction
before it can process that query. Preserve raw input/output and fence offsets.

A plain PTY controlled reply may be verified with the existing B primitives:

```sh
python3 tests/interaction_c/native_caret_pty.py --binary tests/interaction_c/target/release/bin/main --output /new/absolute/capture --cursor-reply 1
```

This recorder freezes the literal changed row1=`ij   nop` then `ijklmnop`, and
known-mode CUP at ANSI2;4, hide/show, original-mode cleanup, actual exit and
exact termios. Reply1 means controlled original-visible;2 means original-hidden;
none waits for the actual public Unknown diagnostic. These are one logical
vector's I015 capability classifications, not extra product scenarios.
On real XTerm/VTE let the real host reply: capture actual visibility/CUP and
original-state restoration with native wire and PNG evidence. With kernelVT
Unknown, all paths must have zero25h/l/s/r; the logical hidden state still
passes, but a physically visible native cursor is unmanaged/insufficient
physical-hide evidence, never a claimed hide success. Capture immutable
cursorVisibilityStatus and savedCursorStatus, real host dimensions/config,
true executable hash/exit/termios and stage screenshots separately. Do not
inject a synthetic known reply while claiming an actual-host capability.
