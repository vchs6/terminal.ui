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
