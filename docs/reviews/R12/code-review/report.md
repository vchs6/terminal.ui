# TASK-073 independent spec and quality review

- Candidate: `4267b1138f70a9b51cc104719c8b38eb770748bc`; baseline `6a7b240`.
- Product paths `src/`, `examples/reactive/`, `docs/product/` are byte-identical to original product commit `f07ff63303071764ea4acef5ba547d617e9d9a7c` (git diff empty).
- Fixed tests: `74d07d3`; candidate `tests/runtime` is identical (git diff empty). Read tests, did not run the full suite or read product-author reports/results.
- Contract: candidate `openspec/changes/implement-reactive-runtime/design.md`, section 6 R001–R017 takes priority; tasks.md A+B scope.
- Review checkout: `/workspace/work/runtime-review/source`, detached fixed HEAD, tracked files unmodified.
- Requested model: Astra/high. Actual serving variant/effort cannot be independently verified; do not treat the requested model as measured identity.
- Skills applied: requesting-code-review and its code-reviewer rubric; cloud-environment-runtime for SDK execution context; verification-before-completion for final artifact and exit-status verification. No subordinate agents.

**Spec verdict: FAIL — fixes required. Quality verdict: FAIL — fixes required. No Critical issue established; six Important findings below.** This is not TASK-074 full execution or TASK-075 acceptance.

## Strengths and reviewed areas

The implementation introduces a single ThreadLocal collector, defers build until materialization and reserves ownership before build, and guards concurrent double-mount with the component mount mutex. Failed build instances are retained as failed; remount changes the session identity without repeating successful build. NodeRef holds WeakRef rather than owning the runtime tree. Existing layout/Frame/Unicode/style implementations remain the rendering authority.

Observable slot/version operations hold their own mutex; user getters execute after runtime locks are released. Emission copies listeners under the source lock, releases it, then invalidates. Binding owner-to-session lock order is consistent in add/dispose/invalidate; subscription installation releases source lock before owner/session invalidation. Version recheck and deferred invalidation preserve a background write in the read-to-subscribe window; dirty sequence cutoffs defer continuous background updates instead of forcing repeated synchronous stabilization. No user getter/callback under these inspected locks was found. This review does not claim a separate stress-test run.

Typed overloads cover existing scalar attributes, replacement removes old bindings/subscriptions, widthAuto/heightAuto detach getters, and equal typed results avoid a new target frame. Collector/evaluation ThreadLocals restore in finally. Macro source preserves generics/interfaces and initialization, qualifies generated types, preserves private State visibility, and uses an AST visitor to distinguish nested lambda/function returns from direct constructor returns. The fixed positive consumer and 15 negative fixtures cover these obligations; no duplicate full macro run was performed here.

Cleanup first invalidates nodes/queues/subscriptions, then attempts registered callbacks child-before-parent; exceptions preserve original objects when there is no extra failure. UICleanupException copies array boundaries, flattens prior aggregates, and appends failures in order. run records primary/cleanup/restore errors and calls actual native close before throwing. The focused hidden-root PTY below independently observed exact termios restoration. Broader injected-error/PTY cases remain the independent execution role's evidence.

## Important findings

### F001 — cleanup callbacks have no active-session domain

Locations: `src/runtime_session.cj:239`, `:256`; `src/application.cj:88` and failure close call sites.

`close()` toggles `inLifecycle` but does not install `activeSession`. `dispose()` invokes it outside `enter`, and failure catch blocks execute after `enter` restores its previous value. Therefore, while session A's cleanup is running, `activeSession` is None and same-thread idle session B accepts `snapshot`/`batch`/dispatch. This violates R005's prohibition on crossing session domains from active callbacks and makes cleanup behavior differ from onMount/key callbacks.

Public probe: start two same-thread headless apps; A.onMount returns a cleanup that calls B.snapshot; A.dispose succeeds in entering B. `raw/probe-render-stale.log` records `FAIL cleanup entered another session`.

Fix at the lifecycle dispatch authority: preserve/install A's domain for the entire cleanup phase even after its tokens become inactive, restore it reliably, and do not hold locks around cleanup. Simply calling existing `enter` after `active=false` cannot work because requireContext rejects inactive sessions. Cover normal disposal and all failure cleanup entrances.

### F002 — mounted global render leaves a broken live binding after getter failure

Locations: `src/layout.cj:287–296`; `src/binding.cj:37–43`; compare `src/application.cj:117–121`.

Mounted `render` stabilizes and renders without the error-to-session-close path used by snapshot. `Binding.evaluate` removes subscriptions before running the getter; a throwing getter skips reinstallation and the dirty bit was already cleared. The session remains live, cleanup does not execute, and later Observable updates are silently lost. This is an actual corrupted active runtime, not merely different exception wrapping for export.

Public probe: initial `"okay"` snapshot; state becomes `"bad"`, getter throws GETTER_SENTINEL during render; caught exception leaves `valid=true cleaned=false mounted=1`. Changing state to `"new"` and calling snapshot still returns `"okay"`. Direct binary exit 1, `raw/probe-render-stale.log`.

Use the same failure boundary/aggregation and Application bookkeeping as other persistent runtime drivers; detach resources and preserve primary plus cleanup exceptions. A detached temporary render must keep suppressing effects. Also address pending stop at this public safe boundary while unifying the boundary logic.

### F003 — hidden-root legacy key callbacks bypass domain, batching and reentry guards

Location: `src/application.cj:227–230`.

For hidden root and a non-interrupt key, `handler(key)` is called directly from run, unlike the visible-root dispatch path. No activeSession, inCallback or batchDepth is installed. A legacy handler can enter another session or recursively call its own snapshot, both forbidden for active input callbacks by R005/R011/R015. Root visibility should affect routing, not the safety of the retained legacy callback.

Actual PTY probe: hidden root's legacy handler calls B.snapshot and A.snapshot; both return successfully. `raw/hidden-pty.json` has `cross: "FAIL accepted"`, `reentry: "FAIL accepted"`, binary `value: 1`, no signal, and `restored: true` with exact before/after termios strings. Raw PTY bytes and stderr retained. This is distinct from F001 because it needs its own input entry repair.

Run the retained legacy handler within the same owning domain and automatic callback batch, without fabricating a UIKeyEvent or routing to hidden nodes. Keep non-interrupt legacy compatibility and default interrupt behavior.

### F004 — UI ownership relies on a reusable numeric thread id at idle boundaries

Locations: `src/runtime_session.cj:18`, `:41`, `:44–50`, `:74–76`.

Session construction saves only Thread.currentThread.id. The session nonce is checked only when activeSession is Some; idle same-thread headless sessions deliberately have no activeSession. Consequently, if the original owner thread ends and a new thread gets that numeric id, it can use a retained Application to enter snapshot/batch: active and threadId match, and no nonce/owner-lifetime check remains. R005 explicitly rejects ownership based only on a reusable thread id. A different session nonce protects NodeRef generation but cannot identify the entering thread's lifetime.

This is a source-level conditional counterexample, not an observed SDK id-reuse run. Store a non-reused owner thread-lifetime token (for example a ThreadLocal-generated identity captured at session construction), or verified stable Thread object identity, in addition to the session nonce. Preserve supported multiple idle headless sessions on one actual owner thread.

### F005 — required node invalidation categories are erased

Locations: `src/component.cj:304`, constant setters and typed setter apply closures; `src/runtime_session.cj:26`, `:68`, `:127–129`; `src/runtime_node.cj:5–16`.

Binding.category only selects which saved getters NodeRef.notify reevaluates. All actual property writes call category-free markChanged, which sets one session Bool; RuntimeNode has no Content/Style/Layout dirty classification. For example constant foreground(Red) and width(4) produce indistinguishable runtime invalidation state, and constants have no Binding.category at all. Typed results also lose their category when applied.

Design §3.1 explicitly permits full M1 layout/paint while requiring classification to be retained for M2. R009 retains typed/constants through one API. Implementing M2 is not requested; retaining typed invalidation metadata is an A+B architectural contract. Track/merge appropriate node invalidation flags through constants, bindings and explicit notifications, including ancestor layout propagation where relevant, while keeping current full M1 rendering.

### F006 — idle polls still sweep all bindings and copy/compare every frame cell

Locations: `src/runtime_session.cj:162–170`, `:203–220`, `:227`; `src/application.cj:197–205`; `src/frame.cj:302`.

Every 100ms poll reaches snapshot/pump/stabilize, which iterates every binding even if there was no invalidation. produce then copies the full cached Frame unconditionally, and the run loop performs full-frame diff comparison. Counters correctly remain unchanged for build/measure/paint/generated frames, but idle cost remains O(all bindings + viewport cells), with a new frame allocation/copy. Thus existing counter assertions do not establish the §3.2 promise that idle only checks size/queue and does no full-tree work; R011/R014 retirement is incomplete under that explicit idle budget.

Maintain a deduplicated pending-dirty work set or an equivalent fast check before scanning, and let the internal run path reuse/skip a cached frame when no state, size or render-profile change needs comparison. Keep external Application.snapshot returning an independent copy. This does not request M2 partial layout/paint. Coordinator disposition during review confirms §3.2 remains binding: idle must only check size/queue, and unchanged counters cannot replace that obligation. F006 remains Important; source/call-chain evidence suffices without inventing a public test hook.

## Lint suppression independent check

Normal complete source lint was run with all configured rules, without disabling G.ENU.01 globally. A separate copy under `lint-unsuppressed/src` removes only the two inline suppression comments. Full lint there adds exactly two distinct findings:

- `src/change_kind.cj:4`: `Enum sugar access 'Style' conflict with type name`.
- `src/style/style.cj:3`: `'Style' redeclared as different kind of symbol`.

No other distinct diagnostic disappears through the two comments. Normal report has zero Mandatory findings. Both forms are valid in the compiled package: ChangeKind.Style is qualified at call sites; Style is the existing exported struct in cjtui.style. The localized suppressions are justified and do not skip lint. Raw reports/exit codes and comparison are in `raw/lint-*`. The raw arrays contain repeated suggestions; counts are not a count of unique findings.

## Scope explicitly set aside

- C: If/ForEach/ListItem/manual child APIs, structural command rollback/ordering, structuralOpsPerBatch and structural cycles: R001 assigns implementation and full validation to 076–080. No early failure for absent C APIs.
- M2 partial rendering, theme integration, focus, modal/overlay domain routing, full keyboard decoding: follow-on tasks. F005/F006 concern explicit retained metadata/idle behavior, not a demand to implement those future features.
- Linux full completion, TASK-002/004/014/015/032 full acceptance, other OS targets, release: outside this A+B review; not declared complete.
- No deterministic real SDK thread-id reuse experiment was attempted; F004 is explicitly a source/lifetime guarantee gap.
- No full suite rerun, no standard bundle/clean package consumer run, and no repeated 15-negative macro run; TASK-074 owns them. This review reads fixed tests and adds only targeted new probes.

## Reproducibility and evidence

SDK `/workspace/work/validation/sdk/cangjie/envsetup.sh`; actual cjc 1.2.0 x86_64-unknown-linux-gnu (`raw/sdk.txt`). Probe is a normal CJPM executable depending on `../source`, with normal product build hook. Independent cache copied from the read-only seed into `runtime-review/cache`; registry setting uses port 18973. Product/test/spec tracked sources were not edited. `sourcehash.txt` records the exact technical diff SHA256 and candidate commit; `source-files.sha256` and `artifacts.sha256` enumerate contents.

Commands, run from `runtime-review/probe` after sourcing SDK:

```
cjpm build -i
TERM=dumb COLORTERM= timeout 20s target/release/bin/main </dev/null
node /workspace/work/runtime-review/hidden-pty.mjs
```

Final consumer builds: `raw/probe-build-final.exit=0`, `raw/probe-build-render-stale.exit=0`. Headless focused probe `raw/probe-render-stale.exit=1` is expected RED from F001/F002. PTY focused probe `raw/hidden-pty.exit=1` is expected RED from F003; native restoration passed.

Probe authoring initially used illegal mutable escaping captures; compiler rejected only probe source. Corrected to Array reference storage before behavioral execution. The first and second build logs overlapped briefly because the first failed compiler's wrapper was still finishing; retain `probe-build-initial-syntax.log` and the original contaminated `probe-build.log` as non-authoritative authoring records. The later uniquely named build logs/exit files above are clean and authoritative. No compiler failure was counted as a product behavioral test.

Final recommendation: return F001–F006 for coordinator ownership and independent regression additions; repair product, then review only affected paths/probes against a new fixed SHA. TASK-073 must remain open while Important findings are unresolved.
