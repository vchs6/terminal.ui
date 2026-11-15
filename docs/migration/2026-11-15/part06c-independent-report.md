# Part06c independent verification

Result: **PASS**, 0 findings. Verified all 11 source originals and 12 regular tar members, including exact embedded manifest. All SHA-256, size and mode checks passed. Every raw header and PAX control record matched source-derived metadata byte for byte, including owner/group/mtime. Paths are safe and unique; no links, unexpected members or nonzero trailing data.

Archive: `/dev/shm/terminal-ui-migration-20261115-host/terminal-ui-migration-20261115-part06c.tar.gz`

- Bytes: 53861580
- SHA-256: `bc133b37fa46d1431f5a57ca304b9513184888ac760cf85114338c0adf2d65ca`
- Git blob: `597a58ba2d7ebd0bfd666b8c48e7d1ee3cd50b64`
- This volume: 11 gzip originals, 0 metadata originals; 189245752 original bytes streamed.

The two volumes are a disjoint exact cover of all 21 physical round2 gzip files. All 21 gzip streams passed EOF/CRC and original SHA-256/size plus compressed SHA-256/size checks, totaling 378506472 original bytes. Part06b supplies all 65 metadata originals; its metadata validation is reused for part06c. The immutable restore-map.json/receipt-index.json are historical partial10 records. Full21 bindings use restore-map-final.json/receipt-index-final.json. Both map/index bindings, 42 receipt hashes and original identities, and partial/final completion bindings were checked. Historical partial status is preserved, not rewritten.

Scope is these two custody migration volumes only. No claim that the entire sixth group is complete or Linux acceptance passes. Verification used read-only originals and host-RAM archives with in-memory streaming; no unpacked ELF was written or run, and no build, VM or network was used.
