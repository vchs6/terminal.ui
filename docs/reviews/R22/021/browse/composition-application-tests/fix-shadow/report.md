TASK021.a bounded shadow-fixture correction
Classification: execution; one confirmed fixture error against existing public shadow contract.
Parent: c51f9bfc02e2844391282ea80b761362aba400d2
TESTONLY commit: 2e5e998d00f2f60e45376bca4ada8376273d339a
Source: /workspace/work/composition-application-tests/fix-shadow/source
Reason: Component.shadow has style/offset/enabled, no glyph override; Frame.shadowClipped emits ░, or '.' if not one column.
Fixed source: e35d407a src/component.cj285, layout.cj85, frame.cj175–186; docs/product/README.md37.
Accepted010 decoration source/raw corroborates ░; expected glyph derived from public source, not generated from output.
Diff: only modal.json shadow-only cells and interaction-contract.md shadow sentence.
Wide/narrow each change 40 spaces to ░ (8 exposed right +32 bottom); coordinates/black bg/whole-grid/style assertions retained.
Before tools-only fixture check: actual exit1, 0 ░ vs expected40.
After tools-only glyph/oracle/syntax/whitespace checks: each actual exit0.
No compiler/application build or product run; no new coverage/API/hooks/product edits/subagents/push.
Application delivery/build/smoke/TTY/background/review outcomes remain pending as original handoff.
Original c51 source/index84da/report/all indexed raw hashes verified unchanged.
First unadopted 4a3e index/5ca report exact bytes were overwritten and are not separately retained; no reconstruction claimed.
Git5ca source commit retained; current original raw retained unchanged.
Separate immutable provenance/results: fix-shadow/index.json; commands: fix-shadow/evidence/verify.sh.
