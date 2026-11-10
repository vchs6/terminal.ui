# TASK-073 F007 final scoped review

Candidate: `c3d743d2dd5cb125e4ca435b2842d1b10c501281`. Previous reviewed candidate: `19b620f206e37be42ef387020ee8b441b27246f3`. Product projection equals original `01efa7676438f2978feb712b9dd9a4ddb89bbdec`. Frozen tests/runtime equals `6f97109`; contract R001–R018 is unchanged from the preceding review.

**Spec verdict: PASS within the reviewed A+B contract. Quality verdict: PASS within this scoped review. F007 is closed; no unresolved Critical or Important findings remain from F001–F007.** This permits handoff to independent TASK-074 execution and TASK-075 acceptance; it does not establish all Linux capabilities, C APIs, full parent tasks, package acceptance or release readiness.

The independent checkout is `/workspace/work/runtime-review/round3-source`, detached at the exact candidate. Tracked product/test/spec files were not edited. Author reports, self-evaluation and execution conclusions were not read. Requested Astra/high; actual serving model/effort is not independently verifiable. The existing code-review rubric and verification-before-completion process were applied; no subordinate agents.

## Change and failure-boundary review

The complete product diff from 19b620f is exactly `src/application.cj`: one insertion and six deletions. snapshot's catch now delegates all failures to `value.closeFailure(error)`, removing the WrongUIContext code exemption. All other product sources, macros, public signatures and the justified G.ENU.01 local suppressions are unchanged.

At application.cj:115–117, current session lookup, requireBoundary and pending-stop handling remain before the try. A wrong-thread, foreign-domain or lifecycle entry rejected there does not close the target session. Once A has entered the try, a callback/getter failure belongs to A and now follows its normal teardown path regardless of the exception's code string. No user exception is misclassified as pre-entry rejection.

The previously reviewed closeFailure implementation is unchanged: it closes A, aggregates an additional cleanup error only when one exists, notifies A's Application bookkeeping through the WeakRef owner and returns the original exception when there is no additional failure. close revokes refs/subscriptions/queued work before effects, owns/restores the cleanup TLS domain, and attempts each cleanup once. sessionClosed is guarded by session id. B's rejected snapshot still throws at its precondition before its own try, so it remains usable.

F001–F006 remain closed by reuse of the previous fixed-source review and targeted successful evidence. The only changed exit now uses the same shared lifecycle helper already reviewed for owner render and hidden-key failure. The diff contains no changes to owner thread identity, dirty categories, pending-work deduplication, cutoff logic, idle fast path, native close, macro expansion or lint suppression; no unrelated full rerun was warranted.

## Independent targeted execution

SDK: `/workspace/work/validation/sdk/cangjie/envsetup.sh`, Cangjie 1.2.0. Independent existing `runtime-review/cache`, registry port 18973. Normal product build hooks remained enabled. From `round3-source/tests/runtime`:

```
cjpm build -i
CJTUI_RUNTIME_CASE=post-cross-session TERM=dumb COLORTERM= timeout 20s target/release/bin/main </dev/null
CJTUI_RUNTIME_CASE=post-cross-session-cleanup TERM=dumb COLORTERM= timeout 20s target/release/bin/main </dev/null
CJTUI_RUNTIME_CASE=getter-cross-session TERM=dumb COLORTERM= timeout 20s target/release/bin/main </dev/null
```

Normal CJPM build exit **0**. All three directly executed modes exit **0**. Actual assertions verify:

- A NodeRef is invalid; cleanup executes once; mounted nodes, bindings, subscriptions and pending posts are all zero.
- Later queued owner work does not run, new posts are rejected, and dispose does not repeat cleanup.
- B NodeRef and subscriptions stay valid; B's subsequent state update renders `B2`.
- The plain post and getter cases throw the exact original UIException object/type (`refEq`).
- The post-plus-cleanup case preserves that exact primary and the exact cleanup failure object in UICleanupException; message/count include the added cleanup failure.

Raw logs and real exit files are in `round3-raw/`. Build emitted two existing test-source warnings (unused event parameter and unused expression); neither is a product build error. No compiler failure, wrapper-success shortcut or author-reported result was treated as behavioral evidence. The previous reviewer-authored foreign-post RED remains preserved in round2-raw; the three fixed new tests cover its condition plus getter and cleanup aggregation, so rebuilding the duplicate private probe was unnecessary.

## Explicit scope limits

- No full runtime default suite, unrelated legacy regressions, macro negatives, PTY suite or standard bundle was rerun. Independent TASK-074 owns its required execution evidence; no author execution claim substitutes for that role.
- C (If/ForEach/manual structure), M2 partial rendering, full Linux completion, later platform targets and parent-task completion remain outside this bounded review.
- No CPU sample is labeled a performance pass. F006 retains its previously established source/call-path closure.
- No new unrelated issue was elevated from outside the load-bearing exception path.

Artifacts: `scoped-f007-findings.json`, `scoped-f007-sourcehash.txt`, `scoped-f007-artifacts.sha256`, `round3-raw/core-build.{log,exit}` and the three case `.log/.exit` pairs. The original first- and second-round reports and RED artifacts remain unchanged.
