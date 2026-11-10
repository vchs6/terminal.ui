# Independent RichText round1 regression ledger

- Scope: execution-only formal test addition for TASK009/082; no product/spec/main-repository edits, no subagents or product-author communication.
- Base: `034685dacd76f1450317b0352411ddc4be112136`, detached isolated clone at `source/`.
- Frozen input: design sections 4–6 and coordinator's ruling in `task-r1-regression-brief.md`: a UTF8 lead inside existing ASCII CSI framing is immediately illegal; same-byte resource priority does not replace earlier syntax on later bytes. Normal UTF8 C1 introducers remain valid.
- Skills read/applied: TDD + writing-good-tests, verification-before-completion, local `/workspace/work/CangjieSkills/SKILL` (batched language queries), cloud runtime. No new public/API decision or product implementation.
- Facts read: retained formal test sources and factual independent `probe/src/main.cj`, `raw/probe-build.log`, `raw/probe-run.log`; no product-author report/progress read.
- Initial hashes: `raw/source-initial.sha256`; SDK: `raw/sdk-version.log`.
- Test targets: immediate prefix issue, first-fault preservation across cuts and byte budgets, quarantine/no style changes, later invalid/incomplete UTF8 fail-close, ordinary UTF8 C1 and non-C1 continuation.
- Mutation targeted: postponing CSI syntax classification until UTF8 scalar completion; later byte-budget error then masks the earlier illegal lead. Also catch accidental C1 restart or payload release and skipped UTF8 validation in failed-sequence drain.
- Shared replay cache used only as read-only source copied into task-local `cache/`; private ignored configs and normal build hook retained.
- 2026-11-10T20:17–20:20Z: ordinary root `cjpm build` exit 0; ordinary `tests/rich-text` consumer `cjpm build` exit 0 on the first attempt, no syntax rescue or test correction.
- Direct actual executable exit 1; all old 11 groups printed PASS, all 98 new case executions reached the final summary. There were 56 failed checks: prefix issue absent/delayed, or budget-3 final issue wrongly `SequenceTooLong`. The existing same-byte resource rule, budget-4 final goldens, normal C1/continuation, output isolation and exception closure checks did not add failures.
- Final content hashes match the first build/run inputs (`regression-hash-check.exit`: 0). Product plus all retained old assertion files hash-check exit 0; raw generic initial check intentionally shows the changed README/main only.
- Fixed test-only commit: `cc556f4e4548c51c3d99e5a06768e61b41932d75`, direct child of fixed product base. Commit includes only one helper file, main wiring and README. Task-local generated lock files, ignored configs, build artifacts/cache, raw evidence and this ledger are not committed.
- Delivery report: `report.md`; no product/spec/main-repository edits, no subagents, no author communication; no GREEN claim or product fix made.
