# Linux first-slice independent tests (TASK-048)

Frozen input: `openspec/changes/implement-linux-first-slice/design.md` at
`09f3e513cd62fb16ae85633c11ee2d3e15bb7d52`; all expected results come from that contract.
This is execution work, scoped to independent consumers and test facilities. There was
no product implementation at the input revision. No prior implementation is replaced.

Source Cangjie SDK **1.2.0** `envsetup.sh`, then from the repository root run:

```sh
./tests/run-slice.sh native-smoke # TASK-049 only: public Unicode adapters
./tests/run-slice.sh native-session # C bridge owner/setup-signal regressions
./tests/run-slice.sh contract     # Frame/style/components, no terminal required
./tests/run-slice.sh coordinates  # Int64 coordinate extrema, no terminal required
./tests/run-slice.sh integration  # build external application, then actual Linux PTYs
./tests/run-slice.sh all
```

Each project is an ordinary external CJPM executable depending on `cjtui` by relative
root path. No private imports, embedded product logic, test hooks, product stubs, or
framework test runner are used. Failed assertions throw and exit nonzero. Compiler or
linker failure is a failing run, never a test pass. Consumers require the product's
normal build hook; they must not be given ad hoc FFI flags to rescue product packaging.
Every executable consumer entry uses `cjpm build` then directly runs the produced
binary, so a nonzero assertion exit reaches the caller. SDK 1.2.0 `cjpm run` itself
can return zero after a failing consumer; its wrapper status is not sufficient evidence.

If the environment uses an existing official offline cache, create an **untracked**
`cangjie-repo.toml` in each consumer directory (including `tests/integration/fixture`):

```toml
[repository.cache]
path = "/absolute/path/to/existing/cache"
[repository.home]
registry = "https://pkg.cangjie-lang.cn/registry"
```

Use the cache read-only; never patch its sources or native artifacts. SDK installation,
cache paths and temporary syntax-only stubs are environment inputs, not repository
content or product dependencies.

## Coverage

| Consumer | Contract expectations |
| --- | --- |
| native-smoke | Empty input; CJK; combining EGC; ZWJ emoji/flag segmentation and columns; ambiguous-width option |
| contract / Frame | Negative/zero dimensions, out-of-range cell reads, EGC cells, wide continuations, overwrite either half, left/right clipping, out-of-area writes, zero-width clusters, original-x LF/CRLF |
| contract / input | Every C0 other than LF/CR, every C1, lone CR, CSI/OSC/ESC rejection, component text rejection |
| contract / snapshot | Full-column plain spaces and LF structure, no extra LF/ESC; ANSI reset/absolute rows/final reset, no newline scrolling; style-only overwrite affects ANSI |
| contract / construction | Text/Row/Column chains, if/for/custom function, inherited styles/explicit override, multiline root, actual-width clipping, clean context after nested construction exception |
| coordinate-boundary | Frame(1, 1) put at Int64.Max and Int64.Min x clips without exception and leaves the frame unchanged |
| integration | Actual external application q/resize exit; Ctrl-C, SIGINT, SIGTERM cancellation; callback exception reporting; exact termios restoration; idle no-update; resize repaint clipped to actual width; non-TTY no ESC |

`tests/integration/pty.mjs` needs Node and util-linux `script`/`stty` on Linux.
Those are test facilities only. `script` allocates a real PTY. The wrapper records
termios before/after the actual executable, without restoring it on the application's
behalf. Timeouts fail and kill test processes. A SIGKILL used for timeout cleanup is
never considered successful cancellation. No Python or node-pty dependency is needed.

The fixture uses only `Application`, `Column`, `Row`, `Text`, and `onKey`. Key `e`
throws a callback exception; `q` stops. The final line makes resize clipping observable.
To rerun the same PTY harness against a compatible built executable directly:

```sh
node tests/integration/pty.mjs /absolute/path/to/executable
```

A different executable must supply the fixture's three text lines and q/e handlers.
The ordinary product minimal example should additionally be built/run by TASK-052;
this external fixture verifies the public API without depending on example internals.

Input cancellation regressions added against product revision
`2794136e45aee98300f4b16456dfa6b605cfdf74` follow the same design contract:
default Ctrl-C exits, unknown control sequences are bounded and ignored, and UTF-8
bytes cannot become separate text characters. `osc-ctrl-c` sends the unterminated OSC
prefix `ESC ] 0 ; xyzxyz`; `utf8-ctrl-c` sends only the UTF-8 lead byte `0xc2`.
Each waits briefly before sending raw Ctrl-C (`0x03`), requires normal exit, and compares
the exact saved/restored termios values. No OSC terminator, UTF-8 continuation, external
signal, or q key rescues these cases. A timeout is a failure; SIGKILL is cleanup only.
Both run by default. To collect separate regression logs after building the fixture:

```sh
node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main osc-ctrl-c
node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main utf8-ctrl-c
```

Further public-input regressions use an opt-in event recorder in the external
fixture (`CJTUI_TEST_EVENTS=1`, set only by the two corresponding harness modes).
The recorder prints the actual public `KeyEvent.code` and `.text`; it does not
decode input or emulate the product. In this mode q still stops, while e is recorded
instead of triggering the ordinary exception scenario. With recording disabled,
all original fixture behavior is unchanged.

`utf8-fragmented` writes the three UTF-8 bytes of 中 in separate writes, each 160ms
apart, then q. The exact callback event list must be text/中 followed by text/q.
`sos-ignore` writes `ESC X secret ESC \\` then q; its callback event list must contain
only text/q, with no key event fabricated from the unknown SOS control or payload.
Both require normal exit and exact termios restoration, and run in the default suite.
Run either independently using the final argument:

```sh
node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main utf8-fragmented
node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main sos-ignore
```

`sos-escape-utf8` applies the same no-fabricated-events assertion to the exact bytes
`1b581be4b89c7365637265741b5c` (`ESC X ESC 东secret ESC \\`), then separately sends q.
An ESC followed by a UTF-8 character inside the unknown SOS payload must not expose
any payload as text or hotkeys. The expected event list is still only text/q, with
normal exit and exact termios restoration. This case runs by default and can be
isolated without changing any existing assertion:

```sh
node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main sos-escape-utf8
```

The `coordinate-boundary` project is another ordinary public-API consumer. It tests
both extrema independently and reports both before failing if any write throws or
changes the initial blank frame. It must use the normal product build, just like
the other consumers; it does not contain overflow handling that alters the product.

This suite does not claim to exhaustively test injected device write failure, official
Unicode conformance data, concurrency/thread isolation, or later full-framework/M2
features. Public API exposes no device writer injection; independent code review and
later fault evidence must address write-failure baseline rules. This is not product
acceptance. After freeze, implementation authors report assertion problems through the
coordinator; they do not alter expected results to fit implementation.

TDD and verification-before-completion skills were applied to establish real RED
and distinguish compiler syntax checks from behavioral results. OpenSpec apply state
was read for the existing `implement-linux-first-slice` change; the coordinator updates
authoritative task state, since this test author is restricted to tests/test documentation.

Native bridge ownership/setup-signal module regressions can run through
`./tests/run-slice.sh native-session` or directly via `./tests/native-session/run.sh`.
The default `./tests/run-slice.sh all` runs both C cases before the SDK consumers,
so existing CI slice checks include them. They link the actual product C and control external
syscalls; they are white-box C tests, distinct from the public consumers and real
PTY suite above. See [native-session/README.md](native-session/README.md) for the
contract, controlled interleaving, and evidence limits.

## Layout and decoration contract (TASK-054)

Binding input: `implement-layout-decoration/design.md` at product revision
`86b088f`. This is an execution task: public API and behavior are already frozen;
only independent consumers and runners are added. The existing R8 consumers and
assertions remain unchanged. TDD and verification-before-completion skills apply.

```sh
./tests/run-slice.sh layout
```

`tests/layout` is an independent public Cangjie consumer. Its literal snapshots are
hand-derived from the design, not from product output. It catches wrong largest
remainders/ties, fixed/gap deductions, infeasible minimum allocation, overflow in
integer multiply/divide, invalid setter rollback, viewport constraints, padding,
axis alignment, zero dimensions, and complete validation of clipped text. The
runner builds then executes the binary directly under a 30-second bound; timeout,
compiler failure, and nonzero binary status fail. `all` includes this consumer after
all retained R8 modes. Missing APIs at the binding input must produce genuine RED.

For exact fractions: eight columns with weights 1:2:3 allocate 1:3:4 (remainders
2/6, 4/6, 0); ten columns allocate 2:3:5. An infeasible 8:4 minimum in six available
columns first clamps to 6:4, then allocates 4:2. These are specification fixtures.

```sh
./tests/run-slice.sh decoration
./tests/run-slice.sh layout-integration
```

`tests/decoration` independently checks literal borders (including zero/one-cell
and ambiguous-width cases), signed shadow set difference, original-rectangle
clipping, huge bounded geometry, styled-space fill, wide-cluster cleanup through
all three low-level operations, component insets, transparent unused allocation,
explicit Default background, paint order, ancestor clipping, and clearing on
border/shadow removal. `░` is narrow under the current public width policy even
with ambiguousWide enabled; the conditional dot fallback cannot be forced through
this public policy. Border glyphs are ambiguous and their whole-set ASCII fallback
is executable. No artificial width API or product test hook is introduced.

`layout-integration` builds the actual `examples/layout` application and runs it in
a real Linux PTY. Its agreed public interaction is: initially rounded borders and
visible shadow, d toggles both off/on, q exits. The harness starts at 48x14, compares
the complete frame after d/off/on, resizes to 23x9 then 8x4, toggles there, and
returns to 48x14. It checks no stale decoration, deterministic restored geometry,
full actual-width output rows with bounded cursor addresses, idle silence, normal
exit, and exact termios restoration. It does not bind titles or business text.
The small screen reader consumes the existing Linux backend's CUP/SGR full-row
output, with independent terminal-column accounting for ordinary Latin/CJK/emoji
content; it is a test facility rather than a full terminal emulator. A future
backend that changes the supported encoding must update this facility deliberately.

Set `CJTUI_LAYOUT_PTY_ARTIFACTS=/absolute/output/directory` to retain raw bytes,
frame snapshots, stderr, and termios evidence in a chosen directory. Otherwise a
new temporary artifact directory is retained and printed. A timeout fails; SIGKILL
is used only to clean up a failing session. The fixture is never replaced by a
fake terminal application. `LAYOUT_SESSION_BIN` can select a compatible actual
example binary after the ordinary example build. The default `all` mode includes
both new consumers and actual example PTY after all original R8 modes.

## Application cleanup and error preservation (TASK-060 / D027)

```sh
./tests/run-slice.sh application-lifecycle
# Or one focused case after building the fixture:
node tests/application-lifecycle/pty.mjs tests/application-lifecycle/target/release/bin/main callback-close-failure
```

This ordinary public Cangjie application uses a test-only FFI link wrapper, not a
product hook. The consumer's `link-option = "--wrap=cjt_close"` redirects its real
Application close call to `__wrap_cjt_close`. The wrapper **always calls the real
product close first**, records its actual result, then optionally returns failure.
The C wrapper neither restores termios itself nor substitutes a terminal backend.
Each case requires exactly one real close, real result 0, and exact before/after
termios equality even when failure is injected after cleanup.

The real PTY cases cover normal q and callback exception, each with successful and
failed close, plus Ctrl-C and resize followed by q with successful close. Normal
cleanup succeeds; close failure exits nonzero and explicitly reports
`terminal restore failed`; callback failure preserves its original sentinel; a
dual failure must explicitly report **both**. The unmodified baseline masks the
callback exception when close also fails, so the dual-failure assertion must be
RED. Failures propagate from the directly executed binary through util-linux
`script --return` and the Node harness. Every selected case runs even after an
assertion fails, preserving the four-combination evidence.

Set `CJTUI_LIFECYCLE_ARTIFACTS=/absolute/new/output/directory` to choose a retained
artifact directory (otherwise a fresh temporary directory is retained). Every case
stores original raw output, stderr, termios snapshots, wrapper record, and result.
A timeout is failure; forced signals are cleanup only. This support compiles only
test-local C and links it into the external consumer. Original product source,
FFI archives, R8 consumers, and public assertions are not modified. The runner's
`all` includes this new mode after existing checks. The separate ordinary
`cjpm bundle` check must still pass mandatory SDK lint without suppressions;
source-text assertions do not replace running that packaging command.

## Capability-aware colors and six text attributes (TASK-061)

Binding input: `implement-color-style-output/design.md` at
`f3329d2f9308c7242aea22266d5ab45d781e03b1`. Existing R8/R9/060 tests and
assertions are retained. New modes also run after those checks in `all`:

```sh
./tests/run-slice.sh colors
./tests/run-slice.sh colors-integration
# After the ordinary builds, directly select one real PTY scenario:
node tests/colors/pty.mjs fixture
node tests/colors/pty.mjs example
```

`tests/colors` is an ordinary external public consumer. It checks constructor and
channel-sensitive Color equality, every Style field, four distinct ColorMode values,
all sixteen named/alias colors, all indexed values in exact-capability modes,
independently calculated nearest/tie cases, RGB channel endpoints, foreground and
background bytes, six attributes and their reset/order, original raw Cell styles,
wide continuation/run output, explicit false inheritance, complete border/shadow
styles, and exact legacy eight-color/bold bytes. Expectations are literal standard
SGR bytes and nominal color distances from the contract, never captured product
output. No private projection/diff function is imported.

The separate `tests/colors/session` application supplies four fixed text rows.
`b/i/r/m` selects the four modes; `x/y` switches red249/red250; `n/a/d` selects
named Red / indexed alias1 / Default; `t/f` enables/disables all six attributes;
`q` stops. Each harness action is followed by a second public `h` key event.
That callback writes a serial acknowledgement file, demonstrating that the prior
run-loop render completed, and toggles bold on the otherwise independent fourth
`EVENT-FENCE` row. Receipt of that row's complete bytes is an additional PTY
transport barrier. The harness compares **all** bytes since the action against
exact expected business-row updates plus the fence row. It does not use a fixed
sleep, idle interval, output hook, stdout sentinel, or private API to infer that
a silent event was processed. Fourteen actions distinguish real changes from
Basic16/Indexed256-equivalent changes, Monochrome-only color changes, indexed
aliases, and mode changes that leave plain/named rows unchanged.

The other PTY scenario executes the actual `examples/colors` binary. It checks
initial Basic16 despite truecolor environment hints, `c` cycling through
Indexed256, TrueColor, Monochrome, and Basic16, `t` changing each of the six
attributes and round-tripping, actual-size resize 100x40→31x12→8x4→100x40,
normal q status, and exact before/after termios. Its screen reader observes CUP
and SGR bytes with independent column accounting; it is test support, not a
terminal emulator or product encoder. It does not require example business text
or a particular title. Positive example repaints wait for complete rows and
stream quiescence; the silence fixture instead uses the explicit event and
transport barriers above.

Both executables are built normally, then run directly under util-linux
`script --return`. Compiler errors, assertion status, timeouts, and forced cleanup
are failures. Set `CJTUI_COLOR_ARTIFACTS` to retain raw session/action bytes,
parsed example snapshots, stderr, terminal snapshots, and results in a chosen
directory; otherwise a fresh temporary directory is printed. Compatible already
built binaries can be selected with `CJTUI_COLOR_FIXTURE_BIN` and
`CJTUI_COLOR_EXAMPLE_BIN`; these do not bypass the runner's normal builds.

This test author establishes missing-API RED and freezes consumers/facilities;
it does not sign the subsequent product implementation GREEN. Device-write
failure baseline/mode commit ordering remains an independent review obligation
because the public application API supplies no writer injection hook. Normal
bundle and clean package-consumer execution are separate integration obligations;
no source scan or PTY assertion substitutes for them.
