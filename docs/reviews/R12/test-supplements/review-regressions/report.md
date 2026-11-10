# Frozen review regressions

Test-only commit: `d95803372871c89442f131e362f38aff97633779` (5 files; 141 added, 2 existing branch lines extended; no previous assertions removed). Cherry-pick **only this commit**. Its local parent `3a499d20664ec47731cdafe064c59eb3aa6e76dc` is an isolated cherry-pick of the fixed product dependency `f07ff63303071764ea4acef5ba547d617e9d9a7c`, not part of the test output.

The isolated product `src/native/build.cj/cjpm.toml` Git blob listing was compared byte-for-byte with main candidate `4267b1138f70a9b51cc104719c8b38eb770748bc`; listings are identical. Hash: `074bf5442595eaa30dfbc2a074bc2ea57c398510d36659264cf500c7646d0a3f`. Listings are `raw/review-candidate-{original,local}-product-tree.txt`. The test role did not inspect development implementation code/reports or derive its expected result from output. Expectations came from R004/R005/R011/R012 and the coordinator's error-code clarification (hidden callback same-session reentry is LifecycleReentry; cross-session is WrongUIContext).

## Actual builds and separate REDs

Every raw prefix has UTC start/end, exact command/cwd, HEAD/source hash, stdout, stderr and actual exit.

| Prefix | Actual result |
| --- | --- |
| `review-candidate-normal-build` | normal product CJPM build, **0** |
| `review-core-normal-build` | normal external core CJPM build, **0** (one retained unused-event warning and one new discarded-frame-expression warning) |
| `review-session-normal-build` | test-local wrapper compile/archive and normal external session CJPM build, **0** |
| `review-red-cleanup-context` | direct core binary, **1**: cleanup accepts B.snapshot, observed `accepted` instead of WrongUIContext |
| `review-red-owner-render` | direct core binary, **1**: getter error propagates but ref valid, cleanup 0, mounted/bindings/subscriptions/posts all 1 |
| `review-red-owner-render-cleanup` | separately selected direct core binary, **1**: same retained resources; cleanup/aggregation never runs |
| `review-red-hidden-cross-session` | direct Node PTY harness, **1**: hidden legacy callback accepts other.snapshot instead of WrongUIContext |
| `review-red-hidden-reentrant` | separately selected direct Node PTY harness, **1**: hidden legacy callback accepts app.snapshot instead of LifecycleReentry |
| `review-pty-native-facts` | read-only raw-artifact facts verification, **0** |
| `review-facility-check` | bash/Node/C syntax and Git whitespace, **0** |

The cleanup-context binary also records A cleanup completing twice, A resources zero, B ref staying valid, and B successfully showing C then D after A cleanup. Thus the test's cross-session rejection does not require destruction of an uninvolved B or failure of a later legal boundary.

The owner-render cases enqueue owner work before changing the mounted getter to throw. Both print the original getter message and exact live-resource counts before the failing assertion. Expected teardown, original primary identity/type, cleanup aggregation, empty resource counters, and no repeated cleanup are independently specified in the source. The no-cleanup and cleanup-error variants run in separate processes; one failure does not hide the other.

Both hidden PTY cases send actual default Ctrl-C and wait for normal child exit **before** the context assertion. Actual fixture binary exit is **0**, no forced signal. In both cases before/after termios match exactly, the wrapper records exactly `real_result=0 injected=0\n`, and cleanup runs once. The hidden non-interrupt legacy business callback still executes while new UI capture/bubble/application counts stay unchanged. In the cross-session case B remains usable at a later legal boundary. These native/compatibility assertions pass before the intended context RED. Harness exit 1 is distinct from child binary exit 0.

Raw PTY directories:

- `review-pty-artifacts/cjtui-runtime-pty-jAa52Q/hidden-cross-session`
- `review-pty-artifacts/cjtui-runtime-pty-1TAaPX/hidden-reentrant`

Each retains session bytes, stderr, saved termios, close record, acknowledgement/context files, and result JSON. No product hook, private import, implementation-source assertion, sleep-based race, or new public API was added. Existing D027 close wrapping always calls the real product close first. No implementation fix or full old suite was run in this test-only increment.

Fixed test manifest: `raw/review-regression-test-source.sha256`, SHA-256 `0f9865bfe000319bbe8307501406362f688d4915fac32d06f75a11625023e09e`. Requested model/effort remains Sol/high; actual serving identity remains independently unobservable. This records reproducible fixed-candidate failures, not a repaired-product or acceptance verdict.
