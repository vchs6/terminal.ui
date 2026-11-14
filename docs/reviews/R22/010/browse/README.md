# Reading original TASK010 evidence

Reports, indexes, selected replay receipts and both PNGs are original byte-for-byte copies. Role prefixes distinguish test-author development proof, product documentation, independent review, independent execution and (when published) independent acceptance. The canonical OpenSpec task card owns current activity status; status strings inside originals remain historical.

The complete allowed regular evidence is in [../raw-evidence.tar.gz](../raw-evidence.tar.gz). [../raw-evidence.manifest.jsonl](../raw-evidence.manifest.jsonl) maps exact original absolute paths to role/member, byte count, SHA256 and file/libmagic description. [../archive-index.json](../archive-index.json) binds every browsing copy and exclusion. Tar/gzip metadata is deterministic; source bytes are unchanged, streamed without staging another raw tree.

Absolute paths inside original reports/JSON remain provenance. After checkout, resolve an original reference by exact `original` lookup, then read the corresponding relative `member`. From `docs/reviews/R22/010`:

```sh
original=/workspace/work/visible-snapshot-execution/raw/view-xterm/identity.json
member=$(jq -r --arg original "$original" 'select(.original == $original) | .member' raw-evidence.manifest.jsonl)
tar -xOzf raw-evidence.tar.gz "$member"
```

Only allowlisted regular evidence is included. Binaries (including actual ELF short-write-launcher files in raw/files), CJP/archive/object/bitcode/shared-library files, SDK/cache/build inputs, external inputs and symlinks are excluded without dereferencing. Original indexes retain binary/source/toolchain references as provenance; absence from the manifest makes no portability claim. Raw ANSI `.ansi`/`.bin` data and genuine 32-byte short-write receipts are valid evidence.

Original CLI03 failure and corrected CLI04 remain separate. Each screenshot is an unmodified original capture of a 3×1 file viewed at 80×25, with its source bytes, host identity, dimensions, command and exact replay trace retained under the same role. They establish only that file-view case, not a whole-framework GUI/VT matrix. The known T087 `themes/light.toml` checker failure and full Linux/release gates remain open.
