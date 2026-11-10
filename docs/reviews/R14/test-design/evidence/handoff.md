# TASK081 frozen test handoff

Contract: 7a33ddc7fb93da3f30007e49538cb00821a2d81b, design.md/tasks.md.
Final test-only commit: 6d3ae1353f32f7b191bae65257081ea6fca47703.
Initial core commit: e6b3229a947ed0143d91616a8bd158e0e72474cd.
Independent clone: /workspace/work/rich-text-tests/source, branch task081-tests.

Apply both commits in order or consume the test-only.patch. All changes are limited
to tests/rich-text. No run-slice mutation; integration owner should append that case
after dynamic-test wiring is fixed. Reproduce with SDK1.2.0 sourced, own ignored
registry/cache config, then tests/rich-text/run.sh (normal build, direct binary).

Evidence:
- baseline-build.*: normal original product build exit0.
- core-red.*: first public core missing-API RED, exit1.
- freeze-red.*: all final consumer source, normal real product build exit1; compiler
  reports missing public types/APIs, not an assertion pass.
- frozen-tests.sha256: exact final consumer source hashes; verified after commit.
- syntax-only-freeze.*: compile-only declaration scratch, exit0, never executed;
  placeholder unused warnings retained. This is syntax evidence only, not product
  behavior or public-runtime integration evidence.
- search-docs.txt/environment.txt: actual CangjieSkill queries and SDK versions.
- frozen-source.txt/test-only.patch: fixed test commit, scope and patch checksum.

All expected spans, cells, styles, issue kinds and byte offsets were hand-authored
from the contract. DecodedStream only concatenates outputs and compares with these
literals. Successful streams enumerate all small-stream two-block splits, bytewise
feeds and empty blocks. InvalidUtf8 streams assert code+closed state and make no
claim of prefix-batch equivalence. InputTooLarge and asymptotic memory bounds are
explicitly not claimed as directly executable public-consumer checks. Product
implementation and independently executed GREEN remain downstream work.
