# Part06f independent verification

Result: **PASS**, 0 findings. Verified 113 original files and 114 regular tar members, including exact control manifest bytes. Source and member SHA-256/size/mode match. All raw header/PAX control bytes match source-derived uid/gid/name/mode/mtime metadata. Paths are safe and unique, with no links, unexpected members or nonzero padding/tail.

Archive: `/dev/shm/terminal-ui-migration-20261115-host/terminal-ui-migration-20261115-part06f.tar.gz`

- Bytes: 82898446
- SHA-256: `d55442d8883333f27691e2c26f3e5a620607bc8f0aa1dd7145acd1777770d344`
- Git blob: `1bb3682199044f67ac353991794871e4c014b68d`
- ELF gzip originals: 15; metadata originals: 98.
- Original ELF bytes streamed: 288437240.

Queue roots r01, r02, r03 were enforced before reading originals. Actual original index/progress files matched queue hashes; 110 indexed file bindings and 15 before/verified/after receipt triplets passed. The migration ELF descriptors were independently cross-checked against those actual records. All gzip streams reached valid CRC/EOF and match original and compressed SHA-256/size. ELF64 x86_64 headers passed. Physical gzip files, actual maps and archive payloads cover the same set exactly.

Source-index path/hash references agree across original maps, before receipts and migration manifest. Referenced source indices outside the bounded custody roots were not opened; this check preserves recorded provenance without asserting fresh source/compiler identity. Small already Git-covered metadata is retained for self-contained restoration and is not counted as newly added ELF. This migration does not close the sixth group or Linux acceptance.

All originals were read only; decompression was streamed in memory, with no ELF written or executed, build, VM, network or subagent. No raw environment or credential files were read. Volumes a–e were not reverified.
