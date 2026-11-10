# Independent148 S007 safe-pop supplement

Formal test-only **`f8b95815616c850145b647aae57e082c7915dab0`** adds the
complete-save/zero-byte-set safety assertions required by frozen S007/S008.
Its parent is the separately reviewed namespace correction
`47d267fe802dcb817b4f95247eac18a4a30c2fab` ([key-report.md](key-report.md)).
The independent product base is
`e9121c9768291b65fae56ca9b0f38b9bb6c3ee1f`; all product bytes remain unchanged.
The S007 commit changes six files under `tests/session_extensions/` only.
No149 implementation source/report/progress was read, no author communication
or subagents were used, and no producer result shaped these expectations.

[summary.json](summary.json), [progress.md](progress.md), and
[source-hashes.json](source-hashes.json) provide structured scope and provenance.
This delivers formal tests and **fixture-only** checks. The old library still
fails normal consumer compilation at missing public Session APIs; there is no
claim of product behavior RED/GREEN, actual cleanup execution, GUI restoration
or AC030 acceptance. Actual149 source must be built and executed independently
by150/151.

## Existing observation seam is sufficient

The frozen148 `src/live.cj::fault` arms mode1/offset0/target sequence2 for
`fault-set`: the first writer sequence is the complete save and the second is
set. `native/session_fault.c` selects a write failure by
`in_writer && sequence == target`; its `failed` flag detects later polls but does
not inject failures into a different writer sequence. Consequently the existing
seam can observe a later sequence3 cleanup pop, exact bytes and successful
native result. Its `__wrap_cjt_close` delegates real cleanup and records the real
return before optional injection; sequence/write/result records establish
whether pop happened before close.

A minimal fixture-driver branch now accepts three literal input files and
invokes the **existing real native writer**, requiring results0/-1/0 after
arming only sequence2. It does not implement Session, create public results,
manage a title ledger or add another writer/backend. It proves fault selection
and observability, not that the unavailable product Session cleanup ran.
All three route inputs are hand-authored hex vectors, independent of product
encoding. Actual native probes return:

| Route | save bytes | failed set bytes | pop bytes | exact observed wire |
|---|---:|---:|---:|---:|
| Direct |7|0|7|14 bytes: save+pop |
| TmuxPassthrough |17|0|17|34 bytes: save+pop |
| ScreenPassthrough |11|0|11|22 bytes: save+pop |

The existing close-failure injector is process-wide, so the one new zero-set
aggregation configuration combines **callback and UI cleanup** failures without
adding its persistent native-close injection to the same-process reopen test.
Existing partial-failure/native-close aggregation cases are untouched.

## Exact new assertions

For existing `fault-set` offset0 on every route, the oracle now requires:

- Exact session wire save+one pop; no set byte, missing pop or duplicate pop.
- Failed SetHostTitle with emittedBytes equal to the save, WriteFailed and offset-1;
  exactly two actual steps: SaveHostTitle/SentUnconfirmed/save length/NoIssue,
  followed by SetHostTitle/Failed/0/WriteFailed.
- Ordinary post-fault CopyLocalText remains zero-byte Failed/Cancelled;
  existing run-failure and zero-byte reopen requirements remain enforced.
- Exactly one cleanup result, including defensive-copy requery: RestoreHostTitle,
  SentUnconfirmed, exact wrapped pop bytes, NoIssue, offset-1,
  RestoreSentUnconfirmed, and exactly one correct restore step. This also detects
  a same-byte-count SaveHostTitle step poisoning the requery through aliasing.
- The actual primary (`run.primary` when aggregated, otherwise `run.error`) is
  nonempty and cannot be a controlled later callback/UI/native-cleanup, consumer
  assertion or post sentinel. Exception text/type for the first device failure
  is not invented or frozen by this test.
- Native sequence/result records before first real close are exactly save0,
  set(-1,0 bytes), pop0; the selected fault is sequence2 byte0. Actual native close
  succeeds, and all pre-close bytes are exactly save+pop. Ordinary healthy
  reopened-screen bytes after close remain separate.

The pre-existing partial-offset branch remains unchanged: all-wire must end at
the exact failing prefix, with no pop or any further control/frame bytes.
One additional **same-scenario Direct fault-set/offset0** configuration exercises
later callback+UI errors while retaining safe scope release and first-error
priority. The matrix is278 configurations, of which four are the supplemented
zero-set cases (three routes plus that one aggregation variant). No other
runtime case expectation is changed.

## Covering commands and actual results

`tests/session_extensions/safe_pop_selftest.mjs` drives the actual `verifyLive`
oracle with explicitly synthetic observations. It has three valid safe-route
observations and39 deliberate negatives (13 per route): missing/extra pop,
missing or wrong cleanup result, wrong/aliased restore step, lost save step,
known later errors replacing primary, pop after native close, and unsafe extra
pop. These are test-facility controls, never fabricated product output.

Before the supplement, this new control failed because the old oracle accepted
Direct's missing pop: [safe-pop-old-oracle-gap](raw/safe-pop-old-oracle-gap/execution.json)
exit1, with adjacent stdout/stderr. This is an **oracle gap**, not product
behavior RED.

The final command, cwd `/workspace/work/session-safe-pop-tests/source`:

```sh
bash tests/session_extensions/run.sh selftest
```

[Final execution](raw/final-s007-selftest/execution.json) exits0; adjacent raw
stdout/stderr retain the exact output. The final line is:

```text
PASS fixture-only S007 safe-pop oracle: routes=3 deliberate-negative-controls=39 native-selection-checks=3; no product runtime PASS
```

Its unchanged existing native fixture checks22 / negatives7, host-observation
controls4 and namespace controls3 also pass in that same command. The three
new native probes' literal inputs, exact stdout/wire/all-wire, native log,
stderr and actual child exit/argv are copied into
`raw/final-s007-selftest/native-controls/{Direct,TmuxPassthrough,ScreenPassthrough}`.
Each log records sequence1 success, fault2 byte0, and sequence3 success. No
actual native close/termios is claimed for these standalone writer probes.

Normal public consumer command:

```sh
source /workspace/work/session-safe-pop-tests/commands/env.sh
bash tests/session_extensions/run.sh build
```

[Old API build](raw/old-api-build/execution.json) exits1 with missing Session
public methods/types and their cascading compiler diagnostics. It is a normal
SDK1.2.0 CJPM path consumer, not a declaration-only replacement. No executable
Session behavior is claimed from it, and it was not repeatedly cold-built.
S007 changes no Cangjie API calls; the separate namespace correction changes
only a test record prefix. API absence remains the barrier to real execution.

SDK/compiler/project manager are actual1.2.0 ([versions](raw/sdk-version.txt)).
Root and consumer have ignored normal config using own cache
`/workspace/work/session-safe-pop-tests/cache`, copied from read-only
`/workspace/work/validation/replay-dependencies/cache`, existing relay18973 and
the fixed UCD17 archive. SDK/UCD/product/native-fixture hashes are recorded in
source-hashes.json. No relay/dependency/SDK/product modification was made.
Node syntax and git diff --check pass. No ELF, cache, checkout or generated lock
is committed. TDD/verification and the read-only Cangjie guidance were used.

Root can pass this fixed test SHA to150/151. The formal scenario remains
`fault-set`; `run.sh run fault-set` selects its three-route offset matrix plus
this one same-scenario aggregation configuration. Full independent Session
execution and host evidence remain downstream responsibilities. The supplied
149 headless TSV was used solely for the separately committed namespace fixture
control; no149 development count or behavior result is used as acceptance here.
