# Part06a independent verification

Result: **PASS**. Verified the dedicated archive bytes, all 71 source originals, 72 regular tar members (71 payloads + exact manifest), and all 20 first-round gzip ELF streams. There are 0 findings.

Archive: `/dev/shm/terminal-ui-migration-20261115-host/terminal-ui-migration-20261115-part06a.tar.gz`

- Bytes: 90909862
- SHA-256: `77b360183bacc9b1f499b1a40e2ec68c9b051b11127a4b69bc74cf631098a451`
- Git blob: `3ce973a2426ea13300e28a857e260eb153ef82d4`
- Original ELF bytes streamed and hashed: 317561592

Every source and archive member matched manifest SHA-256, size and mode. Raw PAX headers and control records matched source-derived encoding byte for byte, including owner/group/mtime; member names were safe and unique, with no links, unexpected members or nonzero trailing data. Embedded manifest bytes matched the supplied manifest exactly. All gzip streams reached valid EOF/CRC with no extra compressed stream and matched restore-map original SHA-256/size, verified-decompressed fields, and gzip SHA-256/size. Receipt-index restore-map binding, all 20 original/gzip identities and 40 receipt hash/content bindings matched. Existing records were read only.

Scope is first-volume historical custody migration only: first20 gzip originals plus 51 existing custody/receipt/restore files. Round2 payloads are excluded; the existing round2-custody.py helper is included as metadata. Historical root-verification was not substituted for this verification. Main docs/reviews/R24/E/README.md explicitly excludes runtime/SDK/cache/ELF payloads from the earlier archive; hash references in earlier proofs do not establish delivery of these gzip bytes. This verifies their presence and integrity in part06a. It does not complete the whole sixth group or certify Linux acceptance.

Verification used read-only archive/source access and in-memory streaming; no unpacked ELF was written or run, and no builds, VM or network were used.
