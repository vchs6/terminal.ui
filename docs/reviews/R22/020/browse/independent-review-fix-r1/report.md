# TASK020.d scoped R1 SPEC + QUALITY review
Parent `97f43b733545e4a39f7670571ea3464b49ce1019`; fixed head `8929bd09ca0e77093ac8d070e513b388e02487a7`.
Scope: 020R1–020R4 and new breakage in the 11-test-file fix diff only; initial review artifacts remain immutable.
SPEC verdict: PASS_SCOPED_FIX_REVIEW. QUALITY verdict: PASS_SCOPED_FIX_REVIEW.
020R1 ADDRESSED: requested/actual Auto versus declared endpoint policy is preserved, checked and recorded; exact policy-specific HUP error lists derive from native returns.
Raw Auto read0 has `terminal write failed` primary + native restore extra; declared read0 has title primary + paste/native extras. EIO restoration remains unavailable, with no restart/repair.
020R2 ADDRESSED: native snapshots capture the same fd0 endpoint and every defined Linux termios field before open and after each close; PTY and host oracles require exact child equality.
The observer preserves caller errno. Its opt-in negative changes actual post-close child ECHO without repair; it is separate from ordinary observation.
Four positive nested-PTY transports exit0 with equal child fields; negative has App exit0, equal outer termios, child lflag 35387→35379 and host-runner exit1 from the child mismatch.
020R3 ADDRESSED: cleanup extras use complete ordered list equality; fixtures reject unexpected, duplicate and reordered extras.
020R4 ADDRESSED: both runs check final mode25; second hidden run must restore HIDE after paste cleanup, while unchanged visible needs no redundant restore; missing/early-hide negatives exist.
Raw final logs show build-02, Auto64, declared9-safe+1-HUP, transport suite and tool checks exit0; the expected negative wrapper itself exits1. These remain author execution facts.
No new material breakage found in the fix diff; no unresolved prior findings. Production src/native/cjpm/build is unchanged and fixed source worktree is clean.
764 selected source/raw bindings, original review output hashes and original sealed-index hash were independently checked read-only.
Nested transport replies are explicitly emulated: actual XTerm/VTE/VM-VT originals, independent execution/acceptance and C004/M1 completion remain pending.
No source/test/spec/main edits, builds, test reruns, subagents or pushes; only this separate review directory was written.
