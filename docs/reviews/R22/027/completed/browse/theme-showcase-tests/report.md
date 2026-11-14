# TASK027.a formal test freeze
Status: TEST_ONLY_FROZEN; product delivery RED; app/keyboard/GUI outcomes unrun.
Base: 39d56c0f7ca2d751a9ce5fb4e18913636fdff43a; final test commit: f74351cbce2bbd71237b1d2f26c53209b481dc90 (prior f6a6063a).
Input manifest SHA256: 80862cf7d9f7bd9d80351dcb40fab96fd96f5216888e71163dc1997cf3a77e28; AC021 accepted prerequisite per manifest.
Scope: 14 test-only files in tests/theme_showcase; no src/native/themes/examples/product config edits.
Frozen: four exact preset names; complete literal 80x24/40x12/16x6 grids, pending, modal, retained/scrolled frames; public API basis and CLI/key/file contract.
Tool: `node tests/theme_showcase/selftest.mjs` exit 0 (v1 raw); literal width/Unicode, existing Screen oracle, partial/style/negative controls.
Delivery: `node tests/theme_showcase/delivery.mjs` exit 1 (v1 raw): only examples/theme_showcase/{cjpm.toml,src/main.cj,README.md} absent.
Runner: `bash tests/theme_showcase/run.sh` exit 1 (v2 raw), same intentional delivery RED before build.
Earlier runner v1 exit 1 from wrong test root; one-line path correction committed, v1 raw retained and superseded by v2.
Static: all new `.mjs` `node --check`, `bash -n` runner, and `git diff --check` exit 0; source clean after commit.
SDK: Cangjie Compiler/CJPM 1.2.0, x86_64-unknown-linux-gnu; runner sources /workspace/work/validation/sdk/cangjie/envsetup.sh and sets approved stdx/UCD paths.
Pending product phase: ordinary CJPM build, direct finite smoke/invalid exits, PTY real keys/file, GUI original PNG/full grid/style metadata and independent acceptance.
No full library rebuild or unrelated suites repeated; unchanged theme/editing/Frame and AC021 proofs reused under AGENTS 11.1.
