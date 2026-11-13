# TASK-153 zero-frame serialization fixture correction and bounded audit
Test-only SHA: `fc7344eecdabcb318210ff9c0b6793e83b2c47f5`; baseline `b26529e5bd31839fdc19fb11e05cb5d814ef36f3`.
Only progress_geometry.cj line10 changes: width0/height2 manual golden empty → one LF; all nonzero bars/styles/events/fraction checks unchanged.
Authority: accepted Frame composition design §2 explicitly preserves height−1 LF for zero-width finite-height exports; height0 and width0/height1 stay empty.
Independent public Frame consumer builds0/direct0 against manual goldens for (0,0), (0,1), (0,2), (1,0); no product helper generates expected values.
Remaining S04/S05 assumptions audited once against accepted Frame/Runtime/Interaction/Theme and existing positive cases; no other clearly proven fixture mistake found.
Audit covers content/padding/viewport/readsets, initial themes, batch/post cutoffs, stale generations, cleanup/resources, multiview/error/native setup; details in evidence/remaining-S04-S05-audit.md.
Exact one-line diff/inverse equality, parser0, unchanged other35 test files and preserved prior evidence verified; clean test-only commit.
Actual154 runner-palette.log preserved separately; no S154 implementation source read or expected values inferred from its output.
Evidence/index.json binds authority/input/probe/source/binary/raw hashes. No widget/PTY/154 acceptance PASS or generic correctness claim.
