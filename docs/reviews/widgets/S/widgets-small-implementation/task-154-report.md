# TASK-154 product development report

Product commit: `1df1325f7b51777d8adab62f950c936051aa5876`; full review base: `5413dc768a93b3e3f172227161bc9d8545993508`.
Independent fixed test: `b3f20f3d1dca6e440bef654d80124df256586db9`; its `tests/widgets_small` tree is byte-identical to the product checkout.
Five public Text/Canvas widget factories, shared caption/activation helpers, example, guide and single dispatcher mapping are committed.
`bash tests/widgets_small/run.sh` exit 0: fixture sanity, prerequisite build/direct, target build/direct, device build, three real PTY modes, and two expected Bool constructor compiler rejections.
Example normal CJPM build and SDK PTY q smoke exit 0; the initial unsourced smoke exit 127 remains historical evidence.
Direct source cjlint exit 0; JSON inspection: 0 ERROR, 0 MANDATORY, 13 suggestions in the new source files. Dispatcher shell syntax exit 0.
Immutable source/test/bin/raw index: `evidence/final-index.json`, SHA256 `40e091dd2718e57e9619b362a6dbd459e06afae8288b818b819510940eec5a58`.
Prior failed runner/fixture phases and their hashes remain under `evidence/`; canonical LEGACY-PROP-001 metadata is on root main, not cherry-picked here.
Development evidence only; independent source review, execution, clean bundle and acceptance remain separate.
