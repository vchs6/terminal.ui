# TASK090 scoped fix round2

**Scoped spec: PASS_SCOPED. Scoped quality: PASS_SCOPED.** Combining the original complete TASK090 review, round1 and this correction, final source `fa6a46ec339ea0f098dea521c814226a7a373c7e` has **spec PASS_SOURCE_REVIEW and quality PASS_SOURCE_REVIEW**. T090-I01 and T090-M01 are both ADDRESSED; no findings remain in this review chain. This approves the reviewed source for the next independent gate, not TASK091/092 or release acceptance.

Scope is exactly `4971528013f89f5ec00fac7d5f0c41a693fb2ee8..fa6a46ec339ea0f098dea521c814226a7a373c7e`: the seven-line product delta in src/layout.cj and the fixed independent regression overlay in atomic_caches.cj. No untouched functionality was reopened. Canonical design SHA256 remains `084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4`.

## Dispositions and source reasoning

**I01 — ADDRESSED.** Public active render now updates session.validationWidth/Height only when the supplied Component is the application root. A mounted-subtree export keeps the existing root extent while still processing the global candidate at the same UI boundary. validateCandidateLayout therefore validates session.root against the application extent, rather than the subtree's 1x1 output size. This directly removes the dimension-identity mismatch demonstrated in round1.

The identity guard is axis-independent. Row and Column still use the same unchanged layoutPass/allocateMain checks; the previously demonstrated Column counterexample is closed by the same guard, without a separate allocator or axis special case. Root render and Application.snapshot retain their dimension-update behavior. Getter/build/mount execution, theme commit ordering, locks and cache invalidation are not changed by this delta. The prior paint-only cache judgment remains applicable: this correction neither clears measuredLayout nor changes layoutChanged. No additional runtime probe was necessary to establish these limited source effects.

The independent regression explicitly snapshots the root at `(Int64.Max,0)`, submits the overflowing candidate, then invokes `render(mountedTextChild,1,1)` before another root snapshot. Actual output now records:

```text
OBSERVED after mounted subtree: failed:InvalidCandidate info=SubtreeBase
OBSERVED subtree candidate minima: error=[], result=failed:InvalidCandidate, info=SubtreeBase/0/0, post=true, ref=true
```

It also asserts both refs, business state, getter and mount counts, prior Frame independence and the old pixels. The earlier 49-line direct-root/finite-clipping controls remain unchanged, and their actual output still shows Failed(InvalidCandidate) for the oversized allocated sum while accepting the finite viewport control. The current-cache case also completes successfully.

**M01 — ADDRESSED in round1.** The product documentation correction is unchanged here and is not reopened.

## Fixed input and execution evidence

- Independent test overlay `862e4ee` is byte-equivalent to `71f9312` under tests/theme-loading. Removing only the new import, test hook and appended subtree case reconstructs the prior atomic_caches source exactly; existing assertions are preserved.
- Pre-identity UTC `2026-11-11T06:21:33.898056+00:00` contains 213 tracked hashes, all independently matching final fa6a46e git bytes. Every detailed focused command starts after that capture. The post-identity record at `06:25:38.126408+00:00` identifies final fa6a46e and records no mismatches.
- All seven focused commands have actual exit 0, including atomic-caches and current-cache with null controller errors and their actual completed-case sentinels. Their recorded HEAD remains `862e4ee`, correctly reflecting the pre-product-commit run; pre-execution content identity establishes applicability to fa6a46e without a commit-only rerun.
- Seventy-eight tracked test hash records match the fixed source. Twelve generated cache records are kept distinct. Five ignored configuration hashes are recorded, with no rereading of the author's worktree configuration.
- The inspected producer manifest SHA256 is `e950d247c036b619e0dc410d9bc5aeccfb2bd192866c2adfc80206a5f2152808`. Later updates for bundle/clean execution are not silently substituted for that observed version.

No formal suite or prior probe was rerun by this reviewer. Earlier probe output remains evidence for its original source revision, not a claimed fa6a46e execution. Column closure here is the source proof above, not an invented new runtime result. Final package/clean-consumer verification, TASK091/092 and the broader whole-checker/release gaps remain with their respective gates; earlier evidence limits are preserved.

## Minimal handoff

This directory contains only report.md, findings.json, reviewed-hashes.json, three small raw command/stdout records and artifacts.sha256. There is no copied source tree, contract, old raw archive, SDK, cache, package or binary. Original and round1 sealed reviews were left unchanged. No author report/self-assessment/communication or subagents were used; no product/tests/main/contract changes were made.
