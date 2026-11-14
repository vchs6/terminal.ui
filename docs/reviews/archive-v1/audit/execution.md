# Lossless review archive migration: PASS

All 26 original round groups are archived and accepted; the 1,138-byte root review README remains inline without a round archive. The frozen inventory contains 36,756 originals / 453,165,327 bytes. Every archived member was independently checked against frozen SHA256, size and mode before deletion; every removed original was restored to bounded owned scratch and rechecked. All retained originals were checked again in the final global inventory.

Retained: **3800 files / 107293030 bytes**. Removed from checkout: **32956 files / 345872297 bytes**. Three conservative additions to retention are documented below; no frozen keep file was removed.

Archive shards, manifests, retention/transaction records, current catalog and canonical catalog history total **51756740 bytes**. Net logical savings: **294115557 bytes**. Actual allocated bytes for the archive representation: 52350976; retained originals: 117145600. Allocation and free-space measurements are separate from logical byte savings; original pre-migration allocated totals were not measured, so no exact allocated savings claim is made. Current free workspace bytes: 528535552.

Each remaining group ran pack, CLI archive verify, independent every-member verification, remove once, CLI verify again, independent one-at-time restore of every removed original, actual CLI restore with overwrite refusal, and the unchanged repository checker. Groups with no removals restored one retained member via the CLI control. R11 evidence is reused from its accepted pilot. Whole-catalog logical lookup covers every 36,755 round path in relative and historical absolute spelling. Repository checks passed for every group. No further test, product build, or CLI51 rerun was needed.

Git has exactly 32956 intended original deletions and the 26 new round archive directories plus catalog/history directory. No staged changes, source/test/product edits, HEAD/config changes, commits, pushes, or unrelated cleanup. R22 ran last; frozen storage receipts, R16 X.Org input, Markdown/PNGs/indexes and all active link inputs remain unchanged. Existing compressed originals were treated as opaque bytes.

Catalog history is preserved in both owned raw/catalog-history and canonical docs/reviews/archive-v1/catalog-history, with hash-named bytes and per-stage path→snapshot maps. Earlier sealed report/index files were not rewritten. The final evidence pins the final catalog separately.

Additional retained files:
- `docs/reviews/interaction/A/TASK-100/findings.json` (8590 bytes); rationale in interaction/preflight.json.
- `docs/reviews/interaction/B/TASK-105/findings.json` (11156 bytes); rationale in interaction/preflight.json.
- `docs/reviews/interaction/C/source-review/review-fd286174..61e4de9d.diff` (141703 bytes); rationale in interaction/preflight.json.

| Group | Originals | Retained | Removed | Archive + group metadata bytes |
| --- | ---: | ---: | ---: | ---: |
| E | 6271 | 312 | 5959 | 2804017 |
| K | 2626 | 175 | 2451 | 2255938 |
| R0 | 2 | 1 | 1 | 4544 |
| R1 | 1 | 1 | 0 | 1739 |
| R10 | 1667 | 129 | 1538 | 1935796 |
| R11 | 515 | 71 | 444 | 391922 |
| R12 | 1331 | 80 | 1251 | 563478 |
| R13 | 759 | 74 | 685 | 884112 |
| R14 | 1138 | 159 | 979 | 1899450 |
| R15 | 1664 | 112 | 1552 | 2332966 |
| R16 | 1645 | 122 | 1523 | 1614940 |
| R17 | 369 | 185 | 184 | 281131 |
| R18 | 5193 | 265 | 4928 | 3165886 |
| R19 | 93 | 8 | 85 | 30114 |
| R20 | 1 | 1 | 0 | 4973 |
| R22 | 592 | 485 | 107 | 14099399 |
| R23 | 1985 | 187 | 1798 | 2200349 |
| R3 | 2 | 1 | 1 | 3492 |
| R4 | 5 | 1 | 4 | 8401 |
| R5 | 58 | 14 | 44 | 35960 |
| R6 | 8 | 6 | 2 | 16114 |
| R7 | 111 | 53 | 58 | 154620 |
| R8 | 130 | 63 | 67 | 186102 |
| R9 | 700 | 86 | 614 | 400570 |
| interaction | 7585 | 666 | 6919 | 12589383 |
| widgets | 2304 | 542 | 1762 | 3175154 |
