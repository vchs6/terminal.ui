# Independent formal RichText round1 RED

Status: formal behavioral RED established on the real old product. No product fix
was made. Coordinator may integrate this fixed test commit and dispatch the scoped
product repair for R14-T082-001.

- BASE: `034685dacd76f1450317b0352411ddc4be112136`.
- Test SHA: **`cc556f4e4548c51c3d99e5a06768e61b41932d75`**, a direct child of BASE.
- Isolation: `/workspace/work/rich-text-regression-tests/source`.
- Commit scope: only `tests/rich-text/src/csi_utf8_first_fault.cj` (184 lines), one
  main entry call, and the README addition. No old expected assertion changed.
- SDK: Cangjie Compiler 1.2.0 (cjnative), target x86_64-unknown-linux-gnu, CJPM 1.2.0.

| Check | Actual result | Raw evidence |
| --- | --- | --- |
| Normal product `cjpm build` | exit 0 | `raw/initial-product-build.log`, `.exit` |
| Normal real consumer `cjpm build` | exit 0, first attempt | `raw/initial-consumer-build.log`, `.exit` |
| Direct actual consumer executable | **exit 1**, 56 failed checks | `raw/initial-consumer-direct.log`, `.exit` |
| Retained 11 test groups | all 11 PASS before new group | same direct log, first 11 lines |
| Product + retained old test sources | all initial hashes match, exit 0 | `raw/retained-source-final-check.log`, `.exit` |
| First build inputs versus delivered test content | identical hashes, cmp exit 0 | `raw/regression-initial.sha256`, `raw/regression-final.sha256`, `raw/regression-hash-check.exit` |
| Product tracked diff BASE..test SHA | empty, exit 0 | `raw/product-unchanged.exit` |
| Committed diff whitespace | exit 0 | `raw/diff-check.log`, `.exit` |

The consumer was run as:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
TERM=dumb COLORTERM= timeout 60s tests/rich-text/target/release/bin/main </dev/null
```

No `cjpm run`, declaration-only stand-in, private API, product test hook, custom
compiler/link flags, dependency source changes, new dependencies, or product code
was used. Product and consumer manifest versions remain 0.0.0. Commands, cwd and environment are in
`raw/commands.md`. The standard native build hook used the verified official UCD17
archive and normal Unicode generator; replay dependencies were copied from the
read-only seed into a task-local cache. Both project configs are ignored.

## Precise RED cause

The frozen design sections 4–6 and coordinator ruling require immediate first
syntax/resource diagnosis inside existing ASCII CSI framing. At `ESC [ C2`, C2 is
already outside parameter 30–3F, intermediate 20–2F and final 40–7E; with budgets
3/4 the prefix batch must contain `MalformedSequence@0`. The old real product
returns zero diagnostics there. A valid A0 continuation and final m produce a
later diagnostic, incorrectly `SequenceTooLong@0` at budget 3. Budget 4 eventually
produces malformed, which still violates the prefix-batch timing assertion.

Representative raw assertions:

```text
FAIL: CSI UTF8 ESC [ C2 budget 3: immediate malformed: issue count 0/1
FAIL: CSI UTF8 budget 3: valid scalar tail and final drain without second resource: issue count 1/0
FAIL: CSI UTF8 ESC [ C2 budget 4: immediate malformed: issue count 0/1
FAIL: CSI UTF8 valid non-ASCII scalar stays in CSI drain budget 3 cuts case 0: issue 0 expected MalformedSequence@0, actual SequenceTooLong@0
CSI UTF8 first-fault regression failures: 56
```

The first run reached all 98 new case executions and the final aggregate assertion.
All failures match missing/delayed first diagnosis or its budget-3 replacement;
there were no extra output, offset, UTF8 exception-code or closure failures.
The combined raw stdout/stderr contains a runtime stack trace interleaved with one
stdout line due buffering; its exit is the actual binary's 1, not a wrapper success.

## Coverage and limits

- Immediate exact three-byte `1b 5b c2` prefix batches at limits 3/4, followed by
  valid continuation/final and no second diagnostic. Limit 2 checks resource
  priority on the same byte.
- The same successful whole streams at every two-block cut, bytewise feeds and
  empty chunks, at limits 3/4. All issue/output expectations are hand-written.
- Literal introducer offsets 0 and 4 (after `界A`), valid scalar drain, UTF8 C1
  inside failed CSI, and a non-C1 scalar with 9B continuation. No body release or
  SGR style restart is allowed.
- Later invalid continuation and finish with incomplete UTF8 must throw
  `InvalidUtf8` and permanently close both feed/finish; valid scalar but unclosed
  CSI adds only `IncompleteSequence` at finish after the original malformed issue.
- Normal pending C2 is legal; subsequent 9B starts ordinary C1 CSI/SGR. Ordinary
  D2 9B remains text. Normal paths are covered across every cut using existing
  public test helpers and literal spans.

No ASCII ESC-framing extension, astronomical-offset hook, API/spec change,
unrelated cold full suite or memory-complexity claim was added. Old 11 groups ran
once with the complete new consumer. Product fix and post-fix GREEN remain the
original author's/coordinator's next step. No product-author report was read and
no product-author communication occurred.

Evidence manifests:

- Initial source manifest SHA256: `df41962b3cc7157a877067f90179beda147161df856b3dd957603c1a6e4f7daa`.
- Final source manifest SHA256: `fbf7c303e39a92513e49681f511137b173cb48d0f2f6bb90cc3be6d3b0f0742b`.
- Direct RED raw log SHA256: `05c7bf31df475a73f80292e9964e257de796da7faf03bf46eba7185f4b40c36c`.

Full manifests, SDK identity, actual exits, commit parent/files and factual ledger
are in `raw/` and `progress.md` outside the committed repository. The generic
initial hash check predates exclusion of the intentionally changed main/README;
only those two differed. The retained-source checks exclude exactly those two
and include all product source plus every old assertion/helper unchanged.
