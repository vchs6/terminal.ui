# TASK-062 cumulative final review — bf308bf

## Verdict and cumulative scope

Fixed final target: **`bf308bfccb43d0e88305c6d0ec64b4a92adbc892`**. Cumulative reviewed technical range: **`96bdb9b7c5b1f58c5ec223a0475be3d86cfae660..bf308bfccb43d0e88305c6d0ec64b4a92adbc892`**, product plus applicable tests.

**Spec compliance: PASS for this finite color/style/automatic-output implementation and test-contract review. Code quality: PASS with the explicitly adjudicated minor row-emission duplication deferred.** F1–F8 are closed. No open Critical/Important finding remains. The fixed source/harness may proceed to independent real-GUI execution (TASK063 stage B). This is not a GUI/screenshot, package-consumer, final acceptance or complete-framework success claim.

The cumulative conclusion reuses the unchanged content already reviewed: full technical review at `96a8c4b`, product repair at `f8b194e`, and F5/F6/F7/ordinary-example capture delta through `ead6a8d`. This pass inspected only the four-file `ead6a8d..bf308bf` exit-oracle repair and its directly related evidence. `git diff --stat ead6a8d bf308bf -- src native cjpm.toml examples` is empty. No unrelated whole-slice rescan or repeated same-source suite occurred.

Historical artifacts remain intact: `round-1.md` and `review.md` preserve the initial FAIL; `round-1-recheck.md` records the product repair; `round-1-final-review.md` and `final-findings.json` preserve the first limited PASS at ead6a8d and its explicit host/application-exit boundary. The controller subsequently promoted that boundary to **F8 Important/P2**, requiring a fix before GUI execution, rather than leaving it hidden behind the earlier PASS. This report records that decision and its resolution. Original and repaired projection/raw probes remain available.

Model dispatch: `gpt-6-astra/high` (controller-confirmed; no additional runtime model identifier exposed). No subagents; no author self-assessment used; no product/frozen test files edited by the reviewer.

## F8 — Important/P2, test application-exit oracle: CLOSED

Original affected location: `tests/terminals/run.sh` at ead6a8d lines155–156. The old condition treated `wait(hostpid)` as the application result while only waiting for recorder status fields to exist. Its exact historical branch produces two concrete incorrect decisions for an expected application exception:

| Recorded inner/outer application status | Terminal host status | Old branch | Required/fixed oracle |
|---|---:|---|---|
| 7 / 7 | 0 | Rejects (exit1), false failure | Accepts (exit0) |
| 0 / 0 | 7 | Accepts (exit0), false success | Rejects (exit1) |

The repaired `verify-exit.mjs` requires exactly one `exit_status` line in each recorder, an integer in0..255, and agreement between inner and outer. It determines expected success/nonzero solely from that application status. Host status is separately validated as legal evidence and retained in `host-wait-status.txt` and `exit-verification.json`; it cannot establish or negate the application exception. The run script invokes this same oracle for fixture q/exception/interrupt and ordinary example, and includes the oracle in the harness hash.

The diff leaves the bounded waits, recorder field waits, termios comparisons, visible raw fence checks, resize evidence and example checks in place. No product change, new application hook or private override was introduced. README accurately describes the changed authority and independent host evidence. The new seven black-box tests cover both differing-status counterexamples, normal success/failure, disagreement, missing/duplicate/malformed/out-of-range recorder values and invalid host/expected values.

## Evidence inspected and commands actually run

- Read the four-file fixed `round-2-exit-fix.diff` in full, SHA256 `1ae64346ab6e731ff7be38df0c6938a21984821b5fb5acabceb2c45e2cce902a`.
- Read `/workspace/work/auto-harness-repair/evidence/fixround2/counterexample-results.json` (SHA256 `02d44b7cdf8dc4a3176ebfd61359eb4dc92f71a5412d7d6ccc4dfe4050271d82`), both cases' original inner/outer/host inputs, old/fixed statuses and fixed stdout/stderr. These show the table's actual old/fixed branch results. The negative fixed case reports `application exception must exit nonzero`, establishing rejection for the intended reason.
- Read `legacy-exit-oracle.mjs`: it executes the exact extracted historical shell condition, rather than reimplementing a different assumed behavior. `cmp` against `git show ead6a8d:tests/terminals/run.sh` confirms its `historical-run.sh` is byte-identical to the reviewed old runner. These are real executions of the historical/new oracle on fixed status inputs; they do not claim a live GUI host was launched for this probe.
- Compared all four final changed files to `/workspace/work/auto-harness-repair/` with `cmp`: all match. This ties the inspected raw oracle evidence to the fixed source bodies.
- `git diff --check ead6a8d bf308bf -- tests` and `sh -n tests/terminals/run.sh`: exit0. Final checkout HEAD is bf308bf and `git status --porcelain` is empty.
- The controller reports the exit-oracle suite7/7 and combined tool suite25/25 already executed. This review inspected the new test cases and retained counterexample raw evidence; it did not repeat either same-source suite or present those totals as newly executed reviewer tests.

## Cumulative finding ledger

| ID | Severity | Disposition at bf308bf |
|---|---|---|
| F1 unknown NCV preserves attrs | Important/P1 | Closed at f8b194e; repaired colored/uncolored/Monochrome/NCV18 reviewer probes passed |
| F2 detection outside cleanup fence | Important/P1 | Closed at f8b194e; original try/finally restored around detection |
| F3 capability cwd paths | Important/P1 | Closed at226886a; URL-based paths and retained completed capability run |
| F4 override action argument | Important/P1 | Closed at226886a; correct three-argument call and separate profile check |
| F5 missing fixture nodes | Important/P1 | Closed; constructors now attach within Column and references remain connected |
| F6 real-host SGR/provenance oracle | Important/P2 | Closed at ead6a8d; required diagnostics, exact host/palette expectations, Basic8 and NCV checks |
| F7 recorder completion barrier | Important/P2 | Closed at ead6a8d; alternating full raw fence and exact no-op interval, inspected real-PTY raw |
| F8 application vs host exit oracle | Important/P2 | Closed at bf308bf; exact old/new counterexample outcomes inspected |
| M1 named ABI/NCV constants | Minor | Closed at f8b194e |
| M2 unused private wrappers | Minor | Closed at f8b194e |
| M2 localized row-emission duplication | Minor | Controller-ledger deferral accepted; existing active reset boundaries unchanged |

## Remaining execution and acceptance scope

The earlier real-PTY evidence validates the recorder/fence mechanism, not real xterm/VTE rendering. Actual GUI hosts, normal-example stages, original PNGs/metadata/hashes, terminal process outcomes and terminal-state restoration remain independently executable obligations. No PNG was generated/redrawn or accepted from a synthetic TERM branch. Two xterm configurations continue to represent one implementation; XFCE/VTE is the other.

The controller reports stage-A cold-slice/bundle work already underway at reviewed ead6a8d. This review does not independently certify those execution results. Product/manifest/example content is unchanged by the final tests-only exit fix, so reuse should follow the recorded content/provenance rules; do not rerun unchanged product suites solely because the commit changed. The final test runner and its hash must correspond to bf308bf for stage-B evidence.

Normal complete applicable testing, standard package and clean consumer proof, final metadata/source consistency and TASK064 acceptance remain outside this review's success claim. Physical Linux console, tmux/screen, other libc/platforms and the complete framework remain unverified/out of this finite slice's accepted scope.
