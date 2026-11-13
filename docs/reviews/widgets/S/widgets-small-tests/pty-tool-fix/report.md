# TASK-153 PTY runner import correction
Test-only SHA: `b3f20f3d1dca6e440bef654d80124df256586db9`; baseline `480b066fac8d4fbe437732f2fcae6712e3ae1da6`.
Only pty.py lines3/12 change: remove shadowed pty import and call existing POSIX os.openpty().
All device source, product assertions/inputs/exit codes/mode checks/restoration/time budgets and other35 test files are byte-equal.
Actual AttributeError runner-focus.log preserved; failure preceded product PTY execution and is classified TOOL failure.
Python syntax/help/import surface0; actual nonproduct OS PTY normal and forced-termination transport controls0; inverse/scope/commit checks0, clean worktree.
Bounded launcher import/FD/metadata/termination audit found no further proven pre-execution defect; controls are TOOL-ONLY, never target PASS.
Producer must use a fresh PTY output path because the preserved failed run already created its normal directory.
Evidence/index.json binds before/after, raw logs, module origins, helper/transport bytes/metadata and prior immutable index; all prior bindings checked unchanged.
No widget/three-mode product/native restoration/154 acceptance PASS; producer154 and later independent156 retain actual execution responsibility.
