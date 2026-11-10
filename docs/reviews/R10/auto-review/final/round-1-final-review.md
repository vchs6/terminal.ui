# TASK-062 final scoped re-review at ead6a8d

## Final review verdict

Fixed target: **`ead6a8d732c96fc108a52df3775dea8f84a84c59`**.

**Spec compliance: PASS for the reviewed implementation/test-contract scope. Code quality: PASS, with the recorded localized row-emission duplication deferred.** All seven Important findings from the original full review are closed. No new Critical/Important finding was identified in this fixed repair delta. This admits the fixed source and harness to independent TASK063 execution; it does **not** assert real-GUI, package, consumer or final acceptance success. TASK063/TASK064 remain separate evidence gates.

This verdict combines the original full technical review at `96a8c4b`, the fixed product review at `f8b194eadce879e8fe3a8c900c0bd7aa8d9bd8c2`, and the current remaining test/capture repair review. Product/native/manifest/example sources did not change between f8b194e and ead6a8d. The reviewed complete final test delta is `226886a..ead6a8d`, supplied as `round-1-final-test-fix.diff` (51,845 bytes; SHA256 `8d064789db32de22777e1890aba73b1157c90573191d43d122a931fa3f4724ff`). Only changed test paths and directly related evidence were examined in this last pass; unrelated code was not re-reviewed.

Historical FAIL and measured counterexamples remain in `round-1.md`, `review.md`, `findings.json`, and `probe/`. Product-scoped dispositions and repair probe remain in `round-1-recheck.md` and `probe-round1/`. They have not been overwritten with a PASS-only account. Model dispatch remains **gpt-6-astra/high**, as confirmed by the controller; no additional runtime-model identifier was exposed and no subagents were used.

## Remaining repairs reviewed

**F6 — closed.** `verify-sgr.mjs` now requires a known host profile, all boolean diagnostic fields, known color/terminfo evidence, the expected mode/source and empty success reason. The frozen expectations distinguish Basic8 xterm, Indexed256 xterm configuration and truecolor XFCE/VTE. Basic8 rejects bright foreground/background codes; NCV uses bit masks against the attributes active on colored text, correctly handling combined/unknown bits while allowing supported uncolored attributes. The three sample foreground/background pairs are literal nominal expectations; all three must appear, and an unexpected pair on the rich line fails. No copied product nearest-color implementation was added. The original false-positive input from `probe/invalid-basic8-*` now exits1 (missing required support field), as retained in `final-test-raw-inspection.json`; the supplied black-box tests also specifically exercise bright codes with otherwise complete diagnostics.

**F7 — closed.** The fixture's dedicated `fence` boolean changes on each `p`, independently of event serial parity. Each ordinary action is followed by a separate `p` callback. The observer requires the exact complete changed row, including final reset and actual terminal columns, to appear in the recorder file. Quiet checks require that fence to start exactly at the interval's pre-action offset. Thus an action's earlier render bytes must have traversed the PTY/recorder before the observed fence; file acknowledgement alone no longer establishes output completion. Resize additionally waits for the actual inner PTY grid change before a subsequent action/fence pair. Raw offsets, style, width and observation time are retained. This resolves the previously identified delayed-recorder and old-style-fence counterexamples without a timing-based silence oracle.

**F5 — remains closed.** The final fixture still constructs rich and fence nodes inside Column, retains those objects for callback updates and offers the separate public render validation. Its additional key filter avoids counting unrelated key events as scripted acknowledgements. No product test hook or special case was introduced.

**Ordinary example capture — source review accepted, execution pending.** `CJTUI_TERMINAL_SCENE=example` uses the actual `examples/colors` build or explicitly selected normal binary, the same real terminal hosts and the original source. It captures initial/red/gray/restored/t-off/t-on/resized PNGs via the actual X11 window, original stage raw spans and SHA256 metadata, then q and both termios records. It neither changes the example nor claims fixture diagnostics belong to that binary. Inherited COLORTERM is removed before starting a host; host-created declarations remain recorded in `outer-tty.txt`. GUI/capture dependencies stay entirely in tests. Positive output observation waits for newly recorded CUP output ending in SGR0 with a brief stable interval; documentation correctly confines this to positive example capture and assigns exact silent-event proof to the separate fence fixture.

The positive-output helper counts CUP occurrences and checks the ending reset; it is not a full terminal-screen or complete-frame validator. Actual stage PNGs/raw content still require executor/acceptance inspection, and `completeRows` in its JSON must not be read as an independent geometric validation of every row. This is a stated evidence limitation, not a claim that the screenshot stages have already passed.

## Evidence checked without duplicate suite execution

- Read all ten changed test files and all 18 new observer/oracle test cases in the fixed diff. Cases cover valid profiles, bright rejection, provenance/field errors, nominal pairs, NCV combined/unknown masks, unsupported attributes, absent/incomplete/stale fence output, delayed recorder delivery, positive output and missing growth. Controller reports these 18 tests already executed. No complete same-source Node suite was repeated, and that report is not presented as the reviewer's own new execution.
- Compared those ten fixed files with `/workspace/work/auto-harness-repair/` using `cmp`; every file matched the evidence-producing author's fixed source. No author self-assessment was used. Read `evidence/check-real-pty.mjs` to establish commands, binary selection and what the retained session demonstrates.
- Independently inspected the retained `evidence/pty-fence/session.raw` against every JSON fence interval (startup, red, gray, restored, attributes, resized, noop). All seven byte slices exactly match the expected fence row, including the terminal width. Resize has 1029 preceding bytes and the 100-column fence; no-op has zero preceding bytes and its new 100-column fence. Before/after termios files are identical. This supports recorder/fence behavior under a real Linux PTY, not a real xterm/VTE window. The raw inspection result is `/workspace/work/auto-final-review/final-test-raw-inspection.json`.
- Re-invoked only the original reviewer false-positive oracle input against the repaired verifier with `xterm-default`: exit1. No product test suite was re-run.
- `git diff --stat f8b194e ead6a8d -- src native cjpm.toml examples`: no changes. `git diff --check 226886a ead6a8d -- tests`: no errors. `sh -n tests/terminals/run.sh tests/terminals/inner-recorder.sh`: exit0. Independent checkout HEAD is the exact final target and its tracked worktree remains clean.

The product-specific NCV repair, cleanup fence, ABI constants and wrapper-removal evidence remains in `round-1-recheck.md`; nothing in this test-only delta invalidates it. M2's localized active row-loop consolidation is expressly deferred in the controller ledger, with the reset-boundary reasoning already recorded; that ruling remains applicable.

## Final disposition and limits

| Finding | Final review disposition |
|---|---|
| F1 unknown NCV | Closed at f8b194e; reviewer repair probe confirms colored/uncolored/Monochrome/NCV18 boundaries |
| F2 detection cleanup fence | Closed at f8b194e by corrected control flow; retained lifecycle raw evidence reviewed |
| F3 cwd paths | Closed at 226886a; capability suite reaches its end in retained raw log |
| F4 override call | Closed at 226886a; proper action argument and separate profile assertion |
| F5 detached fixture nodes | Closed; construction and retained mutable references fixed |
| F6 real-host SGR/provenance oracle | Closed at ead6a8d |
| F7 recorder transport barrier | Closed at ead6a8d |
| M1 ABI/NCV constants | Closed at f8b194e |
| M2 unused wrappers | Closed at f8b194e |
| M2 localized row-loop duplication | Explicitly adjudicated/deferred; no active encoding/reset behavior altered |

No actual GUI matrix, ordinary-example window, original PNG validity, host process behavior or stage rendering has been independently executed in this review. Normal cold build, complete applicable suites, standard bundle and clean package consumer remain TASK063 obligations. Existing raw PTY evidence is not substituted for actual xterm and XFCE/VTE; two xterm configurations remain one terminal implementation. No physical Linux console, tmux/screen, other libc or other platform claim is made. The whole-framework/release scope remains outside this limited color/Auto review.

### Explicit execution check: terminal-host versus application exit status

The controller highlighted the neighboring fixture exit oracle in `tests/terminals/run.sh:155–156`. Source review confirms that it waits for both recorder `exit_status` fields but then judges q/exception against `wait(hostpid)` status. Only the ordinary-example branch subsequently asserts inner/outer status0. A terminal host is a separate process: if it exits0 while its child exits nonzero, the current exception case would fail despite the application behaving correctly; a nonzero host status alone also cannot establish the application's expected exception. No actual fixed-host XFCE/xterm exception result proving a status mismatch was available in this review, so no specific host behavior is claimed or marked passed.

Per the controller's instruction to leave unproven host-specific behavior to execution, this remains an explicit TASK063 check rather than a new unverified product defect: inspect the inner/outer recorder statuses and actual exception sentinel on every real-host exception run, and do not accept the host status alone as application evidence. If the host does not propagate status, correct only the test oracle to use recorded application status as authority and retain host status separately, with a focused recheck. The new bounded host wait correctly avoids an unlimited hang. The finite source-review PASS above is not an assertion that this real-host compatibility condition already holds.
