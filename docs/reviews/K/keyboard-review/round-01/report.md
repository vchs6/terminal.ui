# TASK115 round 01
Fixed candidate: `5baa09f33251e9f572640a2f6d4ae46245f7eea8`; BASE: `c96cc601c547f869e64632e955091cf44546d192`.
Spec verdict: **FAIL**. Quality verdict: **FAIL**. Six Important findings; no Critical finding.
Scope: complete finite K001–K004/F001–F003/F006–F007 source and authorized dispatcher/doc/example diff; independent test overlays retained.
- K115-01: string ESC branch loses UTF8/ST boundaries and exposes payload keys.
- K115-02: nonstring UTF8 handling breaks malformed drain and recognizes continuation C1.
- K115-03: bare ESC swallows raw C1 instead of honoring its frozen cancellation/string rules.
- K115-04: Alt ASCII/UTF8 bypasses ordinary sequence byte budgets.
- K115-05: diagnostic stop can be followed by same-byte retry dispatch and SessionInactive.
- K115-06: persistent output ArrayLists retain historical batch capacity; paste clear does not release backing storage.
Exact paths/lines, byte vectors, expected/actual source traces and scoped remedies are in [findings.json](findings.json).
The findings are source-derived, not claimed executed reproductions. SDK1.2.0 clear/capacity disassembly settles container retention.
Fresh checks: fixed HEAD and no tracked delta; all 15 final product/dispatcher hashes match the aggregate raw receipt; full diff whitespace check clean.
Reused evidence: phase-final-01 actual aggregate exit0/output; phase-lint-final exit0, zero error text (warnings retained). Their passing vectors do not cover the six counterexamples.
Accepted owners, fail-close arithmetic, normal paste target/generation, ordered callbacks, native EOF, one-byte fairness, I015 timing and unified writer were examined; no independent second parser found.
Review used verification-before-completion; no author self-assessment, author contact, source/test/spec/main edits, subagents, builds or cold suites.
Immutable round evidence and external raw index references: [round-01/index.md](round-01/index.md), [round-01/manifest.sha256](round-01/manifest.sha256).
TASK116 mandatory bundle/clean/actual-host checks and TASK117 final acceptance remain outside this source verdict.

