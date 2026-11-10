# Initial Auto RED evidence: historical-code reproduction

**原件未留存，以下为现在固定历史代码重现，不是恢复旧日志。**

## Original search and preservation

Searched /workspace/work/auto-tests (including its raw/ directory and relevant generated consumer artifacts) and relevant /tmp/cjtui* logs/PTY outputs. No complete original missing-API compiler log, default-snapshot assertion log, or ordinary-example assertion/exit log was found. The old report is a claim of what was run, not a replacement for those logs.

original-search/ preserves that report and the Basic16 arithmetic file unchanged. Two likely contemporary example raw candidates, /tmp/cjtui-colors-QpFnqS/actual-example (09:47:57 UTC) and XKDlC3 (09:48:06 UTC), were also copied unchanged. Their result.json files have no assertion/exit fields and there is no retained assertion stderr, so they provide only partial raw scene evidence; they do not become complete recovered RED by association. The dmAAbE candidate is an SDK runtime-library loader failure and is explicitly excluded from functional RED. preservation.json records original paths, mtimes, copied locations and original-byte SHA256. No old explicit-mode or unrelated R5–R9 log is substituted.

## Fixed inputs, independent workspace

- Independent new clone: /workspace/work/auto-red-reproduction, branch evidence/auto-red.
- Product: 187e126fc20b13a4f5526a28a9189cc0acb4037f.
- Initial public Auto test: 9466f89a0bfc738e0b15538225b413a22deba85f.
- Frozen Auto/PTY/default-snapshot/ordinary-example test content: 762a25e62d23b9a5d0c5e3b94689367248b0c11a (contains the preceding public test).
- Only later content adjustment: independently established SGR36 Cyan correction from 789bea3aba509c17e39fcd743b6a290fc665ba2a in tests/capabilities/src/main.cj. golden-correction.patch records the exact one-byte expectation and description change; none of the failing Auto expectations changes.
- Effective reproducible test-overlay commit: **0d2f6c77621cafdd0be267f3837f80652c9fc66b**, whose parent product is 187e126. It changes only the frozen test files/documents. No SDK shim, product stub, missing dependency, or alternate implementation was introduced. No additional tool patch was needed to reach these REDs.
- Product files are unchanged before and after: product-diff-before.txt and product-diff-after.txt are empty. effective-test-unchanged.txt is empty after the runs.

old-product-187e126.tar preserves exact fixed product source/build inputs; effective-tests.tar and effective-test.patch preserve the complete effective frozen test source. effective-test-sha256.json and product-source-sha256.json record every relevant file. fixed-revisions.json and effective-test-commit.txt record full Git IDs. SHA256SUMS hashes all retained evidence files.

## Environment and commands

Cangjie compiler/CJPM 1.2.0, Node 24.22.1, ncurses tic 6.5.20250216, script util-linux 2.41.5 and GNU stty 9.7. tools/ preserves the actual output. SDK is sourced from /workspace/work/validation/sdk/cangjie/envsetup.sh. CJTUI_UCD_ARCHIVE points to the existing verified /workspace/work/validation/UCD-17.0.0.zip. Ignored cangjie-repo.toml files select the existing private /workspace/work/auto-tests/cache and http://127.0.0.1:18972 registry relay. environment-inputs.json records paths and hashes; generated-locks/ preserves dependency locks. No product manifest or cached source/native artifact was patched.

run-command.py executes the supplied actual command under that SDK, records separate stdout.log and stderr.log, and writes full argv/cwd/start/end/actual subprocess returncode to result.json. Its own outer process status is not used as the tested command status. The three required REDs were reproduced on 2026-11-10 at 11:43–11:46 UTC.

| Check | Actual command and cwd | Build exit | Actual tested exit and cause |
| --- | --- | --- | --- |
| Missing Auto API | bash tests/capabilities/run.sh, repository root | 1 | Compiler RED: undeclared TerminalCapabilities, missing Application.terminalCapabilities / colorModeAuto and ColorMode.Basic8; 7 diagnostics |
| Pure default snapshot | cjpm build, tests/colors; then ./target/release/bin/main directly | 0 | Binary exit 1: FAIL: default snapshot is the pure TrueColor projection, encodingAndCells:116 |
| Ordinary example | cjpm build, examples/colors; then node tests/colors/pty.mjs example at root with an explicit retained artifact directory | 0 | Node harness exit 1: normal example starts with its first rich RGB sample under automatic direct-color profile, pty.mjs:180 |

The API runner also successfully compiles its test-local dynamic-loader wrapper and generates terminfo before reaching the real missing public API compiler failure. The two successful ordinary consumer/example builds prove these are not missing SDK or dependency failures. Direct binary execution avoids the SDK cjpm run status issue. The ordinary-example RED is its frozen assertion observing the normally built old executable in an actual util-linux PTY; it does not claim the application itself exited nonzero before test cleanup.

Commands used, from /workspace/work/auto-harness-repair (each target has exact full argv in its result.json):

```sh
python3 evidence/red-reproduction/run-command.py api-build-red /workspace/work/auto-red-reproduction bash tests/capabilities/run.sh
python3 evidence/red-reproduction/run-command.py snapshot-build /workspace/work/auto-red-reproduction/tests/colors cjpm build
python3 evidence/red-reproduction/run-command.py snapshot-red /workspace/work/auto-red-reproduction/tests/colors ./target/release/bin/main
python3 evidence/red-reproduction/run-command.py example-build /workspace/work/auto-red-reproduction/examples/colors cjpm build
python3 evidence/red-reproduction/run-command.py example-red /workspace/work/auto-red-reproduction env CJTUI_COLOR_ARTIFACTS=/workspace/work/auto-harness-repair/evidence/red-reproduction/example-pty node tests/colors/pty.mjs example
```

## Scope and limitations

This author only supplemented evidence, independently of product implementation and acceptance roles. No main-checkout product file changed, no Auto assertion was altered, no unrelated suite or GUI matrix ran, and current cold/GUI acceptance evidence remains independent. These freshly reproduced REDs establish that the fixed tests reject the fixed pre-Auto product; they cannot retroactively establish an original test-first timestamp. Original complete logs remain missing, and the report preserves that limitation.
