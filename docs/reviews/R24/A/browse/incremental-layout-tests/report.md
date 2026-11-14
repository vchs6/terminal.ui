TASK123 independent Unit A public tests; classification=execution; no product implementation.
Input M1: d654ae59da4749a43c946e1541c21b08e9b3ffba; version0.0.0; source trees unchanged.
Fixed test-only commit: 34240845e4bf393cc5d83475a2c9860a8de10f0e (nine test files).
Cases: nine total; baseline seven executed; statistics two compile-blocked.
Baseline normal cjpm build exit0, direct ./target/release/bin/main exit1.
Existing cases1/2/3/4/5/7 GREEN: Row/flex/style; Column/wrap/pad; root fallback/scroll;
explicit viewport/clamp; detached/mounted reference/lifecycle/old stats; Unicode/ASCII markers.
Existing case6 RED: after narrow reference reads alternate Canvas draw dependency,
wide.set(文) then snapshot gives 中 Z instead of literal 文 Z (second row blank).
R004/M004 require persistent Canvas subscriptions survive reference computation.
Read-only trace: layout.cj:155 uses persistent Binding.track; binding.cj:72 replaces reads.
Root retained this failure as Unit A124 acceptance obligation; core/oracle unmodified.
Case6 later measure-dependency assertion is not reached on frozen M1.
Statistics normal cjpm build exit1:29/29 diagnostics are missing arranges/cellWrites/frameAllocatedCells;
no unrelated diagnostics; runtime not executed; consumer compile-option only emits all errors.
Statistics require initial target costs, actual full-reference work, ownership and lifecycle semantics.
Hand-derived literal layout/raw Cell/Style/Canvas oracles and node/grid count bounds: committed README.
SDK/CJPM1.2.0; exact env/cwd/build/direct-run/status capture: commands.txt and raw/.
Actual source/dependency/SDK/config/executable hashes and skills provenance: accompanying JSON files.
Main observed36b19d776b45c2aeafd2ad77bb4352103e87f44f; no main/sparse/sharedconfig changes or subagents.
No B/C/D/E/performance/bundle/full-suite claim; no compiler-object pins; all raw retained (<100KB).
