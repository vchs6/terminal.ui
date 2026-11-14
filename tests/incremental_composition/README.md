# Incremental composition public consumer — TASK138

The consumer was normally built and directly executed against accepted C137
source `ee84e7ac7a35bb6481a17ecb91f1ec07804b672a` after root capacity GO. Final
baseline: all 15 domains completed with zero correctness failures and 14 expected
work RED assertions in row replay, hide/show/removal and cached-caret domains.
The process correctly exits 1 for that work RED; this is not a passing D product.
Raw build/run evidence and the initial fixture correction are indexed at
`/workspace/work/incremental-composition-tests/index.json` in the test workspace.
It consumes only `import cjtui.*` through
the ordinary CJPM path dependency, with no package-local test code, native
adapter, rendering mode switch or new product flag. Existing tests are unchanged.

For reproduction, source the SDK environment and set the established stdx/UCD
environment, then use `bash tests/incremental_composition/run.sh build` and
`bash tests/incremental_composition/run.sh run`. The executable requires no TTY.
`run.sh` itself does not set SDK, registry, cache or product configuration.

## Public functional and work oracles

Every application action is synchronous, committed by public `batch`, and
increments a business epoch. No external producer writes during a pair. Each pair
captures M2 observations first, renders the same mounted root with the same size
and glyph mode using full M1, verifies unchanged epoch, and compares dimensions
and every Cell's grapheme, width, continuation, complete raw Style and opacity.
Both frames separately match literal Cell arrays. Expected arrays enumerate
individual cells; they neither parse strings nor implement width/layout rules.
Caret assertions use `Application.caretSnapshot` and public NodeRef identities.
The pair also verifies that full M1 preserves the application's caret result.

DrawProbe records only callback allocation, local clip and default style. Every
target callback must run at most once. Exact 0/1 counts follow the literal geometry
below. M1 callbacks are recorded separately after saving the target observations;
their work cannot satisfy or fail target count assertions. `WORK_RED` accumulates
without throwing, so all subsequent functional actions still execute. Functional
assertions also accumulate; an unexpected exception is reported separately and
the next domain still executes. Any correctness/work failure makes exit nonzero.
These are contract work counts, without time/CPU thresholds or performance claims.

| Domain / function | Frozen geometry and independent obligation |
| --- | --- |
| `rowReplay` | Two rows, 8 columns. First row is three Canvas boxes 3+2+3. Shorten ABC→A→empty: all three same-row callbacks once, second-row callback zero. Clean target after M1 invokes none. |
| `movesAndRemoval` | Four rows, 4 columns. A two-row Canvas moves from rows 0–1 to 2–3. Hide/show/remove restore blank old rows while the surviving rows 0–1 remain untouched. Removed NodeRef becomes invalid. |
| `surfacesAndLatest` | 8×3 base, centered 3×1 layer at (2,1). X at local 0, optional opaque default blank at 1, hole at 2. Blue local background fills holes; Unset removes fill. Lowercase→uppercase base changes under a clean foreground and close reveals current values. Base callback always sees full 8×3 context, including single-row damage. |
| `descendantShadows` | 8×5 base, transparent 4×3 parent centered (2,1), child 2×1 at (2,1). Its dim shadow at (3–4,2) must survive lower-row change; offset 2 moves it to (4–5,2). Parent itself has no opaque paint, so subtree bounds must include descendant shadow. Disable/close clear old shadow. |
| `movedShadowLayer` | Centered 2×1 layer and dim shadow in 8×5 then 10×5. Body moves x=3→4, shadow x=4–5→5–6. Literal old/new cells and all shadow styles are checked. |
| `widePartners` | Base row `ab界efgh`, centered 3-cell layer at x=2. A one-cell opaque write at target continuation x=3 clears partner x=2. Negative Canvas source position skips the complete clipped cluster and preserves subsequent Q. Right-clipped wide source writes neither half. |
| `negativeFrameTransfer` | Public Frame composition at x=-1 turns a clipped source half into one opaque red blank. A transparent hole on a target continuation preserves its cluster; an opaque blank clears both target partners. Explicit canonical transparency metadata checked. |
| `scrollAndAnchor` | Header row, 6×2 viewport, footer row. Anchor B scrolls screen y=2→1, moving BelowStart popup y=3→2 and restoring its old footer row. Scroll to 2 clips anchor completely, closes AnchorGone and restores latest C/D rows. |
| `viewportCaret` | Focused 6×4 Canvas within 6×2 viewport; the ScrollView wrapper is explicitly nonfocusable because it otherwise owns initial focus. Local caret (1,2) starts clipped; offset 1 maps to screen (1,1). Resize to width 3 changes allocation/clip; offset 2 maps to (1,0). Local context clip remains (0,offset,width,2), never damage-shaped. |
| `cachedCaretAndOwnership` | 6×3. Unrelated second-row change skips first-row Canvas but preserves its caret. Caret-only movement leaves all grid Cells identical. Empty passive host layer preserves caret; opaque default StyledSpace at the same blank cell hides it without any grid change. Close/focus/hide/show/remove independently verify ownership and no stale resurrection. |
| `invalidCaretRequests` | Literal wide leader/continuation plus blanks. Leader caret valid; continuation, right edge, negative and explicit invisible requests normalize to hidden. |
| `nestedModalClose` | 6×3 base, centered 4×1 parent and 2×1 child modals. Both lower layers change while covered. Child close exposes latest parent; parent close closes attached replacement child, invalidates both identities and restores current base/caret. Stable target afterward draws none. |
| `layeredGlyphPolicy` | Ellipsis width 5, centered transparent layer writes X at column 1. Unicode→Ascii→Unicode yields literal `aXcd…`→`aX...`→`aXcd…`, with same-policy M1 pairs and intersecting clean layer replay. |
| `rootFallbackLayers` | Real implicit root overflow: four one-row children in 4×2. Public root scroll to 2 retains centered popup and pairs the actual C/D viewport with mounted M1. No detached/reference-only tree evades fallback. |
| `shadowCaretOcclusion` | Base caret (6,2), transparent 4×3 layer centered (2,1). Its opaque dim right shadow covers caret; closing restores the live base request. Literal complete shadow grid checked. |

## Existing recovery/profile matrix and source proof

These paths are existing fixtures in the full repository. They are intentionally
not copied, adapted or edited here. Independent execution must fix their actual
source hashes with accepted C137/D product input; no execution is claimed now.

| D contract inaccessible through normal public APIs | Existing executable proof / required source review |
| --- | --- |
| Complete successful device transactions; caret-only CUP; same frame/profile/caret zero output | `tests/output_recovery/run.sh build`, then `CJTUI_RECOVERY_ARTIFACTS=<new-dir> bash tests/output_recovery/run.sh run --normal`. Preserve strict `normal-caret` no-redundant-CUP assertion; it remains meaningful with a clean M2 target. |
| Partial UTF-8/CUP/SGR/reset/mode write, EIO/zero k=0 and k>0, success short/EINTR retry, first-error and cleanup fences | Full unchanged `tests/output_recovery/run.sh run` matrix. Existing fault driver cuts actual production writer transactions and checks exact raw bytes, unsafe latch, same-process reopen, termios/signals and UI/native cleanup. Fatal partial output stops the session; a public continuing-baseline probe would violate 008. |
| Clean compute cache but pending display debt after output allocation failure | Existing `allocation-full-retry` mode 5 in the full output recovery matrix: current target already computed, first output buffer allocation fails before bytes, retry emits the complete literal target. Source proof must verify compute cache cannot clear output resync debt. |
| Resize and effective profile transitions | Existing `run --supplement` covers coherent 4→2→5→4 size/full target changes, monochrome transition and same-effective-profile silence. Public resize target Cells also covered above. |
| M011 中→文 and 中→?? project to identical two question columns; old/new glyph profile belong to their own baselines | Existing `bash tests/glyphs/run.sh internal`, especially `glyph_device_diff_compares_projected_rows`, `glyph_color_and_glyph_equivalence_is_silent`, `glyph_diff_projects_old_and_new_with_their_own_profiles`; conservative/uncertain-advance equivalents remain in `tests/glyphs/internal/glyph_conservative_test.cj` and `tests/glyph_advance/internal/advance_frame_test.cj`. These are legal existing package-local tests against actual production sources, with literal wire expectations. They are not a new public consumer hook. |
| Unknown/unrelated lineage and externally mutable snapshots | Existing glyph diff cases use unrelated Frame objects and same Frame with different profiles. Existing `tests/incremental_layout/frame_cow` and `tests/composition` prove public mutation/copy/partner isolation. New public tests verify saved raw Cells and target correctness, but cannot call private terminal diff. Exact D-source review is mandatory for arbitrary externally mutated baseline fallback, shared-row proof and any lineage token; combined evidence is not a fabricated direct public diff test. |
| Full target/frame/profile/size/caret baseline committed only after all successful output; partial failure forbids later cleanup bytes | Review fixed `Application.run` output/commit sequence, runtime target publication vs device baseline ownership, Frame row identity/revision gates, and native writer/parser-unsafe cleanup latch. `tests/output_recovery/README.md` defines this existing source-order proof because public frame counters count generated targets, not successful presentation. Review must trace actual code, not match source strings. |

No public arbitrary TerminalRenderProfile/diff API exists in the fixed input.
That is a coverage boundary with an explicit existing-harness/source mapping,
not grounds for adding production exposure. If a future product introduces a
lineage shortcut, its complete proof must be reviewed at the fixed source version.
Actual applicable TTY and complete 008 evidence remain for independent execution;
this headless consumer does not claim those results or overall M2 acceptance.
