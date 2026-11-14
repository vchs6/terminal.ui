# TASK027.a bounded preset contract correction
Status: TEST_ONLY_CORRECTED; original f743 test seal and raw evidence remain untouched.
Parent: f74351cbce2bbd71237b1d2f26c53209b481dc90; correction commit: 1a5812dc68001ebbcd68f87a37815110ec9e71d9.
Input: canonical themes in parent and fixed product source 954d7492 read only; no product/core/build edits.
Root causes: High contrast full display name clips to `Gallery | High c` at 16 columns; Modal border+padding yields one blank on each inner side; High contrast is ASCII/no shadow like Classic, while Dark/Light are rounded/shadow.
Pre-fix v2 `node tests/theme_showcase/preset-contract.mjs` exit 1 with exactly those three independent source/arithmetic mismatches; v1 exploratory raw retained separately.
Post-fix v3 source/arithmetic projection exit 0; existing `node tests/theme_showcase/selftest.mjs` exit 0; JS parse/bash syntax/diff checks exit 0.
`bash tests/theme_showcase/run.sh` v3 exit 1 at expected delivery RED: sparse test tree lacks three examples/theme_showcase product files; app build/PTY/GUI not run here.
Diff boundary: all 80×24 and 40×12 startup grids and all retained grids unchanged; only High contrast 16×6 footer in both startup sets, modal interior padding for all four, and High contrast modal border/shadow changed.
Source-derived modal inner width = 32 - 2 border - 2 padding = 28 columns; Dark/Light one-cell right/bottom shadow, Classic/High contrast none.
No old report/index/raw overwritten; full actual example execution and GUI acceptance remain independent downstream work.
