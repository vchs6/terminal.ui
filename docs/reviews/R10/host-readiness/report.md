# TASK065 actual cross-terminal reconnaissance

Run date: 2026-11-10 UTC. All evidence in this directory was produced on the attached Debian 13 executor (`5a154db51e9e`) with an isolated Xorg display and no existing `$DISPLAY`. The images below are `import -window <real X11 window-id>` captures; they are not ANSI-to-image conversions, compositions, or redraws.

## Outcome

Two independent terminal implementations ran successfully and have acceptable real-host PNG evidence:

| status | host and version | character / pixel size | child capability evidence | original PNG and SHA-256 | scene source and SHA-256 | raw evidence |
| --- | --- | --- | --- | --- | --- | --- |
| passed | XFCE Terminal `1.1.4-1`, backed by VTE `0.80.1-1` | `100x28` / `1017x561` | actual child TTY: `28 100`; `TERM=xterm-256color`; `COLORTERM=truecolor` | `raw/vte-actual.png` `870c6f39642a0580b9db49a8c5fe240e3dde98f1b5196b8be2c383a5ee292919` | `probes/scene-vte.sh` `5493d16fc20d0181ab13cb9eb4eacdb3151166c6ea9ca84808079d3897ec133b` | `raw/vte-actual-child.txt`, `raw/xwininfo-vte-actual-window.txt` |
| passed | xterm `398-1` (`XTerm(398)`) | `100x28` / `1004x536` | actual child TTY: `28 100`; `TERM=xterm`; `COLORTERM` empty | `raw/xterm-actual.png` `38dc9a7516f43c91aad6e9d3ae9ecb93098d845ef99dbb2230f08bd587facc4f` | `probes/scene-xterm.sh` `d135b892accac61fc4460cf8cfc567fcf1ae03e7cf090b954511f693413297c2` | `raw/xterm-actual-child.txt`, `raw/xwininfo-xterm-actual-window.txt` |

The two passed rows are distinct host implementations. They were each launched in a fresh isolated Xorg server, with their own terminal emulator and PTY child. This is not a single PTY rerun with a different `TERM` value.

`identify` validated the preserved originals as `1017x561 8-bit sRGB` and `1004x536 8-bit sRGB` respectively. The corresponding `xwininfo` records show `Map State: IsViewable`, an `InputOutput` X11 window, and the stated geometry. The scenes visibly exercise cyan/bold, red foreground, underline, and inverse SGR sequences; their exact emitted source is retained rather than reconstructed from the image.

## Reproducible host launch

The isolated display used `probes/xorg-dummy.conf` (SHA-256 `224b8d18426890cfd7bb4a2e7b313e2873720920cf30aac2418e0e6ed0f16119`) with X.Org `1.21.1.16`. The successful Xfce invocation was equivalent to:

```sh
DISPLAY=:96 dbus-run-session -- xfce4-terminal --disable-server \
  --geometry=100x28+20+20 --title='TASK065 VTE actual' \
  --command='/bin/sh probes/scene-vte.sh'
```

The successful xterm invocation was equivalent to:

```sh
DISPLAY=:95 hosts/xterm/usr/bin/xterm -geometry 100x28+20+20 \
  -T 'TASK065 xterm actual' -fa Monospace -fs 12 \
  -e /bin/sh probes/scene-xterm.sh
```

Each launch was followed by `xwininfo` for its window ID and `import -window <window-id> raw/<host>-actual.png`. The server and host were then terminated; no desktop display was reused.

## X11 control and resize probe

`probes/x11-xtest-inject.c` is a throwaway control probe, compiled as
`probes/x11-xtest-inject`. It dynamically loads the already-present
`libX11.so.6` and `libXtst.so.6`, verifies the actual XTEST extension, sets
input focus on the real X11 terminal window, injects `p` plus Return using
`XTestFakeKeyEvent`, and invokes `XResizeWindow`. It does not write a PTY
slave. Its source SHA-256 is
`e2cbf4798f2916800d07fd0c3141e34478502714e6c7774032bf32369204d532` and
the compiled probe SHA-256 is
`1d5ab7a80f34f389734f4ce19ad58f98cbf21c85f01cd14a36d467da3c45f9e2`.

`probes/run-control-probe.sh` (SHA-256
`b9d58ed47b499d4050e8a251f544d54fa995cbf542d8867ac111f73716fe3727`)
launches an isolated Xorg server and one real host. It waits for the child
ready record and a viewable X11 window, then waits for both a child input
acknowledgement and a SIGWINCH acknowledgement before it captures the
window. Completion is therefore based on observed child and X11 state; the
short polling interval is only a timeout-bounded wait mechanism.

| profile | actual host configuration | child capability and control evidence | X11 geometry before → after | PNG and SHA-256 |
| --- | --- | --- | --- | --- |
| `xterm-default-recorded-stable` | xterm 398 default (`TERM=xterm`) | XTEST `2.2`; `input_ack=p`; `resize_ack=34 120` from `ready_tty_size=28 100` | `1004x536` → `1204x650` | `raw/control-xterm-default-recorded-stable-after.png` `2bd72292c056931d2a46c34c972beb017dadd67dce5de013003a125d7d57d9d8` |
| `xterm-256color-stable` | xterm 398 with `-tn xterm-256color` | XTEST `2.2`; `input_ack=p`; `resize_ack=34 120` from `ready_tty_size=28 100` | `1004x536` → `1204x650` | `raw/control-xterm-256color-stable-after.png` `0dac5b934fa6763d969c43d3fb5c7fb7485201e5c4dac9cf3d08abc91cc91f81` |
| `xfce-vte-stable` | XFCE Terminal/VTE (`TERM=xterm-256color`, `COLORTERM=truecolor`) | XTEST `2.2`; `input_ack=p`; `resize_ack=34 120` from `ready_tty_size=28 100` | `1017x561` → `1217x675` | `raw/control-xfce-vte-stable-after.png` `13f9e9e5ecc66c28fd9f5a512941e3664f8b4d5000ac2c20ec7796f2e5ceba6d` |

Every row has `before`, `after`, `child`, `inject`, and `tree` raw files
under `raw/control-<profile>-*`; the before/after records both say
`Map State: IsViewable`. The after images visibly contain the typed `p`, the
SIGWINCH line, and the application acknowledgement. This establishes three
usable host profiles across two independent terminal implementations. It does
not establish framework Auto-mode behavior.

For the first xterm row, util-linux `script 2.41.5` was additionally used as
a transparent inner-PTY recorder:

```sh
script --quiet --flush --return --log-out raw/control-xterm-default-recorded-stable-ansi.log \
  --command '/bin/sh probes/scene-control.sh'
```

The raw log SHA-256 is
`be8b760bf10c77f1696fb726469c6e0af34577c6d8bdf8530b41a98db41d7813`.
It contains the actual ESC `CSI 1;36m` bytes, `TERM="xterm"`, the controlling
TTY, `COLUMNS="100"`, `LINES="28"`, the input echo, the SIGWINCH output, and
`COMMAND_EXIT_CODE="0"`. This recorder is test infrastructure only and does
not substitute for a terminal host or the original PNG. On this util-linux
version, do not append the historical `/dev/null` positional argument when
using `--log-out`; it rejects that form as an unexpected argument.

Xterm 398's advertised `-l`/`-lf` logging is an optional raw-output path, but
its `-help` output exposes no noninteractive screen-dump option. The preserved
real window PNG plus transparent recorder is the usable evidence combination.

## VTE grid probe and attribute boundary

`probes/vte-testhost.c` (SHA-256 `00c39357b1479cfa8c6835b7c92e5e3b107ced6ea452a9dae45c75f198590dc0`) creates a real VTE terminal, spawns `scene-vte-testhost.sh` on its PTY, and calls the installed VTE `vte_terminal_get_text` API. Its raw result is `raw/vte-testhost-grid.txt` (SHA-256 `a5d91c79078e72df7776ba10b5197e663d0cdad4d045ca9bca983f8c51f3705d`). It records the actual VTE grid text plus the child TTY observation `32 126`.

VTE `0.80.1` rejects the deprecated non-null attributes argument at runtime:

```
VTE-CRITICAL: ... vte_terminal_get_text(...): assertion 'attributes == nullptr' failed
```

Passing `NULL` is the supported path and obtains grid text. Therefore this environment has no public VTE per-cell attribute readout through that API. The two accepted real-host PNGs remain the evidence that the SGR foreground, underline, and inverse attributes were rendered. The testhost did not yield a viewable toplevel X11 window, so no testhost image is counted as evidence.

## Dependency and environment findings

The existing image contained XFCE Terminal, VTE, Xorg, `xwininfo`, and ImageMagick `import`, but did not contain `xterm`, `Xvfb`, `tmux`, `screen`, or VTE GIR data. `/dev/tty*` exposed only `/dev/tty`; there is no evidence of a usable `/dev/ttyN` Linux-console target.

System installation was attempted using the documented full escalation path:

```sh
apt-get update && apt-get install -y --no-install-recommends \
  xterm xvfb gir1.2-vte-2.91 tmux screen
```

It failed without changing packages: `apt-get update` reported `List directory /var/lib/apt/lists/partial is missing. - Acquire (13: Permission denied)`. `sudo` is absent (`sudo -n true` exited `127`) and `/usr/local/bin/cloud-agent-packages` is absent, so no permitted system package route exists in this executor.

To obtain the second host without changing the system, the official Debian snapshot package was downloaded, checksum-verified, and unpacked only below this reconnaissance directory:

| artifact | source / SHA-256 | use |
| --- | --- | --- |
| `packages/xterm_398-1_amd64.deb` | Debian snapshot 20261103T013555Z / `633a43579b5d5445472fb01f897c10b33976ea27f54384848415cb706e74d381` | `hosts/xterm/usr/bin/xterm`; `ldd` resolved all runtime libraries on the existing image |
| `packages/libvte-2.91-dev_0.80.1-1_amd64.deb` | Debian snapshot 20261103T013555Z / `0becd0c52b2f023b01f037ca18191ca6eb9e453c5b8dd03d716f958d5ec783d4` | public VTE headers used to check the grid API contract; no product dependency |

## Scope and status limits

This is reconnaissance evidence only. It adds no product source, product runtime dependency, or formal test to `work/terminal.ui`. Commit `187e126` exists in that repository and its existing explicit-mode baseline was not used to claim an Auto-mode pass. The matrix increment justified by this run is the three host profiles above, across two actual host implementations. Linux console, tmux, screen, Xvfb, and any unimplemented Auto default remain pending rather than passed.
