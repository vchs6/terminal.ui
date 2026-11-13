# TASK159 — DONE_WITH_CONCERNS
Product commit: 6f7d6feeb18b714d10300505d02e163d97b6c68a; integrated verification HEAD: 6e3f26aaaeee9442fde91ce31d720a841eeda473; frozen test revision: ad100b79956de30fe65c6d561f11be67186821d5.
Delivered public menu, popup, status and split factories, example and guide; no runtime/renderer/decoder changes.
`bash tests/widgets_composite/run.sh formal`: exit 0; prerequisite, M01–M05/S02 headless, normal/callback-failure/getter-failure PTYs pass. `evidence/formal-fenced.log`, `evidence/pty-fenced/`.
The compiler reports two unused-expression warnings in fixed test assertions; all exact PTY results and binaries are indexed.
`cd examples/widgets_composition && cjpm build`: exit 0, `evidence/example-final-fixed.log`; `cjpm bundle`: exit 0, `evidence/bundle-current.log`.
Current CJP SHA256 1bbd2e986ef993b05f3248d122c4a7991a72702d51472fdaf904a9f322eaf7e0; 226 packaged source/example/product-doc files match; `evidence/bundle-source-equality.json`.
`cjlint -f src`: exit 0, 0 MANDATORY / 788 SUGGESTIONS; `evidence/lint-fixed.json`; changed product sources formatted with cjfmt.
S156 full execution reused by unchanged scope; S02 modifier prerequisite replayed; `evidence/s-reuse.txt`, upstream index SHA256 9d15fcee7473101f21edec529063d380d0d2dc0f5d75b006498e5927239b78a0.
Baseline `scripts/check-bundle.mjs` rejects included themes/light.toml (T087 allowlist mismatch); raw `evidence/bundle-check-fixed.log`; no release claim.
Earlier fixed-test failures, raw PTY data and binaries remain indexed; all corrections independently supplied, with no author edits to tests.
Developer verification only; independent review160, execution161 and acceptance162 remain pending. No full Linux or release claim.
