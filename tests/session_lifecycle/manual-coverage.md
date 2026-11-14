# Frozen C004 hand expectations and precise coverage

Base13e7880ce96d1331fc9e12a2b62275a307183e9a; independent author tests only.
Canonical owners: complete-linux-integration C004; session-extensions S007/S008;
linux-input-editing K004 design118–120; public-interaction I015 design438–506;
reactive-runtime R003/R011/R012/R017/R018. Existing152/117/122/112/162 remain
finite scoped inputs through reuse-map. No new public API or cleanup promise.

For every safe ordinary exit: close owned title scope once (only
RestoreSentUnconfirmed), then owned2004 disable; restore known managed mode25
if actually changed; restore exact original termios and handler/mask/flags;
free native buffer and release owner; revoke all UI tokens, subscriptions,
posts/focus/caret/layers; attempt every registered cleanup once. Business error
stays primary and later cleanup failures remain additional. Same Application
run2 starts without prior bindings/posts/focus/caret/layers/error state.

| Scenario | First run literal expected outcome | Second run |
|---|---|---|
| stop | q→stop; queued owner post cancelled | q normal |
| ctrl-c | raw03 default cancellation, normal return | q normal |
| prevented | raw03 prevented; alive until q | q normal |
| signal-int / signal-term | actual catchable OS signal cancels; no UI prevent | q normal |
| callback | L020_CALLBACK | q normal |
| getter | L020_GETTER after first frame | q normal |
| draw | L020_DRAW after first frame | q normal |
| post | L020_POST from queued closure | q normal |
| cleanup | L020_CLEANUP; other cleanup attempted | q normal |
| callback-cleanup | primary L020_CALLBACK, additional L020_CLEANUP | q normal |
| close | terminal restore failed injected after actual successful restoration | same explicit injection |
| callback-close | primary L020_CALLBACK, additional terminal restore failed | same explicit close injection |
| worker-stop | actual worker queues owner post then stop; consumer joins; queue cancelled | q normal |
| pipe-eof | actual OSpipe read0 via native poll/read, normal EOF | q normal |
| pipe-hup | OSpipe POLLIN\|POLLHUP: z key, incomplete CSI→IncompleteInput, then real read0 | q normal |
| initial-getter/mount/measure/draw | exact L020_INITIAL_GETTER/MOUNT/MEASURE/DRAW; all registered cleanup once | reset fixture fault; same app q normal |
| tty-eof | actual original TTY read0 after external canonical-VEOF setup, normal EOF | product restores exact termios, real raw re-open; q normal |

All21 rows have visible/hidden/Unknown PTYwire states (63 processes,126 runs).
Known visible first layer hides and restores visible; known hidden base/layer
shows and restores hidden. Unknown times out and emits zero25h/l/s/r. The default PTY stress consumer (not normal Auto host integration)
declares title stack support, sets L020-N, receives
SaveSentUnconfirmed, and cleanup receives RestoreSentUnconfirmed. Actual host
acknowledgement is not inferred. NoImageAdapter is Unsupported, not startup
failure. Prior2004 remains unknown-unqueried in PTYwire: owned enable/disable
is the contract, not query/preservation of pre-enabled2004.
The same21×3 safe matrix additionally runs with CJTUI_020_HOST_AUTO=1:
color/glyph/session policies stay Auto; no optional title request or scope is
created, no title save/set/pop bytes are allowed, NoImageAdapter stays Unsupported.
Normal actual-host execution defaults to this Auto branch; declared title
stress is a separate explicit opt-in and is not capability confirmation on VT.

Resource break detection: removing token/queue revocation fails stale refs,
layer handles, inactive/old owner posts and getter silence while closed;
missing cleanup/free/native close fails once-only counters/tracked buffer,
full handlers, termios and restart ownership; broken focus/caret closure fails
literal canonical empty assertions. A competing real native cjt_open must
return -1 while active and must not disrupt the owner. No duplicate native
runtime is created. Real buffer tracking only surrounds cjt_buffer_add's
realloc; it does not misclassify arbitrary Cangjie heap allocation as native.
The business owns and joins its worker, while Application owns session queue
tokens; C004 does not add arbitrary business-worker cancellation/join ownership.

Actual endpoint HUP is separate (one Unknown process, no restart): after public
ready close the last real PTY master. The frozen oracle selects by actual native trace, never by exception text:
read -4 requires actual TTY read0 and makes title cleanup the primary
`host title restore failed; visual title state not confirmed`; read -3 makes
`terminal input failed` primary, followed by title cleanup; a size snapshot -1
before another read makes `terminal size unavailable` primary, followed by title
cleanup. Every branch then has paste `terminal write failed` and native
`terminal restore failed` in exact additional order. Both EOF and input-error
branches were observed; the size-error branch is a prepared native-trace
contract branch, not claimed executed. Consumer checks
UI empty, once-only cleanup; native confirms buffer free and restored handlers.
Post-HUP tcgetattr is EIO, so exact termios restoration is unavailable and
native reports failure. No replacement descriptor or fake recovery/reopen is
allowed. SIGKILL is outside cleanup guarantee; forced timeout kills fail tests.

008 zero/partial fatal output and baseline commit ordering are reused from
accepted ae1eaf30/880f71ed, whose src/native/cjpm/build match this base exactly.
Partial unsafe permits native-only cleanup, no subsequent2004/25/title/frame/
clipboard bytes, same-process reopen refused. Zero fatal is not partial unsafe.
The existing accepted338 cuts are not repeated. RuntimeStats.frames is never a
successful device-write counter. Prior finite title Unknown/Unavailable,
no-request, disabled/invalid capabilities, original I015 cancellation/clock
and nested112/117/122/162 behavior are reused only within their pinned scope.

Actual Linux -3 input-error transport retains117 native evidence/source
contract; natural last-master HUP observed both read0 (-4) and native input error (-3).
No claim covers all possible kernel/device error paths or uncatchable signals.
The canonical-VEOF and mapped OSpipe rows each state their external mechanism,
not spontaneous EOF from an untouched raw physical device.

Remaining required evidence: run frozen host driver/probe/oracle and fixed keys
on actual XTerm/VTE/VM-VT (host-plan), exact before/after original mode25 and
prior2004 observations, title property, direct exit, original PNGs and native
records. VM console must be labelled virtual, absent hardware not certified.
Host fixtures currently syntax-only. Final M1 all-widget/input/edit/native
integration must be assessed by independent review/execution/acceptance against
unchanged scoped evidence and this delta; this author cannot close020/M1/Linux.
M2/release affected changes later return to024; no early final Linux claim.
