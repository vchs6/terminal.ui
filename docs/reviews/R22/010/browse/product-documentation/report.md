# TASK010.c product documentation delivery
Classification: execution; inherited REQ-005.6 / AGENTS §9 viewing-instructions gap VS-REVIEW-001.
Base: e002cc44d7b2fc5ec78d47bf85959e5d56b0f9b6.
Commit: ebf0ef5663c3ac69d84ec7888424de6e24138ab2 (detached sparse worktree /workspace/work/visible-snapshot-doc/source).
Only committed file: docs/product/README.md; 11 added lines.
Added UTF-8/CUP/SGR terminal requirements, captured-grid sizing, direct Linux replay commands, and color/glyph limits.
Kept logical offline TrueColor/Unicode semantics and existing APIs; no source/test/build/spec changes.
Checks: source/API/contract inspection; git diff --check exit 0; extracted shell block sh -n exit 0; command availability checked.
No Cangjie/native build, snapshot-suite rerun, actual terminal replay, or bundle build performed for this documentation-only delta.
Prior 80d21e07/ecbf0999 bundle evidence does not bind the new README bytes or establish full release readiness.
Evidence: index.json; product-doc.patch; view-snapshot.sh; diff-check.log; shell-syntax.log; changed-files.txt.
Independent scoped review and separate actual-file execution remain downstream; no AC010/full Linux/release claim.
