TASK132 — PASS_UNIT_B
Candidate: 275149c274df41d38ffc950f104b31185dea19a7.
Accepted A input: 4f7e853f821c334318e2038d4e20ab26e72c16c8, product-exact to 0f83f73d0268b30b429f3f7482f4c9d1031b5006.
Frozen B tests: 9908551d206922d0083711abbc70738c60da9215; nine A files remain exact to 34240845e4bf393cc5d83475a2c9860a8de10f0e.
Verdict: zero blockers and zero detected defects within original B128–132; parent TASK031 remains open.

| Original requirement | Evidence and acceptance judgment |
| --- | --- |
| Fixed independent baseline and real allocation RED | B128 raw final-baseline/final-cow: functionality passes, cached snapshots allocate 48/48 Cell slots for area 24; COW assertion fails. Original ELF restored logically by exact lossless gzip witness. PASS. |
| Same Frame, immutable sharing, every write | Candidate frame.cj/frame_row.cj: permanently frozen rows; source and copy both detach via writeCell, including clearAt/cluster partners. B131 alias/write-entrance literals pass. No public hook, second Frame or Unicode kernel. PASS. |
| Source/copy isolation and self-composition | B128 alias/composition cases executed by B131: original, sibling, grandchild and later app generation stay independent; transfer snapshots intersection before writing. PASS. |
| R11/F003 transparency, StyledSpace and clusters | B131 full Cell/style/continuation/opacity literals cover holes, styled spaces, half-clusters, emoji, negative offsets and partner repair; same-candidate composition/layout execution is valid audited reuse. PASS. |
| Copy/resize policy, zero axes and budget | B131 tests retain ambiguousWide/default opacity/maxCells; changed dimensions use transfer. Frame(0,Max)/Frame(Max,0) allocate no row directory and run under address-space cap; overflow/export budgets reject. PASS. |
| Actual slots, writes, ownership and lifetime | Initial rows, detach and transfer scratch charge successful actual storage and initialization writes. Full sharing charges zero. Returned copies/render results release owner; external edits are uncharged. A statistics runtime reuse verifies cumulative/dispose/restart; B131 verifies first/repeated/different-row external writes. PASS. |
| First/repeated owned-row detach | Source proof: first frozen-row write clones W slots and counts W initialization writes; later private-row writes allocate zero until sharing freezes it again. This is not claimed as separately measured owned-detach runtime. PASS. |
| Hot-path allocation reduction | Same frozen B test: B131 cached snapshot slots 0/0 versus B128 48/48; changed generation 24 versus 72; complete reference remains 24. Correctness output preserved. Accept Cell-slot reduction only. PASS. |
| Arbitrary old/external changes/profile fallback | Equal dimensions + complete equivalent profile + identical frozen row are the only skip predicate; otherwise project both rows with their own profiles and compare. External writes detach; no damage/lineage cache exists. Conservative mapped-policy identity uses immutable copied data. PASS by source proof. |
| Backend synchronization and profile/resize | B131 native/raw transactions and actual harness commands show 4→2→4 full coherent grids, RGB→Monochrome retaining bold, same effective profile/target no update. Application commits frame/profile/caret/dimensions only after successful output. PASS. |
| TASK008 failure fences and output compatibility | B131 normal/supplement runs plus same-candidate full-fault reuse preserve literal prefixes, unsafe stop, cleanup and reopen refusal. Composition file bytes/error cases and public full ANSI are preserved. PASS. |
| Ordinary build/package and provenance | B131 ordinary CJPM builds pass; producer normal bundle succeeds with tests/lint enabled (zero discovered default tests, existing warnings). CJP's 193 product/native/build files equal candidate; 245 inspected files equal both trees; eight current ELFs match. Existing A/public-consumer packaging status is reused, not re-described as a fresh unpacked-consumer run. PASS. |

B130 source review was checked against the original contracts and actual four-file delta; its PASS heading was not the acceptance oracle.
Own binding verification: 1,115 execution records, 7,414 producer factual records, six review records and 36 B128 records match; no mismatch. Frozen input-index hashes are in index.json/raw/bindings.json.
Same-input reuse follows AGENTS11.1: current candidate/test/native/dependency/build bindings are recorded; B131 independently ran B and affected normal/supplement backend consumers. Old A acceptance is reused by fixed SHA, without historical archive rescans.
Producer report, Q1 and self-assessment prose were excluded. Main/overlay owner cleanup is independently visible in finally blocks; A127's related nonblocking observation is resolved in this delta.
Initial execution failure was a missing sparse tests/support module; unchanged support was materialized and both affected commands then succeeded. It is not an outstanding product failure.
Limits: slot counts are not bytes, CPU, total heap, GC or RSS. Changed targets still render completely; row-directory/projection overhead remains outside this slot metric. No end-to-end performance claim.
No test/build rerun, source/test edits, publication or subagents by this acceptance role. Requested Astra/high for judgment; actual serving not independently verified.
Only PASS_UNIT_B: C/D/E, AC031/full M2, benchmarks and whole Linux acceptance remain open. Detailed conditions, scope and bindings: findings.json and index.json.
