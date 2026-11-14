# TASK020 indexed intermediate addendum — stage 1, 2026-11-14
Status: STAGED / HOLD PHYSICAL PATHS. No indexed artifact, sealed index, product, test, or published 020 file changed; no file removed.
Scope: 124 original `.a`/`.cjo` files at the two `source/tests/session_lifecycle/target` trees, 62 per role; 64,823,224 logical / 65,093,632 allocated bytes.
Frozen authority: `formal-tests/evidence/index.json` SHA256 `06b9228d5f74f7f21187204cac7d5cf6db28413661c93b0392691118520e126c`; `fix-r1/evidence/index.json` SHA256 `a0d0d4280f263af90fc7ed75ac37fb70e4ac4e716d1e27d3147b923184a3be26`.
All 124 original path/resolvedPath/bytes/SHA256/role records match those indices and direct files; fresh target process users: zero.
Existing published main 020 tar has 20,071 regular members, zero `.a`/`.cjo`/target entries; its manifest has zero original path or same-size/SHA match for these 124.
New content-addressed archive: 67 unique members for 124 logical paths; 57 duplicate content references; each `objects/<sha256>` stores exact original bytes.
`packed-build-targets.tar.gz`: 3,880,864 bytes; SHA256 `769d6469a2c4f4012b14f45d144bf54247035a63356811b108d649f86865b0aa`.
`packed-build-targets-map.json`: 92,637 bytes; SHA256 `7f0694e8ef1e854c241cc2b809e08f03e380a6a86f04b54af8611196ae5d0192`.
The map binds all frozen index records and path→member/bytes/SHA256, plus mode, UID/GID, mtime_ns, xattrs; inode/ctime are recorded as observations, which cannot be restored after removal.
Archive + map occupy 3,973,501 logical bytes; potential net reclaim is about 61,120,131 allocated bytes before filesystem/Git overhead, insufficient by itself for a 150–200 MiB target.
`pack.py` SHA256 `1726698047a673ed762d5f60cbaaf4b49593f7d99d54f8216e978ce44120a3fe`; stages atomically, checks no active target process, verifies all archive blobs and originals before completion.
`restore.py` SHA256 `af7e800533d80c25c535a4ca02554f6c03cd37b2649fb83dd0c761c754db278a`.
Verifier: `cd /workspace/work/validation/task020-intermediates-store-20261114 && python3 restore.py verify-direct` → PASS, 124 direct paths and 67 archive members.
Also available: `python3 restore.py verify-store` (archive/index only), `python3 restore.py resolve "$ORIGINAL"`, `python3 restore.py restore "$ORIGINAL"` (one absent allowlisted path only; rejects any existing path).
Restore checks the map, archive and frozen index hashes, verifies content, writes in the target directory, and links atomically without overwrite; it has not been run against an absent original.
Before any later physical removal: independently verify all 124 round trips and unchanged source metadata, publish a versioned archive/map/tool/checksum addendum, record logical-path resolution, and confirm no active users.
After such a migration, a frozen direct path is a historical logical identifier, not a claim that a physical regular file remains at that path; consumers needing direct files must restore first.
Physical paths remain HOLD pending a separate decision. Existing inode/ctime preservation receipts stay historical; exact inode/ctime recovery is impossible after removal.
