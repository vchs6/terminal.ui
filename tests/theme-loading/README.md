# TASK-089 public asynchronous theme contract tests — preparation

This tree is a **tests-only preparation artifact** for
`openspec/changes/implement-theme-styles/design.md` §§2.2, 6–7, 10
(T001–T016) and TASK-089. It changes no product, contract, task state, or common
test wiring. The source baseline is
`a0eae9998f8f72410148c1845840fde591e23d9b`.

**Strong async-only RED is pending. No asynchronous product behavior has passed.**
The baseline has neither the foundation Theme implementation nor the loading
API. Failure to import/resolve the whole Theme foundation cannot establish that
the asynchronous increment is missing. TASK-026 still waits for the frozen
foundation/088 and the completed 089 gate. TASK-091 must independently execute
the fixed product and test revisions; the author's static checks are not that
execution.

## Running with a real product

Use Linux, SDK 1.2.0, a C compiler, and the product's declared official stdx and
normal dependency configuration. Each CJPM consumer uses a normal relative
path dependency on the library. Use an execution role's own cache and ignored
registry configuration; do not consume an author's target/cjo or substitute
declaration library.

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
./tests/theme-loading/run.sh foundation --logs /tmp/theme-load-foundation
./tests/theme-loading/run.sh async-probe --logs /tmp/theme-load-red
./tests/theme-loading/run.sh all --logs /tmp/theme-load-execution
./tests/theme-loading/run.sh all --case session-fence --logs /tmp/theme-load-fence
```

`foundation` first builds **and directly executes** a real public consumer of
Theme.parse, the typed read-only bridge, Application(theme:), and themed pixels.
If that gate fails, the runner exits 78 and labels the result foundation-blocked,
never async-only RED. `async-probe` repeats that gate and then builds the small
separate `api-probe`, which names only the frozen asynchronous API. Preserve its
actual diagnostics and distinguish genuinely absent API from syntax/environment
errors. `all` additionally builds and directly executes the behavioral consumer;
its exit codes and completion sentinel must both succeed.

The runner saves UTC, exact argv/cwd, checked git SHA, stdout/stderr, real exit,
source/input hashes, the test interposer hash, and ordered handshake events.
Each behavioral case is a new process with a new temporary regular-file tree.
An explicit parent deadline detects deadlock; elapsed time never decides success.
Use a fresh `--logs` directory for each invocation.

## Deterministic real I/O and scope

`native/gate_wrap.c` is a Linux **test-process-only** LD_PRELOAD interposer on
actual libc open/fopen calls. It validates that selected `gate-*.toml` inputs
are regular files and blocks immediately before opening them. The production
loader still uses its real SDK file API, reads the real TOML bytes, parses with
the real Theme implementation, and publishes through its real UI path. There
is no product hook, virtual worker, fake future, fake parser, injected Theme
result, or sleeping to guess completion. FIFOs exist only in the interposer's
control directory; they are never passed as Theme configuration paths.

The child requests a barrier on stdout; the parent waits for an actual libc
entry event on stderr, releases the control FIFO, and acknowledges on stdin.
Unexpected gated reads, duplicate reads, and simultaneous gated reads in one
Application case fail. Multiple Applications must reach separate blocked file
reads before either is released. `pump` advances only public UI boundaries and
uses a stdin/stdout rendezvous between attempts; it stops on a public terminal
result. Ordinary read-only result/info queries do not drive the UI.

The already recorded `infrastructure` probe uses the real SDK File.readFrom,
checks the exact returned file bytes, and checks an actual cwd change. Its
success proves the test mechanism only. No previously valid infrastructure
probe or TASK-085 suite was rerun for this preparation continuation.

## Frozen scenarios

| Case | Public assertion |
| --- | --- |
| lifecycle | Initial 0/0 info; inactive load/reload SessionClosed with no file I/O; accepted theme and terminal history survive dispose/restart; request/revision sequences never restart. |
| session-fence | Dispose while a real read is blocked; SessionClosed is immediate and immutable; release old worker after restart and request a new theme; only new session can commit. |
| queued-restart | Uncommitted Prepared intent closes at dispose; its old candidate cannot appear on a new session's first frame. |
| latest-success | Slow File followed by newer Prepared intents; first replacing id stays frozen, latest intent wins, stale file never paints. |
| candidate-order | Multiple Prepared candidates before any UI turn; queries do not commit and only the latest requested candidate can be accepted. |
| latest-failure | A newer invalid file or NoFileSource reload supersedes an old valid slow file; failure retains the accepted theme and cannot revive old intent. |
| pending-bound | Block old regular read; issue 32 files; only latest pending file may enter actual I/O, no intermediate read or concurrent read, exact superseding ids retained. |
| post-capacity | Fill ordinary post queue; reject overflow post; independent candidate mailbox still commits once. |
| atomic-caches | Missing named style, inapplicable gap and weight-sum overflow fail before mutation using stable caches; no unrelated getter/build/mount; successful layout/color commit retains nodes, business state and subscriptions. Full visible cell/style comparison against active-root M1 render; previous Frame remains independent. |
| current-cache | Change live named-style declaration cache while real file I/O is blocked; commit checks the latest cache and refuses the newly missing style. |
| reload-origin | External atomic replacement has no automatic action; reload captures only accepted File origin, ignoring failed/in-flight File requests; Preset/parse memory clear File origin, Prepared(readFile) restores it. |
| relative-origin | Relative path is captured at request acceptance before delayed I/O; cwd change cannot redirect it or a subsequent reload. |
| synchronous-values | Synchronous parse/readFile change no application; parse sourceName that looks like a path is still memory and cannot be reloaded. |
| observability | UI result/info binding automatically invalidates at acceptance; getters run on UI owner; background nonblocking queries create no dependency and execute no UI getter. |
| event-post | Ordinary event/post callback may request a theme; ThemeInfo and Applied snapshots remain immutable. |
| multi-application | Two Applications concurrently reach actual file entry gates; independent request ids, active themes and UI turns; shared immutable Theme is unmodified. |
| getter-reentry | Both load and reload during a typed getter raise the existing ReentrantEvaluation error and normal runtime cleanup follows. |
| build-reentry | Both operations during structural build are rejected and leave initial theme/nodes uncommitted. |
| background-race | Eight simultaneous public background requests have a single unique id order; superseded first-replacement history is retained; only maximum id commits. |
| cleanup | R017 child/parent cleanup errors aggregate while pending load closes; refs/posts/bindings/subscriptions release; old worker and failed cleanup cannot contaminate restarted session. |
| exception-boundary | User event exception after acceptance keeps ordinary runtime error/cleanup semantics and cannot roll accepted ThemeInfo/Applied history back. |
| recoverable | Read, invalid path/NUL, invalid UTF8, syntax, type, reference, input byte/depth capacity failures retain accepted pixels and active session; equal successful Theme still increments revision. |

Candidate validation permits the specified `InvalidCandidate` or corresponding
specific diagnostic; it does not force an implementation to choose one allowed
spelling. Expected names/colors/layout positions and terminal sequences are
literal; the implementation never computes its own expected output.

## Required review and remaining evidence

These black-box cases establish visible request, I/O, and commit semantics.
They **cannot prove the exact internal capacity** of one active task + one
latest pending request + one latest candidate mailbox. TASK-090 must inspect
the fixed loader implementation for those invariants, actual thread creation,
lock ordering, locks released around I/O/parse/user work, UI id/session recheck,
bounded input reads/preparse budgets, worker retirement/resource release, and
candidate storage independent of ordinary post capacity. No public worker
counter has been invented and existing RuntimeStats fields are used only for
their existing resource meanings. A Prepared intent can be pending without a
public way to inspect whether its candidate already occupies the mailbox;
exact candidate capacity/session fencing requires that review together with
the tests.

The design's UInt64 id/revision exhaustion has no practical public route to
seed counters; inspect checked overflow/no-wrap behavior in TASK-090. Device
output failure after theme acceptance remains a required integration check of
the real terminal/backend recovery path during TASK-091; this headless tree
does not pretend to prove device failure by throwing a user callback exception.
Real controls' focus/selection/edit/scroll preservation is checked alongside
their actual APIs once those components exist; current coverage retains
Component/NodeRef and independent Observable business text. Common run-slice
integration is deferred until the prerequisite suite and product are frozen,
so this preparation cannot break the accepted runtime/richtext slices.

## Preparation evidence

`evidence/preparation/commands.jsonl` and the adjacent raw logs preserve the
real SDK infrastructure success and declaration-only static compilations.
The latter build exact consumer source copies against throwing declarations
in an external scratch directory; **they were never executed and prove no
product behavior, RED, foundation readiness, or GREEN**. Static source/library
hash inventories and source equivalence are recorded with these logs. The
first failed static pass and subsequent qualification fix are retained in the
external author raw directory rather than hidden.

This is author preparation, not independent execution/acceptance. TASK-089's
strong real async-only RED, TASK-090 review, TASK-091 actual fixed-suite runs,
normal bundle/clean path consumer and affected regressions, and TASK-092
acceptance remain pending. Original TASK-085 evidence/fixtures and R15 are
reused by reference; this tree does not rewrite or rerun that suite.
