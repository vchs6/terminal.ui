# TASK-078 / R13 independent fixed-source code review

**Spec verdict: FAIL. Quality verdict: FAIL. One Important (Battle severity major) finding, DYN-F001.** Do not advance TASK-078 to PASS or start dependent TASK-079 on this candidate. This is a bounded C/runtime review, not all-Linux/release acceptance.

Candidate: `167c2a3f701b8718e90fe7d9b78050af5665a23b`; base: `1d2af2c1aefa140e2f2f2fb11c20dd6e7b749531`. Detached checkout: `/workspace/work/dynamic-review/source`. Formal dynamic tests are byte-identical to fixed `bc91577` (original `3ee1a9b`). No tracked product/test/contract changes. Parent integrated candidate as 266cf7e; this review never follows moving main.

Requested reviewer model/effort: Astra/high; actual serving model variant and effort are not independently verifiable from available runtime metadata. No subordinate agents. No product-author report, progress narrative or self-assessment was consumed. Inputs were fixed technical diff/commitstat, formal brief, contracts, source, tests and raw command artifacts. `using-superpowers` was read and explicitly exempts dispatched subagents; cloud-environment-runtime was used for environment inspection, and verification-before-completion for evidence checks. Existing OpenSpec change `implement-reactive-runtime`, tasks Global constraints/078, AGENTS 10.5/11.1/13.2/14 and Battle protocol govern this execution review. It introduces no product decision or expanded scope.

## DYN-F001 — incomplete preflight exposes invalid nested dynamic subtrees before validation

**Severity: Important / major.** Relevant contract: design §4.1 (complete key validation before tree changes), §4.3 (complete descriptions checked before structural effects; failure leaves that coordination's committed tree unchanged; commands run in order and stop at the failing command), R007 and R013. The contract does not promise transaction rollback; this finding concerns work performed *after an already-invalid insertion* and publication/removal inside the *failing new-subtree construction*.

Root cause: `src/runtime_session.cj:408` only descends into `ChildDeclaration.DeclaredComponent` during preflight. It ignores `DeclaredGroup`. `mount` at lines 440–443 merely installs a marker and queues a new Structure binding. Manual insert at lines 549–553 then mounts, inserts and publishes this subtree immediately. `stabilize` at lines 740–748 runs all remaining commands before evaluating those nested dynamic bindings. For an outer group replacement, `src/foreach_group.cj:54,60,75,83` follows the same incomplete preflight and calls replace; `src/dynamic_group.cj:85–100` updates the public sequence, invalidates old roots and executes their cleanup before the newly mounted descendant group is validated in a later pass. ConditionalGroup uses the same staging mechanism.

A new Column/Row/custom-component root can therefore contain an invalid ForEach or throwing If body and still become a valid published NodeRef. Its replacement may unmount old content and run user cleanup while the session is still active, despite the new nested construction subsequently failing. Later commands in a batch can execute after that invalid append. These are observable lifecycle effects and committed child snapshots, not merely internal temporary allocation.

Two independent public-API counterexamples are in `probe/src/main.cj`:

1. Start a parent with an old Text whose registered cleanup logs whether the parent remains valid and, if so, its children count. In one batch append `Column { ForEach<String>({ => ["dup", "dup"] }, { x => x }, { item => Text(item.value) }) }`, then remove the old Text. The invalid subtree should fail its preflight before publication and before the later remove. Existing cleanup should occur only when the failed session is shut down, after all tokens become invalid. Instead, the old cleanup sees a valid parent and one committed child: the invalid appended Column. DuplicateKey is reported only afterward.
2. Start outer ForEach with key `old`, then replace its source with key `new`; the new item's Column contains the same nested duplicate-key list. The outer old-item cleanup likewise sees a valid parent and the newly published replacement before DuplicateKey. A failed nested construction has already replaced the outer committed item.

Fresh normal SDK 1.2.0/CJPM build exit **0**, direct executable exit **1** (intentional contract assertion failure):

```text
manual:error=DuplicateKey
manual:old-cleanup:active-parent,children=1
replacement:error=DuplicateKey
replacement:old-cleanup:active-parent,children=1
```

Expected for both: `old-cleanup:session-stopped`. This expectation allows required session teardown and cleanup; it does not require preserving a failed session or rolling back business state. The probes then call dispose and do not leave live sessions. They use only public cjtui APIs and log ordinary user cleanup callbacks; no private RuntimeNode inspection, fake runtime or modified golden is involved.

Reproduce:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
cd /workspace/work/dynamic-review/probe
cjpm build
timeout 30s target/release/bin/main
```

Build metadata/output: `raw/probe-build-corrected.meta/.log`; execution: `raw/probe-run.meta/.log`; exact sources and binary hashes: `evidence-manifest.sha256`. The initial probe build had a reviewer-owned Cangjie mutable-variable escape error; its source/log/exit are preserved separately. Correcting the probe to use a reference box produced the successful normal build above. That initial syntax failure is not a product finding.

Repair direction: make newly introduced subtree construction/validation a true staging operation that includes its initial nested dynamic content before publishing the insertion or replacement, retiring old roots, or advancing to the next explicit command. Preserve dependency collection, one sequence, key/body cardinality and guard rules, net replacement budgets and deferred lifecycle effects. The exact internal implementation is for the product owner; do not add rollback of arbitrary user side effects or a second live ordering tree. Validate both manual insertion and dynamic replacement, including nested duplicate/empty keys, body/build errors and capacity rejection, with appropriate focused regressions. Parent should allocate author/test-role work independently.

## Reviewed behavior and boundaries

- **Single order authority:** RuntimeNode.sequence is authoritative, with MountedChild and GroupMarker entries. Component.declarations is immutable construction/remount source; no active alternative Component.children remains. LayoutNode consumes MountedChild entries only and skips hidden nodes; markers create no layout boxes. Its private LayoutNode.children is the derived per-frame layout tree, not a second source of component ordering. Frame/Style/Unicode/ANSI implementations remain shared and unchanged.
- **Slot algorithm:** DynamicGroup.owned scans the whole parent sequence, including nodes moved beyond markers. replace maps Q into owned S positions, removes spare S, inserts overflow after the last original S, or before its own marker only if S is empty. Other entries retain relative order. Group ids separate equal keys in different groups; cells is a typed value lookup, not an ordering authority. Manual removal forgets cells but does not change application data; later Structure/source invalidation recreates a new node id.
- **Identity/value:** retained ForEach keys reuse RuntimeNode and ListItem cells; slot.update invalidates typed getters after source evaluation guards are restored. New keys call body once, removed/readded keys receive new cells/nodes. NodeRef stores weak node reference and session/node unique ids; committed validity is separate from staging. If tracks selected/empty branches and supports zero or one real root.
- **Commands and guards:** batch reads come from the committed sequence; queued inserts do not publish refs during the callback. Explicit commands precede ready structure reconciliation. Anchor resolution rejects stale/foreign children; same-parent move retains identity, no-op moves validate first, cross-parent move fails. Reservations detect duplicate pending root descriptors; prepareTree rejects repeated static descriptions/ancestor cycles. Structure/evaluation ThreadLocals restore in finally; observable writes reject both structure and typed evaluation. Lifecycle structure operations fail; post defers to the next turn. DYN-F001 is the missing recursive validation in this otherwise shared path.
- **Budgets/lifecycle:** static preflight and mount enforce tree depth/node counts; replacement mountingCredit accounts for retiring static/dynamic descendants and hides staged additions from stats/isValid. Structural operation and stabilization budgets are present. Unmount invalidates the whole removed subtree before clearing mounts/subscriptions/owner posts, then attempts cleanup child-first and aggregates failures. Session close retains the active owner domain and invalidates all tokens before effects. No further confirmed defect was found in these reviewed paths; this is not an exhaustive concurrency stress claim.
- **A+B and R019:** fixed application failure boundaries, owner-render handling, TLS thread-lifetime identity, dirty categories and constant-work idle guard remain in place. Application/layout/ui_thread_identity/observable_source differ from accepted c3d only by the separately accepted R019 size call; candidate native/terminal_bridge/application are byte-identical to 0912436. Old F001–F007 and R019 reviews are reused within this source-impact boundary. Dynamic runtime changes were read independently rather than assumed covered by old reviews.
- **Code/package/public use:** each introduced type has its own lower_snake_case file in cjtui; no dependency or JS/TS runtime was added. Public example uses component blocks, If/ForEach, typed state getters and NodeRef operations without stdout/ANSI/manual flush. Ordinary CJPM built the independent public probe against the fixed source using normal hooks. No arbitrary file-size threshold, speculative future API or focus/theme/M2 requirement was introduced.

## Evidence reuse and limits

`raw/delivered-source-check.log` verifies every entry of the author's raw delivered-product-source.sha256 against this fixed checkout. The frozen dynamic test diff is empty. Raw final delivery build/direct-run records show 32 formal dynamic groups exit 0; raw extracted-bundle public consumer repeats those groups with exit 0; dynamic example build and `--smoke` exit 0. These records are developer execution evidence, not independent TASK-079 execution or TASK-080 acceptance. The 32 tests cover flat failed body/key validation but do not contain the two nested-validation counterexamples above.

Earlier final-runtime-core/session/layout/decoration logs record successful execution, but their stored source hash predates the final runtime_session edit. Only README and runtime_session differ in the two raw product manifests. Their earlier successes are supporting history; this report does **not** relabel them as exact-final full regression passes without a recoverable earlier source comparison. The unaffected A+B/R019 boundary evidence is reused by direct fixed-source comparison instead. No suite was repeated mechanically under AGENTS 11.1.

Normal bundle production and public consumer records exist. The normal bundle boundary checker explicitly fails at missing `examples/composition/cjpm.toml`, the already registered future all-Linux composition deliverable. It is neither a newly invented C defect nor an all-release PASS. No check was skipped or bypassed to manufacture success. Full release, Rich, theme, focus/overlays, M2 and other platforms remain outside this review.

Artifacts: `findings.json` (Battle array), `sourcehash.txt`, `evidence-manifest.sha256`, `raw/*`, `probe/*`. No commit or product fix was made. DYN-F001 must be resolved on a fixed follow-up and independently reviewed before 078→079→080.
