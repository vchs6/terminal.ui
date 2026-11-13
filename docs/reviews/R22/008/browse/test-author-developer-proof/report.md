# TASK008.a independent formal tests — baseline RED
Fixed test-only commit: `9d224da8f74997fa8329a84c798c61e5a57d2fc9` (includes `6a6ac8eb`); BASE `51529b7f5bce9c639d54876c378b54aa1cd3aaf2`.
Only nine new `tests/output_recovery/` files; no product/source/build/config/other-test changes, no subagents, no main push.
Requested assignment Sol/high; actual serving model/effort cannot be independently authenticated.
Frozen inputs: public manifest SHA256 `6f10c6eb41e83164bae545cb3b7fd93fa56fffd4f6613ca9b85755fa9c81a3fb`; admission index `d137d921dc02d96609c5bc68a8665da72d23bdede17b0bc0b58f3110b5a7c27b`.
Normal build: `source /workspace/work/validation/sdk/cangjie/envsetup.sh`; export stdx/UCD as in `evidence/index.json`; `./tests/output_recovery/run.sh build` → exit0 (`build-5.*`).
Actual SDK/CJPM1.2.0, GCC14.2, Node24.22.1, util-linux2.41.5; own ignored config uses read-only warmcache and public HTTPS registry, no relay/cache/SDK copies.
Direct own binary SHA256 `c77f87222831545d01e1a96b10c1ef7fc7c301a0a0297f8acc7d087ec339c527`; binary stays outside Git.
`CJTUI_RECOVERY_ARTIFACTS=<newdir> ./tests/output_recovery/run.sh run` is the complete reproducible entrypoint.
Exact `6a6ac8eb` final-baseline: 326 cases, 325 pass, one RED; wrapper exit1; every direct consumer binary exits0 without forced termination.
Final descendant adds only managed-caret phase: `run.sh run --only=cut-frame-startup-4` → exit0, 12/12 pass; previous326 unaffected and reused under AGENTS11.1.
Combined338 cases:337 GREEN, one root-adjudicated C002/AC008 product RED, `normal-caret`; expected injected faults themselves pass.
RED repro: `run.sh run --normal --only=normal-caret`; unchanged grid/profile/visible caret emits another six-byte `ESC[1;3H` (transaction005), expected zero additional transaction.
RED has direct exit0, one cleanup, stats `0/0/0/0`, exact restored termios and native signal evidence; wrapper correctly returns1 after collecting these.
GREEN: hand-literal normal/short/style grids; same frame/profile silence; RGB→Monochrome; coherent4→2→4 resize; exact query/2004/OSC/title/caret/restore bytes.
Faults: every byte cut in bounded representative current transactions, EIO/zero return, EINTR/full successful short writes, allocation retry, exact first error plus UI/native cleanup extras, unsafe/no-later-byte and reopen distinctions.
Earlier fixture API/import/default-SGR/title-cleanup expectation mistakes and all original failed logs remain; none is counted as product RED. Title-cleanup retains its exact existing first-error text.
Manual expectations/proof obligations: `source/tests/output_recovery/README.md`; real native wrapper reuses S152 method and existing row interpreter/atomic resize helper, without a second backend/parser.
Public stats count generated targets, not commits: independent review must prove success-only baseline ordering at fixed `src/application.cj:660–683` and native non-output cleanup/free/latch ordering.
Accepted R10/070/S152/I112/I117/E122/M162 inputs retain their original scope/limits; historical unchanged evidence is not silently relabeled current source equality.
Read TDD/good-tests, verification, systematic-debugging, specified-design brainstorming and pinned Cangjie coding/reference conventions; exact provenance/commands/hashes in `evidence/index.json` and `evidence/artifacts.sha256`.
No full TASK008/Linux/release acceptance: product implementation, independent review/execution/acceptance and real-host visual restoration remain later roles.
