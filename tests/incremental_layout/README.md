# Incremental layout Unit A public consumers (TASK-123)

Two independent ordinary CJPM executables depend on the public `cjtui` package.
`baseline` uses only existing M1 API and has seven behavior cases. `statistics`
has two further cases and directly reads the three planned readonly `Int64`
members. The contract expects all seven baseline cases to pass. On frozen M1
d654ae59da4749a43c946e1541c21b08e9b3ffba, statistics must fail compilation because `arranges`,
`cellWrites`, and `frameAllocatedCells` do not exist. Do not hide those reads
behind a runtime branch. After Unit A implementation both consumers must pass.

Actual author run on this fixed M1: cases 1–5 and 7 pass; case 6 fails after
a different-width reference render replaces persistent Canvas draw dependencies.
The literal assertion is retained as Unit A's M004 acceptance obligation.
The parent evidence index records the direct exit status and exact diagnostics.

From the repository root, in each build/runtime shell:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CANGJIE_STDX_PATH=/workspace/work/linux-build-recon/stdx-env
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
bash tests/incremental_layout/run.sh baseline
bash tests/incremental_layout/run.sh statistics
```

The SDK is 1.2.0. The root and each consumer need an ignored
`cangjie-repo.toml` configured for the existing dependency cache:

```toml
[repository.cache]
path = "/workspace/work/viewport-tests/cache"
[repository.home]
registry = "https://pkg.cangjie-lang.cn/registry"
```

For separated evidence, run `cjpm build` in the consumer, then directly execute
`target/release/bin/main` in that consumer. Retain the
actual direct process exit status. No test macro, private API, product switch,
terminal session, benchmark, or public RuntimeStats constructor is used.

## Hand-oracle basis and breaks caught

| Case | Literal derivation / observable break |
| --- | --- |
| 1 | Width 11 minus left/right 1/2 and two gaps leaves 6; weights 1:2:1 allocate 2/3/1 by declaration-order tied remainder. Full raw Style values check inheritance and explicit override. |
| 2 | Width 7 minus left/right 1/2 gives wrap width 4. Six graphemes need two rows plus top/bottom 1/1, so Z starts at y=4. One grapheme needs one row, moving Z to y=3. |
| 3 | Height 10, two weights retain finite 5/5 while natural demands are 1/3. Growing the first demand to 8 triggers natural extent 11 with 8/3 allocation. Offset 1 exposes seven A rows and three B rows. Reference export at another size must leave committed geometry intact; shrinking clamps offset to zero. |
| 4 | Three one-row children in a two-row explicit viewport have maximum offset 1; growing to height 3 clamps it to zero. |
| 5 | A three-node Column produces literal text before/after shortening. Detached render has no lifecycle effects/ref. Repeated mounted full render counts all three nodes without remount/build/duplicate children, preserves pending target work and saved snapshot independence. |
| 6 | Width 4 Row reserves one cell for Z, leaving Canvas width 3; 中/文 use lead width 2 and an empty width-0 continuation, with all raw Style fields checked. Width-2 export instead leaves Canvas width 1 and reads N. Its different draw dependency must not replace persistent wide-text or independent measure subscriptions, or publish its caret. |
| 7 | Unicode ellipsis occupies one of five columns: abcd…. ASCII marker occupies three: ab.... Unicode→ASCII→Unicode stays on one session; paired references use matching policy. |
| 8 | A 3×2 target needs at least six successfully allocated/initialized Cell slots, including first generation. External saved-snapshot edits/copy and unrelated Frames have no Application ownership. Dispose retains cumulatives and restart resets generation counters. |
| 9 | Full mounted reference of a three-node Row executes measure/arrange/paint for all nodes, generates one frame, and allocates/initializes at least its four target cells. Stats snapshots remain independent and binding stabilization leaves later target work available. |

Each paired frame compares dimensions and every Cell's grapheme, width,
continuation, full raw Style, and transparency. Literal expectations do not
come from captured output or a second renderer. Deterministic synchronous
mutations fix the business epoch for each pair. Count bounds come from node
or grid size, not time/performance targets. Exact internal pass, temporary
buffer, or COW counts are deliberately unspecified; generation/return-snapshot
cost is cumulative under M003, and later caller work has no owner.

Authority: incremental-rendering tasks Global Constraints and A/123–127,
design §§3/9/10 and final M001–M004/M009/M010, Runtime R004/R008, frozen Canvas
and viewport I001/I009. This is execution of the approved Unit A test contract.
Product code, B/C/D/E behavior/performance implementation, full-suite repeat,
and final independent execution/acceptance are outside this test-author role.
