# TASK124 Unit A implementation evidence

Source base: b4ccd47c9cf883288e9613d9c06f73f087788717.
Candidate: 4f7e853f821c334318e2038d4e20ab26e72c16c8; tree 0b72a9e87a2abc1fc7e19ba031bba9554000537b.
Fixed tests: 34240845e4bf393cc5d83475a2c9860a8de10f0e; tests/incremental_layout diff exit 0.
Source scope: shared measure/arrange/paint, RuntimeNode-owned layout cache, transient reference observation and readonly statistics.
Retired paths: allocation in paint, ordered LayoutNode child list, session.measuredLayout and reference Canvas subscription replacement.
Counters: actual arrangement, owned target/snapshot Cell writes, successful target/copy/transfer temporary Cell slots; terminal output projection excluded.
SDK/CJPM 1.2.0; shells source SDK envsetup and set CANGJIE_STDX_PATH and CJTUI_UCD_ARCHIVE per brief.
Fixed baseline: ordinary consumer cjpm build exit 0; direct ELF exit 0, cases 1–7 PASS.
Fixed statistics: ordinary consumer cjpm build exit 0; direct ELF exit 0, cases 8–9 PASS.
Existing theme_canvas_integration/run.sh exit 0; finite, control and subtree modes PASS.
Existing tests/layout cjpm build exit 0 with two unused-expression warnings; direct ELF exit 0.
Initial normal cjpm bundle exit 1 on G.EXP.03; condition changed and checks rerun.
Final normal cjpm bundle exit 0; configured tests ran (0 discovered), lint ran with warnings and no mandatory errors.
CJP contains byte-matching changed product source/docs; CJP SHA256 56a7318d7931490545ee5fd255628170ed0bdc32aca71a11bc549955cfa53b49.
Raw logs retained as lossless gzip with original and compressed SHA256 in index.json.
Generated cjpm.lock files are untracked workspace artifacts and excluded from commit and index.
New regressions observed: none in listed final runs; independent TASK125–127 remain pending.
No B/C/D optimization, local performance or full M2 acceptance is claimed.
