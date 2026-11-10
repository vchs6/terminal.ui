# Frame implementation preparation

- Baseline: `31a7017e6bb522e3f4bcabd2f01abe1d81ea2170`, independent clone at `repo`.
- SDK: `/workspace/work/validation/sdk/cangjie/envsetup.sh`, `cjc --version` reports 1.2.0 x86_64 Linux.
- Independent registry cache: `cache`, seeded from validation cache; ignored repository configuration uses relay `127.0.0.1:18973`. Native build uses UCD archive `/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip` and a private archive copy.
- Reviewed main repository AGENTS.md and current design/tasks, and baseline `src/cell.cj` and `src/frame.cj`.
- Existing `Cell`, `blankCell`, `Frame.clearAt`, and clipped drawing are the existing single kernel to extend. Geometry uses `signedAdd`; export shares existing ANSI encoding. Wide-fragment copying requires styled blanks, target cluster clearing, and a source snapshot for overlapping self-composition. Zero-area operations need early exits and bounded zero-width text export.
- Preparation only: no product or formal test changes. Await final contract SHA and frozen test-only SHA; execute the independent consumer to obtain actual missing-API RED before implementation.
- Baseline build raw output: `baseline-build.log`; `cjpm build` exited 0.
- Final contract fetched and read: `458a4b684afe8bb9a8c1dfbe050f368bcc2fc123`; `git diff 31a7017 <contract> -- src` empty. Checkout stays on product baseline until frozen independent test arrives.

## Implementation and verification

- Test input: core `79f7582d4988692d2b4c4c56dd4cace32dd8f300`, plus test-only `afaced158050e8954f75de43a122b81f4c8b3107` (locally cherry-picked as `67191f0`).
- Real RED on baseline: `tests/composition/run.sh` exited 1, missing `isTransparent`, `transparent` constructor argument and `composite` among other new API; `red.stdout`, `red.stderr`, `red.exit`. Initial environment attempt failed to resolve registry before adding private config in consumer; this was an environment failure and is not claimed as RED.
- Product-only commit: `7f9c57eaf65ab02ce04804965f50a644149742f1`. The three product files are `src/cell.cj`, `src/frame.cj`, and `docs/product/README.md`.
- Full frozen composition matrix: `bash tests/composition/run.sh`, exit 0; `final-matrix.stdout`, `final-matrix.stderr`, `final-matrix.exit`. Includes independently specified file bytes and error paths.
- An initially started `tests/run-slice.sh all` was interrupted on scope direction; partial `all.stdout`/`all.stderr` are not a full-suite result. Contract, coordinates, colors, layout and decoration are run separately with actual exit files and raw streams in this directory.
- All five scoped regression commands exited 0: `contract`, `coordinates`, `colors`, `layout`, `decoration`. Files `<suite>.stdout`, `<suite>.stderr`, and `<suite>.exit` preserve actual output and exit status. `git diff --check HEAD^ HEAD` exited 0. Independent review and integration remain with the corresponding roles.

## F003 clarification and scoped fix

- Contract clarification `277841d`, independent test `0395ed970a91155ba0453cefdb3b37bf6cb3ac5d`, locally cherry-picked as `b8c6542`.
- Before fix `bash tests/composition/run.sh` exited 1: transparent hole flags were lost by copy/resized and XBZ became X-space-Z. Raw `f003-red.{stdout,stderr,exit}`.
- Root cause: both copy and resized called composite, which correctly skips transparent cells for overlay but did not copy their metadata to opaque-default result. Shared transfer now selects the operation's transparency semantics; copy destination retains original default blank for out-of-source regions.
- Product-only fix `4a99a5306bccf2d46f78f873ee6e782fe61135bf`; full frozen composition matrix exited 0. Raw `f003-green.{stdout,stderr,exit}`. Earlier five legacy regressions are not repeated because the change is scoped to this shared copy/composition path, covered by the full frozen matrix; independent scoped review remains pending.
