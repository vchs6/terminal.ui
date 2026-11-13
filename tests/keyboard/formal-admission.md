# TASK113 formal test admission — current qualification

Root ACTUALGO follows independent C112 PASS. This is a test freeze for K001–K004/F001–F003/F006–F007, not product114, keyboard behavior PASS, editing118 or final117 acceptance. Root brief `.superpowers/sdd/tasks-implement-linux-input-editing/task-113-final-brief.md` governs the current admission; old planned/preparation wording remains historical.

The previous91379725e102a0d1d1caa9ca8d311efcfb0293c7 assets and R19 evidence remain immutable. Original PF001–004 were independently closed at88ed5f7866fae04c0459ab7310f927b02fb59c29 (`/workspace/work/input-preflight-resume/findings.json` and reviewed-hashes); later F006/F007 are independently scoped at `docs/reviews/R17/i015-preflight/`. Old `execution_ready=false` described absent actual role/dependency prerequisites, not unresolved design findings. Actual080/084/088/092/102/107/112/152 admission is supplied by root. Public C112 `docs/reviews/interaction/C/overlay-acceptance/acceptance.md` SHA256702cd9f253fbc005821920875eccc865f7cf1dfad4847c87ed13a27ef0d8c123 was checked.

The new normal `upstream/` public consumer actually builds/runs0 on accepted main91f79bbad8d22d1902f03a267430bbb2bd2a1c14. It uses real Canvas/focus/activeTarget/viewport, modal open/close/focus restoration and Session152's honest headless Unsupported/NoDevice result. It does not implement or stub Keyboard. The normal public decoder consumer then actually fails compilation for missing KeyboardIssue/Decoder/Limits/Batch and modifiers. This is missing-API RED, not protocol/paste/device behavior execution; complete new consumer body type correctness remains pending actual K declarations.

## Frozen entry and manual oracles

Run with the normal SDK/stdx/UCD environment and a complete ordinary registry cache:

```sh
bash tests/keyboard/run.sh         # upstream, decoder/API-negative, dispatch, real native ABI
bash tests/keyboard/run.sh --pty   # additionally original seven device modes + formal native vectors
```

Each normal CJPM build and actual direct binary exit is required. No missing binary, infrastructure error, unexpected compile failure or skip counts as PASS. Root alone connects `tests/run-slice.sh keyboard`. `check-api.sh` only runs after the positive actual API consumer, preserving its original negative-test gate. `src/protocol_report_cases.cj` appends standalone public-decoder F006 reports: status0–4 exact9-byte CSI, budgets8/9/64, literal Unsupported/SequenceTooLong offsets; no device contact or second decoder. All original pure byte/split/UTF8/C1/paste/limits goldens retain their semantics. `formal_dispatch/` pins reserved invalid combinations before callbacks, healthy session, legacy interrupt/backtab, tab+shift and custom unknown codes through public dispatch.

`formal_pty.py` never parses terminal keyboard input. It writes literal bytes and checks public callback records; every event/diagnostic/paste target expectation below is hand derived. Native read/poll FD remapping uses a real OSpipe while isatty/TCGETS/TCSETS/size remain true PTY. Its trace records actual read counts/data, real poll revents and actual read0. Before a pending-paste mutation, the producer supplies only the prefix, observes its bytes consumed and a subsequent real empty-pipe poll, then requests a real background app.post and observes a later poll after that callback's safe commit. No elapsed sleep alone proves ordering; no cjt_read or return value is mocked.

| Frozen selector family | Literal oracle / barrier |
|---|---|
| stream-two | One stream `b,begin,x,end,a,begin,y,end,q` yields exactly `B:x;A:y;`; focus callbacks commit before each begin |
| focus / scroll | begin+x, real-prefix-consumed barrier, focusB or scrollA offclip, end: exactly `A:x;` |
| hide / disable / unmount / remount / modal / no-target | Same prefix barrier then actual mutation; no paste/app/legacy delivery, one PasteTargetUnavailable@0; remount occurs in a subsequent post after old unmount commit |
| diag-begin / diag-context | Unsupported CSI99~ at offset0 precedes begin; diagnostic commits focusB and Observable before begin, target is `B:x;`; context variant allows structure/post and rejects snapshot/dispatch/dispose with LifecycleReentry |
| issue-stop / issue-throws | Same UnsupportedSequence@0; no later input delivery; stop or original thrown object preserved, all resources released |
| eof-input / eof-paste | Real pipe close retains tail; `ESC[12` gives IncompleteInput@0, begin+xy gives IncompletePaste@0; actual native read0 required; active issue callback commits Observable and accepts post, then EOF cancels unrun post, emits no extra target frame/half-event |
| fair-normal | First x callback FIFO-gated;8192 more x are queued; queued post observed at text count1…4096, final text count8193 |
| fair-paste / fair-drain | First-x gate plus begin+5000a; post progress while incomplete/drain is proven by real prefix/poll barrier and subsequent app.post before end; complete paste is exactly5000a, drain gives only PasteTooLarge@1 |
| cancel-paste / cancel-drain / signal-paste / signal-drain | Prefix and actual idle-poll proof precede app.stop or real SIGINT/SIGTERM; no partial paste or UI interrupt; drain retains only prior PasteTooLarge@0 |
| protocol-reply | Exact real device mode25 report is consumed by the single native decoder contact, creates no business key/issue; only q is delivered; public decoder has the opposite frozen unsupported-report oracle |
| fault-{init,cleanup}-{zero,partial} | Match actual stdout buffer containing2004h/l, never guessed call index; partial writes deliver one byte then fail, unsafe permits zero later stdout; failure reported, native termios/resources restored, display-mode restoration explicitly insufficient |

The root-frozen private `int cjt_read(int)` ABI keeps byte0…255, -1 actual timeout, -2 cancellation, -3 error and -5 nonidle interruption; -4 is reserved for actual read0. `native/pipe_probe.c` asserts the measured byte0/255/timeout control and tail/EOF boundary; -2/-5 are unchanged accepted native constraints, not newly executed probe branches. Real POLLIN|HUP tail must precede EOF. Phase01 separately proved the OS mechanism and old defect: positive0/255/-1; real simultaneous POLLIN|HUP returns native-3 while ABC still exists, real read0=0 but native-3. An external read/poll FD remap positive control achieved actual read3/read0 with cjt_open/close on a real TTY and exact termios restoration. This is not master-close-as-EOF. The final adaptive regression assertions for65/66/67/-4 remain UNEXECUTED against a K implementation.

## Exact execution limits

Actual evidence: native OS feasibility/old ABI gap, accepted upstream baseline0, missing public K compile RED, and static/tool checks. All new K normalized behavior, formal_dispatch, original seven Keyboard device modes, all formal_pty selectors, EOF Keyboard finish/callback behavior, new2004 fault paths, real-host input production/PNG and complete body type checking are UNEXECUTED until114 supplies actual APIs. Old isolated declaration/syntax/negative/FIFO evidence is reused only within its original language/infrastructure scope; no fake Keyboard implementation is linked or executed. Counter exhaustion/asymptotic bounds require source review or reachable production evidence, never a fabricated2^63-byte run or public hook. See formal-integration-ledger.md for each old obligation's current qualification.
