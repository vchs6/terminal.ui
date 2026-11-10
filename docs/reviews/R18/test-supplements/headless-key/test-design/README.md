# Fixed148 headless-key fixture archive

[Original report](key-report.md) and [source-to-copy/hash/omission index](archive-index.json) preserve the fixed test-only facts.

Namespace separation prevents capability/operation cross-shape overwrite. Three cross-shape negatives are rejected;60 legal same-shape repeated keys remain last-value-wins. This legacy design does not reject all duplicates or independently validate every repeated call. No149 product PASS is claimed.

The old fixture RED, fixed fixture selftest and original command records are preserved. [Original self-owned TSV](../../../../../../tests/session_extensions/fixtures/headless-key-collision.tsv) and [fixed control source](../../../../../../tests/session_extensions/key_selftest.mjs) remain in the formal tests with verified SHA256; no duplicate source tree or TSV is copied. Independent review fixed.diff preserves exact changed control source. No S007 WIP files or other author report folders were accessed.
