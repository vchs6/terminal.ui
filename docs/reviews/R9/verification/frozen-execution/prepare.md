# TASK056 preparation

Independent clone: `/workspace/work/layout-execution/repo`.
Initial HEAD: `d655f9baab146320441e449f2d15f9f74cc5bb35` (not accepted as final test version).
Read: AGENTS.md §§11,13.2,14; implement-layout-decoration design.md/tasks.md; scripts/check-product.sh; tests/run-slice.sh; scripts/check-bundle.mjs; tests/integration/layout-pty.mjs.
Copied shared dependency cache into independent writable `cache/`; shared cache unchanged.
No product/test edits; no build or acceptance commands executed. Awaiting reviewed fixed commit.

Execution obligations: fresh check-product.sh slice, SDK1.2.0, direct executable tests, actual layout PTY toggles/resize/termios with raw and frames, local cjpm bundle (never publish), unchanged bundle boundary checker, clean extracted package and ordinary external consumer without private FFI flags, package entities/subpackages coverage and source/output checksums.
Known scope: complete release remains incomplete while composition/rendering benchmark projects are absent. Bundle checker currently requires them; preserve its actual result and report separately from slice/source-consumer results.
