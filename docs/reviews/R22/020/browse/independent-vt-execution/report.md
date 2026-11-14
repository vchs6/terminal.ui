Executed the frozen 13 ordinary lifecycle cases on actual Linux kernel VT tty1 (VM, not physical hardware).
Source e35d407a87ab197537ccc931c143c9927458a75f; independent producer build exit0; consumer SHA256 6448608e02572b788a162ddf1dcb25d4401d378ad6e2e1aa0c90d97d33529c12.
All 13 recorded consumer exits, QEMU exits and unchanged host_verify.py exits are0; no product/test/spec changes or Cangjie rebuild.
Every consumer fd0/fd1 is direct /dev/tty1, rdev4:1; no script/inner PTY. Native snapshots plus KDGETMODE/GIO_UNIMAP strace retained.
Kernel Linux6.12.107+deb13-amd64; QEMU10.0.13 TCG/max/pc/oneCPU/512MiB; tty1 active, fixed80x25, TERM=linux, UTF8=1, uid/euid1000.
Default kernel console font metadata8x16/256glyphs; actual console720x400; bootargs, font buffer and ABI/tool context retained.
Actual QMP keyboard generated r/o/s plus q/x/CtrlC; SIGINT/TERM delivered in guest to actual tested PID, with successful kill and child wait recorded.
Both runs per case retain exact same-child full Linux termios fields/endpoint, native handlers/flags/masks, owner, buffer/free and public resources/restart files.
Actual mode25/2004 queries returned empty before/after. Cursor physical visibility remains Unknown; zero25h/l/s/r; own2004h/l exactly twice, prior2004 restoration unclaimed.
Auto/NoTitleRequest and NoImageAdapterUnsupported verified by frozen consumer; no title scope or injected replies/TERM substitutions.
53 original QMP PPMs plus pixel-identical lossless PNG conversions retain active/layer/restart/afterrestore states; prevented case adds live prevented state.
Raw serial/strace/tar are retained as lossless gzip with original-byte SHA256 and checked decompression; native/public/wire/input files are retained directly.
Immutable v1/v2 guest payloads and full member source/destination byte/SHA manifests retained; v2 changes only post-test tar export compression.
Guest Python closure runs the exact frozen host_probe.py; util-linux script was neither packaged nor invoked because transport is direct VT.
Minimum free disk sampled during the monitored remainder: 128737280 bytes; final local evidence size is indexed; no disk block/retry occurred.
Scope: these13 surviving-endpoint ordinary VT rows only. Separate matrix/GUI, destroyed-endpoint, accepted unchanged unsafe-output scopes and independent acceptance remain separate.
No M1/AC020/041, full-Linux or release verdict is made here.
