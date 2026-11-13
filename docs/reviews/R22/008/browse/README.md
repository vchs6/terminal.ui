# Reading the original TASK008 evidence

This directory contains selected original reports, indexes and receipts, copied without changing their bytes. Its role directory names distinguish developer proofs, independent source review, independent execution and the bounded fixture limitation. Original status wording remains historical evidence; the canonical task card owns current acceptance status.

The complete original regular evidence is in [`../raw-evidence.tar.gz`](../raw-evidence.tar.gz). [`../raw-evidence.manifest.jsonl`](../raw-evidence.manifest.jsonl) maps each original absolute path to its relative tar member, role, exact byte count, SHA256 and file/libmagic description. [`../archive-index.json`](../archive-index.json) binds the archive, manifest and individual browsing copies. The archive has deterministic metadata; original contents are unchanged.

Absolute paths inside copied JSON and reports describe the original role workspaces. They are preserved provenance references, not repository-relative links or a promise that those workspaces exist on another machine. To resolve an evidence reference after checkout, look up its exact `original` value in the manifest and read its `member` from the tar. For example, from `docs/reviews/R22/008`:

```sh
original=/workspace/work/output-recovery-execution/raw/run/normal-caret/check.json
member=$(jq -r --arg original "$original" 'select(.original == $original) | .member' raw-evidence.manifest.jsonl)
tar -xOzf raw-evidence.tar.gz "$member"
```

The manifest contains archived regular evidence only. Some original indexes also describe binaries, SDK/cache inputs, source files or historical references outside the selected evidence roots; those are deliberately not archived. Absence of such a reference from the manifest means the original reference was retained for provenance, without a copied artifact or portability claim. No executable binary, build input, external symlink, SDK or cache is bundled. `.bin` members are raw ANSI transaction receipts.

Original RED and failed build attempts remain visible. The fixture supplement records an unmet fixture precondition, not an adjudicated product failure or a positive runtime test. The product author's successful run remains developer proof; the independent execution report and receipts have their own role prefix. No current actual GUI/host image, complete M1, TASK020/041, release TASK023 or Linux TASK024 acceptance is established by this archive. The existing `themes/light.toml` archive-boundary checker failure stays visible for T087.
