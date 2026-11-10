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

The complete matrix additionally covers:

| Files | Independent expectations |
| --- | --- |
| `sgr.cj` | All 16 foreground/background colors, indexed/RGB endpoints, all six enables, selective disables, top-level empty resets, unset/reset distinction, atomic unsupported/malformed sequences and leftmost semantic fault |
| `utf8.cj`, `invalid_utf8.cj` | Every two-block byte boundary plus fully bytewise feeds, raw and UTF-8 C1, non-control UTF-8 continuations resembling CSI/ST, absolute byte offsets, CRLF, isolated controls, overlong/surrogate/out-of-range/truncated UTF-8 and permanent closure |
| `limits.cj` | Defaults and valid/invalid bounds, 63/64/65 fields for SGR and non-SGR CSI, operand/empty-field counts, fourth-digit immediate failure for any final, 4095/4096/4097 original-byte boundaries, terminator-byte accounting, same-byte resource precedence, first-error preservation and incomplete residuals |
| `control_strings.cj`, `unsupported.cj` | OSC/DCS/SOS/PM/APC in ESC/raw-C1/UTF8-C1 forms; BEL/ST rules; bounded and overlong isolation across embedded CSI, ESC, CAN/SUB and UTF-8 continuation; unknown operations never execute; malformed framing, cancellation and finish |
| `aliases.cj` | Defensive batch/result arrays, no retained mutable pending CSI/UTF8 chunks, subsequent feeds cannot mutate an old batch |
| `component.cj`, `bindings.cj` | Exact Cell styles; high-level explicit attributes override span fields while Frame base yields to span; shared grapheme/layout path; typed getter/constant constructor and setter overloads; String/RichText replacements detach subscriptions; equal normalized values avoid frames; style-only changes paint without measure |

For successful streams the accumulator compares concatenated normalized spans and
ordered diagnostic `(kind, offset)` pairs against author literals. It never compares
one decoder run to another as an expected-value oracle. Each small stream exercises
every cut, empty chunks and bytewise feeds. Long boundary streams use bytewise feeds
and selected cuts around the limit. Invalid UTF-8 tests assert the same error code
and closed state only: successful prefix batches can differ by split, as specified.

`InputTooLarge` requires an unrepresentable cumulative Int64 input size and cannot
be exercised economically through this public consumer. No test hook or fabricated
offset is added. Bounded-memory complexity also requires independent source review;
functional isolation tests are not claimed as a direct memory-bound proof.

A separate ignored, non-repository declaration-only scratch package was compiled
solely to detect consumer language errors before new APIs exist. Its callable bodies
throw, it is never run, and its build is not evidence that the product works. The
formal consumer remains dependent on the real `cjtui` package, with no scratch path.

Round1 regression `csi_utf8_first_fault.cj` retains all existing expectations and adds
literal public-API checks for a UTF8 lead inside an already-open ASCII CSI. The
lead is immediately outside parameter/intermediate/final ranges; at byte budgets
3 and 4 it reports `MalformedSequence` in the prefix batch, and a later resource
crossing cannot replace that first issue. Budget 2 retains same-byte resource
priority. Whole feeds, every two-chunk cut, bytewise and empty chunks check literal
output and offsets (including a multibyte text prefix), drain/no SGR restart,
incomplete residuals, invalid UTF8 and permanent closure. Normal UTF8 C1 CSI/SGR
and an ordinary continuation resembling C1 remain valid. The new group collects
failures across cases before failing the consumer, so its first RED does not hide
later checks. No expected value is obtained from another decoder run.
