# TASK-066 terminal matrix test program

Frozen input is 62035bfb5b34c0cd3b637efea23fbc7e180f705a and color-output D031-D033. This work changes only repo/tests/terminals and this report.

The immutable TASK-066 harness commit is 108c0ed175be12f8ee333406df01340486316806, with parent 62035bfb5b34c0cd3b637efea23fbc7e180f705a. It contains only tests/terminals fixture, README, collectors, SGR verifier, and XTEST injector; generated locks, target output, capture directories, PNGs, package files, and host artifacts are excluded.

The old explicit baseline is intentionally RED. With SDK 1.2.0, source the SDK envsetup.sh, change to repo/tests/terminals/fixture, and run cjpm build. It exits 1 because Application.terminalCapabilities is absent at src/main.cj:25. This is the required missing-public-API failure, not a skipped host test or an Auto pass.

tests/terminals/run.sh is frozen for TASK-063 execution after product integration. It uses fresh Xorg, real default xterm, xterm-256color, and XFCE/VTE windows; XTEST keyboard/resize plus a test-only Ctrl-C injector; raw script recording and an SGR parser; source PNGs and metadata; and q, callback exception, Ctrl-C, resize, no-op, and inner/outer termios checks. /workspace/work/cross-terminal-recon images remain host-readiness probes only and are not framework results here.

Current status: xterm default pending; xterm-256color pending; XFCE/VTE pending; Linux console pending; tmux pending; screen pending. No row is passed by TASK-066.
