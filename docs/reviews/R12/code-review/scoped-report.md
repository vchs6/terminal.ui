# TASK-073 second-round scoped and boundary review

Fixed candidate: `19b620f206e37be42ef387020ee8b441b27246f3`, compared to first review `4267b1138f70a9b51cc104719c8b38eb770748bc`. Product projection is byte-identical to `0aa92652e9756770a8b4c6942fd80c5e86af6e76` over src/examples/reactive/docs/product. The actual product diff contains **8 src files**, not 9. Tests/runtime is identical to frozen `78cde41`. Contract is candidate design.md R001–R018, including R018's clarification without weakening earlier obligations.

Checkout: `/workspace/work/runtime-review/round2-source`, detached fixed SHA. No tracked product, tests, or spec edits; normal CJPM build generated an untracked tests/runtime/cjpm.lock and ignored build/config artifacts. Old report, findings and RED evidence remain untouched. Requested Astra/high; actual serving model/effort remains independently unverifiable. Applied the existing code-review rubric and verification-before-completion workflow; no subordinate agents or author reports/results.

**Spec verdict: FAIL. Quality verdict: FAIL.** Original F001–F006 are closed for this fixed scope, but one adjacent Important finding F007 remains open. No new Critical finding. Do not promote this review into full-suite/bundle/release acceptance.

## Original finding dispositions

| Finding | Disposition | Independent evidence and limits |
|---|---|---|
| F001 cleanup active domain | Closed | RuntimeSession.close:352–369 installs owning activeSession for cleanup and restores it in finally, including thrown cleanup. Resource invalidation still precedes effects and no mutex surrounds callbacks. Fixed cleanup-context direct exit 0 verifies foreign B remains alive and usable after A cleanup; cleanup-same-session exit 0 verifies LifecycleReentry for own snapshot/dispatch/dispose, post=false, complete cleanup, restored TLS and later restart. requireOwner rejects foreign domains before inactive/reentry checks, outside B's failure handler. |
| F002 owner render failure teardown | Closed | layout.cj:287–306 now requires safe boundary and uses closeFailure/closeStopped. RuntimeSession holds only WeakRef<Application>; notifyClosed synchronizes Application bookkeeping, guarded by session id. Two fixed owner-render modes directly exit 0, preserve original exception object/type and additional cleanup identity/order, invalidate refs and release all current resources. Additional public ownerRestart probe directly exits 0: restart succeeds after render failure, old reference stays invalid, new identity differs, cleanup executes once per generation. |
| F003 hidden legacy event boundary | Closed | dispatchHiddenKey installs owning enter domain, inCallback and batchDepth, restores flags in finally, stabilizes and uses failure cleanup. Hidden root still does not receive a fabricated UIKeyEvent; interrupt remains the default stop path. Reused independent real-PTY probe exits 0 with foreign access WrongUIContext, own snapshot LifecycleReentry, exact termios restoration, no forced signal. |
| F004 thread lifetime identity | Closed by source | ui_thread_identity.cj stores a lazily allocated unique identity in ThreadLocal; session captures threadNonce separately from session id and numeric threadId. requireOwner checks domain, numeric id, then thread-lifetime nonce; inActiveDomain checks both identity components. Same-thread multiple idle sessions remain allowed. No scheduler-dependent thread-id reuse experiment is claimed. |
| F005 retained invalidation categories | Closed by source | Every scalar constant setter and typed apply closure now supplies Content/Style/Layout. RuntimeNode retains independent flags; Content/Layout propagate layout invalidation to ancestors. Observable-ready bindings retain category, and NodeRef notifications merge category metadata in PendingNodeChange. Flags are cleared on full target production; subsequent pending notifications remain queued. Shadow is correctly paint/style-only under current layout semantics. No demand for M2 partial layout/paint was introduced. |
| F006 constant-cost idle path | Closed by source | run:215–230 guards snapshot/copy/diff with O(1) needsWork, dimension, color-mode/profile and baseline checks. needsWork reads only bools and queue emptiness; idle does not traverse nodes/bindings or frames. stabilize now visits only pending bindings/nodes. External snapshot still returns Frame.copy. State and explicit notifications enqueue work; changed constants set changed; resize/profile differences force comparison. Baseline advances after successful output or a no-output equivalence result; throwing write does not advance it. No CPU sample without a threshold is labeled PASS; this closure rests on inspected call paths. |

Queue/concurrency cross-check: a clean binding enters pendingBindings once, repeated invalidation only lowers its sequence; drain clears dirty before evaluation, allowing an invalidation arriving during evaluation to queue a later turn. Source subscription-version recheck remains deferred. Pending node records deduplicate by node.pendingChange and reset when drained. Mutation/removal and close clear pending work under the session lock. Binding owner-to-session locking remains consistent; newly added component.readMount is under the session lock, but inspected mount/definition/close code releases component mountLock before taking session lock, so no reverse held-lock path was found. User getters and callbacks continue outside runtime/source locks. These are source-review conclusions, not a new full concurrency stress run.

Current render profile other than colorMode derives from the session-constant capabilities snapshot; the idle guard therefore covers all currently mutable profile input. A future mutable capability API must expand the profile comparison, but no such API is in this candidate.

## F007 — Important: snapshot suppresses teardown for WrongUIContext thrown inside application code

**Location:** `src/application.cj:123` (inside the snapshot catch block), with the user callback execution in `src/runtime_session.cj:295`.

After the public entry checks have succeeded, snapshot can run posted callbacks and binding getters. Its catch block unconditionally rethrows any UIException whose code is WrongUIContext, bypassing close and sessionClosed. This confuses an invalid entry into a foreign session with a failure of user code already running in the owning session.

Concrete ordinary public consumer:

1. Start same-thread headless A and B; A owns a subscribed Text and a registered cleanup.
2. Queue `A.post({ => B.snapshot(1, 1); () })`.
3. Call A.snapshot and catch the unhandled WrongUIContext from that callback.

B correctly rejects entry and stays alive. **A also stays alive incorrectly**: its NodeRef is valid, cleanup count is zero, mountedNodes/subscriptions remain one. R007 and §3.2 require an unhandled callback error to terminate and clean its owning session; only the foreign target B should be preserved. This branch existed in the original candidate but is an adjacent failure path exposed by the requested cross-domain follow-up; it is not a newly introduced line.

Actual SDK 1.2 normal CJPM build exit 0; direct executable exit 1:

```
post foreign access error=WrongUIContext A-valid=true cleanup=0 mounted=1 subscriptions=1
B after rejection=B
```

Source: `round2-probe/src/main.cj`; raw output/status: `round2-raw/foreign-post.log` and `.exit`. The probe calls A.dispose only after recording the failure to avoid leaving its own resources alive. The same catch could also leave a getter unsubscribed if a typed getter encounters an unhandled foreign-entry error.

**Repair guidance:** distinguish entry validation by control-flow location, not exception-code inspection. snapshot's requireBoundary already occurs before its try block; B's boundary rejection occurs before B enters its own try. Once A's user callback/getter is executing inside A's try, an unhandled exception must use A's normal close/primary-plus-cleanup aggregation path. Keep B untouched and preserve the original WrongUIContext error object when no cleanup failure is added. Add an independent regression for A closure/B survival, plus cleanup-failure aggregation if needed; do not broaden this into closing B at the rejection site.

## Evidence and execution limits

- SDK: sourced `/workspace/work/validation/sdk/cangjie/envsetup.sh`; same 1.2.0 SDK and independent `runtime-review/cache`, registry port 18973. Normal build hooks were enabled.
- `round2-source/tests/runtime`: `cjpm build -i` compiled the fixed consumer. Only `CJTUI_RUNTIME_CASE=cleanup-context`, `cleanup-same-session`, `owner-render`, `owner-render-cleanup` were executed; all direct exits 0. Full core default suite, macros and unrelated regressions were not rerun.
- `round2-probe`: normal `cjpm build -i`, direct foreign-post probe exit 1; restart-mode direct exit 0. The original focused hidden-root PTY consumer/harness was reused with only new source/output paths; actual child and harness exit 0, `signal=null`, termios before=after, exact expected error codes.
- A first core build attempted before the intended local config was copied failed dependency resolution. Its `core-build.log/.exit` are retained as environment/setup failure, not product RED. The corrected `core-build-configured.log/.exit` are authoritative and exit 0. Build/test expected results were not changed to accommodate this failure.
- Macro code, ChangeKind/Style source and the two inline G.ENU.01 suppressions are byte-identical to first review; reused the prior independent suppression comparison. No suggestion to remove justified local suppressions and no global lint bypass. A new complete lint or macro-negative run was not necessary for this scoped review.
- Read fixed sources/contracts/tests only. No product-author self-evaluation, report or execution conclusion was consumed. No CPU measurement is claimed as a performance threshold pass.

Artifacts: `scoped-sourcehash.txt`, `scoped-findings.json`, `round2-raw/*`, `scoped-artifacts.sha256`. Fixed product/test projection diffs are empty and recorded. Source-status records only normal generated build artifacts. Original review artifacts are retained.

Recommendation: accept closure of F001–F006 at the fixed candidate, keep TASK-073 open for F007, then review only the failure-boundary correction and targeted regression evidence at its next fixed SHA.
