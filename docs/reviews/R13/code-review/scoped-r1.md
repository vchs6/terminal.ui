# TASK-078 / R13 — scoped fix round 1

**Spec verdict: PASS. Quality verdict: PASS for the bounded C review. DYN-F001 is verified closed. No new Critical/Important findings.** Together with the unchanged portions of the initial fixed-source review, this clears the TASK-078 code-review gate for independent TASK-079 execution. It does not substitute for TASK-079/080 or close all-Linux, parent task, release, Rich or other feature acceptance.

Candidate `216b2ab5f2315f4be19467b7e49f4047aec78ab9`, compared against initial candidate `167c2a3f701b8718e90fe7d9b78050af5665a23b`. Product changes are exactly `src/runtime_session.cj` and `src/dynamic_group.cj` (29 additions/10 deletions). Formal tests/dynamic is byte-identical to independent test pin `10c4ee3bf94a63995c2ffa16cedd79c4905d6b73`; product checkout contains its equivalent local pin `3f2515e21ab33490aa90b492d8c8a05b050c601d`. Detached checkout is `/workspace/work/dynamic-review/r1-source`; current main is not used as the review identity.

Requested Astra/high; actual serving variant/effort remains independently unverifiable. No product-author report/self-assessment, no agents, no communication with the product author and no tracked product/formal-test/spec changes. Original report/findings/RED/raw artifacts remain unchanged. Applicable contracts, code-review rubric, AGENTS 11.1 evidence reuse and verification-before-completion workflow continue from the initial review.

## DYN-F001 closure

`RuntimeSession.mount` now calls `initializeGroup` for every declared group while the enclosing node remains uncommitted. initializeGroup installs a normal owned Structure binding, evaluates under its own dependency tracker/structure guard, restores those guards, then commits its plan. Descendant mount recurses through the same path. A nested invalid key/body/build/cardinality/depth/capacity failure therefore unwinds before the outer manual insertion can append/publish the new root, before later explicit commands run, and before an outer group can replace its existing roots.

`DynamicGroup.replace` only calls publish when its parent was already committed. Initial nested groups can populate the single staged parent sequence, but their nodes do not become valid public references or count as committed nodes. The successful outer publish traverses the complete subtree and publishes all descendants together. On failure, staged nodes are present in the session's ownership list for cleanup, so normal close clears their mounts and subscriptions; all existing tokens are revoked before existing user cleanups execute. No user onMount runs during staging. This fixes the actual publication boundary rather than masking DuplicateKey or special-casing the probe.

The original independent public probe source files were copied unchanged (byte equality checked) to `r1-probe/src`. Only the dependency path points to the fixed r1-source checkout. Normal SDK 1.2.0/CJPM build, normal hooks enabled: **exit 0**. Direct binary, not cjpm run: **exit 0**.

```text
manual:error=DuplicateKey
manual:old-cleanup:session-stopped
replacement:error=DuplicateKey
replacement:old-cleanup:session-stopped
```

This independently reproduces both former REDs and confirms the intended ordering without weakening assertions. It still permits failed-session cleanup and preserves the original error; no business transaction rollback is demanded. Original 167c2a3 output/exit 1 remain at `raw/probe-run.log/.meta`; fixed output is `r1-raw/probe-run.log/.meta`.

Reproduce:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
cd /workspace/work/dynamic-review/r1-probe
cjpm build
timeout 30s target/release/bin/main
```

## Adjacent change review

- **Initial binding cleanliness:** addBinding defaults to the old initiallyDirty=true behavior for ordinary typed bindings. Only immediately evaluated initial Structure bindings use false. Thus they are not redundantly left in pendingBindings after initializeGroup. Binding.evaluate still subscribes/version-checks normally; a real racing invalidation can mark the now-clean binding dirty and enqueue a later pass. Runtime ownership, per-node binding budget, published dependency statistics and disposal remain shared.
- **Recursion and guards:** structure preparation uses the existing binding/collector guards, then commits after evaluation state is restored. Nested initialization creates its own tracker; body/build collector reads remain separate from source/key dependencies. Retained-key updates still occur outside evaluation guards and invalidate the dependent value getters. New-key bodies are not rerun merely because their initial structure was staged. The existing depth/node/structural budgets bound recursive initialization; this introduces no alternative live tree/order.
- **Net replacement capacity:** preflight now subtracts the already active mountingCredit as well as its own retiring subtree. During recursive initial mounting, the outer retiring nodes still occupy the session ownership list, so subtracting their credit is necessary to permit a same-size replacement at the limit. Newly created nested groups have no committed retiring nodes, avoiding duplicate retirement credit. The actual mount check continues counting staged new nodes minus current credit. Credit is restored in finally, including thrown nested initialization.
- **Startup operation accumulation:** start sets structuralOps=0 before any recursive initial group construction. The first stabilize uses resetStructuralOps=false, so initial recursive work and synchronous startup follow-up share one batch budget. Other stabilization boundaries retain the old reset=true default. This closes the potential budget reset between initial construction and startup effects; it does not reset inside nested groups.
- **Failure, cleanup and generations:** staged initial groups have no registered mount effects. Failing descendants remain owned for complete error cleanup, while old committed roots were not removed. Successful outer commit publishes the subtree before its normal effects and retires old roots as before. No change to nonce/WeakRef, command ordering, slots/manual ownership, stale-anchor resolution, typed setter boundaries, application/native close, Frame/Layout/Unicode/ANSI, macro/package surface or R019 occurred in this fix.

No additional confirmed issue was found within those changed paths. The review does not claim a newly executed concurrency stress suite.

## Formal test and raw evidence inspection

The two independent formal tests inspect actual user cleanup callbacks via parent NodeRef.isValid and children only while valid, with literal expected cleanup traces. Both require DuplicateKey, no invalid body/mount effects, business writes retained, old refs invalid, resource counters zero, and idempotent dispose. Their wrapper runs the second nested case even when the first fails. The old 32 cases/expectations remain intact; total default cases are 34. This is an appropriate regression for DYN-F001 rather than a test of implementation details.

`r1-raw/delivered-source-check.log` verifies the delivered per-file product SHA-256 list against the fixed candidate. Relevant raw command metadata uses final source aggregate `76a7bff748f0e2cd12e4f17e73e2db89db4a9f6cf4ce6037fb79b4b1f814717e`; 26 selected raw/probe input hashes were checked against `r1-raw-manifest.sha256` by `r1-raw/verify-inputs.mjs`. The independent original probe is newly built and run; broader unchanged obligations reuse effective records under AGENTS 11.1.

Inspected developer raw evidence, correctly scoped as supporting execution evidence:

| Evidence | Observed result and reviewed coverage |
|---|---|
| r1-final-dynamic-build/run | Normal build/direct binary exit 0, all 34 formal cases; nested cleanup traces exactly stopped, failed assertions 0 |
| r1-final-nested-probes-build/run | Exit 0; manual/list/If replacement × empty key/condition/branch/body/build/root-count/capacity/depth failures; no premature cleanup/effects, full resource release |
| Same probe successAtCapacity | Exact 3-node nested replacement succeeds; body counts remain once per generation; new source subscription updates rendered value; three active bindings and subscriptions; final release |
| Same probe initialBudget | Two initial groups under one-operation budget fail CapacityExceeded; stopped current node count zero |
| r1-runtime-core/session | Both commands exit 0 on final aggregate; A+B contract succeeds; 12 PTY scenarios record expected process outcomes, exact termios restoration, harness failures=0 |
| r1-normal-bundle | Ordinary cjpm bundle exit 0; no skip/bypass introduced |
| r1-bundle-consumer-build/run | Normal extracted-package build/direct binary exit 0; all 34 public cases |

The developer probe sources were read, not merely their PASS labels: assertions check correct exception codes, parent invalidation timing, mount/cleanup counts, ref invalidation, current resource counts, actual rendered values, identity change, and exact capacity. Sources and raw status/hash records are linked in `r1-raw/reused-inputs.sha256`. They are not represented as newly independent TASK-079 runs. The registered normal bundle checker missing future composition example remains an all-Linux boundary limitation from the initial review; bundle generation success here does not convert that checker or full release into PASS.

## Artifacts and handoff

- `scoped-r1-findings.json`: original finding verified at fixed revision, no new finding.
- `scoped-r1-sourcehash.txt`: candidate identity and source/formal-test hashes.
- `scoped-r1-manifest.sha256`: review artifacts, raw metadata, probe source/binary and reused-input index.
- `r1-raw/probe-build.meta/.log`, `r1-raw/probe-run.meta/.log`: fresh independent normal build/run.
- `r1-raw/verify-inputs.mjs/.log`, `reused-inputs.sha256`, `delivered-source-check.log`, `formal-test-pin.diff`, `product-scope.txt`: input identity/evidence checks.

TASK-078 has no unresolved Critical/Important issue for this fixed C candidate. Proceed to independent TASK-079, then TASK-080; no broader acceptance is implied.
