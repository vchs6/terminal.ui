# Historical frame storage

The nine historical JSON paths recorded in [migration-v2.json](migration-v2.json) now resolve to members of the already published [original evidence archive](../raw-evidence.tar.gz). Their original bytes, byte counts and SHA256 values remain unchanged. The frozen execution indices were not rewritten. These paths describe completed earlier attempts, not the current physical presence of regular files.

[Migration v1](migration-v1.json) covers three interaction frame files; v2 adds six startup frame files. Every direct file and corresponding archived member was compared before removing the duplicate uncompressed representation. All other raw records, original screenshots and the archive remain unchanged. File metadata in the receipts is historical; original inode and ctime cannot be restored.

To inspect or recover a frame, find its `member` and `sha256` in the receipt, extract that exact member from `../raw-evidence.tar.gz`, then compare its SHA256 and byte count. For example, from this directory:

```sh
set -C  # refuse overwriting an existing destination
tar -xzOf ../raw-evidence.tar.gz \
  composition-application-execution/raw/pty-retry3/pty-BQP53p/interactions/frames.json \
  > /tmp/ac021-retry3-frames.json
sha256sum /tmp/ac021-retry3-frames.json
```

The expected digest for that member is `a361e7409823714b4d286996e44262aefc1593e00a3d0391f89d766b88d88f07`. Restore to a historical absolute path only when needed, without overwriting a different existing file. This is offline evidence storage and adds no product dependency or runtime behavior.
