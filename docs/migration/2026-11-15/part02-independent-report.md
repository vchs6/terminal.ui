# Independent migration evidence verification — part 02

Result: **PASS**. Source coverage and byte verification passed for all **7,404 eligible regular original evidence files** (30,849,827 bytes), including **737 original PNGs**, **77 valid gzip streams**, failed-attempt evidence, and **90 cleanup evidence files**, including the allowed `ssh-server/final-owned-cleanup.json`. Original SHA-256, size and permission mode match the manifest. The manifest and omissions SHA-256 remain unchanged, so that source audit remains applicable.

The rebuilt archive was fully rechecked: **7,406 regular members**, comprising 7,404 evidence members plus the exact manifest and omissions files. All member hashes, byte lengths, and modes match. All names are canonical relative paths without traversal or duplicates. No source files are missing, and the archive stayed unchanged during verification.

Archive: `/workspace/shared/downloads/terminal-ui-migration-20261115-part02.tar.gz`

Size: **10,096,232 bytes**. SHA-256: `33f2864cb281a1b1fae5dea6b12f922ebe3b74c19365366ecc09471726eab6ae`

The initial archive contained five hard-linked `paste002-facts/declaration-ready.json` members in screen-attempt3, ssh-attempt5, tmux-attempt3, vte-attempt4 and xterm-attempt2. The parent rebuilt it with `dereference=True`. Full archive revalidation confirms those members are now regular files with matching bytes and modes; the original evidence and manifest were unchanged.

Only the three declared cpio.gz VM images, two declared native supervisors, and two nonregular FIFO endpoints are omitted from the inspected regular evidence inventory. Forbidden and credential directories were pruned before inventory descent. The ssh-server exclusion has its expressly allowed cleanup exception; omissions.json's whole-directory wording is imprecise but causes no missing evidence.

This audit makes **no final Linux product success claim** and does not establish GitHub main availability. It performed no build, VM run, network action, extraction, original edit, or archive modification. It inspected metadata, hashes, gzip stream validity and tar member metadata/content hashes without printing sensitive evidence contents.

Remaining verification errors: **0**. Machine-readable counters and the resolved hard-link finding are in `independent-findings.json`.
