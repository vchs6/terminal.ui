# Real terminal matrix (TASK-066)

run.sh drives one ordinary Application(root) fixture, with no color override, through real default xterm, xterm -tn xterm-256color, and XFCE/VTE windows. The two xterm rows are configurations of one implementation; XFCE/VTE is the second implementation.

Run with CJTUI_SDK_ENV set to the SDK envsetup.sh, CJTUI_TERMINAL_HOST_ROOT set to the verified host-probe directory, and CJTUI_TERMINAL_CAPTURE_DIR set to a new empty directory.

Missing host/XTEST/PNG/raw evidence exits nonzero as insufficient evidence. Each row uses fresh Xorg, terminal-owned PTYs, XTEST input and resize, unmodified import -window PNGs, raw script recording and SGR parsing, public capability diagnostics, source/binary/hash metadata, q/exception/Ctrl-C, and inner/outer stty -g restoration. Linux console, tmux, and screen stay pending without real hosts.

Earlier shell-probe PNGs only establish that these hosts are usable. They are not framework-Auto evidence.
