# C003 visible snapshot public consumer

These tests use the frozen C003/G002/G007/G009/T014/T015 and overlay/viewport
contracts. Actual TASK010.a author validation compiled and executed this public
consumer with SDK 1.2.0 at accepted base `ecbf0999a392e5298e6e5bd15bd796dd9d40e582`.
All 29 unchanged manual grids and actual file checks passed. This author result
does not replace independent review, execution, or AC010 acceptance.

The first actual run preserved a fixture failure: the original helper passed
`takeFocus:false` for Modal, forbidden by the accepted overlay contract. The
helper now enables focus for Modal only; literal grids/styles are unchanged.
Original preparation is commit `54f31bc386f0990f9b796d1b1ce8b5f85689a131`.
Raw history, exact inputs, binary/file hashes and results are indexed in
`/workspace/work/visible-snapshot-formal-tests/evidence/index.json`.

The consumer is ordinary CJPM source with `cjtui = { path = "../.." }`, using only
public API. Its manifest follows the accepted `tests/interaction_c/cjpm.toml`
shape and SDK 1.2.0; no SDK/cache/source archive is copied. Each Cangjie entity
has its own file. No fake Frame, renderer, runtime, public API, file glyph
parameter, or product implementation is supplied.

`Application.startHeadless` plus the existing two-argument/default and explicit
`snapshot(..., glyphMode: ...)` calls exercise stable committed tree/layers and
viewport. `save` checks every Cell field, exact literal full plaintext, actual
UTF-8 file reads, and writes default ANSI plus explicit monochrome ANSI. Old
Frame objects are written again after updates, policy swaps, resize, or close.
Diagnostics must remain absent and captured stdout must contain no ESC.

## Manually counted grids

Coordinates are zero-based display columns. No fixture comes from product output.
`grid` only makes one-column expectation cells; explicit `mark` installs the
fixed combining/wide clusters. It does not reimplement Unicode layout. The
separate ANSI reader has a finite reviewed fixture vocabulary: ASCII, é, e+0301,
中/界/👩‍💻, ellipsis, rounded border glyphs, and shade. Their widths are fixed by
the accepted narrow ambiguous-width contract (1, 1, 2/2/2, 1, 1, 1).

| Fixture group | Hand derivation and complete expectations |
| --- | --- |
| glyph (4×2) | `éBCDE` consumes five columns: Unicode/default/Auto truncate to `éBC…`; Ascii reserves three dots, producing `é...`. Row two is `中é `, width 2+1+1, in every mode. After shortening, `Q   ` clears the old suffix. |
| layers (8×3) | Rich row `é中👩‍💻ABC` is 1+2+2+3 columns; é alone is RGB(17,34,51), underline. Centered 3×1 nonmodal begins (2,1), writes X at x2 and a bold blue-background space at x3; untouched x4 preserves m. Nested centered modal writes `M  ` at x2..4 with full underline+inverse style. Covered base changes `ijklmnop`→`IJKLMNOP`; parent closure reveals the newest row and closes its modal child. |
| viewport (4×1) | Chrome # and ! surrounds a two-column viewport of `A界B`: offsets 0/1/2 give `#A !`, `#界!`, `# B!`. A centered transparent 2×1 layer writes X at x1: replacing the wide lead clears its continuation (`#X !`); scrolling underneath gives `#XB!`; close reveals current `# B!`. Shortening to B clamps and clears (`#B !`). |
| decoration (8×5, 10×5) | Centered 4×3 rounded box begins (2,1), content 界 at (3,2), default opaque space/border style. Shadow offset (1,1) occupies x6 y2..3 and x3..6 y4, dim only. At width10 box moves right by one; old ranges reveal base. Width3 box begins (2,1), content width1 clips 界 completely; shadow becomes x5 y2..3 and x3..5 y4. Close restores all five current base rows. |
| theme (3×1) | Parsed theme has only global background #112233. `x  ` has underline+inverse on x alone under root seed fill, and on all three cells with an explicit local background. This checks T015 rather than accidentally inheriting a preset. |
| zero axes | 0×2 plaintext is one LF, not empty; ANSI is empty. 3×0 and 0×0 plaintext/ANSI are empty. |

Exact rows, style coordinates and dimensions are independently literal in
`manual_fixtures.mjs`; Cangjie expectations are inline with each scene. Every
lead/continuation/blank carries a full Style comparison and `isTransparent=false`.
The glyph case deliberately starts Application with device Ascii while the
default offline call still generates Unicode. No new offline border-transcoding
promise is tested: decoration fixtures use the accepted logical Unicode border.

## Independent ANSI consumption

`ansi_oracle.mjs` starts each file from a new default blank grid and interprets
only standard CUP/SGR plus the finite fixture glyphs. It checks complete cell
coverage, final grid/styles/widths/continuations, initial/final style reset, no
device-mode/erase controls, and no dependence on a previous device frame.
It never imports a product parser, calls product code, or treats exported cells
as an expected result. Monochrome removes colors while retaining attributes and
business Unicode per the existing offline color contract. Other unchanged color
mode mapping remains covered by R10 rather than being copied into this suite.

`oracle_selftest.mjs` uses manually written standard ANSI bytes and negative
controls (missing blanks, malformed RGB/CUP, missing reset, mode controls,
overwide glyph, incorrect style). A tool-selftest PASS proves only that tool;
it is neither TASK010 RED/GREEN nor product evidence.

## Real file errors and execution

Both public writers must throw actual SDK exceptions for directory, missing
parent, embedded NUL and an unprivileged unwritable directory. NUL must not
create a prefix-truncated filename. `/dev/full` adds a real post-open write
failure. `short_write_launcher.c` sets RLIMIT_FSIZE=32, ignores SIGXFSZ and execs
the same consumer in short-write mode: a normal 256-column frame targets regular
files, each must accept an actual 32-byte prefix and throw. It does not intercept
write or add an SDK/product hook. Exception types/messages are logged from the
actual runtime; atomic replacement is not required. If the SDK swallows a
partial write, the test fails; it does not synthesize success or relabel it.

In the root-frozen accepted product+test source checkout:

```sh
# Use the actual SDK1.2/stdx/UCD/registry environment frozen by root, not an old relay.
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CANGJIE_STDX_PATH=/workspace/work/linux-build-recon/stdx-env
tests/visible_snapshot/run.sh
```

The entry performs normal `cjpm build`, directly executes the public consumer
binary, compiles/runs the small resource-limit launcher, and independently checks
the resulting files. Snapshot targets are preseeded with a longer dummy byte
sequence so exact file checks also detect missing truncation. `set -o pipefail` preserves direct binary failures through
tee. Use an unprivileged Linux user with `/dev/full`; otherwise the command
reports infrastructure failure. It creates a fresh artifact directory by default;
if overriding `CJTUI_VISIBLE_SNAPSHOT_FILES`, supply a new empty directory.
The recorded normal public-consumer build is formal TASK010.a author evidence;
no bundle, separate clean-source consumer, real host or screenshot is claimed.

Tool-only checks (independent from product execution):

```sh
node tests/visible_snapshot/oracle_selftest.mjs
bash -n tests/visible_snapshot/run.sh
git diff --cached --check
```

Contract/source links at preparation base `51529b7f5bce9c639d54876c378b54aa1cd3aaf2`:
`openspec/changes/complete-linux-integration/{tasks,design}.md` (C003, original010),
`docs/requirements.md` REQ005.5/.6 and `docs/acceptance.md` AC010;
`openspec/changes/implement-linux-vt-glyph-fallback/design.md` G002/G007/G009;
`openspec/changes/implement-theme-styles/design.md` T014/T015;
`openspec/changes/implement-public-interaction/design.md` B/C;
`src/{application,frame,cell,overlay_options,overlay_handle,paint_context}.cj`;
`tests/{interaction_b,interaction_c,glyphs,composition}/` for accepted public
construction, file and headless helper shapes. These are source references,
not a substitute for independent final010 review/execution/acceptance.
