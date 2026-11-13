# TASK008.a caret supplement — fixture limitation; stopped
No new commit; clean sparse worktree remains at frozen tests `9d224da8f74997fa8329a84c798c61e5a57d2fc9` (product BASE `51529b7f5bce9c639d54876c378b54aa1cd3aaf2`).
One bounded positive-control attempt: caret scenario `x` sets logical visible caret `(2,0)`; `c` selects Monochrome; a following `h` fences event processing.
Hand-literal attempted requirement: default 4-cell `Aé  ` row rewrite followed by CUP `ESC[1;3H`; no actual output was used to generate that expectation.
Attempt: `bash evidence/run-command.sh` → wrapper exit1, cases1/failures1; direct exit0/signal=null, no forced termination; replay guard now requires restoring attempt.patch.
Actual profile-change wire was only six-byte CUP `ESC[1;3H`; the necessary nonempty-grid-rewrite precondition was absent.
This is a fixture-precondition failure, not a new product RED or a completed positive test.
Color-output design D030 requires updating only rows whose effective projected style changes; default-style cells are unchanged by Monochrome.
Existing caret driver `x` changes only position, `s` only invalidates, and `c` only changes mode; it has no text/emphasis mutation in the caret scenario.
Per controller instruction, stopped without extending the fixture/Cj/native code or weakening the expected post-text positioning requirement.
Cleanup evidence: UI once, public resources `0/0/0/0`, identical termios, native close0, all three signal handlers/masks restored.
Reused exact binary SHA256 `c77f87222831545d01e1a96b10c1ef7fc7c301a0a0297f8acc7d087ec339c527`; no Cj/native build, binary/cache/SDK copy, or original338 rerun.
Original frozen index/artifact-list/report/binary hashes remain unchanged; original337GREEN/normal-caret C002RED evidence is reused without relabeling.
Skills used: TDD + writing-good-tests, verification-before-completion, using-git-worktrees, systematic-debugging; exact resource locators in evidence/index.json.
Attempted runner/README patch is retained only at evidence/attempt.patch; own test edits were restored and no product edits/push occurred.
Proof index: evidence/index.json; immutable artifact hashes: evidence/artifacts.sha256 and evidence/index.sha256.
Later independent product review must still verify post-text positioning when logical caret is unchanged; no TASK008/Linux completion or acceptance is claimed.
