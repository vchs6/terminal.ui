# TASK020.d independent SPEC + QUALITY review
Fixed BASE `13e7880ce96d1331fc9e12a2b62275a307183e9a`; test HEAD `97f43b733545e4a39f7670571ea3464b49ce1019`.
SPEC verdict: CHANGES_REQUIRED for test coverage/host evidence readiness; full current C004/M1 acceptance is not established.
QUALITY verdict: CHANGES_REQUIRED (2 Important, 2 Minor); no product defect or product edit is justified by these findings.
020R1 Important — `endpoint_hup.py:24` forces declared title even in Auto runs; raw Auto endpoint policy confirms it. Auto/no-title HUP and its distinct exact cleanup result are missing.
020R2 Important — `host_run.sh:18–29` compares outer termios while Application uses script’s child PTY; `lifecycle_native.c:42–48,85–93` never records that child’s original/restored termios. Host restoration proof is incomplete.
020R3 Minor — `oracle.py:38–41` accepts unexpected/duplicate cleanup extras through substring membership; compare the entire literal list.
020R4 Minor — `oracle.py:20–24` checks known mode25 restoration only on run1; second known-hidden restoration is unasserted by the PTY oracle.
The 23-file/1764-line delta is tests only; source worktree is clean and src/native/cjpm/build delta is empty.
Observed raw build-08 and both final driver exit files contain 0; 64 check files per directory report pass. These are author execution facts, not independent acceptance.
Coverage is 63 safe processes/126 same-App runs per command plus one declared-title endpoint each; the Auto endpoint is not Auto.
Declared HUP oracle correctly maps actual native -4 plus kernel read0 to title-primary; -3 to input-primary; size -1 to size-primary, then exact title/paste/native order as applicable.
Read/poll observers preserve the syscall errno and result used by cjt_read; no exception-text allowlist or endpoint repair was found. Final raw HUP is read0; alternate historical outcomes do not make size-error an executed branch.
Destroyed-PTY tcgetattr EIO is correctly unavailable restoration, with explicit native failure and no same-endpoint restart.
Safe tests exercise raw mode, full three-handler state, native ownership/free, UI cleanup, posts/workers, stale references and restart; NoImageAdapter and SentUnconfirmed remain correctly bounded.
2004 means owned enable/disable, not preservation of pre-enabled state; Unknown mode25 remains untouched. SIGKILL/all-OS-signal cleanup is not promised.
Accepted008/010 and finite upstream scopes remain reusable; no new writer/parser/runtime, public hook, gratuitous product author or 338-cut rerun is warranted.
Actual XTerm/VTE/VM-VT executions, host identity/version/config, mode probes/title observations and original PNGs remain pending; synthetic host fixtures cannot supply them.
Resolve Important test/observer gaps, then independently execute affected coverage and actual-host plan, and perform independent acceptance. Full020/M1/M2/release/Linux remains open.
Bindings, precise contracts, evidence gaps and remedies are in `findings.json` and `index.json`; no source/test/spec/main edits, builds, test reruns, subagents or pushes were performed.
