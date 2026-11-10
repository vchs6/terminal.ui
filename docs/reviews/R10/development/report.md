# TASK-006 implementation handoff

- Baseline: c839ab20c6f2a289ff91a60e5f36989be02be04d; frozen consumer RED reproduced before implementation: `/workspace/work/color-implementation/red.log` (exit 1, undeclared ColorMode and missing Bright colors).
- Product commit: `a8b2327`; complete merge with second frozen tests and design: `9bc94b5fa690ec4cb290b289e2a8a8e60683e06e`.
- Implementation: Color/ColorMode/Style models, six inheritable component attributes, deterministic output projection, ansies encoding, effective row diffs with per-run projection reuse, Application mode committed after successful output, public colors example and product docs. Existing logical frames retain original styles.
- SDK 1.2 rejects ordinary positional parameters with a default; zero-argument and positional Bool overloads implement the frozen calling forms. Independent reproduction: `/workspace/work/color-implementation/default-parameter-diagnostic.log`, exit 1.
- SDK: `/workspace/work/validation/sdk/cangjie/envsetup.sh`, Cangjie 1.2.0; private copied dependency cache and `CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip`.
- `tests/run-slice.sh colors`: exit 0, `/workspace/work/color-implementation/final-colors.log`; mappings, Style and Color equality, inheritance, raw cells and legacy bytes.
- `tests/run-slice.sh colors-integration`: exit 0, `/workspace/work/color-implementation/integration.log`; 14 handshake actions and actual example mode and attribute switches, resize, terminal restoration. Raw PTY artifacts `/tmp/cjtui-colors-KlNLOc`.
- Full cold slice, bundle, and clean consumer are reserved for independent executor; these have not been asserted here.
- Final third frozen consumer tests integrated in HEAD `5482f8146774852df382e925794bf0d79df35e83`. Product paths match `a8b2327` with no diff. `tests/run-slice.sh colors` rerun after integration: exit 0; raw `/workspace/work/color-implementation/final-colors-third.log` includes independent default, false and same-receiver assertions for all six setters. Previously successful PTY integration evidence remains applicable to unchanged product paths.
