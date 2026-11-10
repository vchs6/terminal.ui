# TASK-011 independent local review

- Round: R9-TASK011-local-1, execution review, 2026-11-10.
- Base: `87a45d467a0abf178a402547c6e5547df9b9c9fa`.
- Revision: `ba868f891a4d45e68deac93e140c1b59f27fd9a4`.
- Independent checkout: `/workspace/work/layout-review/repo`; detached at the revision above; product and test files were not changed.
- Scope: TASK-011 / AC-011, `openspec/changes/implement-layout-decoration/design.md` layout contract and D-024/D-025; task brief `/workspace/work/terminal.ui/.superpowers/sdd/tasks/task-2-brief.md`.
- Budget: at most three repair reviews or 60 minutes; one review, no repairs required.
- Process: AGENTS.md §§10.5, 11, 13.2; BATTLE_PROTOCOL.md; Superpowers requesting-code-review reviewer template and verification-before-completion. The task's explicit no-duplicate-test instruction and AGENTS.md §11.1 govern reuse. No subagents were dispatched. No author analysis/report was read.

## Verdicts

**Spec compliance: passed for this local code review.** No reproducible violation of the frozen TASK-011 contract was identified. This is not the final independent execution/acceptance of AC-011 or the combined layout/decoration change.

**Code quality: passed.** The changed path is coherent, old recursive measure/draw implementations are retired, and no parallel Frame/Unicode implementation or unrelated product changes were introduced. There are no must-fix findings; `findings.json` is empty.

## Contract checks

All source references below refer to the fixed revision above.

| Check | Evidence and conclusion |
|---|---|
| Public geometry and setters | `src/layout.cj:4–21`, `src/component.cj:14–36`: Rect preserves signed origins, rejects negative extents; setters return `this`, validate before mutation, and reject invalid target kinds/Stretch uses. Auto clears optional fixed size. |
| Actual viewport, fixed/min/nonflex | `src/layout.cj:125–130,159–178`: root and child sizes converge to their actual available axis, fixed/min precedence is explicit, declaration order is preserved. Zero sizes remain zero unless an explicit minimum requires more space. |
| Integer proportions | `src/layout.cj:66–80,118–153`: no Float arithmetic; sum overflow is diagnosed; nonflex/gaps are subtracted first; minima are clamped before summing; infeasible minima select the minimum ratio. Exact quotient/remainder uses bounded binary arithmetic. Largest-remainder ties retain declaration order. |
| Arithmetic safety | All calls of `sat` in this layout path receive nonnegative operands; `Int64.Max - b` is safe. `mulDiv` callers ensure `0 <= a <= d`, positive denominator and nonnegative amount; its partial quotient never exceeds the final amount. Shares plus minima and total used cannot exceed the pool. |
| Padding/gap/alignment | `src/layout.cj:90–104,155–170`: left/top padding consume space first without negative inner dimensions; gaps occur only between children; Center floors positive free space; Stretch applies only to auto cross sizes; overlong text starts at its original origin. |
| Unicode and control safety | `src/layout.cj:37–49,95–104`, existing `src/frame.cj` validation/put: every Text is validated before painting, including fully clipped or zero-size Text. Only whole grapheme clusters fitting the content/ancestor right edge reach Frame.put. LF/CRLF handling and style/continuation ownership reuse the established Frame path. |
| Background and inheritance | `src/layout.cj:84–94`: only explicit `bg != None` fills the outer box, including padding; `Some(Color.Default)` remains an explicit reset. Unset child background retains glyph inheritance without introducing its own box fill. Fill bounds are intersected before iteration, and empty visible width/height skips the loop. |
| One Frame / one recursive measure | `src/layout.cj:29–64,173–179`: one temporary measured tree per render and one Frame. Arrangement and painting are fused in one traversal; there is no repeated subtree measurement at each ancestor. Per-cluster width calls during paint do not rescan descendants. |
| Old behavior and retirement | Actual diff removes `measure(Component)` / `draw(Component,...)`; callers use the sole public `render`. Default spacing/padding/alignment preserve old visible content and text style inheritance; explicit background fill is the deliberate D-025 behavior. Existing R8 Frame/Unicode/session source is unchanged. |
| Scope/documentation | Only `src/component.cj`, new `src/layout.cj`, and layout usage in `docs/product/README.md` change. No native/session/dependency or test edits in the reviewed diff. |

## Evidence and reuse limits

1. Review package: `/workspace/work/terminal.ui/.superpowers/sdd/tasks/review-87a45d4..ba868f8.diff`; SHA-256 `214685ea5e42667acd8c3a263e91210df15258a512e0c17ff3f4ea122bf6363f`. Checked against the actual fixed git diff (3 files, 205 insertions, 51 deletions).
2. Fresh identity checks: `git diff --exit-code 09773a4de01b2b32f6a80ab9a7cdd001cdb58ea8 ba868f891a4d45e68deac93e140c1b59f27fd9a4 -- src` and `git diff --exit-code 7ce8c945791fced240ea4107ba60f36d01b487bd ba868f891a4d45e68deac93e140c1b59f27fd9a4 -- tests/layout` both returned exit 0 with no output. This establishes content identity for the reused final layout run.
3. Reused raw final layout log: `/workspace/work/terminal.ui/docs/reviews/R9/layout-development/final-layout.log`; SHA-256 `2a3e1fdf3d144f4a3bda58ce76fb0de57212f3e9fda01a7f419abfa6a93c9a20`. Read in full. Contains `cjpm build success` and all layout PASS output, including the near-equal extreme-weight `ABB` result, zero-size/clipped control rejection, and the final assertions. The coordinator supplied the exit-0 execution result and command: source SDK 1.2.0, set `CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip`, run `tests/run-slice.sh layout`. This is reused development execution evidence, not a run by this reviewer.
4. Old R8 raw suite log: `/workspace/work/terminal.ui/docs/reviews/R9/layout-development/suite.log`; SHA-256 `41497a9b50227f9528d4d78f18ef4e20d5eed130e9f9e0ca74d3657299613f45`. Only development regression reference: the coordinator states the empty-visible-background guard was added during that suite run. It is **not** treated as a whole-suite result on the final fixed revision. Final fixed-source independent execution remains the executor/acceptance role's responsibility.
5. Fresh tools check: sourcing `/workspace/work/validation/sdk/cangjie/envsetup.sh` reports Cangjie Compiler 1.2.0 (cjnative), x86_64-unknown-linux-gnu, and CJPM 1.2.0. Available dependency cache `/workspace/work/validation/replay-dependencies/cache`, relay `http://127.0.0.1:18972`, UCD archive as above. No dependency install or build was needed for this review.
6. Fresh static checks found the sole `render`, one Frame construction, one recursive `measure` path, no Float reference in changed layout/component source, and a clean independent checkout. No new counterexample emerged, so no temporary consumer was compiled and existing suites were not rerun.

## Declined to judge

- TASK-012 border/shadow/decoration APIs and rendering: explicitly outside this task and not yet implemented; absence is not a TASK-011 defect.
- Interactive decorated example, combined cold package delivery and final whole-suite/PTY acceptance: later implementation/execution work, not this local source review.
- Scrolling, themes, reactive state, overlays, M2 and other operating systems: excluded by this change's stated non-goals.

Must-fix summary: none. Proceed to the next authorized task; retain the separate final independent execution/acceptance gate.
