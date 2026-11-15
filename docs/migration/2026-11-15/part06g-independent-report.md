# Part06g independent verification

Result: **PASS**, 0 findings. Verified 154 original files and 155 regular tar members, including exact control manifest bytes. Source and member SHA-256/size/mode match. All raw header/PAX control bytes match source-derived uid/gid/name/mode/mtime metadata. Paths are safe and unique, with no links, unexpected members or nonzero padding/tail.

Archive: `/dev/shm/terminal-ui-migration-20261115-host/terminal-ui-migration-20261115-part06g.tar.gz`

- Bytes: 89460006
- SHA-256: `1062ec85b4bb260cf4c2ef34614e0b5cf995533eba6a5ac0c2ca7f9fa7105ac2`
- Git blob: `a3f1d820b6c43f6deca1b5d54c2471b8abe50e16`
- ELF gzip originals: 16; metadata originals: 138.
- Original ELF bytes streamed: 313176208.

Queue roots r04, r05, r06, r07 were enforced before reading originals. Actual original index/progress files matched queue hashes; 150 indexed file bindings and 16 before/verified/after receipt triplets passed. The migration ELF descriptors were independently cross-checked against those actual records. All gzip streams reached valid CRC/EOF and match original and compressed SHA-256/size. ELF64 x86_64 headers passed. Physical gzip files, actual maps and archive payloads cover the same set exactly.

Source-index path/hash references agree across original maps, before receipts and migration manifest. Referenced source indices outside the bounded custody roots were not opened; this check preserves recorded provenance without asserting fresh source/compiler identity. The original index also references 14 fallback/cache files outside the queue's explicit direct-file/ELF scope; those references remain preserved but their targets were excluded and not opened. Small already Git-covered metadata is retained for self-contained restoration and is not counted as newly added ELF. This migration does not close the sixth group or Linux acceptance.

All originals were read only; decompression was streamed in memory, with no ELF written or executed, build, VM, network or subagent. No raw environment or credential files were read. Volumes a–e were not reverified.
