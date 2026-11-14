TASK021.a bounded asynchronous-theme wait correction
Classification: execution; label-only wait contradicts existing pending→Applied theme lifecycle.
Parent: 6dbece66e2989849d87729a5da10d95b4fbb0a24
TESTONLY commit: d07a6933be8ff2429ee9799ee32043642e0dfeb4
Source: /workspace/work/composition-application-tests/fix-theme-wait/source
Contract: docs/product/theme.md ThemeRequest pending/Applied; ThemeLoader.submit starts preset worker then finish accepts theme.
Fixed e301 Commands.toggleTheme sets business Light label before submitting asynchronous loadTheme.
Captured last frame has Light label and default bg; raw has no completed white frame before immediate assertion/termination.
This is an allowed pending observation, not evidence of eventual product success or a proven color defect.
Counterexample replays original failure: true exit1; old label passes while white-bg assertion fails.
Fix: all6 existing F3 waits require matching footer plus expected root/footer bg and default fg under existing12s deadline.
Existing explicit color, editor focus/selection/undo, scroll and business assertions remain; no sleep/override/new hooks.
Oracle covers pending Light/Classic, complete Light/Classic, wrong fg/label and partial bg.
After tools-only replay/oracle/syntax/whitespace: each true exit0; captured pending frame correctly remains rejected.
No application/compiler build or run; actual eventual-theme/key/business outcomes remain pending independent execution.
Exactly3 formal test/contract files changed; no app/core/API/CLI changes, subagents, cleanup or push.
All original c51/84da, shadow2e/4798 and PTY6dbe/805a indices/reports/indexed raw verified unchanged.
Original stdout/events and exact pending-frame snapshot retained in new evidence; full capture files hashed.
Separate immutable commands/results/proofs/limits: fix-theme-wait/index.json and evidence/verify.sh.
