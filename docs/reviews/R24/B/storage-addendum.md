# Storage addendum: historical runtime witnesses

Earlier accepted runtime executables were migrated to local lossless gzip witnesses to recover workspace space. Original sealed indices/reports and the old public Unit A proof are unchanged. Their absolute ELF paths now identify historical logical artifacts; this addendum records the later storage mapping. Generated binaries were already excluded from compact public proof.

| Local receipt | Index SHA-256 | Witnesses |
| --- | --- | --- |
| `validation/accepted-unit-a-elf-witnesses-20261114/index.json` | `03607651ee03e17ca6368a046ecb086dc8c6f5eae26494c997c1ebe4ca311cbf` | 6 |
| `validation/ended-runtime-witnesses-20261114/index.json` | `9dc4c45f38c6fdae59ed2628128cff4c2b47eff27ad70777804b6b8623ae5a07` | 4 |
| `validation/ended-more-runtime-witnesses-20261114/index.json` | `7dac4803bfde36b1dacaf9e1c26b625b0860767e1425ae1bcfa627fdefb66510` | 3 |

Each receipt's original `index.json`, `progress.json` and `report.md` is retained as a small raw member under `work/validation/<receipt>/`. The public gzip manifest also retains every mapping's original logical path, SHA-256, byte count/mode, compressed witness path/SHA-256/byte count and source-index binding. Exact gzip ELF payloads and large invariant inventories remain local and are explicitly excluded; neither this addendum nor the archive claims to publish them.

The B128 RED executable has original SHA-256 `2aab266d5abfe9f0de2e34b1629b2504b470bfec2c762d1a935e49e8539b41db`, 19,136,384 bytes, mode 0700. Its local witness is `validation/ended-more-runtime-witnesses-20261114/2aab266d5abfe9f0de2e34b1629b2504b470bfec2c762d1a935e49e8539b41db.gz`, 5,535,305 bytes, compressed SHA-256 `35a078a2abdfc1b1925af3610c2bd1839409b65b17fbca8d22f6de54088f046f`. This preserves the original historical failure, not a new execution.

Ordinary reconstruction uses the recorded fixed source/tests/dependencies and build commands. Local exact restoration follows the receipt's restore procedure and verifies original payload SHA/size/mode; it was not performed for publication. Developer compiler-object cleanup covered only rebuildable intermediates and preserved pins. No authority was deleted or rewritten by this publication.
