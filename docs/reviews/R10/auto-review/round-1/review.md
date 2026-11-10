# TASK-062 independent complete technical review — round 1

## Verdict and fixed scope

**Spec compliance: FAIL / changes required. Code quality: CHANGES REQUIRED.** Do not admit this target to final execution as clean-reviewed code. No Critical finding; seven Important findings identified (two product, five test/evidence), of which F3/F4 are now closed by source re-review of the fixed tests-only delta below; five Important remain open, plus two Minor maintainability findings.

Reviewed product/test target: `96a8c4b8fde11c44487718c8ebcecca01d058830`, complete technical range from `96bdb9b7c5b1f58c5ec223a0475be3d86cfae660`. Independent detached checkout: `/workspace/work/auto-final-review/repo`. Read the supplied complete 138,744-byte technical diff, SHA256 `b0dcdd7bc3dc617b794e33bd3659eeeaba6ee11921bbe160fcf08d399580cac7`, all changed product code and test harnesses, surrounding shared calls, AGENTS and the controlling design D031–D033/tasks constraints. Product-author analysis and prior reviewer conclusions were not read.

Additionally reviewed fixed tests-only `96a8c4b..78ae76c` delta: `tic --version` becomes supported `tic -V`, with corresponding README text. This delta is correct and preserves assertions; it does not repair the findings below. Original checkout remains at `96a8c4b`.

Second fixed tests-only technical delta reviewed: `78ae76c..226886a80ae848b3806a4e855c2ca33b7249328d`, `tests/capabilities/pty.mjs` only (accompanying reports/progress were not used). Script-URL-based root/default paths fix F3 independent of cwd; the three-argument `runCase(..., 'a')` plus a separate profile assertion fixes F4. Added `TERM=cap-é,COLORTERM=truecolor` requires `term-invalid`, unknown/Monochrome and no supported effects, consistent with strict ASCII validation. These are source-review closures; final execution remains TASK063. The new normal-example capture/fixture delta is still pending.

Model: controller confirms actual spawn configuration `model=gpt-6-astra`, `reasoning_effort=high`. Reviewer-visible generic identity is Codex/GPT-6; no separately observable runtime model-id was supplied. No delegation occurred.

## Important findings

### F1 — Unknown NCV bits preserve all six attributes instead of removing them

- Severity: **Important / P1**, product; `src/color_mapping.cj:103–113`.
- D031 requires a colored style with any unmodelled positive NCV bit to discard all six attributes. `unknownColorVideo` is detected, but the implementation sets `video=0`; every return-field predicate consequently permits its supported attribute.
- Concrete reproducer: a profile `Basic8`, all supports true, `noColorVideo=19`, and `Style(foreground: Red, bold/dim/italic/underline/inverse/strikethrough: true)`. Compiling the unchanged projection/component implementation bodies in the isolated probe produced `bold=true dim=true italic=true underline=true inverse=true strike=true`; the required result is six false. The existing frozen `cap-ncv-unknown` case expresses the same required output.
- Fix in the shared projection policy; gate all six attributes for `hasColor && unknownColorVideo`. Preserve attributes for Default/Default and Monochrome-projected styles, and preserve normal bit-specific NCV18 behavior.
- Evidence: `/workspace/work/auto-final-review/probe/main.cj`, `result.txt`. This was a scoped implementation-body probe, not a full public-consumer or package run.

### F2 — New detection work sits outside the terminal restoration fence

- Severity: **Important / P1**, product contract; `src/application.cj:38–47`.
- After successful `cjt_open`, `detectTerminalCapabilities`, diagnostic assignment and mode selection execute before `try`. D031 explicitly places detection inside the existing D027 `try/finally`. Any exception escaping this new phase bypasses `cjt_close` entirely, even though the session is already open.
- Concrete control-flow counterexample: `cjt_open` succeeds, detection/diagnostic construction throws, control exits `run` before entering its `try`; line 107's cleanup is unreachable. This is a source-proven restoration gap. No real detection exception or termios leak was injected/observed in this review, and the existing native ordinary-failure paths normally return conservative values.
- Move all post-open work that can belong to the session into the existing restoration fence. Do not weaken cleanup/error propagation, and do not invent a new terminal lifecycle path.

### F3 — Supported capability runner resolves its binary/database under the wrong directory

**Status: CLOSED by source review of `226886a`; description below records the original fixed-target defect.**

- Severity: **Important / P1**, tests; `tests/capabilities/run.sh:3,11`, `tests/capabilities/pty.mjs:9–11`.
- The supported `./tests/run-slice.sh capabilities` path invokes `run.sh`, which changes directory to `tests/capabilities` and runs `node pty.mjs`. The JS defaults are repository-root-relative and are passed through `resolve` against that new working directory.
- Concrete resolved binary: `<repo>/tests/capabilities/tests/capabilities/session/target/release/bin/main`; actual build output is `<repo>/tests/capabilities/session/target/release/bin/main`. The generated terminfo path is doubled likewise. Therefore the normal entry cannot reach its capability assertions without undocumented environment overrides.
- Anchor defaults to the script URL/repository location, or run the harness from its documented root with consistent paths. Retain ordinary builds and all assertions.

### F4 — Override/Auto test passes an object where input bytes are expected

**Status: CLOSED by source review of `226886a`; description below records the original fixed-target defect.**

- Severity: **Important / P1**, tests; `tests/capabilities/pty.mjs:117`, signature at line 32 and use at line 52.
- `runCase(name, environment, action='')` is invoked with four arguments: the third is `{colorMode:'TrueColor'}` and the intended `'a'` is an ignored fourth argument. `child.stdin.write(action)` receives the object and throws a Node argument TypeError.
- Concrete counterexample: after the preceding capability cases succeed, `override-auto` cannot send the `a` event; namespace-isolation and loader-failure cases after it also never execute because the suite has one outer catch.
- Pass `'a'` as the third argument and assert the expected diagnostic separately. Preserve the before/after device-byte assertions.

### F5 — Real-terminal fixture omits its rich-color and fence nodes from the tree

- Severity: **Important / P1**, tests; `tests/terminals/fixture/src/main.cj:11–18`.
- `rich` and `marker` are created outside the Column block. Evaluating `rich[0]` or `marker[0]` inside the block does not invoke `attach`; only actual constructors attach. Thus changing their colors/styles never changes the visible root.
- Concrete execution of the unchanged `Component` construction functions with the same fixture shape produces `root.children.size=2`, with children `Unicode` and `Resize edge` only. `AUTO RGB…` and `EVENT-FENCE` are absent. The full real-host SGR check must fail, and screenshots cannot demonstrate automatic rich-color output from these missing nodes.
- Assign each state holder from a `Text(...)` construction inside the Column block, as the existing colors fixture does. No product special case is appropriate.
- Evidence: scoped probe `main.cj`/`result.txt` cited above.

### F6 — Real-terminal oracle accepts forbidden Basic8 output and unverified capability provenance

- Severity: **Important / P2**, tests/evidence; `tests/terminals/verify-sgr.mjs:20–48`, caller `tests/terminals/run.sh:76`.
- Basic8 and Basic16 share one branch that permits every bright foreground/background SGR. The verifier trusts the reported mode instead of checking the expected real-host profile/source. It does not require diagnostic support fields to exist (`undefined != 'false'` passes). Its NCV mapping also treats masks as exact numbers and maps `4` to dim rather than inverse; combined masks are not checked.
- Concrete probe ran the unmodified verifier with `colorMode=Basic8;source=unknown;terminfoKnown=false;colorKnown=false;ncv=-1` and a raw file containing SGR91 plus the required labels. It exited **0** and printed `PASS SGR profile=Basic8 sequences=2 named=1 indexed=0 rgb=0`. This output violates Basic8 and supplies no credible real-host profile. Files: `probe/invalid-basic8-cap.txt`, `invalid-basic8.raw`, `invalid-basic8-result.txt`.
- Make assertions specific to the observed host/configuration and declared profile. Reject bright SGR for Basic8; validate required source/known fields and actual expected nominal mapping, and use NCV bit tests in the applicable colored style context. An oracle should reject the counterexample above before its results are used as acceptance evidence.

### F7 — Matrix's file acknowledgements do not fence recorded device bytes

- Severity: **Important / P2**, tests/evidence; `tests/terminals/run.sh:70–76`, fixture `src/main.cj:43–44`.
- The fixture writes each ack inside the callback, before that event's following render. The capture script immediately takes screenshots/byte counts after reading acks. The second `p` at event 8 deliberately leaves the already-false fence style unchanged, so it supplies no output marker that must traverse the recorder.
- Concrete possible schedule: erroneous/no-op output is successfully written to the PTY after event 7; the application reads event 8 and writes its ack while `script` has not yet copied those PTY bytes into `inner-tty.raw`. Both `wc -c` values remain equal, so the no-op check passes despite emitted output. Conversely delayed legitimate event-6 output can make it fail. The event-6 screenshot also need not represent the completed resized render. This is a demonstrated ordering gap by control flow, not an observed timing failure in this review.
- Establish a post-render transport marker/complete-row barrier in the raw recording for observations, using the independent colors fixture's existing two-event plus visible-fence principle. Keep each check's byte interval explicit; do not make sleeps the proof of silence or completion.

## Minor findings and cleanup

- **M1 — scattered ABI/NCV numeric constants**, `native/cjtui_capabilities.c:56,152–191`, `src/terminal_capabilities.cj:39–85`, `src/color_mapping.cj:103–112`. Bit indices, shifts, masks, numeric mode/reason matches and NCV mask54 repeat without names across the boundary. The values currently agree with the packed contract, but D031 explicitly requires named constants on C and Cangjie sides. Consolidate names with the existing design as shared documentation; no new runtime state or abstraction framework is needed.
- **M2 — superseded unused projection/diff wrappers**, `src/color_mapping.cj:93`, `src/frame.cj:214`. Whole-src/native/test reference search finds no caller of `projectStyle` or the new mode-only `changesSince`; all active paths use profile projection. Remove directly superseded private remnants per AGENTS10.5. The row-emission loop is also duplicated between `encodedRowForTerminal` and `toAnsiForTerminal`; consolidating must preserve their different existing reset boundaries. This duplication is localized, not evidence that a second Frame/ANSI kernel was introduced.

## Positive architecture assessment (source review, bounded claim)

- The native isolation strategy is appropriate: only `dlmopen(LM_ID_NEWLM, libtinfo.so.6, RTLD_NOW|RTLD_LOCAL)`, one private handle with a mutex; symbol lookup/query/restore/free are under the lock, base `setupterm` is not called. Library and symbol failures become conservative packed results. No runtime shell, tput, GUI or custom terminfo-parser path was introduced. Strict ASCII TERM validation precedes COLORTERM handling. Exact known-SGR whitelist prevents arbitrary capability string passthrough. C compiled with `-std=c11 -Wall -Wextra -Werror -fPIC -O2` successfully. This does not replace the independent namespace runtime case or clean-consumer linking gate.
- The packed layout, colors thresholds, diagnostic sources/reasons and nonnegative NCV field match the frozen ABI by inspection. The private single cached handle avoids repeatedly consuming linker namespaces. Unsupported-libc conditional code is conservative; no broader platform success is claimed.
- Nominal palette, integer distances, lowest-index tie behavior, Basic8 candidates0..7, indexed alias normalization and absence of synthetic bold match the contract. Six raw Style fields and explicit false inheritance reach text/fill/border; shadow keeps its own full Style. Source Color/Cell values are retained.
- Public offline snapshots select TrueColor and all six attributes through the same profile/style/ansies path. Application overrides affect only the color mode. Changed-row comparison separately projects old/new profiles, caches adjacent raw-style runs and compares glyph/width/continuation. Frame/profile/dimensions are committed only after `writeScreen` completes; invisible changes need not commit a new raw baseline to remain output-correct.
- One existing Frame and one `encodeStyle`/ansies boundary remain authoritative. New public/implementation product types each have their own lower_snake_case file. `native/build.sh` and manifest normally include the new archive without adding consumer-specific flags. Standard bundle and consumer execution still require actual TASK063 evidence.

## Commands, evidence and limits

Actual actions/commands included:

1. `git -C /workspace/work/terminal.ui worktree add --detach /workspace/work/auto-final-review/repo 96a8c4b8fde11c44487718c8ebcecca01d058830`; verified HEAD and clean `git status --short`.
2. Read full supplied diff in sequential chunks (and re-read truncated pieces from their exact source files), controlling contracts and changed call sites. `sha256sum` recorded the full-diff hash above.
3. `source /workspace/work/validation/sdk/cangjie/envsetup.sh; cjc --version; cjpm --version`: both SDK1.2.0, x86_64 Linux.
4. `git diff --check 96bdb9b7c5b1f58c5ec223a0475be3d86cfae660 HEAD -- src native examples tests cjpm.toml docs/product/README.md`: exit0.
5. `git diff 96a8c4b..78ae76c -- tests/README.md tests/capabilities/pty.mjs`: examined only the announced tests-tool delta.
6. Scoped probe copies original projection/profile/component/style bodies into `probe/`, changing only style package declarations to put them in one compilation unit. Initial probe compile failed because the reviewer omitted the existing `Alignment` source; after adding that unchanged source, `cjc /workspace/work/auto-final-review/probe/*.cj -o /workspace/work/auto-final-review/probe/counterexamples` and direct execution exited0. Its printed counterexamples are retained in `probe/result.txt`. This reviewer setup error was not a product failure.
7. `gcc -std=c11 -Wall -Wextra -Werror -fPIC -O2 -c native/cjtui_capabilities.c -o /workspace/work/auto-final-review/probe/native-capabilities.o`: exit0.
8. A Node driver wrote the deliberately invalid Basic8 diagnostics/raw files and invoked the unchanged `tests/terminals/verify-sgr.mjs`; unexpected acceptance exit0 is retained in `probe/invalid-basic8-result.txt`.

Applied skills: `using-superpowers` was read and its dispatched-subagent exception followed; `cloud-environment-runtime` for environment readiness (current environment running, policy enforced); `verification-before-completion` to distinguish source judgments and measured counterexamples from unrun acceptance gates. No author/self-assessment conclusions were used.

No repeated whole same-source suite was run. No product or frozen test file was edited. No full package build, bundle, clean consumer, real xterm/VTE rendering, screenshot authenticity/metadata or termios behavior is certified here; these await corrected fixed code/harness and TASK063. Native symbol/database failure variants beyond source review and the frozen tests are not newly executed. Actual physical Linux console, tmux/screen, other libc and non-Linux platforms remain outside verified scope. The pending ordinary-colors capture delta was not supplied at report time, and is not covered by this verdict. Non-ASCII TERM delta source review is included above; its separately reported RED was not re-run here.

Both verdicts require a fixed repair delta and independent re-review. Product repair should address F1/F2; the tests author should repair remaining F5–F7 without weakening the functional assertions (F3/F4 already closed). Minor findings need an explicit disposition in the integration ledger. Final acceptance remains separate from a clean source-review result.
