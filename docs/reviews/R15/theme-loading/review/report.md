# TASK090 independent async Theme026 code review

**Spec: CHANGES_REQUIRED. Quality: CHANGES_REQUIRED.** One Important and one Minor finding; no Critical finding. This is the complete fixed-diff review, not a release or TASK091/092 acceptance verdict.

Reviewed base `73abef3` (full SHA in reviewed-hashes.json) through `797039d6da9df8d849d382aff52eeb2180ba31b8`, both commits `ec506e7` and `797039d`: 13 product paths, 344 additions, 6 deletions. The supplied review package is 28,478 bytes. The canonical design SHA256 is `084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4`; frozen `tests/theme-loading` tree is `441cfd4da54c26fdad394df94bb633476d2a61e1`. Both were checked from the fixed git object.

## T090-I01 — Important — incomplete candidate layout preflight

Location: `src/theme_candidate_validation.cj:37` (the sibling weight accumulator), with `src/layout_allocation.cj:33` and `src/theme_loader.cj:166`.

The validator resolves the stable declarations and checks the sum of positive sibling weights. The existing allocator also checks the sum of clipped flex minima. That second predictable failure is reached only after `finish` has replaced the session Theme and accepted ThemeInfo and marked the request Applied. The catch blocks inside candidate validation cannot catch a computation that is never performed there.

A minimal ordinary public consumer demonstrates the failure:

1. Create `Row { Text("a"); Text("b") }`, initialize with `schema_version=1, name="initial"`, and start headless.
2. `snapshot(Int64.Max, 0)` succeeds. This is a valid zero-cell Frame under `Frame.init`; it allocates no giant cell array.
3. Submit a Prepared theme containing `[components.text.spacing]`, `weight=1`, and `min_width=9223372036854775807`.
4. Snapshot with the same dimensions.

Actual output from the fixed product:

```text
INITIAL width=9223372036854775807 height=0 theme=initial
SNAPSHOT_ERROR minimum sum overflow
RESULT Applied(1)
INFO candidate revision=1
POST_ACCEPTED false
```

The candidate values are inside the exact signed64 `cells` range in design §4.3. With two children, each clipped base is Int64.Max, so the allocator's second addition rejects. This is a candidate-induced checked layout failure, not a user callback, device error, invalid Frame argument, or memory-exhaustion simulation. T008 and §7 require predictable candidate layout failures before mutation, with Failed, the old theme/revision intact, and the session continuing. Here acceptance is irreversible and the ordinary runtime failure path closes the session.

Remediation should cover all existing checked allocation invariants before Theme/Info/cache mutation, using stable declarations and the relevant layout constraints, without replaying getters/build/mount or adding another renderer. A blanket rejection of large raw minimum values would overreject valid clipped layouts. Independent regression coverage should include this Row case, its Column/min_height counterpart using `(0, Int64.Max)`, and a normal finite viewport control where large minima are clipped successfully.

Probe: `probe/src/main.cj`, ordinary path-dependency `cjpm build` exit 0 and direct binary exit 0 (the probe prints the caught defect rather than asserting product success). Build UTC 2026-11-11T05:43:39Z–05:45:00Z; run at 05:45:00Z. SDK/compiler and CJPM 1.2.0 with the existing official stdx setup. One focused probe only; no formal suite rerun. The product was extracted from the fixed git object into the reviewer's isolation, with a separate dependency cache. All 138 extracted product-input files still match that object after execution.

## T090-M01 — Minor — stale product documentation

`docs/product/theme.md:11` still says explicit loading belongs to a later phase. This contradicts the delivered public loadTheme/reloadTheme/themeInfo API. Replace the stale statement and document concise request/result usage, UI-boundary commit, and accepted-file reload semantics. The complete component showcase may remain described as future work. This is a documentation correction, not a request to extend feature scope.

## Internal constraints reviewed

| Boundary | Source-level judgment |
|---|---|
| API and package direction | Exact ThemeSource/Result/Info data variants and UInt64 fields are present; ThemeRequest remains root-level. Leaf theme files do not import root. No public wait/cancel, callbacks, worker counters or test hooks were added. Entities have individual files. |
| Request admission | `submit:60` rejects property/structure evaluation before path freezing, ID allocation or state mutation. Reload's preliminary currentTheme read is read-only. Ordinary callbacks and background tasks use the same admission lock. |
| Ordering and immutable terminals | Request ID allocation, superseding, pending replacement and mailbox replacement share the loader lock. `ThemeRequestSource.complete` only writes from None; the first superseder is retained. A newer failing request still prevents an older result from committing. |
| Capacity and retention | One workerRunning flag controls spawning under the loader lock. The worker takes and clears one pending slot; there is one mailbox slot and one latest request, without a history list. Disposal clears pending/mailbox but leaves a blocked worker counted, so restart cannot spawn a second reader. Old results are discarded by session/id checks. Non-Theme exceptions become a bounded fault candidate and enter the UI runtime failure path. |
| Lock order and user code | Admission takes loader then request-source/runtime-ID locks; finish takes loader then session and request-source locks. Candidate resolution, readFile, Parser, preset construction, source freezing and observer emission occur outside the loader lock. Runtime close releases its session lock before closing the loader; binding emission releases source locks before owner/session invalidation. No added reverse held-lock edge or user getter/callback under the loader lock was found. |
| Session fence and atomic ordering | `finish:157` and fault claiming recheck active session plus current request ID under the admission lock. Closing removes the active session before cleanup callbacks. Accepted Theme/source/revision persist across restart; in-flight old session work cannot publish into the new one. |
| Paths and reload | Relative File paths freeze before background work. Reload selects the currently accepted Theme's frozen sourcePath under the ordering lock; failed/in-flight files do not change it. Preset/memory themes have no file source. No watcher, shell expansion, networking or implicit search was added. |
| Observation and scheduling | Result/info reads release their source lock before dependency registration; background threads do not inherit the UI ThreadLocal binding. Queries do not pump UI. The bounded mailbox is independent of post capacity; snapshot/batch/dispatch/active render commit at UI boundaries, and the existing run loop checks mailbox work. |
| Identity and stable caches | Candidate resolution uses cached Component styleDeclaration/styleUses/styleStates and existing resolveStyle, without getter/build/mount replay. It does not reconstruct nodes or business state. Named/applicability failures and positive weight overflow are caught before commit. The missing minimum-base preflight is I01. |
| Paint versus geometry | The comparison includes fixed/min dimensions, weight, all four pads, gap, align/justify, wrap and border-presence. Only geometric differences clear measuredLayout. Pure text/color/border-shape/shadow changes refresh the existing resolved paint data and retain geometry. The full frame path handles old/new shadow coverage. |
| Output failure | Accepted ThemeInfo is not rolled back by later callback or device failure; existing failure/cleanup handling remains in charge. |
| Counter boundaries | nextRequest checks UInt64.Max before increment; revision checks UInt64.Max before acceptTheme/accepted mutations. The guards themselves do not wrap or overwrite the old accepted Theme at those explicit limits. No public overflow hook was added. This is static guard inspection, not execution of the entire UInt64 domain: inherited global Int64 runtime identity/dependency-version exhaustion remains a separate runtime limit and is not claimed proven by this review. |

No second Parser, resolver, layout tree, Frame implementation, Unicode engine or terminal writer was added. The review covered all new lines and the relevant existing cross-boundary source, not a second reading of the earlier foundation's full diff. Source-level positive judgments above are bounded by the explicit findings and evidence limits.

## Execution evidence and provenance

The authorized pure `task026-final-raw` records were checked independently:

- The pre-input record at 2026-11-11T05:35:41.152041+00:00 contains 212 tracked files, each byte hash matching fixed HEAD. Its timestamp precedes all 27 recorded commands. The post record identifies the same HEAD and records no mismatches.
- 78 tracked test-file hash records match the frozen tree. Twelve additional generated build-cache records are explicitly distinguished in the evidence index; they are not mislabeled git source. Five ignored environment-file hashes are recorded but their current author-worktree contents were not reread.
- All 27 command exits are 0: five build/infrastructure commands and 22 controlled consumer cases. Each case has the expected actual `PASS CASE` stdout sentinel and a null controller error. Command/stdout/stderr/event/input hashes are indexed. These are producer executions with independently checked raw evidence, not reviewer reruns.
- The bundle exit is 0 and stdout ends in normal bundle success, including lint diagnostics. The producer identity record reports 138 tracked inputs checked, no differing members, and only omitted `src/.gitkeep`. Archive SHA256 is `99c684903319c0eb36d4b7cf7593714bf17de86c77d46051dd03a5e68cb1db68`. This reviewer did not independently unpack/re-hash the archive or reconstruct an absent bundle argv record; final package/clean-consumer verification belongs to TASK091/092.

The 22 existing cases do not cover the I01 zero-axis checked-minimum counterexample. Their successful results therefore coexist with CHANGES_REQUIRED. Clean-consumer completion, whole-checker themes/composition coverage, benchmark gap and final release/root-checker acceptance are not closed here.

## Handoff and artifact boundary

Return the two findings as one batch. After correction, a scoped review should examine the correction delta and focused independent regression evidence; no repeated cold 22-case suite is required solely because the reviewer role changed.

`findings.json` is the machine-readable disposition; `reviewed-hashes.json` records fixed sources, raw references and the independent probe. `curated/` contains only lightweight report/evidence/probe inputs/logs, with `artifacts.sha256`. It excludes product checkout, SDK, dependency cache, binaries, packages and the full old raw trees. No author report/progress/self-assessment or author communication was consulted; no subagents were used. Product/tests/main/contracts and earlier sealed reviews were not modified.
