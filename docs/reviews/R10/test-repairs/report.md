# R10 frozen test host-tool repair

Execution task scoped to tests; base 04271d41e181516ef07c02c096f2c62411df32cd.
Fixed test commit: 5790a287e14cb232734e5966193d47e975a1b91f.

## Root cause and minimal repair

The actual ncurses tic 6.5.20250216 rejects `--version` (exit 1), but documents and accepts `-V` (exit 0). The frozen Node harness used the same GNU-style flag for all tools, failing before any PTY case. It now uses script/stty `--version` and tic `-V`; every status must still equal zero. No product file, expected SGR, golden, case, or functional failure handling changed.

## Evidence

- RED: `node tests/capabilities/pty.mjs` at 04271d4, exit 1, `tic available`, `1 !== 0` (evidence/pty-red.log).
- GREEN tool boundary: real script/stty `--version` and tic `-V` via Node spawnSync all exit 0 (evidence/tool-green.log). Node syntax check and git diff --check exit 0.
- A preliminary fresh build at fixed product 0e202f9 succeeded for tests/capabilities, SDK/cjpm 1.2.0. The binary then failed `explicit offline Basic16 preview preserves the legacy color projection and attributes` in pureSnapshots:63. This is a pre-existing product/test-base mismatch (0e202f9 predates the frozen Basic16 cyan correction); it is not reported as a green suite and no golden was changed. The coordinator subsequently requested avoiding repeated full-suite execution while newer product fixes proceed. Final complete independent execution remains another role's responsibility.
- The generated tool-boundary evidence is local diagnostic evidence, not terminal-host screenshots or independent product acceptance.

## Fixture configuration ownership

The 9-line tests/terminals/fixture/cjpm.toml is a valid ordinary external CJPM executable manifest: SDK 1.2.0, source directory src, executable output, relative public package dependency on ../../.. . This is the normal build path used by tests/terminals/run.sh and does not rescue product packaging with private compiler or linker flags.

It already exists in frozen base 04271d4, originating in test commit 9d69904. Its SHA256 and product 0e202f9's newly added copy are both 2c5a143c4233f0ca5ca3528df1035558f4a3573d37999b6272d4ab23fae832f1; the net file diff between those revisions is empty (evidence/fixture-net-diff.patch). No new configuration transfer commit is necessary. Product commits should exclude the redundant test-file addition; the independent test baseline already owns it.

## Process

Read AGENTS.md, D031–D033, test runner documentation, and the existing manifests. Applied systematic-debugging, test-driven-development, writing-good-tests, verification-before-completion, and managed cloud runtime skills. OpenSpec 1.14.3 reused from the main checkout; existing implement-color-style-output apply instructions captured in evidence/openspec-apply.json. Coordinator owns authoritative OpenSpec task status; this branch is test-only. No implementation-author analysis report was read; no other agent was spawned.

## Follow-up

The existing frozen invalid TERM case already uses TERM=bad;term plus COLORTERM=truecolor and requires unknown Monochrome. Non-ASCII TERM is not separately covered. The coordinator requested a separate ordinary examples/colors real-host capture entry; design and implementation will be a separate test-only commit, retaining all original fixture assertions.

# Subsequent independently assigned test repairs

## Fixed artifacts

| Commit | Scope |
| --- | --- |
| 5790a287e14cb232734e5966193d47e975a1b91f | Supported real ncurses tic version probe |
| 893438cb250c85026688f1e3c86b5d1374298973 | F3 repository-relative defaults, F4 override action/profile, non-ASCII TERM regression |
| b4cead548a0c9eddc19f154516b573f2cd5e71dd | F5 root-attached mutable fixture nodes and public render self-check |
| 3385157cc2a1dda6331440ce08ada1ca29c67954 | F6 strict host oracle, F7 recorded transport fences, ordinary example capture |

All commits are test-only and based on 04271d4; the whole diff contains no product source, packaging, golden change or main-checkout edit. The coordinator may have different cherry-pick SHAs. report.md and evidence/ remain local handoff artifacts and are deliberately outside the committed test patch.

## F3/F4 and missing non-ASCII boundary

F3 was independently reproduced from tests/capabilities cwd. Even after linking normally built target and generated terminfo into the correct test directories, the old harness resolved duplicated tests/capabilities paths and timed out at eight first frame (evidence/cwd-red-confirmed.log). Module-URL-relative defaults let the same focused real PTY eight case pass its original Basic8 profile and SGR assertions from that cwd (evidence/cwd-green.log).

F4 was independently reproduced by executing the original runCase function and exact override-auto call against an actual normally built fixture: stdin.write received the third-argument Object and threw ERR_INVALID_ARG_TYPE (evidence/override-red.log). The corrected 'a' argument passes the original before/after SGR assertions and the now-explicit TrueColor profile check against product 0568a09 (evidence/override-green.log). Focused diagnostic files used unmodified harness functions and literal selected case calls; no fake application supplied the bytes.

D031 requires ASCII TERM. The pre-existing bad;term case already includes COLORTERM=truecolor. A separate cap-é + truecolor case now asserts conservative unknown/Monochrome, term-invalid and no color/video SGR. It is genuinely RED against fixed product 0568a09: actual TrueColor differs from expected Monochrome (evidence/nonascii-red-0568a09.log). Newer product correction GREEN belongs to product self-check / final independent execution; this test author did not change expected results to hide that failure.

## F5 fixture construction RED/GREEN

An opt-in CJTUI_TERMINAL_VALIDATE=1 branch uses only public render(...).toPlainText() and cellAt(). Before the construction correction, the actual SDK 1.2.0 consumer compiled and then failed: missing terminal fixture scene text: AUTO RGB 1,128,254. After constructing/assigning both mutable Text components inside Column, it compiled and printed PASS terminal fixture scene and callback references. The latter also changes rich foreground and fence bold and verifies those exact public cells, proving the retained references belong to the rendered root.

This self-check does not open a terminal, replace Application, or change normal callbacks. The original terminal scene labels and rich/Unicode/fence/resize assertions are retained.

## F6 oracle RED/GREEN

Read only the coordinator-designated test-findings document, not an implementation-author report. The old verifier failed 5 of 7 new black-box test groups by accepting invalid output (evidence/oracle-red.log). The repaired verifier passes 7/7 (evidence/oracle-green.log):

- Host profile is an independent input: xterm-default requires Basic8/terminfo, xterm-256color Indexed256/terminfo, XFCE/VTE TrueColor/terminfo+COLORTERM. Both known flags must be true and reason empty.
- All six support flags and the known flags must be present, valid booleans; NCV is a valid integer; duplicate diagnostic keys fail.
- Basic8 rejects bright foreground/background. Each host must actually display all three independently literal nominal RGB sample projections, including the red background, rather than merely use a generally permitted color class.
- NCV bits 2/4/16/32 apply to underline/inverse/dim/bold in colored text contexts; combinations are checked bitwise. Unknown positive bits remove all six colored attributes. Legal uncolored attributes remain accepted.

Both terminal launch paths explicitly remove inherited COLORTERM before starting the host. XFCE/VTE may declare its own value. The real terminal child's TERM/COLORTERM are recorded in outer-tty.txt. This prevents a root-shell truecolor declaration from upgrading the xterm configurations inadvertently.

## F7 transport-fence RED/GREEN

The fixture's p event now flips an independent fence boolean every time, rather than deriving it from arbitrary event parity. Only recognized test commands advance serials, so the host injector's Return is not mistaken for a test command. Each tested action is followed by a distinct p callback. Acknowledgements identify callback processing; successful observation requires exact complete row3 bytes in the recorder, including all columns, style and final reset.

wait-fence.mjs records raw start/fence-start/fence-end offsets, columns, style and UTC time. For no-op it requires fenceStart == startOffset, allowing only the intentional marker row and rejecting any prior output. Resize first observes the actual PTY grid change, then performs a fresh n/p action/fence pair before capture. No timeout or polling delay proves rendering/silence. The helper's six black-box groups were RED before the helper existed, then GREEN; they reject ack-only, partial row, unchanged old style, and erroneous bytes preceding the fence (evidence/fence-red.log, fence-green.log).

A targeted actual Linux PTY run used normally built product 0568a09 plus the revised test fixture. All c/c/c/t/resize/n actions reached complete recorded fences; resize changed 80→100 columns; the no-op interval had precedingBytes=0; the stricter Basic8/terminfo oracle passed all three sample mappings; q exited zero and exact nonempty termios matched (evidence/pty-fence-green.log and evidence/pty-fence/). This is real PTY branch/infrastructure evidence, not an xterm or VTE window run and not cross-terminal acceptance.

## Ordinary examples/colors capture entry

The coordinator approved reusing the one existing matrix spine. CJTUI_TERMINAL_SCENE=example builds the unmodified ordinary examples/colors consumer, uses the same real host launch/Xorg/XTEST/recorders, and captures initial, c/red, c/gray, c/restored, t/off, t/on and resized scenes before q. It records original PNGs, identify output, stage raw byte ranges and SHA256, source/binary/harness hashes, host version, actual grids and inner/outer termios. The original before/after-resize PNGs remain separate unmodified captures. Host exits and required recorder fields are bounded; timeout remains failure.

The ordinary example has no fixture callback ack or product capability diagnostic. Its positive observation helper requires new CUP output ending in SGR0; 100ms stability is only drawing time, not a silent-event or post-render proof. Metadata explicitly says diagnostics are unavailable in that unmodified scene; they are not borrowed from fixture output. Its five observer tests were RED before implementation, then GREEN (evidence/observer-red.log, observer-green.log). It makes no no-op claim. Final real GUI runs and PNG review are assigned to the independent executor, so no actual example window PNG is claimed here.

Run command (new empty capture directory):

```sh
CJTUI_TERMINAL_SCENE=example \
CJTUI_SDK_ENV=/workspace/work/validation/sdk/cangjie/envsetup.sh \
CJTUI_TERMINAL_HOST_ROOT=/workspace/work/cross-terminal-recon \
CJTUI_TERMINAL_CAPTURE_DIR=/absolute/new/example-evidence \
tests/terminals/run.sh
```

The default scene still runs the fixture with q/exception/Ctrl-C scenarios. Two xterm configurations remain one implementation; XFCE/VTE supplies the second implementation. Linux console, tmux and screen remain unverified as before.

## Final validation and outstanding work

- Node black-box tool checks: `node --test tests/terminals/*.test.mjs`, 18/18 pass at the final committed content (evidence/terminal-tools-final-green.log).
- `sh -n` for run.sh/inner-recorder.sh/outer-recorder.sh, `node --check` for verifier and observers, and `git diff --check` all pass.
- Revised fixture normal cjpm build and public scene/reference self-check pass; indentation-only normalization after that compile did not change any token or behavior.
- No repeated full product suite was run after the coordinator assigned complete independent execution elsewhere. The earlier Basic16 failure and intentional new non-ASCII product RED remain explicitly reported above; no hidden all-green claim.
- Outstanding: scoped re-review of fixed F6/F7/capture commit; final independent build/suite and real xterm/VTE fixture/example captures on the integrated fixed product and tests. This author does not sign those future results.

Brainstorming, writing-plans and executing-plans skills were applied to the added capture path. The coordinator's concrete minimal design approval and execution instructions govern scope; its independent reviewer performs fresh review. The small plan is evidence/example-capture-plan.md; no subagent was spawned.

Detailed commands and historical check scope are retained in evidence/commands.md.
Evidence inventory: evidence/SHA256SUMS (all retained evidence files, excluding the inventory itself).
The actual targeted PTY session.raw SHA256 is d0274d5091f4b030d91f7a8471c4cb2ed282404c17f3331ad2719cf03a898651.
The normally built revised fixture binary SHA256 is 24cb37a7bbbb8813a2168fdcfb9b2a18192a775b197eee2c429c117a846006d6, against product 0568a09bdb55d9cf02de362da5ff1c2631ddaabf plus independently authored test source. The coordinator integrated final test commit 3385157 as ead6a8d and assigned scoped re-review and actual GUI execution separately.

# Exit oracle fixround2

Fixed test-only commit: **4c879e28187644cdf3d5c891858629555a7a4cf9**, parent 3385157. Four files changed, all tests/test documentation. The coordinator independently confirmed that terminal-emulator wait status is not authoritative for the application result and authorized this specific repair.

run.sh now waits for the same required recorder fields and bounded host exit, saves the actual terminal host wait status in host-wait-status.txt, and validates the inner and outer recorder statuses through verify-exit.mjs. Each recorder must have exactly one legal numeric 0..255 exit_status; their values must agree. q, interrupt and ordinary-example outcomes require application status zero; callback exception requires nonzero. Host wait status is separately validated and retained in exit-verification.json, with no requirement to mirror the child. Existing timeout/termios/fence/scene assertions remain, including the ordinary scene's explicit zero-status checks. The new verifier is included in the harness source hash.

The requested counterexamples were independently executed against the exact old shell predicate, then the new helper:

| Inner/outer application status | Host wait | Exception expectation under old predicate | Fixed oracle |
| --- | --- | --- | --- |
| 7 / 7 | 0 | rejected (exit 1) | accepted (exit 0) |
| 0 / 0 | 7 | wrongly accepted (exit 0) | rejected (exit 1) |

Historical run.sh, its narrow execution adapter, materialized raw oracle inputs, exact commands, stdout/stderr/status results and explanation are in evidence/fixround2/ . These controlled exit-status fixtures are oracle tests, not claimed real application/host runs. The test-first run against the old decision was RED with 6/7 groups failing, including both independent requested counterexamples. After repair, the exit oracle passes 7/7 and all terminal-tool checks pass 25/25. Shell/Node syntax and diff checks pass. Logs: exit-oracle-red.log, exit-oracle-green.log and terminal-tools-green.log in that directory. No whole matrix, GUI or product build was rerun for this narrow change, per coordinator instruction.

Remaining work for this fix: Astra scoped review and final independent real-host execution on the integrated fixed sources. This report does not claim those future runs passed.

# Initial Auto RED provenance supplement

**原件未留存，以下为现在固定历史代码重现，不是恢复旧日志。**

The coordinator requested a search for the original Auto API/default-snapshot/ordinary-example RED logs. The original auto-tests/raw directory contains only its Basic16 arithmetic evidence; relevant original-directory and /tmp searches did not find complete stdout/stderr/actual-exit logs for these three Auto REDs. Two contemporary old-example raw sessions were preserved unchanged, with their original paths, mtimes and hashes, but their result.json records do not include the assertion/exit outcome. They therefore remain partial candidate evidence, not recovered complete RED. A third candidate is an SDK runtime-loader failure and is explicitly excluded. Existing earlier explicit-color RED logs are also excluded as substitutes.

The full original search, preserved candidates and a detailed provenance statement are in **evidence/red-reproduction/original-search/** and **evidence/red-reproduction/README.md**. The new reproduction uses an independent clone at /workspace/work/auto-red-reproduction:

- Old product 187e126fc20b13a4f5526a28a9189cc0acb4037f, unchanged in src/native/examples/build/manifest before and after execution.
- Frozen public Auto test 9466f89 and complete Auto/default-snapshot/example test snapshot 762a25e, plus only the independently justified SGR36 correction from 789bea3 to the non-executed Basic16 preview expectation.
- Fixed effective test-overlay commit **0d2f6c77621cafdd0be267f3837f80652c9fc66b**, directly on old product 187e126. No product or failing Auto assertion was altered; no extra SDK/tool shim was required.
- SDK/CJPM 1.2.0, the existing private cache and registry relay, with ignored ordinary-consumer cangjie-repo.toml files. No missing dependency or runtime-library failure is counted as functional RED.

Fresh actual results on 2026-11-10, 11:43–11:46 UTC:

| Scope | Prerequisite/build | Actual RED |
| --- | --- | --- |
| Auto public API | Normal bash tests/capabilities/run.sh reaches cjpm/compiler | exit 1, seven real missing-API diagnostics including TerminalCapabilities, Application.terminalCapabilities / colorModeAuto and ColorMode.Basic8 |
| Default pure snapshot | Normal tests/colors cjpm build exits 0 | Direct binary exit 1: FAIL: default snapshot is the pure TrueColor projection, encodingAndCells:116 |
| Old normal example | Normal examples/colors cjpm build exits 0 | Frozen Node example harness exit 1: normal example starts with its first rich RGB sample under automatic direct-color profile, pty.mjs:180; actual raw PTY bytes retained |

Each phase has separate raw stdout.log, stderr.log and result.json containing exact command/argv/cwd/UTC times/actual subprocess exit code. Normal direct executable invocation avoids cjpm run masking an assertion's status. The example result is the frozen harness's assertion failure after observing a normally built old executable; it is not a claim that the application itself returned an error before harness cleanup.

The evidence directory also retains fixed Git IDs, complete product/test source archives, effective patch, exact per-file source hashes, dependency locks, SDK/environment inputs, successful build logs, built-binary hashes and empty product/test post-run diffs. SHA256SUMS covers all evidence. effective-test-sha256.json SHA256 is 86ee95e29a91b4656d123b8708821d88b0e9c4e8605eb6f6919d619478904230. The new actual ordinary-example raw SHA256 is d7bd2578d1cddf6f82eb33a219d62a5530a12ca5afff5f6c97c2c0d0dd5be80e.

Final targeted checks confirmed all five expected actual statuses (API build 1, snapshot build 0 / binary 1, example build 0 / harness 1), the three exact failure causes, unchanged effective source hashes, empty product/test diffs and nonempty actual PTY raw. No unrelated suite, whole matrix or GUI run was performed. No main-checkout product file changed, and current cold/GUI acceptance work remains independent.

This supplement establishes that fixed frozen tests reject fixed pre-Auto code now. It does not retroactively recover the missing original logs or claim their original test-first execution timestamp has been proved.

# Final Bash entry and DISPLAY version collection repair

Two small independent test-only commits, without product/scene/oracle changes:

- **4c952025f34dd0fa90191ff32e9c3181baa9a9bc** changes only run.sh's shebang to #!/usr/bin/env bash plus README. The executor's preserved original direct entry failed with Unsupported shell: unknown / actual_exit=1. A fresh actual direct-script check with SDK 1.2.0 and a deliberately absent fixture BIN passed envsetup and exited 1 specifically at fixture binary missing; no application or matrix started.
- **6f5f4be5722dafbf215769870501fad431efdf94** changes only the host-version metadata line plus README. It uses the active DISPLAY and a supported option per known host: xterm -version and XFCE --version. Merely adding DISPLAY to the previous XFCE -version first choice was independently observed to time out after 10 seconds, so that unsupported version invocation is not retained. A real XFCE --version on temporary actual Xorg :219 exited 0 and printed xfce4-terminal 1.1.4 (Xfce 4.20). Raw outputs/actual statuses and the failed initial probe are preserved.

The starting script was byte-identical to the actual executed **bf308bf** script. evidence/fixround3/body-equivalence.json proves that the final script differs at exactly lines 1 and 105, and restoring them exactly reproduces its original SHA256 48c04d04548a51d17f2607cf51478be10148fd5cbcec36a89244868035415953. Every application launch, input, rendering, byte/PNG capture, timeout, termios and output/exit assertion line is unchanged. The actual XFCE binary hash matches the executor's supplemental package/binary version evidence.

The executor's direct-entry RED, explicit-Bash successful 9-fixture/3-example records and metadata-version failure were copied unchanged with provenance hashes into evidence/fixround3/executor-originals/. Original acceptance raw/PNG/metadata files were never edited. No complete GUI matrix, product build or rendering test was rerun for these repairs. Existing bf308bf explicit-Bash results remain attributed to bf308bf; they are not relabeled as new-commit executions. The coordinator's reuse decision and third-round scoped review can use the exact two-line equivalence proof. bash -n and diff checks pass.

Detailed commands, controlled early-check environment, original stdout/stderr/actual exits, temporary-Xorg version outputs, source diffs and preservation hashes are in **evidence/fixround3/** and its README.md / SHA256SUMS. Remaining work is scoped review of these two lines and the coordinator's final evidence-reuse ruling; this author does not assert a new GUI acceptance run.

# Finite package-smoke test-contract review

The coordinator separately requested a read-only independent test-contract check of the executor's four consumer/glue sources against frozen AC063. The review is test-contract-smoke-review.md; exact source/manifest hashes, unchanged source copies, frozen contract projection and relevant existing raw/metadata are in evidence/package-smoke-contract/.

The ordinary consumer uses public APIs and an ordinary dependency on the unpacked package, with no private linker/API rescue. Its plain/ANSI, actual q exit and exact full termios assertions are appropriate for the limited smoke. The resize wait predicate only requires raw growth and is not a general transport fence; this limitation is explicit in the review. The existing recorded raw independently contains 6x40 initial output followed by full 9x54 repaint (ASCII row9 alone has54 spaces), so no current missing resize evidence requires a rerun or source change. Raw SHA256 is 524b47e8cee7540313ee3e41f0dde4c110cfe314495978a347a42decd407aca8.

No consumer build/run/check or GUI was repeated. This is a limited clean-consumer contract review, not full AC063 or release acceptance; the known full release-checker missing composition/benchmark results remain separate and must not be overwritten by this smoke conclusion.
