# Accepted Unit B compact proof

TASK132 sealed **PASS_UNIT_B** for `275149c274df41d38ffc950f104b31185dea19a7`: 12/12 original requirements, zero blockers and zero detected nonblocking defects. Frozen B tests are `9908551d206922d0083711abbc70738c60da9215`; accepted A is `4f7e853f821c334318e2038d4e20ab26e72c16c8`. Main merge `bacfa0ba7b25e357636bc21942e2b6e415d2ee07` retains the reviewed candidate as an ancestor and the exact four-file product delta. Publication starts from `c2f57414b3a4ca1ba9e947e651932a0dbaf51012` and changes only this new proof directory.

Read the [acceptance report](browse/frame-cow-acceptance/report.md), [12 original requirement judgments](browse/frame-cow-acceptance/findings.json), [independent execution report](browse/frame-cow-execution/report.md), [review findings](browse/frame-cow-review/findings.json), [archive index](archive-index.json) and [storage addendum](storage-addendum.md). All browse reports and indices preserve original bytes and historical statuses. Full raw evidence is packed once in `raw-evidence.tar.gz`; thousands of original raw files remain inside that single archive. `original-manifest.json.gz` supplies safe relative members, original logical paths, SHA-256/byte/mode records, exact Git bindings, exclusions and prior references. Absolute paths in original evidence are historical identifiers, not extraction destinations.

| Original requirement | Sealed result |
| --- | --- |
| B132-01 Functional baseline and real allocation RED | PASS |
| B132-02 Same Frame, immutable row sharing and every write | PASS |
| B132-03 Full Cell, cluster, transparency and composition semantics | PASS |
| B132-04 Zero area, metadata, copy/resize and budget boundaries | PASS |
| B132-05 Actual successful Cell slots and writes | PASS |
| B132-06 Ownership, returned snapshots and cumulative lifecycle | PASS |
| B132-07 Measured hot-path Cell-slot reduction | PASS |
| B132-08 Arbitrary-old/external changes and complete-profile fallback | PASS |
| B132-09 Backend resize, profile and no-change synchronization | PASS |
| B132-10 Failure fences and output compatibility | PASS |
| B132-11 File and ANSI compatibility | PASS |
| B132-12 Fixed source/tests/package/ELF provenance and compatibility | PASS |

TASK128's seven fixture cases passed the functional baseline and exposed a real COW RED. TASK131 freshly built and executed those same seven cases in baseline and COW modes, both with zero failures; these are seven cases exercised twice. For area 24, cached snapshot slots fell from 48/48 to 0/0, changed generation from 72 to 24, and complete reference remained 24. Public external first/repeated/different-row mutations were executed. First owned-row detach charging W slots and later private writes charging zero are source proofs, not separately measured owned-detach runtime claims.

TASK131 also executed affected native recovery commands: five normal and 45 supplement cases, including coherent 4→2→4 grids, RGB→Monochrome with bold retained, and no update for the same effective profile/target. Original failures remain: the initial independent backend command lacked sparse `tests/support`; materializing unchanged support allowed the affected commands to succeed. Producer compiler/build failures and original logs remain available. Old A behavior/statistics, composition/layout, full fault and normal package evidence use the sealed same-input reuse judgments under AGENTS §11.1. Normal bundle succeeded with tests/lint enabled, zero default discovered tests and existing warnings; no new unpacked-consumer run is claimed.

The accepted ordinary source package is included once: `cjtui-0.0.0.cjp`, 181,784 bytes, SHA-256 `5cf548610d87fc9603e8313e5b4660e1649880448f837baf6fe725c14742c9f0`. Runtime ELFs, SDK/cache/native compiler outputs and whole worker worktrees are explicitly excluded. Current B producer/executor pins are checked in place; historical B128 and earlier ELF paths resolve through local exact-byte witness receipts, as described in the storage addendum. Those large witnesses are not published here. Source copies and fixed Git commit/blob/path/SHA bindings preserve historical versions without a full source checkout. Existing Unit A and earlier large proof archives are referenced, not duplicated.

Accepted B source uses finally-based main/overlay owner release; TASK132 independently records the related A127 Q1 cleanup observation as resolved. Publication leaves the old A finding/report unchanged. Cell-slot reductions are not CPU, byte, heap, GC, RSS or end-to-end performance results; changed target generation still renders completely, and row-directory/projection overhead remains outside the metric.

This mechanical publication performs no product/test edits, builds, suite reruns or acceptance reruns. It adds no PNGs or real-host claims: this is a headless COW unit, and prior Linux GUI screenshots remain prior-round evidence. Unit C/D/E, TASK031/AC031/full M2, performance benchmarks, full terminal matrix, whole Linux acceptance and release remain open. Root integration runs the main repository/OpenSpec checks separately; local publication checks cover new Markdown closure, every archive/browse member, exact bindings and exclusions.
