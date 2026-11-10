# TASK079 independent finite dynamic execution

Status: **PASS for the finite TASK079 execution obligations**. TASK080 independent acceptance is still pending. Fixed product `216b2ab5f2315f4be19467b7e49f4047aec78ab9`, integrated main `5de716f`; original test commit `3ee1a9b` plus `10c4ee3` (34 groups). This is the independent execution role (requested Sol/medium), with its own checkout and caches. No product-author self-assessment was used. No product, formal test or contract changes; no delegated agents.

Scope is TASK079 brief and runtime design sections 4/6 R001–R019. TASK080 remains an independent subsequent acceptance. Initial `167c2a3` review FAIL/DYN-F001 and formal RED remain historical facts. This finite execution does not close Linux, parent ACs, composition, benchmark, or release readiness.

Fresh commands record UTC start/end, cwd, shell argv, stdout, stderr and actual exit in [evidence](evidence). Executable invocations use the built native binary; no `cjpm run` result is used as binary exit evidence. [Source scope](evidence/source-scope.json), [source inventory](evidence/source-inventory.json), [fixed-content proof](evidence/fixed-content-proof.json), and [binary hashes](evidence/executed-binaries.json) define the tested content.

## Native consumers and terminal restoration

Fresh root `cjpm build` and `cjpm check`, normal `cjpm bundle`, and all required native consumers exited0. The bundle performed its ordinary lint path; warnings remain in raw output and no lint skip was used.

| Fresh scope | Actual result |
|---|---|
| Formal dynamic direct binary | 34/34 groups; exit0 |
| Runtime core direct binary | 255 public assertions; exit0 |
| Runtime12PTY | 12/12; all exact termios restored and real close recorded exactly once |
| Macro positive direct binary | 16 assertions; exit0 |
| Layout / decoration consumers | 114 /59 assertions; exit0 |
| Public dynamic native example `--smoke` | exit0 |
| Clean unpack root build/check | exit0/0; own empty clean-cache |
| Clean fixed dynamic consumer | same34 groups; direct exit0 |
| Clean public dynamic example build/smoke | exit0/0 |
| Actual XTerm398 /XFCE1.1.4 +VTE0.80.1 | each8 complete settled grids equal; real resize and q; app/recorder/host exit0 |

Counts above distinguish assertion/group counts from host counts. [Command exits](evidence/command-results.json), [PTY summary](evidence/runtime-pty-summary.json), and [GUI checker raw](evidence/gui-dynamic-raw-check/stdout) are the result authorities. Failure modes callback/cleanup/callback-cleanup/callback-cleanup-close/mount/bind each have actual binary exit1, expected by the fixed tests; remaining6 scenarios exit0. Each original `before`, `after`, `close-record.txt`, `session.raw`, stderr and result.json is preserved. The injected close error occurs only after one successful real close; it remains explicit alongside primary and cleanup errors.

Both native GUI hosts have original PNGs at every stage, complete raw, host version, isolated/default configuration, locale, actual grid, UTC, source/binary/harness hashes, and inner/outer recorder state. [XTerm metadata](evidence/gui-dynamic/xterm-default/q/metadata.json) and [VTE metadata](evidence/gui-dynamic/xfce-vte/q/metadata.json) parse strictly as JSON, including escaped literal tabs in version output. [Host runtime provenance](evidence/host-runtime-provenance/stdout) records actual VTE0.80.1 package/linking facts. Reordered XTerm and refilled VTE PNGs were visually inspected.

The initial external clean preparation helper exited1 because it compared the hidden `src/.gitkeep` placeholder as product source, although ordinary CJPM bundle intentionally omits hidden placeholders. Diagnosis found no differing `.cj` or native source. Original [failure stderr](evidence/clean-prepare/stderr) and exit1 are retained; the external helper excludes only that placeholder and [recheck](evidence/clean-prepare-recheck/exit) exited0. All relevant product source comparisons then pass. No product, fixed tests, expected outcomes or release checker were changed.

## Real hosts

The unmodified ordinary public `examples/dynamic` is exercised on actual XTerm398 and XFCE1.1.4/VTE0.80.1 through the prior R12/R10 host infrastructure. Only external recorder/driver code is adapted. Host binaries and tools are reused; previous c3/R12 scenes are not relabeled as216 execution. No real user clipboard is queried.

The hand-written full-grid expected rows are: initial title/description/A/B/C; `v` title/A/B/C; `i` title/A/manual/B/C; `r` title/C/manual/B/A; `e` title/manual; `e` title/manual/D/E; `v` title/description/manual/D/E. Remaining cells must be blank. Resize changes actual 100×28 to120×34; settled final complete grid is compared, allowing an earlier coherent in-flight frame. `q` must exit0 and restore exact termios. [Independent raw checker](commands/verify-dynamic-raw.py) saves observed and expected complete grids; original PNGs and complete raw remain unmodified.

## Reused evidence and limits

Under AGENTS11.1, [fixed-content proof](evidence/fixed-content-proof.json) proves macro source and all15 negative fixtures unchanged from `f07ff633`, plus unchanged lower-level Frame/Cell/ANSI/Color/Style/text content from `c3d743d`. [Independent macro audit](evidence/reuse/macro-negative-independent-audit.json) verifies each original actual nonzero compiler exit, fixture source location and required diagnostic. No positive runtime is inferred from compiler-negative results.

R12 raw regression output is retained only for unchanged direct Frame/color encoding observations. It is not a fresh216 run and does not cover render(), RuntimeSession, or the full prior aggregate. That aggregate's actual exit1 is preserved; current affected runtime/layout/decoration consumers are fresh. Dynamic tests are exactly the fixed34 groups and original32 expectations remain intact.

Normal bundle execution and new clean extraction use public registry dependencies and a new clean-cache. No target/native archives/cache are copied into clean product. Only standalone consumer manifest dependency paths are changed. Product source content comparison and dependency hashes establish equivalence.

The unmodified full release bundle checker still requires the future composition and rendering benchmark artifacts; its failure is retained explicitly. A finite dynamic source bundle and clean consumer pass cannot be relabeled full-release PASS.

## Delivery and reproducibility

[Clean source comparison](evidence/clean-source-comparison.json), [consumer source equality](evidence/clean-consumer-source-equality.json), [manifest-only path diff](evidence/clean-consumer-manifest.diff), and [dependency content](evidence/dependency-content.json) establish clean-consumer scope. Fresh main/clean dependencies and prior reused dependency sources match. [SDK/UCD hashes](evidence/sdk-ucd-sha256.json) pin SDK1.2.0 tools and UCD input; the reused source proof and raw versions remain separate from fresh runs.

[Original bundle SHA](evidence/bundle-sha256.json) identifies the external `.cjp`; the archive deliberately excludes it and all executables/native archives/targets/caches/source checkouts/private keys. [Final tracked diff](evidence/source-final-tracked.diff) is empty; only ordinary untracked build lockfiles are observed. Commands and external evidence tooling are in [commands](commands). `artifacts.sha256` covers every curated file except itself; its verification and all Markdown target/strict JSON checks pass. The first archive safety audit rejected a copied external X11 injector ELF; its original exit1/log is retained. The external archiver now excludes that tool binary, and the corrected curated archive passes the no-ELF check. This did not change product content or test outcomes.

The [unmodified full bundle checker](evidence/archive-boundary/stderr) actually exits1 at missing `examples/composition/cjpm.toml`; the archive also lacks the required future rendering benchmark. Both remain pending. This report claims only the finite dynamic runtime execution, not all-Linux completion, release readiness, or TASK080 acceptance. Formal historical RED and original167 review FAIL are not overwritten or weakened.
