# TASK020 indexed build intermediates: storage addendum

**Publication state:** prepared from verified stage 1; physical removal is HOLD until this addendum is durably published and separately authorized. `stage1-report.md` records the stage 1 snapshot, when all direct source paths were still present. Its status is historical if storage representation later changes.

The frozen original and fix-r1 evidence indices remain unchanged. Their 124 absolute `path` and `resolvedPath` entries identify the original build outputs. `packed-build-targets-map.json` maps each such path, byte count, SHA256, role, and frozen index SHA256 to one of 67 `objects/<sha256>` members in `packed-build-targets.tar.gz`. A mapped path is a **logical historical identifier** after any later removal; the map does not claim a regular file still exists at that path. All original bytes are recoverable from the members. Mode, UID/GID, mtime_ns, and xattrs are recorded for restoration. Original inode and ctime can be observed in the map but cannot be recreated after removal.

The addendum is offline evidence storage. `pack.py` and `restore.py` are evidence tools; no product or runtime Python dependency is introduced. `checksums.json` binds all other files in this folder; its own hash is omitted to avoid a self-reference. Verify it separately when moving or publishing the folder.

## Verify and resolve

Run from this folder, with both frozen evidence indices at the absolute paths recorded in the map:

```sh
python3 restore.py verify-store   # archive, map, index records, all 67 members
python3 restore.py verify-direct  # additionally checks all 124 physical source paths; stage 1 only
python3 restore.py resolve "$ORIGINAL"  # reports member and whether the direct file currently exists
```

For a standalone tar/SHA check of one mapped original (requires `jq`, `tar`, and `sha256sum`):

```sh
set -euo pipefail
ORIGINAL='/workspace/work/session-lifecycle-formal-tests/source/tests/session_lifecycle/target/release/unicode/libunicode.test.a'
MEMBER=$(jq -er --arg p "$ORIGINAL" '.mapping[] | select(.original == $p) | .member' packed-build-targets-map.json)
EXPECTED=$(jq -er --arg p "$ORIGINAL" '.mapping[] | select(.original == $p) | .sha256' packed-build-targets-map.json)
ACTUAL=$(tar -xOf packed-build-targets.tar.gz "$MEMBER" | sha256sum | cut -d ' ' -f 1)
test "$ACTUAL" = "$EXPECTED"
```

`python3 restore.py restore "$ORIGINAL"` restores one *absent* allowlisted path after verifying the archive, map, and frozen indices. It refuses to overwrite any existing path, checks the member bytes and SHA256, requires the target directory and matching UID/GID, and installs atomically. Use it only when direct bytes are required. The tool preserves recorded mode, mtime_ns, and xattrs; inode and ctime necessarily change.
