# TASK020 indexed intermediate migration — phase 2, 2026-11-14
Status: COMPLETE; all 124 mapped `.a`/`.cjo` physical paths are absent. Their original paths are historical logical identifiers.
The four phase 2 receipts and this verification are bound by `phase2-checksums.json`; the 124 allowed unlink operations are recorded in `phase2-after.json`.
Frozen index SHA256: `06b9228d5f74f7f21187204cac7d5cf6db28413661c93b0392691118520e126c`, `a0d0d4280f263af90fc7ed75ac37fb70e4ac4e716d1e27d3147b923184a3be26`.
Content archive SHA256: `769d6469a2c4f4012b14f45d144bf54247035a63356811b108d649f86865b0aa`; map SHA256: `7f0694e8ef1e854c241cc2b809e08f03e380a6a86f04b54af8611196ae5d0192`.
`python3 restore.py verify-store` passed now: 124 mapped logical paths, 67 archive members, two frozen indices; all 124 direct paths are currently absent.
A sampled absent path restored with matching bytes/SHA256; restore rejected an overwrite and preserved the existing file. All 124 direct files and 67 archive members had passed before unlink.
Original content remains recoverable by `restore.py resolve`/`restore` from the archive; direct-path checks require restoration first.
Logical bytes represented: 64,823,224; recorded allocated bytes removed: 65,093,632; free space rose 65,044,480 bytes during unlink.
Original inode and ctime observations remain historical and cannot be recovered after removal.
Durable main commit recorded in receipts: `6de3bb61e7ffd177a443ea049a07eb75aa1aa984`.
