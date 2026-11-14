# Independent mode-fix affected execution: PASS

Fixed implementation HEAD `9286956d1547f9a6ab9c42b8cc8cfc78292ceae9` passed **70/70 cases**: original CLI contract 51/51, corrected operator v2 13/13, and checkout portability 6/6. Each sealed suite ran exactly once, exited 0, and emitted empty stderr. Exact absolute argv, timestamps, exit statuses, stdout/stderr and their SHA256 values are in raw/.

The unchanged preserved real-data R1 source fixture (retained original mode 0600) and fresh umask022 clone (mode 0644) both verify with the fixed CLI, exit 0 and empty stderr. Their bytes and filesystem modes were not changed. Original failure proof is preserved unchanged.

Before/after snapshots confirm the source HEAD/status, all source/module/test/index hashes, previous sealed portability evidence bindings, original real-fixture modes, main HEAD and production catalog hash remained identical. No product/source/test edits, main Git changes, chmod, production archive changes, builds, repeated migration/restoration, or subagents were performed.

The checkout cases cover normalized 0600/0700→0644/0755 inline permissions, executable classification changes rejected in both directions, strict full-mode archive checks, full original mode restoration plus overwrite refusal, removal replay on normalized clones, and strict present archive-only mode preflight before any deletion.

This establishes affected test and bounded real-fixture acceptance for the fixed source. It does not replace independent source review or the queued full fresh-main-clone acceptance after root integration.
