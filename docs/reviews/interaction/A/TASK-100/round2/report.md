# TASK100 scoped fix round2

Fixed `6f0fcc4006d3b6138e823eaa6d127a548db58a21` → `f8a028b39daf8a341576f304335d262544b9cca5`. **Spec PASS_SOURCE_REVIEW; quality PASS_SOURCE_REVIEW. T100-I05 ADDRESSED.** Combined with the original full review and round1 closure of the other six findings, TASK100 source review passes at f8. No remaining Critical/Important findings.

This review covered only the16-line application timing delta and the fixed7225603 test overlay. Prior sealed reports are untouched; six already-addressed items were not reopened. No author reports/self-assessment, author contact, subagents, source/test/contract/main edits, or repeated cold suite.

The post-read failure branch no longer calls decoder.timeout merely because the clock returns-1. It preserves the incoming byte for the same decoder. The no-input return branch credits only the completed readTimeout interval against100ms and defers the remaining idle; a short probe wake is not treated as100ms. Existing-5 EINTR/EAGAIN handling bypasses completed-idle credit, and the valid-clock branch retains its monotonic elapsed check. No second decoder/writer, input queue or mode25 behavior was added.

Fixed pure raw confirms the same-binary transition pair: control suffix gap789279ns and failure gap970586ns; both events `up:|text:q|`, child exit0, termios restored. Poll records show readable input (`result=1`) before100ms, and the failure clock trace actually transitions1000→-1. The original always-minus-one/real100ms case and eight relevant idle/deadline/clock/order cases also have actual command exit0 and preserved stdout. The old13 cases and94 vectors remain; original vector bytes were independently compared. The short-poll failure branch is source-verified here, without inventing a dedicated execution result.

All195 pre-identity tracked hashes independently match f8 Git bytes; four config identities remain recorded by the supplied raw. The true pre label `a6f56faba003c32bdb08a6569933a0dbcd0f151a` and UTC `2026-11-11T08:35:23.486208+00:00` are retained; no pre-f8 commit claim is fabricated. All43 test files match frozen7225603; the formal design is unchanged. Exact hashes/commands/raw locations are in reviewed-hashes.json. Existing same-content evidence answers this narrow fix, so no new probe was run.

At sealing, observed package exits: `{"bundle": 0, "clean-build": "PENDING", "clean-run": "PENDING"}`. These observations do not close TASK101 fresh execution or TASK102 physical-host/acceptance. Those gates remain separately open; source review PASS is limited to the reviewed scope and fixed SHA.

Minimal archive: report.md, findings.json, reviewed-hashes.json and artifacts.sha256. External raw stays at its original hashed path; no full source/contract/Markdown copy, SDK/cache, CJP or compiled artifact is included.
