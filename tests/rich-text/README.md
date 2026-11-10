# TASK-081 rich text public consumer

Execution task; frozen API/semantics: `openspec/changes/implement-rich-text/design.md`
at `7a33ddc7fb93da3f30007e49538cb00821a2d81b`. Required skills actually read:
TDD, verification-before-completion, local Cangjie Coding (`CangjieSkills/SKILL`);
its `search_docs.py` was used before implementation. Requested role Sol/high;
actual serving model is not independently exposed or attested.

Source SDK 1.2.0 `envsetup.sh`, configure an ignored private `cangjie-repo.toml`
as documented in `tests/README.md`, then run `tests/rich-text/run.sh`.
The script uses ordinary `cjpm build`, then directly executes the resulting binary
so assertion exits propagate. No terminal, private APIs, product stubs, dependency
source edits, compiler rescue flags, or decoder-derived expected values are used.
`tests/run-slice.sh` integration is deliberately left to sequential integration.

Initial core assertions use hand-written patch, normalized span and Cell goldens:
None versus explicit reset, independent style fields, CRLF across spans, combining,
ZWJ/flag first-scalar styles, clipping/overwrite, defensive arrays, strict String
compatibility and whole-value validation. Failure of missing public APIs is RED,
never a test pass. Additional decoder and runtime tests follow the same contract.

Independent evidence is kept outside this clone in `../evidence`: UTC, source,
commands, stdout/stderr and real exit codes. Author runs are development evidence;
independent execution and acceptance remain separate tasks.
