# Independent scoped source rereview — round 3
Revision: `9286956d1547f9a6ab9c42b8cc8cfc78292ceae9`; prior revision: `d32f9ec08f36222e2759a44cd905ec079c7c98fc`.
Scope: checkout-mode portability and committed-clone removal replay; previous review findings/evidence remain immutable.
SPEC verdict: **PASS (current 26-group migration scope)** — original mode finding resolved; no current-data adoption blocker found.
QUALITY verdict: **PASS (same scope)** — strict archive/full-mode boundaries and preflight deletion checks remain intact; one nonblocking future-input limitation is recorded.
CHECKOUT-MODE: **RESOLVED**. `core.mjs:49` and `pack.mjs:93` compare retained files by regular type, bytes/size/SHA and user-executable bit `0o100`.
Archive header verification, restore chmod, recorded historical modes and present archive-only full-mode checks remain strict; this fix does not require rewriting any original archive.
Replay now correctly allows absent non-inline records missing from Git's index, rejects missing tracked inline records, rejects unknown tracked originals, and checks absent-index paths for present shadows.
SRC-003 (minor/P3, open/nonblocking): `pack.mjs:99` still calls inventory's unconditional `empty group` guard (`:27`) before manifest-backed replay. A future group with zero retained originals cannot replay after its removal commit.
Independent one-file fixture: pack/remove exit 0; commit/fresh clone; `verify R11` exit 0; replay exits 1 with `empty group`. Clone stays clean and bytes remain archived. See `empty-group-replay-result.json`.
This is a safe false rejection, not data loss. Root clarified that generic zero-inline support is outside the concrete migration; the independent full-v1 table confirms all 26 frozen groups have at least one retained original. The observation is preserved, not marked fixed.
Inspected supplied development results: CLI 51/51, operator 13/13, checkout 6/6; retained initial checkout failure documents the index-replay defect. All indexed source/tests/evidence hashes match.
The six checkout cases cover permission normalization, executable changes, strict archive modes, restoration and replay with retained originals; none covers a zero-inline group.
No broad suite reruns, source/main edits, production mutations, repacking, or author self-assessment reads. One bounded synthetic replay probe ran in this review directory.
Final independent execution remains separate. This verdict covers the current migration and guide workflow, does not claim generic zero-inline replay support, and does not invalidate original byte-preservation evidence.
