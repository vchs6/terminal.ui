# TASK100 scoped fix round1

Fixed `f02d8124dfad6028da1427c3da877eeec05a5708` → `6f0fcc4006d3b6138e823eaa6d127a548db58a21`. Spec **CHANGES_REQUIRED**; quality **CHANGES_REQUIRED**. Six findings addressed; original **T100-I05 remains Important / NOT_ADDRESSED**. No new out-of-scope issue or expanded review round.

Reviewed the full22-file delta only: original seven fixes, their direct cache/layout/input/queue impacts, and the immutable independent13f75 overlay. Original review remains sealed. No author report/self-assessment or author communication; no product/test/contract/main modifications and no subagents.

| Finding | Disposition | Evidence and source judgment |
|---|---|---|
| T100-I01 | ADDRESSED | Natural measurement dependencies are retained as a bounded seed alongside the current constrained dependencies; trackNatural replaces the prior seed, subscribe/version checks remain shared, dispose clears both. Original geometry case passes. |
| T100-I02 | ADDRESSED | Behavioral state changes compare cached resolved layout fields through the single resolver; geometry differences invalidate measurement, pure appearance remains Style. Shared comparator is byte-equivalent to the prior theme candidate field test; no business getters are invoked. Focus and enabled constant/getter cases pass. |
| T100-I03 | ADDRESSED | Pending structure/focus share a queue bound, and valid focus requests consume the existing structuralOps counter at repair. Focus/focus and both mixed order cases pass, including the inclusive positive control. |
| T100-I04 | ADDRESSED | Effective enabled and visible now traverse their respective properties. Eligibility and activeTarget explicitly combine both; readonly query and resolver preserve separate behavior meanings. Ancestor and own visibility cases pass. |
| T100-I05 | NOT_ADDRESSED | Initial/known-before-read clock failure uses completed-poll fallback and the original always-minus-one regression passes. Failure first observed after read still calls decoder.timeout immediately on now<0, with no elapsed100ms evidence; independent sub2ms CSI direction sequence is corrupted. |
| T100-I06 | ADDRESSED | Unmount invalidates all descendants, then removes invalid pending focus refs before repair. Node and ancestor removal cases pass; direct stale-ref use remains rejected. |
| T100-I07 | ADDRESSED | Both recordCommand and commitCommand reject Canvas and Text parents as leaves before mounting. Root/nested Canvas rejection and ordinary container append/insert controls pass. |

## Remaining I05 counterexample

At application.cj:630, a clock failure first observed after reading the next byte is still an immediate ESC timeout. Line645 retains the same assumption after a read timeout, including potentially shortened probe polls; the actual independently reproduced failure is the line630 input branch.

One ordinary SDK1.2 public consumer, exported from fixed6f, links the frozen test-only clock seam. After a valid original-visible report, it sends ESC with two clock samples at1000, switches the seam to-1 while poll waits, then sends `[A` **1.554632ms** after ESC. Actual events are `escape:|text:[|text:A|text:q|`; expected `up:|text:q|`. Same-binary control at1.158898ms yields the expected up event. Both child exits are0 and termios restores. The driver exit0 means the observation completed, not that product behavior passed; `matches_expected=false` is preserved in the failure result.

The original always-minus-one test now passes and is credited. It does not cover failure first detected after a valid timestamp and before processing a timely suffix. This is the same I05 clock-failure/ordinary-input obligation, not a demand for future Keyboard features.

## Source and execution identity

All195 entries in pre-identity-2 independently match final6f Git bytes; four configs are recorded by that raw identity. Its real pre-run commit label remains e56ce5c and UTC2026-11-11T08:13:31.911692+00:00; the subsequent commit-only identity is not backdated. All43 fixed interaction test files match13f75. The authoritative design hash is unchanged. Exact file/diff/raw hashes are in reviewed-hashes.json.

Existing focused-2 actual13 results (12headless variants plus initial UnknownClock real100ms PTY) are0. The eight targeted device cases are0; their clock-pending-fails case verifies capability failure, not the retained ESC-state transition. Normal headless and mandatory bundle raw exits are also0; available clean outcomes are listed below. These facts do not negate the independently reproduced remaining defect. No cold suite repeated.

- headless: actual exit0; recorded UTC2026-11-11T08:14:22Z.
- bundle: actual exit0; recorded UTC2026-11-11T08:16:36Z.
- clean-build: actual exit0; recorded UTC2026-11-11T08:18:06Z.
- clean-run: actual exit0; recorded UTC2026-11-11T08:19:27Z.

Independent probe build exit0. Own148 exported product inputs were checked against fixed6f before execution; only a small public consumer and the existing link seam were built, using the existing ordinary SDK/cache. The first control-driver attempt had a Python bytes-to-JSON serialization error after a child exit0; its stderr/exit/wire remain under raw/harness-first*. The driver serializer was corrected, then the control and failure were actually run. No product failure is inferred from that harness error.

Physical-host acceptance, final independent TASK101 execution and TASK102 acceptance remain open. Source CHANGES_REQUIRED is based on I05, not on a pending packaging task.

Archive only artifacts.sha256 entries: report/findings/reviewed-hashes, minimal public probe/driver/command and raw. Source export, SDK/cache, ELF/object files and full contract/source trees are excluded. Original report/findings/evidence are untouched.
