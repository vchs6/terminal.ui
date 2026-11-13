# Hand-judged C004 matrix — frozen preparation expectations

Status: PREPARED, UNCOMPILED, UNEXECUTED. No product RED/GREEN/admission/020 closure.
Author scope: test-only020.a, Sol/high; no subagents, product edits or builds.
Classification: execution of existing C004, WP004/REQ004/011; no new API/design.
Authoritative base `5a6819ffd2226ad31e725669209b94607f2b1e63`; future formal
base is actual accepted008 plus root fixed admission, not this exploratory base.

## Exit expectations

All rows use the same Application.run and actual native owner. On catchable
exit, stop input/probe authorization, revoke UI tokens/posts/subscriptions,
attempt every registered cleanup once, preserve primary/additional failures,
release native owner/buffer and restore exact termios/handlers. Safe managed
mode/title restoration follows the ownership table below. No wrapper may clear
process unsafe. A timeout/forced kill/missing binary/compile error is evidence
failure, never a product RED or lifecycle PASS.

| Exit/trigger | Expected application result | Prepared/new coverage | Further actual coverage |
|---|---|---|---|
| q calls stop; repeated dispose | normal return, cleanup once, later posts false | stop ×3 caret states; stopped owner post never executes; second run | accepted host delta/rebind |
| raw03 unprevented | normal cancellation via default action | ctrl-c ×3, second run | nested modal/edit/paste cancellation reuse/delta |
| raw03 prevented | session stays active until acknowledged q | prevented ×3, second run | accepted112/117 scoped controls |
| OS SIGINT/SIGTERM | cancellation, not preventable UI key | signal-int/term ×3, second run | original handler flags, masks and owner/reaping supplement |
| business event throws | exact L020_CALLBACK primary | callback ×3, second run | whole final M1 widgets/components delta |
| getter throws after initial frame | exact L020_GETTER primary | getter ×3, second run | initial getter/mount failure input binding |
| draw throws after initial frame | exact L020_DRAW primary | draw ×3, second run | initial draw/startup and measure cleanup cases reuse/gap |
| posted callback throws | exact L020_POST primary | post ×3, second run | actual background worker joined/cancelled and owner race supplement |
| cleanup-only throws | L020_CLEANUP reported, other cleanup attempted | cleanup ×3, second run | multiple/deepest layer failures reuse112 |
| business + UI cleanup throws | callback remains primary, cleanup additional | callback-cleanup ×3 | native/UI triple failure reuse152; final affected components |
| real close reports failure after restoring | terminal restore failed explicit; native owner freed | close/callback-close ×3; run2 closes again with expected injection | exact allocation free proof/handler flags; not real unwriteable-device recovery |
| actual read EOF | decoder.finish, incomplete diagnostics while active, normal run end | reuse117 normal contract; not implemented in this new driver | real EOF -4 + second run/target cancellation, raw/native evidence |
| HUP with buffered data/read failure | follow real read result: bytes first, EOF -4 normal; -3 explicit input failure | historical A -3 oracle predates K; unchanged helper is not unchanged current EOF semantics | true HUP ordering/termios availability after peer closure; no fake PTY recovery |
| zero-byte fatal output | run fails; cleanup only within frozen S008 allowance | reuse actual008 evidence after acceptance | relevant source/order/runtime delta only, no338 matrix duplication |
| partial fatal output | process unsafe; no later frame/2004/25/title/clipboard output; native cleanup only; reopen refused | reuse actual008 +152 primary/additional and native observations | root accepted008 exact source/test/raw binding required |
| SIGKILL | cleanup cannot execute | explicitly outside cleanup guarantee | process reaping recorded as harness abort, never product restore |

## Mode and resource ownership expectations

Canonical clauses (read at fixed base, separately from source observations):
`implement-linux-input-editing/design.md:118` says restore **自己请求的2004**,
with 2004 uniformly session-owned, not component ANSI. `:120` forbids 2004/25/
title cleanup output once unsafe. `implement-public-interaction/design.md`
I015 (`:438–506`) limits mode25 to actual original Known and actual managed
changes; Unknown emits no25h/l/s/r. `complete-linux-integration/design.md`
C004 (`:29–31`) requires termios/raw, handlers, native owner, managed original
caret visibility, 2004, verifiable title scope, baseline and UI resource coverage.
`docs/requirements.md` REQ004.6/.7 requires successful device baseline ordering
and explicit recovery failure, not a guarantee that a broken device recovers.
Root clarified C004 consumes this frozen2004 owned-enable/disable contract; it
adds no original2004 query/preservation promise or unresolved user decision.

| Original/input | Safe cleanup expectation | Unsafe expectation | Evidence/reuse/gap |
|---|---|---|---|
| exact termios (all flags, cc), raw while active | exact saved struct after real native close | same native-only attempt, record failure | existing Capture before/after; new driver records; active raw verification still supplement |
| SIGWINCH/INT/TERM original dispositions | original handler+mask+flags restored | same native-only attempt | Session152 helper observes handler/mask; exact flags gap |
| native owner/buffer | one actual open/close each run; later run reacquires; no outstanding allocation | free/release native resources; unsafe remains latched and rejects next open | wrapper actual open/close logs +2 runs; exact free and competing Application owner gaps |
| caret original visible; actual managed hide | restore25h once if still changed | no25 output, report restoration insufficient | new driver first-layer hide; actual I015 accepted host input reuse/delta |
| caret original hidden; actual managed show | restore25l once if still changed | no25 output, do not assume visible | new driver intentionally requests visible logical caret; accepted I015 hidden scope |
| caret Unknown/timeout/no valid report | preserve native visibility; no25h/l/s/r | zero visibility bytes | new driver timeout branch, no fake known reply; actual VT accepted Unknown evidence scope |
| caret Known but never changed / not probed | no invented or redundant restore required | no25 output | existing I015 cancellation/clock/caret cases reused |
| 2004 original off/on/unknown observations | owned enableh completed => owned disablel on safe exit; never assert unknown original state restored | zero2004 output after unsafe | new driver checks own h/l ordering only, labels prior2004 unknown-unqueried; collect actual off/on/unknown host observations separately |
| title scope known declared/verified support | only own saved scope popped once; result remains SentUnconfirmed absent actual host confirmation | zero title bytes | reuse152 ledger-close/error/cancel, known host title observations; final delta |
| title unknown/no stack/no owned change | no invented restored title; Unknown/Unavailable as existing152 | zero title bytes | reuse unknown-title/no-request/policy cases; no new title parser |
| image adapter absent | Unsupported/NoImageAdapter does not stop core UI | no recovery output | reuse152 invalid/disabled/public host cases |
| UI baseline | success only after complete device write; frame generation is not success | no successful baseline commit/clearing after failure | actual008 raw/phase ordering reuse; RuntimeStats.frames never oracle |
| subscriptions/posts/focus/caret/layers | zero resources/empty queries at close; old references invalid; first-run work absent in restart | same resource revocation without terminal output | new public consumer asserts; old layer rejected by new active context |
| background worker | join/cancel cooperatively, no old owner work can affect new run | native cleanup and process lifetime still observed | separate worker race/join runtime supplement required; not proven by main-thread queued posts |

## Reuse and precisely blocked actual work

`reuse-map.json` pins helpers and accepted evidence indices without copying
source/history/SDK/cache/raw. Existing unchanged scopes retain their verdicts;
R10 PTY oracle changed for atomic resize, so original helper bytes are not all
historically identical. No old result is presented as new020 proof.

After actual008 accepted source and root GO, rebind exact152/117/122/112/162 and
I015 inputs and compare affected hashes. Independent executor compiles these
public consumers with SDK1.2.0 and the unchanged native wrapper; a compilation
error is uncompiled test preparation to correct, never behavioral RED. Freeze
real expected failures only from actual executions, then independent product
role fixes only confirmed gaps, with independent source review/execution/
acceptance. Supplement actual EOF/HUP, startup/competing-native-owner/free/
handler-flags/worker cases before complete020 claims. Run affected final M1
components and genuine host implementations, retaining original PNGs plus
mode/raw/native/resource evidence. M2/release deltas remain for024; full020,
M1, Linux,023/024/041 are not closed by this preparation.

Skills actually used: pinned CangjieSkills277f2e cangjie-coding (batch cjpm/File
queries; SDK1.2.0 generated executable skeleton), Superpowers TDD (tests before
product; no product implementation or fabricated RED), verification (syntax and
literal negative-fixture checks only). Existing OpenSpec complete-linux-
integration contract/brief is consumed read-only; no task-state/spec edit.
