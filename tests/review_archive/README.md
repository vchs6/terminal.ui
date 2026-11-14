# Review archive contract tests

Run from the repository root with Node.js and GNU tar/Git installed:

```sh
node tests/review_archive/archive-contract.mjs scripts/review-archive.mjs
node tests/review_archive/operator-contract-v2.mjs scripts/review-archive-pack.mjs
node tests/review_archive/checkout-contract.mjs scripts/review-archive.mjs scripts/review-archive-pack.mjs
```

The CLI cases use independent tiny archive fixtures. Operator cases use disposable Git repositories with literal bytes and exercise packing, retained originals, corruption barriers, symlink refusal, restart and a fresh checkout. These tests do not read or migrate production review data. Historical failed tests and fixed input hashes are preserved in the migration audit archive.
