# TASK115 scoped re-review — fix round 2/5
Fixed HEAD: `c3c4642d84df57bbd9550d222ed22f602acd13ef`; fix BASE: `500d5ff35632ab7ed55e323458883bbd7e80d2b7`.
Spec verdict: **PASS**. Quality verdict: **PASS** for the scoped source review.
K115-R1-01 **ADDRESSED**; parent K115-04 **ADDRESSED**. Five previously closed original findings remain closed without reopening.
The oversized Alt path now keeps drained=true and retries in the shared nonstring isolation state; digits/final cannot become text. Normal invalid UTF8 and explicit cancellation paths retain their rules.
No new blocker found in the eight-line decoder change or authorized dispatcher wiring.
Reused fixed raw: all eight new literal observations, original04, public pure and Alt controls exit0; final direct lint exit0 with zero error severity and701 warnings.
Fresh fixed-SHA, tracked-clean, diff-check and final-source receipt hashes verified.
No new build/probe/suite, author reasoning/contact, asset audit, subagent or product/test/spec/main edit.
This closes TASK115's open source findings; TASK116 mandatory bundle/clean/actual-host evidence and TASK117 acceptance are not claimed.
Details: [findings.json](findings.json); immutable evidence: [index.md](index.md), [manifest.sha256](manifest.sha256).

