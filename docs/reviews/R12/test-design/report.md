# TASK-071 fixed-source handoff

Requested role configuration: Sol/high. The actual serving model variant and effort are not independently observable in this environment; requested settings are not reported as measured identity.

## Fixed inputs and deliverables

- Contract baseline: `a947857c1ba89ce088c7fe4909239e8a2a85089d`, `implement-reactive-runtime/design.md` section 6 R001–R015. Coordinator additionally confirmed before core freeze that unprevented headless interrupt disposes at the dispatch boundary; background stop waits for the next UI boundary.
- Isolated clone: `/workspace/work/runtime-tests/source`, branch `task071-runtime-tests`.
- Core commit: `62facc4a93caf82a97d9fd44bace48907f70081d`.
- Macro/continuous-state/visibility/device-fixture commit: `489d3293eb850948ae5a8d955b8ac4bee793c678`.
- Explicit Observable and background NodeRef notification commit: `ae8520c57d37bdbfa5831fe5c5496480d4b5856e` (final).
- All changes are under `tests/runtime`, `tests/run-slice.sh`, or `tests/README.md`. No product, specification, task-state, example, or shared-cache files were changed.
- `raw/final-test-source.sha256` records every committed test/runner/source hash. Its own SHA-256 is `a3c6292329c5c3e3135f1590c5ebb8e1b31537ebf9224a4b919970605933381b`.
- `raw/product-tree.txt` records the unchanged Git blobs for `src`, `native`, `build.cj`, and `cjpm.toml`; SHA-256 `e2c0d4d2032e56cc1e1f0b1a81d6e23f5647bc96832d8da716fbff622494f93b` (same as baseline).

## Commands and observed exits

Each named raw prefix has `.command` (UTC start, cwd, shell-quoted command, HEAD and source hash), `.stdout`, `.stderr`, `.exit`, and `.ended`.

| Raw prefix | Actual command/result |
| --- | --- |
| `baseline-build` | Ordinary product `cjpm build`, SDK 1.2.0, exit **0** |
| `core-red-final` | Ordinary core consumer `cjpm build`, exit **1**, missing public runtime types/APIs |
| `core-red-complete` | Ordinary core consumer after 70-turn/visibility additions, exit **1**, missing public runtime types/APIs |
| `core-final-public-api-red` | Final committed source compiled against the actual old product `.cjo` with cjc and all diagnostics enabled, exit **1**; no stub participates |
| `macro-positive-red` | Ordinary macro positive consumer `cjpm build --target-dir .../tests/runtime/target`, exit **1**, dependency scan reports absent `cjtui.macros` |
| `session-red` | Ordinary `tests/runtime/session/run.sh` builds its test-local wrapper and invokes CJPM; exit **1**, absent RuntimeStats and Text getter overload |
| `syntax-only-notifications` | External declaration-only static syntax compile of final core expressions, exit **0**; never executed |
| `session-syntax-only` | External declaration-only static syntax compile of session expressions, exit **0**; never executed |
| `facility-check` | bash syntax, Node syntax, GCC wrapper syntax and Git whitespace checks, exit **0** |

Missing-API diagnostics include UIException, NodeRef, Observable, RuntimeLimits, UIKeyEvent, RuntimeStats, the public inheritable Component/build/finishConstruction protocol, scheduler/session methods, and typed getter overloads. Consequent overload/type errors are not reported as separate product defects. The old product's public constructor lacks the new default base init; the resulting super-constructor diagnostic is likewise missing contract surface.

Earlier diagnostic iterations exposed test-language errors: escaping lambdas cannot capture mutable locals, and unqualified None is ambiguous with imported BorderStyle.None. The fixed tests use local Box reference fields and qualified Option<T>.None. Full raw diagnostic iterations remain present. Declaration-only scratch sources and their exact hashes are listed in `raw/syntax-only-sources.sha256`; the scratch is outside the repository, never executed, and never provides behavior, product GREEN, or a generated expected frame. Macro positive/negative expansion has **not** been compiler-verified against an implementation: the old dependency scan stops at the missing macro package. The positive compile-and-execute gate must pass before any negative rejection can count.

`macro-positive-infrastructure.*` records a separate initial local-registry-configuration failure, not an API RED. The corrected own ignored registry configuration uses the live relay at 18973 and a private copy of the read-only seed cache. All generated lockfiles were retained under `raw/locks` and removed from the clean source working tree. SDK/cache/native build artifacts are environment inputs/outputs, never committed.

## Contract cases present in fixed source

- Once-only deferred build; remount with retained descriptor state/new ref generation; double completion; dual mount; failure permanence; nested collector recovery; concurrent thread collectors.
- Explicit parameter macro init; generic component and two interfaces; public/private State; no-arg init generation; same-name consumer hygiene; throw paths; direct constructor-return diagnostics versus nested lambda return support; 15 separately located negative fixtures.
- Shared Observable views; dynamic dependency removal; default set re-evaluation with equal-target frame suppression; mutable object notify; background get isolation; real read-before-subscribe race; 70 ordered background writes exceeding the synchronous stabilization-pass count.
- Binding/constant replacement and subscription release; typed overload families; width/height auto clearing; category-targeted notify; background NodeRef notify; snapshot/frame/stats independence; no idle getter/layout/paint/frame work.
- FIFO entry cutoff; nested-post next turn; owner/session cancellation; full queue retaining state invalidation; batch coalescing; failure without business rollback; limits and UI/reentrant contexts.
- Fixed capture/bubble/application trace; consume/prevent/stop differences; expired events; hidden target/ancestor rejection; visibility changes applied after fixed route; old interrupt compatibility and headless default teardown.
- Before-cleanup token/subscription/queue revocation; child-before-parent attempts; all cleanup despite failure; first-error retention; no duplicate cleanup; partial mount failure cleanup.
- Detached render without lifecycle/ref publication and latest getter values; persistent effects; full M1 owner reference render; no terminal needed.
- Real PTY facilities for run idle stats, hidden-root legacy route, Ctrl-C default/prevent, and binding/mount/callback/cleanup/combined restore failures. They require exact termios restoration and exactly one actual successful close before optional test-only failure injection.

All expected grids and event traces are hand-authored contract literals. Mutex/Condition handshakes force races without sleep/random scheduling. The PTY idle timer measures three poll windows; callback acknowledgement files order events. No C structure API, implementation-private import, product hook, parallel rendering tree, or implementation-generated golden is used.

This handoff records test source and genuine old-library RED. No new runtime binary was produced from the old product, no macro negative was counted as a pass, and no real runtime PTY result is claimed. Independent product review/execution/acceptance owns implementation GREEN, full affected regressions, normal bundle/public package consumption, real TTY evidence, and final acceptance. No old full suite was rerun here because product source is unchanged and new consumers intentionally lack their APIs.

Applied instructions/tools: AGENTS and frozen OpenSpec proposal/design/tasks/spec; OpenSpec 1.14.3 ready apply context (coordinator owns task-state edits); Cangjie Coding with search_docs batches for actual SDK APIs; TDD/writing-good-tests; using-git-worktrees with authorized independent clone; systematic-debugging for compiler/config diagnostics; verification-before-completion. No subagent was spawned by this role.
