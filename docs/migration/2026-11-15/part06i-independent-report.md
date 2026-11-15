# Independent migration verification 06i

PASS; 159 payload files, 12 ELF witnesses.

All listed physical source files checked with lstat, full SHA-256, size and mode. Queue root index/mapping digests, complete physical witness coverage, safe metadata scope, source indexes and before/after/verified receipts cross-checked. Every ELF gzip streamed in memory with SHA-256, decompressed SHA-256/size, CRC32, single-stream EOF and ELF header verification.

Archive full size/SHA-256/Git blob match delivery; exact safe regular unique tar members, full payload bytes, permissions, uid/gid/mtime and exact control manifest bytes/metadata verified. Outer gzip read through CRC/EOF.

The two old-roots-noncandidates JSON.gz metadata copies are not ELF witnesses and are not members of 06h or 06i. One source metadata gzip was parsed as JSON to cross-check source records; no content was executed.

Historical logical originals were removed by prior custody operations; original size/hash/mode validated from index/progress/before-after/verified receipts and streamed witness decompression. No original ELF restored to disk, executed, rebuilt, or newly accepted. Existing source versions and Linux acceptance conclusions unchanged.

Historical source-index limitation: two r11 historical source indexes are matching provenance references but do not themselves enumerate the unit-a-baseline and std.testrunner ELF hashes. The matching custody receipts bind those measured witnesses; this creates no new acceptance claim.
