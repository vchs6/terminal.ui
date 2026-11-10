# Real terminal matrix (TASK-066)

run.sh drives one ordinary Application(root) fixture, with no color override, through real default xterm, xterm -tn xterm-256color, and XFCE/VTE windows. The two xterm rows are configurations of one implementation; XFCE/VTE is the second implementation.

Run with CJTUI_SDK_ENV set to the SDK envsetup.sh, CJTUI_TERMINAL_HOST_ROOT set to the verified host-probe directory, and CJTUI_TERMINAL_CAPTURE_DIR set to a new empty directory.

SDK 1.2.0 envsetup requires Bash. Run `tests/terminals/run.sh` directly (its
shebang selects Bash), or use `bash tests/terminals/run.sh`.
Host-version queries use the active Xorg DISPLAY and each host's supported option:
xterm `-version`, XFCE/VTE `--version` (its `-version` can start a window).

Missing host/XTEST/PNG/raw evidence exits nonzero as insufficient evidence. Each row uses fresh Xorg, terminal-owned PTYs, XTEST input and resize, unmodified import -window PNGs, raw script recording and SGR parsing, public capability diagnostics, source/binary/hash metadata, q/exception/Ctrl-C, and inner/outer stty -g restoration. Linux console, tmux, and screen stay pending without real hosts.

Earlier shell-probe PNGs only establish that these hosts are usable. They are not framework-Auto evidence.

The fixture constructs its mutable rich-text and event-fence nodes inside the
`Column` block, retaining those same objects for callbacks. After its ordinary
`cjpm build`, run `CJTUI_TERMINAL_VALIDATE=1 tests/terminals/fixture/target/release/bin/main`
from the repository root to check scene membership and callback references through
public `render(...).toPlainText()` / `cellAt()` without opening a terminal.

`verify-sgr.mjs CAPABILITIES RAW HOST_PROFILE` validates all required diagnostic
fields and the frozen real-host mode/source, rejects bright SGR in Basic8, applies
NCV as a bit mask only to colored styles, and checks the three literal RGB sample
projections (including background). Before launching either terminal implementation,
the runner removes inherited COLORTERM; XFCE/VTE may set its own declaration.
The actual child's TERM/COLORTERM remain in outer-tty.txt.

Each fixture action is followed by a distinct `p` callback that toggles only the
uncolored EVENT-FENCE row. Acknowledgements identify callbacks; completion requires
the exact entire row in inner-tty.raw. The no-op interval must consist only of that
intentional fence row. Resize waits for the actual inner PTY grid to change before
another action/fence pair, so a pre-resize callback cannot fence a later resize.
Raw fence offsets, columns, style, and timestamps are stored per action.

Application exit results come from both inner and outer recorder `exit_status`
fields. Each must occur exactly once, contain a legal status, and agree: q,
Ctrl-C and ordinary-example runs require zero; callback-exception runs require
nonzero. The terminal host's wait status is independent evidence in
`host-wait-status.txt` and `exit-verification.json`; it need not mirror the
application and cannot establish that an application exception occurred.

For the unmodified ordinary `examples/colors` program, use the same host matrix:

```sh
CJTUI_TERMINAL_SCENE=example \
CJTUI_SDK_ENV=/path/to/envsetup.sh \
CJTUI_TERMINAL_HOST_ROOT=/path/to/host-bundle \
CJTUI_TERMINAL_CAPTURE_DIR=/new/empty/output \
tests/terminals/run.sh
```

This scene uses the normal example build, three c events, t off/on, resize, and q.
It writes the initial, red, gray, restored, attributes-off/on and resized original
window PNGs, identify output, stage raw bytes/ranges/hashes, source and binary hashes,
version, actual grid and inner/outer termios. Original before/after-resize PNGs are
also retained. `CJTUI_TERMINAL_EXAMPLE_BIN` can select an already normally built
example for an executor; record that binary's build provenance separately.

The ordinary example has no test acknowledgements or capability diagnostic files.
Its screenshots follow positive raw growth containing CUP output ending in SGR0;
100ms stability allows the terminal to draw, and supplies no silent-event proof.
Only the separate fixture scene claims handshake-fenced no-op and capability checks.
Missing output, evidence or a timeout fails; PNGs are never regenerated or redrawn.
Two xterm configurations remain one implementation; XFCE/VTE is the second.

Run the test-tool checks without terminal hosts:

```sh
node --test tests/terminals/*.test.mjs
sh -n tests/terminals/run.sh tests/terminals/inner-recorder.sh
```

The literal byte files in these Node tests test the verifier/observers; they are
not terminal-host evidence and never produce acceptance screenshots.
