# TASK021.b candidate evidence

Product base d80c62be5f902d0dbce64002b5060a1b49677aa5; product commit e3016afe7e61133ef549302cf01383848507d5c3.
Independent test correction 2e5e998d00f2f60e45376bca4ada8376273d339a was cherry-picked as fd7a6b73096f66499343b937cfefff8d24e6dfd8.
Command, environment, artifact and raw-output index: [evidence/index.json](evidence/index.json).
Both examples: normal `cjpm build` exit 0; executed binaries are hard-linked under `evidence/binaries`.
Direct `node tests/composition/application/smoke.mjs` exit 0: both literal smoke frames and both invalid argument forms pass.
`cjpm bundle` exit 0 at e3016afe; 789 warnings, zero mandatory/error diagnostics; `evidence/candidate.cjp` contains examples and guide.
Pre-separation PTY run exit 1 in frozen WireScreen parser before interaction; raw evidence and source-level fixture discrepancy were sent to root for independent test-author review.
PTY interactions, worker behavior, integrated suite, independent review and acceptance remain pending.
