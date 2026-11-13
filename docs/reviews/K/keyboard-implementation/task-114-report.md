# TASK114 fixed candidate

BASE `c96cc601c547f869e64632e955091cf44546d192`; HEAD `5baa09f33251e9f572640a2f6d4ae46245f7eea8`.
Product commits: `2cc38e3a`, `c643d5e7`, `c80e5e41`, `5baa09f3`; test-only cherries: `86126246`, `91697a73`.
`bash tests/run-slice.sh keyboard`: exit 0 on final source, including 113 and both supplemental suites.
`cjlint -f src`: exit 0; zero error diagnostics, 699 warning lines retained.
Runtime core, native-session, application lifecycle, B review, C formal/native caret and public example passed on the identified earlier source snapshots; see phase index for applicability.
Old A `--matrix` exited 1 at obsolete `csi-real-idle-A`; the later K-stage idle test passes in the final dispatcher. The old raw failure remains recorded.
A separate selected-A invocation without the SDK runtime exited 1/product 127; correctly configured reruns exited 0. Both are recorded.
Immutable phase index: `/workspace/work/keyboard-implementation/phase-index-final.txt`, SHA256 `ee69387f43b1d620e1ea3d2c245721dbd17b55ec568184b5d6bf991902ce1922`.
Independent 115 source review and 116 validation remain outstanding.

## TASK115 round 1 fix

Test-only `bce5b9c9` (independent `0df3c1bf`); product/dispatcher `500d5ff35632ab7ed55e323458883bbd7e80d2b7`.
Final-source K115-01–05 selectors, existing pure decoder and I015 pure controls: exit 0, including real PTY K115-05. Final direct `cjlint -f src`: exit 0, zero error diagnostics; 701 warning lines retained.
Earlier related frozen-patch runs: existing argument, I015 native, and formal native issue-stop, issue-throws, EOF input/paste and stream-two: exit 0. The final subsequent change validates the UTF-8 minimum before accepting a C1 scalar; those earlier cases do not exercise that branch.
SDK capacity reasoning and the ESC+C2 budget/cancellation source trace are recorded as source proof, not runtime results.
Cryptographic raw index: `/workspace/work/keyboard-implementation/review-r1-index.txt`, SHA256 `1f2b82caef5821002d0c8a9488cd06c6bb8d8909ff52017a46e5650302cc23b8`.
Scoped independent re-review remains outstanding.

## TASK115 round 2 fix

Test-only `cb636485` (independent `a4a02193`); product/dispatcher `c3c4642d84df57bbd9550d222ed22f602acd13ef`.
New K115-R1-01 oversized Alt drain selector, existing K115-04, public pure decoder, and prior Alt timeout/invalid-offset/cancellation control: exit 0. Direct `cjlint -f src`: exit 0, zero error diagnostics, 701 warning lines retained.
Cryptographic raw index: `/workspace/work/keyboard-implementation/review-r2-index.txt`, SHA256 `a136492bee3bbb38f3a2a201b4c8973b323e855dc23884915f1e85d97593f9b2`.
Scoped independent re-review remains outstanding.
