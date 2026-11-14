# Fixed actual-host execution plan (not executed by formal test author)

Input is the frozen test commit/binary hash in the author index, exact BASE
13e7880ce96d1331fc9e12a2b62275a307183e9a, accepted008/010 indices in reuse-map.
Use `host_run.sh` inside actual XTerm, VTE, and Linux tty1 separately. This
wrapper uses util-linux script to forward actual host replies; it neither
changes TERM nor injects DECRQM reports. Preserve child wire/input/timing,
native.tsv, outer exact termios, direct.exit, all consumer files, UTC and SHA.
Its own run is a new PTY within the actual host, so child termios is independently
observed by native before-open/after-each-close snapshots of all defined Linux
termios fields and endpoint identity, compared exactly by host_verify.py. Outer
termios by stty remains supplementary script-endpoint evidence only. This is not author runtime
host evidence. No script session can certify hardware/terminal host identity.
`host_probe.py` records actual /dev/tty mode25/2004 replies before and after,
restoring its exact termios; `host_verify.py` consumes these literal replies,
real forwarded input, native and public files with fixed C004 expectations.
The probe does not synthesize reports; missing/other replies stay Unknown.
Ordinary and initial host oracles are frozen. These new host helpers have only
syntax verification in author scope; actual host runtime validation is required.

For each host record executable path/version/config/TERM, `uname -a`, `tty`,
`stty size`, actual emulator process argv and geometry. XTerm uses
`xterm -version`; VTE records its actual launcher `gnome-terminal --version`
and package VTE version. A VM tty1 must say virtual console on the recorded
kernel/VM, with physical hardware explicitly absent; never call it hardware.
Record screenshot tool availability before starting. X11 original capture is
`import -window "$(xdotool getactivewindow)" "$OUT/active.png"` while the tested
window is verified active; also capture after exit. For tty1 reuse the accepted
VM console capture transport identified in the pinned I015 evidence, recording
actual VM display and kernel console originals. If framebuffer/screen capture
or host is absent, report that host blocked; never generate/repaint a PNG.

Normal `host_run.sh` leaves all color/glyph/session policies Auto and makes no
optional title request: expected title-scope cleanup is empty and no title
save/set/pop bytes. NoImageAdapter stays Unsupported without startup failure.
Run each original 13 exit cases on actual hosts, preserving original-visible
and original-hidden observations on XTerm/VTE, and actual Unknown on tty1.
Use `host_run.sh "$BINARY" "$OUT" CASE`. Establish prior mode25 with test-only
`printf '\033[?25h'` or `printf '\033[?25l'` before launch and record actual
I015 `probe-1`/`state-1` status, not just the requested prelude. The tty1 Unknown
branch must not inject reports. Establish prior2004 off/on with a recorded test
prelude `printf '\033[?2004l'` / `printf '\033[?2004h'`, or leave it unknown.
Label these requested prior states unconfirmed unless a separate actual host
query verifies them. C004 owns its requested h/l, and does not preserve a
pre-enabled2004 state. Do not mislabel disable completion as original-state
restoration. An optional, separate explicit protocol stress run may set
`CJTUI_020_HOST_TITLE_STRESS=1` before invoking host_run.sh on a host whose
known title-stack support is recorded. This is not normal Auto capability proof
and must not be forced onto tty1. Its exact statuses are SaveSentUnconfirmed /
RestoreSentUnconfirmed; reuse accepted152 actual-title proof only within its
unchanged host/config/scope. Record title before/while/after using actual X11 `_NET_WM_NAME`
via `xprop -id WINDOWID _NET_WM_NAME WM_NAME`; tty1 title remains unsupported/
unconfirmed unless actually observable. SentUnconfirmed never becomes
RestoreConfirmed from wire/screenshot alone. NoImageAdapter remains Unsupported.

Events per ordinary case: wait until first live frame, send `r` until probe-1
exists (real Known/Unknown), then `o`; capture the layer/focus/caret original
PNG, then `s`, which records public readiness, Auto/NoTitleRequest and NoImageAdapter
(or explicit opt-in title stress statuses). Use `q` for
stop/cleanup/close, `x` for callback/getter/draw/post and combined errors,
raw Ctrl-C for ctrl-c, raw Ctrl-C then inspect prevented=yes and live process
before `q` for prevented, or `kill -INT/TERM "$(cat "$OUT/pid")"` for OS signals.
After closed-1 wait for the second frame, `r`, `s`, then `q`. Preserve the native
handler flags/masks/free/owner and resources files; all errors must match cases.
Operator or external GUI key driver records exact actual keys/UTC; no guessed
screen-only pass. Wait for files/status and never use a fixed sleep as evidence.

Initial failure rows need no first key: wait closed-1, then second-frame `r`,
`q`. Worker-stop uses `q` on first run and requires worker=joined. Pipe EOF/HUP
rows use `e` after ready; they remain explicitly OSpipe transport, even inside
an actual host. Actual TTY read0 uses the separate driver canonical-VEOF
fixture; endpoint destruction uses `endpoint_hup.py`, not a GUI window close
pretending to offer a surviving endpoint. GUI host closure may be added by the
independent executor with exact child signal/read/cleanup originals, and no
restoration success claim on an unavailable endpoint. No SIGKILL guarantee.

After safe exits compare actual native mode25 reply or equivalent independent
host observation to the verified original; Unknown must have zero25h/l/s/r.
Check own2004 h/l count/order and Auto absence of title scope/output; optional
explicit title stress additionally checks its owned scope. Observe original PNGs,
exact termios, child exit, native logs, once-only UI cleanup, empty resources,
closed focus/caret, stale refs/handles and second-run isolation together.
Unsafe output cases reuse accepted008 original precise scope/source proof;
if a changed host path needs a delta, independent executor records zero later
bytes and rejected same-process open without resetting its latch. No338 rerun.

Remaining real-host execution/independent review/acceptance and final M1 widget
integration are required downstream. This plan and the author PTY results do
not close TASK020, M1, M2, release or Linux acceptance.

R1 readiness: run host_transport_check.py against the frozen binary first.
This uses actual nested PTYs with explicitly emulated mode replies to exercise
the full host_run/probe/oracle path; it does not establish an actual terminal
host. Its child-state negative must yield direct.exit0, equal outer stty and
host runner exit1 from exact same-child termios mismatch. Actual-host execution
must retain native-termios-before-N.json and native-termios-after-N.json for
both runs. Endpoint HUP is separate and must identify actual Auto versus
explicit declared policy; Auto owns no title scope. No child state is repaired.
