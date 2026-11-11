# TASK090 scoped fix round1 review

**Spec: CHANGES_REQUIRED. Quality: CHANGES_REQUIRED.** T090-I01 remains **NOT_ADDRESSED (partially fixed)**; T090-M01 is **ADDRESSED**. There are no new unrelated findings. This result concerns only the original findings and necessary effects of this correction, not a reopening of the earlier full review.

Fixed range: `797039d6da9df8d849d382aff52eeb2180ba31b8..4971528013f89f5ec00fac7d5f0c41a693fb2ee8`, comprising independent regression overlay `f679974` and product fix `4971528`. Seven paths change, including the 49-line test addition. The test overlay is byte-equivalent under tests/theme-loading to independent `3040111ce5a9bf5f1c3108c0374c4fe697f8d0dd`. Canonical design remains SHA256 `084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4`.

## Original finding dispositions

**I01: partially fixed, not closed.** The new `validateCandidateLayout` uses the same LayoutNode measurement/constrain and shared layoutPass/allocateMain path as actual output, with a candidate Theme supplied independently of session.theme. Both Row and Column minimum-sum checks execute before acceptance when the candidate is processed by the application snapshot boundary. The finite viewport control still accepts individually valid Int64.Max minima. However, the added extent assignment in public render is unconditional for any mounted node, while candidate validation always starts from session.root.

At `src/layout.cj:253`, `render(mountedSubtree,width,height)` replaces `session.validationWidth/Height` with the subtree output dimensions. At lines 207–210 these dimensions are then applied to the entire application root. This loses a previously established root constraint and allows the same known-invalid global candidate to commit. The existing `renderLayout` code itself distinguishes root versus subtree at line 223; the new validation-extent assignment does not.

Minimal remaining counterexample:

1. Create a Row with two Text children, retain one child Component, and successfully snapshot the application at `(Int64.Max, 0)` using the old theme.
2. Submit the original Prepared candidate: `[components.text.spacing] weight=1, min_width=9223372036854775807`.
3. Call `render(retainedMountedTextChild, 1, 1)`. This is a supported active-session subtree render boundary.
4. Snapshot the application again at the original root extent.

The subtree call marks the request Applied and publishes the candidate ThemeInfo; the root snapshot then throws minimum sum overflow and closes the session. The mirrored Column case with min_height and `(0, Int64.Max)` behaves identically. This is the original T008 transaction defect through an entry point introduced by its fix, not an unrelated new feature request. Root validation constraints must remain associated with the application root; subtree export dimensions cannot silently substitute for them. Preserve legitimate finite clipping and the stable cached-declaration/no-user-code constraint when correcting the association.

**M01: addressed.** `docs/product/theme.md:11` now describes delivered load/reload/request/info interfaces and terminal outcomes. Its future-work statement is limited to the full component showcase. No additional documentation finding is raised in this scoped review.

## Necessary layout/cache review

The refactoring of paint into layoutPass keeps geometry/allocation shared across both axes. Frame writes and paint counters are guarded by the optional output; preview traversal has no frame output. LayoutNode carries the candidate Theme down the same child sequence and reads cached content/style declarations without build, mount, binding evaluation or business callbacks. Preview nodes are local and do not replace session.measuredLayout or alter the accepted Theme/Info. Its measurement counters are suppressed; this does not prove that preview measurement costs zero, and no such performance claim is made.

The prior layoutChanged comparison still determines retained measurement-cache invalidation. A focused paint-only control recorded unchanged public measures (6 before, 6 after) after a successful theme acceptance. The source preserves the retained geometry cache on this path, while geometric changes clear it through the existing acceptTheme branch. No second Parser, allocator, text engine or renderer was introduced. The remaining flaw is target/extent identity, not the shared arithmetic itself.

## Independent focused probe

One normal public consumer was compiled against an isolated extraction of fixed `4971528`, using SDK/CJPM 1.2.0 and the reviewer's existing separate dependency cache. It covers direct Row/Column controls, the corresponding subtree counterexamples, and a paint-only cache control. It does not rerun the formal suite or modify product/test sources.

Build: exit 0, UTC 2026-11-11T06:10:34Z–06:11:43Z. Direct binary: exit 0 at 06:11:43Z; the diagnostic probe catches and prints the failure, so its zero exit is not a product-PASS assertion. All 138 extracted product input files match fixed git bytes after execution.

```text
INITIAL Row subtree=false
ROOT_SNAPSHOT_OK
FINAL Row subtree=false result=Failed(InvalidCandidate) info=initial/0 post=true
INITIAL Column subtree=false
ROOT_SNAPSHOT_OK
FINAL Column subtree=false result=Failed(InvalidCandidate) info=initial/0 post=true
INITIAL Row subtree=true
AFTER_SUBTREE Applied(1) info=candidate
ROOT_SNAPSHOT_ERROR minimum sum overflow
FINAL Row subtree=true result=Applied(1) info=candidate/1 post=false
INITIAL Column subtree=true
AFTER_SUBTREE Applied(1) info=candidate
ROOT_SNAPSHOT_ERROR minimum sum overflow
FINAL Column subtree=true result=Applied(1) info=candidate/1 post=false
PAINT_ONLY result=Applied(1) measures=6/6
```

Pure probe source: `probe/src/main.cj`. Command script: `run-probe.sh`. Actual output: `raw/run.stdout`; SDK, exits and UTC files are adjacent.

## Producer evidence identity

The authorized pre-identity record captures 213 tracked inputs at 2026-11-11T06:03:19.762067+00:00; every recorded hash independently matches fixed `4971528`. All seven detailed focused command UTCs follow that capture. The focused commands correctly retain git HEAD `f679974`, because the product fix was uncommitted then; this is not relabeled. The actual pre-execution bytes establish that the focused run used the later fixed product contents. The post-identity record identifies `4971528` with no mismatches.

All seven focused command exits are 0, including atomic-caches and current-cache actual completion sentinels. The new Row regression reports Failed(InvalidCandidate), old ThemeInfo 0/0, post=true and valid reference. Seventy-eight tracked test hash records match the fixed test source; twelve generated cache records remain separately identified. Five ignored environment hashes are retained as records, without rereading the author's worktree configuration. The new tests preserve earlier assertions but do not exercise the mounted-subtree submission boundary.

The final manifest's unrelated integration/package/clean statuses are not used to infer code acceptance. Final package and broader TASK091/092 execution/acceptance remain outside this scoped judgment.

## Handoff and preservation

Close the remaining I01 entry-point failure with an independent minimal regression and a scoped correction; M01 does not need reopening. No cold suite rerun is required merely to change roles or attach a commit identity.

`findings.json` and `reviewed-hashes.json` contain dispositions and exact source/raw hashes. The lightweight curated set includes reports, probe input/script and actual small logs, not a product checkout, dependency cache, SDK, archive or binary. Author reports/self-assessment/communications were not read; no subagents were used. Main/product/tests/contracts and the original sealed review were not modified.
