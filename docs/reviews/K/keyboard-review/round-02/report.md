# TASK115 scoped re-review — fix round 1/5
Fixed HEAD: `500d5ff35632ab7ed55e323458883bbd7e80d2b7`; fix BASE: `5baa09f33251e9f572640a2f6d4ae46245f7eea8`.
Spec verdict: **FAIL**. Quality verdict: **FAIL**.
K115-01 ADDRESSED — string ESC/ST/UTF8 boundary.
K115-02 ADDRESSED — nonstring scalar boundary and original malformed-drain vectors.
K115-03 ADDRESSED — bare-ESC raw C1 cancellation/string entry.
K115-04 NOT_ADDRESSED — complete Alt budget vectors pass, but invalid continuation releases new over-budget drain.
K115-05 ADDRESSED — active-input checks cancel same-byte retry after diagnostic stop.
K115-06 ADDRESSED — history-sized outputs and paste backing allocations are relinquished; retained fields have bounded source invariants.
One Important scoped finding: **K115-R1-01**, decoder lines160–168; maxSequence1, ESC E4 then 1 A B leaks text1/A instead of draining through final A.
The same path affects ESC C2→timeout→1 A B under the controller's frozen budget ruling.
Root ruling was compared with K001/K002/F002/F007; budget-priority/retained-drain interpretation is consistent, not independently overruled.
Final original01–05 raw exits0, native stop summary and pure/I015pure results reused; direct lint raw has zero error severity and701 warnings.
Final source receipt hashes/HEAD/clean tracked state checked afresh; new finding is source-derived, not claimed executed.
Earlier affected raw remains attributed to its earlier patch; no full final-dispatcher, bundle or actual-host PASS claimed.
Details: [findings.json](findings.json); immutable evidence: [index.md](index.md), [manifest.sha256](manifest.sha256).
No author reasoning/contact, subagents, code/test/spec/main edits, new builds/probes/suites or asset audit.

