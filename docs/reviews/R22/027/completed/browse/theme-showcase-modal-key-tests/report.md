# TASK027-R1 independent modal-key RED
Status: TEST_ONLY_FROZEN; genuine runtime RED against pinned pre-fix example binary.
Parent test commit: 1a5812dc68001ebbcd68f87a37815110ec9e71d9; new test-only commit: 71afd32e43e279a9693c6d5c22a6dce4102960a2.
Review finding: /workspace/work/theme-showcase-review/findings.json TASK027-R1 Important; product source read-only 954d7492b91c2f490dcb15d2d42190af5dbe52ae.
Binary: /workspace/work/theme-showcase-implementation/source/examples/theme_showcase/target/release/bin/main SHA256 92dd71989fe12658477dc9aceef8a62c633318f74d99bcc336aed62ce0398bb5.
Command: source SDK1.2 envsetup, set approved stdx/UCD paths and CJTUI_SHOWCASE_BINARY to that binary, then `node tests/theme_showcase/modal-keys.mjs`; exit 1, failures=2.
Both cases verified actual F2→Dark and F1→Classic before modal, then opened literal Classic Preview; second also opened owned PopupMenu.
After sending real F2 inside Preview or PopupMenu, each timed out waiting 12 seconds for visible accepted Dark palette; raw events show key sent, final complete frame remained Classic, and process had not exited. Harness killed it on failure; empty direct.exit is not a claimed product exit.
Expectation after product fix: F2 accepts Dark while the existing Preview/PopupMenu stays open; PopupMenu still navigates past disabled Delete and closes normally; complete fixed Dark modal grid is reused.
New source scope: tests/theme_showcase/modal-keys.mjs plus runner and public basis only; no product/core/API/golden edits, no build or full suite rerun.
Static `node --check`, `bash -n`, `git diff --check` exit 0; original test/source evidence seals remain untouched. Large raw frame JSON is losslessly gzip compressed before this seal.
