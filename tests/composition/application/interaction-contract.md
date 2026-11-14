# TASK021 public application fixture (C005)

These are controller-authorized example fixture choices, not new framework APIs
or user-selected UI. Fixed input: e35d407a87ab197537ccc931c143c9927458a75f;
root manifest SHA256 883136757e06ec26152ba9652cfe1f4f6efe7424d0a55e334bad645f3903b02e.
Existing tests/composition/src and verify-files.mjs remain the low-level Frame
suite. This folder adds public application delivery, smoke and real-key tests.
No example source or framework behavior is supplied by these tests.

## Entrypoints and finite smoke

Minimal retains its ordinary `q` quit key (it has no editor). Composition uses F10.
Both examples/minimal and examples/composition are ordinary relative-dependency
CJPM executable projects. `cjpm build` in each; directly run
`target/release/bin/main` (ordinary interactive launch) or that binary `--smoke`.
README in each explains prerequisites, command, keys and limitations. No other
public CLI is required. Unknown arguments, including `--smoke --invalid`, must
return a real nonzero direct-binary exit and a diagnostic. Non-TTY smoke exits
within 15 seconds, returns 0, prints no ESC and never opens /dev/tty.

Smoke performs actual Application.startHeadless/snapshot/toPlainText and checks
its own startup state; it prints each complete frame as follows (no trimmed
rows, a newline after each row):

    BEGIN tasks 80x24
    <24 rows, each 80 display columns>
    END tasks

minimal: one `minimal 16x3` frame then `PASS minimal`.
composition: `tasks 80x24`, `tasks 40x12`, `tasks 16x6`, `logs 80x24`,
`logs 40x12`, `logs 16x6` in that order, then these literal state/result lines:

    STATE tasks ready=2 done=1 visible=3 notes=Check input
    STATE logs total=24 visible=24 query= errorsOnly=false order=oldest
    PASS composition

The smoke frames are literal files in goldens. Smoke is startup/state evidence;
it does not certify real keys, live background execution, focus, paste or resize.

## Layout and initial business data

Composition uses Application's default Auto glyph/color policy, Classic initial
theme. HorizontalMenu labels (including trailing spaces) are `Tasks `, `Logs `,
`Theme `, `Details `, `Disabled ` (disabled), `Quit`. Root Column declares `.viewport(ScrollAxes.Off)` and fills available
viewport: menu height1, body weight1, StatusBar height1. README documents comfortable
minimum 40x12; 16x6 must still use actual size with normal clipping/scrolling.
No viewport-triggered hiding, refused startup or virtual minimum canvas.

Tasks body is horizontal SplitPane with equal-weight Columns and zero gap:
left title `Tasks`, label `Find:`, TextInput height1 (initial empty, initial
focus), Checkbox `Hide done` false, Radio `ID` true, Radio `Name` false,
Button `Run jobs`, Progress width20, phase Text `Idle`, then weighted ScrollView
with rows `01 Ready Parse`, `02 Ready Render`, `03 Done Export`.
Right is the reusable JobPanel: title `Job 01 Parse`, phase `Ready`, label
`Notes`, TextArea height3 initialized `Check input`, Button `Actions`.
The panel owns its view controller, the business model owns shared notes/status.
Task filtering is case-insensitive substring by name; hide-done and sort are
business decisions. Name sort yields Export, Parse, Render; ID restores 01/02/03.
No framework sorting or data deletion. Status: `Tasks | Ready 0/2 | Classic`.

Logs is a different business: no task progress or task sorting side effects.
Its body is an ordinary Column: `Logs`, `Find:`, TextInput height1 (empty),
Checkbox `Errors only` false, Radio `Oldest` true, Radio `Newest` false,
weighted ScrollView of 24 immutable records. Three-digit IDs 001..024, severity
ERROR for multiples of3 and INFO otherwise, message `record NN` (two digits).
Rows are e.g. `001 INFO record 01`, `003 ERROR record 03`. Filter is a
case-insensitive substring across the whole row; errors-only is ANDed; order
is by ID. Footer: `Logs | 24/24 | Classic`. Query `record 03` yields exactly
`003 ERROR record 03`; clear query and errors-only yields 8 records. Newest
then starts 024,021,018. Returning to Tasks preserves task business/editor data.

Additional goldens/modal.json fixes the same panel centered at wide/narrow sizes, including clipped underlying text; shadow-only cells use the existing public `░` glyph with black background under the single-column width policy, with existing `.` fallback when `░` is not one column (no public shadow-glyph override). Goldens record startup at 80x24, 40x12, 16x6. Full rows include trailing spaces;
all frame text is hand-authored from the above layout, not recorded output.
Styles: Classic root default fg/bg; titles bold; explicit Idle yellow,
Ready cyan, Done yellow pending acknowledgement then green; progress cyan;
menu Disabled named bright-black+dim; current editor/menu/control uses Classic
focused cyan+underline, selected Radio inverse. TextArea selected text inverse.
Theme action toggles Classic/Light; Light fg #182028/bg #FFFFFF, focused accent
#005A9C+underline. Explicit status colors retain their names. No forced host
profile. Synthetic PTY below explicitly uses xterm-256color/truecolor; actual
host matrix projects formal Glyph/Color contracts and records profile provenance.

## Ordinary keys and events

Global commands: F1 Tasks, F2 Logs, F3 toggle theme, F4 open JobPanel modal,
F5 start jobs, F6 continue reviewed work, F9 close the owned Details tree, F10 quit. These are supported normalized
key codes f1/f2/f3/f4/f5/f6/f9/f10; no global q/r/c/v/z/y/text interception.
Tab/backtab traverses ordinary focus order; menu Left/Right/Home/End and
Enter/Space operate normally. F1/F2 return to each scene's Find editor.
Tasks focus order after Find: Hide done, ID, Name, Run jobs, task ScrollView,
JobPanel TextArea, Actions, then menu items in ordinary tree traversal.
Logs order after Find: Errors only, Oldest, Newest, log ScrollView.
Scene switches preserve the retained scene's business data; theme/layer actions
must keep mounted editor identity, selection/undo and scroll offsets.

F4 uses NodeRef.openOverlay(JobPanel(...), options: OverlayOptions(mode:
OverlayMode.Modal)), default Center placement; no coordinate calculation.
Modal is width32 height9, rounded border, shadow offset1/1 with black shadow background; modal content retains ordinary Classic colors.
Its content is the SAME JobPanel class used in the ordinary right pane, with
its own editor controller and the same business notes/status. Initial modal
focus is its TextArea. Tab enters Actions; Enter opens PopupMenu, with entries
`Inspect`, `Delete` disabled, `Confirm`. Down skips Delete; Enter on Confirm
opens a nested width24 height4 centered rounded modal containing Text `Confirm?`
and Button `Acknowledge`. Enter acknowledges; close the confirmation then popup;
Escape closes the outer modal and returns exact original focus/selection.
Escape on popup cancels just popup; Escape on confirmation cancels just it.
Modal blocks F1/F2/F4/F5/F6 and underlying editor input. F3, F9 and F10 stay active. F9 closes the owned outer Details handle even from
a nested confirmation, proving descendant closure and original focus return.
Close parent closes descendants; source review verifies ownership through the
ordinary overlay ancestry, not an application-maintained parallel layer stack.

Task work: F5/Run jobs starts a real Cangjie spawn computing two nontrivial
bounded data results from records 1..10000: first sum=50005000, then
sum-of-squares=333383335000. The worker must compute and check the values before
posting them, not assign precomputed progress. Job rows become
`01 Done Parse 50005000` and `02 Done Render 333383335000`; the reused
JobPanel phase becomes `Done 50005000` when the first result arrives. First completion posts through Application.post,
marks job01 Done, progress 1/2, footer `Tasks | Review 1/2 | Classic`, and phase `Waiting for review: Parse complete`.
Run is disabled while active. This is a business review pause, not sleep or
mock progress. F6 resumes a second real calculation; completion posts job02 Done,
progress2/2, phase `Done` in yellow and footer `Tasks | Done 2/2 | Classic`.
Nested Acknowledge changes only phase foreground to green, retaining `Done`.
First long phase to `Done` must clear stale tail. Under an open modal F6 is
blocked, but work already started continues and shared status changes. No UI
thread Future.get/sleep, shell child, fake static timer or manual flush.

## Independent ordinary-binary execution

`node tests/composition/application/pty.mjs` launches the actual composition
binary in util-linux script --return, observes ANSI cells via the existing
colors/pty.mjs Screen oracle, sends actual input and resizes one real PTY with
tests/support/terminal_frames.mjs. This is explicitly a synthetic PTY profile,
not XTerm/VTE/VT/SSH certification. Waits poll completed visible predicates with
a deadline; no sleep establishes background success. Raw bytes, input events,
frames, direct exit and exact before/after termios are archived even on failure.
The --smoke and invalid-argument tests call the binary directly with pipes.

Required TTY sequence: startup wide; type `qrcvzy`, verify still editing; select
all/paste `Parse` (only Parse remains); undo restores former query; clear;
checkbox/radio filter and sort; type notes including multiline/Unicode paste;
selection+F3+replace+undo proves state preservation; scroll log list; filter and
reverse logs; F4 nested popup disabled skip/cancel/confirm and focus return;
F5 observable review half-progress; F6 followed immediately F4, observe latest Done
with the shared modal open, accepting completion before or after opening, then
close to newest underlying data; acknowledge color-only;
resize80x24→40x12→16x6→80x24, check literal startup frames in a fresh session
and preserve edited/business state in the live session; F10 exits0, modes restore.

The immediate F6/F4 sequence does not prove completion occurred after modal
opening. The modal note edit demonstrates a shared business update while the
layer is open and close reveals latest underlying data. Existing accepted C112
`tests/interaction_c/src/surface_grids.cj` G04 and
`tests/interaction_c/src/pending_and_identity.cj` N02 finite covered-update
proofs are unchanged at the fixed base and reused, not cold-rerun here.

Manual actual-host run also tests minimum dimensions, menu navigation on the
horizontal menu, every disabled item, ancestor closure, editor selection/undo,
scroll offset before/after F3 and modal closure, and no input leakage. Capture
original PNG, raw, UTC, host version/config/profile source, binary/source hashes.
No fabricated screenshots or regenerated expected grids are acceptable.

## Publicness/construction review (independent reviewer gate)

Check full source of both projects, README and public construct docs: blocks,
chains, Observable/@State/@Bind and callbacks use actual signatures. Entry file
only wires and runs; each class/struct/enum/interface in one lower-case file;
business model, controller and reusable JobPanel separated by responsibility.
Show same JobPanel type at ordinary+overlay call sites; shared Observable data,
independent controllers; centered OverlayOptions, standard menu/input defaults.
Review no private RuntimeNode/Node/Frame/Canvas/ANSI/flush/manual invalidation,
no application-specific core change, no shell/PTY/emulator/GUI dependency, no
absolute build-cache dependency. Check real worker calculation/post/rejected
post/stop lifecycle, bounded work and no stale-generation callbacks on restart.
Text snapshots in smoke may use Frame only as returned by Application.snapshot.
Review convenience qualitatively (boilerplate/repetition/ownership/reuse), no
invented line-count budget or grep-only proof. Construction acceptance remains
pending until public consumer build, fixed-diff review and actual runtime pass.

## Reproduction environment and evidence scope

Use SDK1.2.0 on every Cangjie build/run shell: source
`/workspace/work/validation/sdk/cangjie/envsetup.sh`; export
`CANGJIE_STDX_PATH=/workspace/work/linux-build-recon/stdx-env` and
`CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip`.
For this isolated test workspace, ignored per-project cangjie-repo.toml should
point repository.cache.path to `/workspace/work/viewport-tests/cache` and
repository.home.registry to `https://pkg.cangjie-lang.cn/registry`. Do not copy
SDK/cache/CJP or use a relay/global config. Then run
`bash tests/composition/run.sh` (retains all old Frame tests, then application).
Focused application entry: `bash tests/composition/application/run.sh`.
Infrastructure-only: `node tests/composition/application/oracle-selftest.mjs`.
Set CJTUI_APPLICATION_ARTIFACTS to an owned evidence directory to preserve runs.

This author freezes tests only. Initial delivery failure stops before any CJPM
build. All application compile/smoke/TTY/background/API-usability outcomes remain
pending until product source exists and independent execution/review occurs.
Old assertions and existing APIs are unchanged; their accepted evidence is
reused under AGENTS11.1, not cold-built for a new task label. Actual-host PNG,
C008 cross-host coverage and release/M2/020-parent closure are outside this
preimplementation evidence; no synthetic PTY result may stand in for them.
