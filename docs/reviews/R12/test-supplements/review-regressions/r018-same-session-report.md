# R018 same-session cleanup boundary regression

Fixed test-only commit: `b17b97b75ec3a30fb829c8eb3139fd9783d8cb50` (3 test files, 67 added lines). No previous assertion changed. Contract: R018 at design revision e8f3dc7 plus coordinator clarification that closing-session snapshot/dispatch/dispose must reject LifecycleReentry before inactive/stale checks, while closing-session post returns false.

Product dependency remains fixed f07 (`f07ff63303071764ea4acef5ba547d617e9d9a7c`, locally cherry-picked as 3a499d2). The product blob hash is still `074bf5442595eaa30dfbc2a074bc2ea57c398510d36659264cf500c7646d0a3f`, identical to the original candidate 4267b1138f70a9b51cc104719c8b38eb770748bc. Its valid normal product build exit 0 remains `raw/review-candidate-normal-build.*`; no product source changed, so this evidence is reused. Neither the e1 implementation nor its probe/analysis was read or run.

New ordinary external consumer build: `raw/r018-core-normal-build.*`, actual exit **0**, with only the two warnings already recorded before this increment. Focused direct binary command:

`env CJTUI_RUNTIME_CASE=cleanup-same-session timeout 30s tests/runtime/target/release/bin/main`

Raw prefix `raw/r018-cleanup-same-session-red.*`, actual exit **1**. All three operations execute/capture before assertions. Actual observation:

`cleanup-same snapshot=SessionInactive dispatch=SessionInactive dispose=LifecycleReentry post=false posted-runs=0 cleanups=2 valid=false`

The remaining child/parent cleanup completes, resource counters reach zero, and the closing-session post is rejected without execution. A later B.snapshot succeeds, and A can start a fresh session, render, and dispose. Cleanup total reaches four over the two mounts, and the rejected post never leaks into the new mount. Those assertions pass before the intended RED at the exact snapshot LifecycleReentry assertion. The dispatch observation also has the wrong SessionInactive priority; dispose already has the expected code. No failure is inferred for dispose or post.

`raw/r018-facility-check.*` records syntax/whitespace facility checks, actual exit 0. No old full suite, development repair, private API or test hook was used. Source working tree is clean after retaining generated lockfile under raw/r018-locks.

Fixed source manifest: `raw/r018-same-session-test-source.sha256`, SHA-256 `59a75247313150a8b14863ebfe134098a78d98d4ca5a8542d829420ffe0e2300`. Requested role remains Sol/high; actual serving identity is independently unobservable. This is fixed-candidate regression evidence, not repaired-product GREEN or acceptance.
