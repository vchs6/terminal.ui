# Linux console / multiplexer host readiness

2026-11-10 UTC. Development host reconnaissance only, in `/workspace/work/linux-console-hosts`; no product source, formal tests, system packages or shared toolchain changed. This is an execution task within the authorized Linux validation scope. It establishes reusable hosts, not a framework acceptance pass.

## Result

All three missing Linux host paths are runnable without privilege escalation:

| Host | Actual implementation / configuration | Observed child | Evidence |
|---|---|---|---|
| Linux VT on virtual hardware | Official Debian Linux `6.12.107+deb13-amd64`, QEMU `10.0.13` TCG, PC + SeaBIOS + VGA + PS/2 keyboard, `nomodeset vga=normal` | `/dev/tty1`, `TERM=linux`, fixed **80×25**; `VT_GETSTATE` succeeds, active VT 1; `KDGKBTYPE` succeeds, type 2 | `raw/vt-serial.log`, `raw/vt-qmp.jsonl`, original `raw/vt-{ready,input,exit}.ppm`, lossless PNGs, `raw/VCSA_{READY,EXIT}.bin` |
| tmux | Official Debian `3.5a-3`, fresh socket/server, `/dev/null` config, outer actual XTerm 398 with `TERM=xterm-256color`, 100×28 | `/dev/pts/1`, actual `TERM=tmux-256color`, **100×27** (status row consumes one line) | `raw/tmux-x11.png`, `raw/tmux-x11-{child.log,input.txt,window.txt,tree.txt}`, actual `raw/tmux-grid-ansi.txt` |
| GNU screen | Official Debian `4.9.1-3`, `/dev/null` config, user-owned `SCREENDIR`, outer actual XTerm 398, 100×28 | `/dev/pts/1`, actual `TERM=screen.xterm-256color`, **100×28** | `raw/screen-x11.png`, `raw/screen-x11-{child.log,input.txt,window.txt,tree.txt}`, actual `raw/screen-grid.txt` |

The two multiplexer rows run actual distinct server implementations. They do not replace one PTY's TERM value. The X11 images are direct `import -window` captures of viewable 1004×536 XTerm windows, with actual tmux/screen between the outer terminal and child. XTEST delivered `p` and `q` through that terminal. Its helper also injects Return; the empty `INPUT=` record is this newline, not an input failure. Both outer terminal processes exited 0 and both child logs record exact before/after `stty -g` equality.

An additional controlled PTY probe preserved outer raw bytes and termios: `raw/{tmux,screen}-outer-ansi.bin`, `raw/{tmux,screen}-host.json`, and `raw/{tmux,screen}-child.log`. Both host JSONs record outer exit 0 and `outer_termios_equal=true`. Input `p`, `q` reached each actual child. The PTY evidence is control/byte evidence; the separate X11 captures supply the actual display evidence.

## Linux VT evidence and limits

`probes/vt-probe.c` is a throwaway static C readiness program, not product code or a terminal emulator. Init mounts guest devtmpfs/proc/sysfs, then opens the real guest `/dev/tty1` with a controlling session. The child writes its scene to tty1 and reads input there. The guest kernel's console implementation interprets its output and the guest kernel's keyboard driver interprets QEMU's virtual PS/2 input.

The serial channel only exports kernel/probe telemetry and the kernel-provided `/dev/vcsa1` bytes. Serial output is **not** counted as VT rendering or keyboard evidence. QMP `screendump` independently captures the virtual VGA device's actual display, and QMP `send-key` supplies keyboard events rather than writing input bytes into a PTY or serial port. `-display none` disables a host GUI frontend, not the virtual VGA device.

Observed sequence in `raw/vt-serial.log`:

```text
KERNEL Linux 6.12.107+deb13-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.12.107-1 (2026-08-29)
TTY=/dev/tty1 TERM=linux GRID=80x25 winsize_rc=0 VT_GETSTATE_rc=0 active=1 KDGKBTYPE_rc=0 keyboard=2
READY
INPUT 70
INPUT 1b
INPUT 5b
INPUT 41
INPUT 71
RESTORE rc=0 iflag=4500/4500 oflag=5/5 cflag=4bf/4bf lflag=8a3b/8a3b cc_equal=1
PROBE_EXIT=0
INIT_CHILD_EXIT=0
[   34.257289] reboot: Power down
```

Thus `p`, Up (`ESC [ A`), and `q` arrived via the kernel keyboard path, the normal exit restored input modes, init observed child exit 0, and the unprivileged QEMU process exited 0 on guest poweroff. QMP `query-kvm` records KVM disabled and not present; this uses CPU emulation and needs no `/dev/kvm`. Guest root exists only inside the emulated machine. No host device or host root permission is requested.

Each vcsa dump is 4004 bytes: the kernel's four-byte rows/columns/cursor header and 2000 character/attribute pairs. Header reports 25 rows and 80 columns both before and after. `raw/VCSA_{READY,EXIT}.txt` is a derived ASCII/CP437 text view for convenience; the `.bin` remains authoritative. The VGA originals are 720×400 PPMs; PNGs were obtained by lossless ImageMagick conversion, not repainting or ANSI-to-image rendering.

This proves a **real Linux kernel VT on virtual hardware**, not access to a physical console or real physical keyboard. Host `/dev/tty*` contains only `/dev/tty`; no physical VT target was available. This fixed profile intentionally has no resize promise. The probe uses ASCII and basic SGR. No CJK, emoji, arbitrary Unicode, font coverage, alternate-screen restoration, or product output behavior has been accepted on this profile. Font limitations must be tested honestly with the product's fallback policy rather than inferred from a successful VM boot.

## Sources, installation, and runtime

Host is Debian GNU/Linux 13.6, ordinary uid/gid 1000 (`raw/host-id.txt`), with host kernel in `raw/host-uname.txt`. Package/runtime/network skill: `cloud-environment:cloud-environment-runtime`, including its package and networking references, was read and applied. Managed environment status returned current observations and enforced unrestricted network policy. Downloads inherited the supplied HTTPS proxy and CA trust with normal TLS verification. Neither sudo nor system APT installation was retried.

All added binaries and libraries were unpacked with `dpkg-deb -x` below `hosts/debian`. `probes/package-download.py` selects packages from the official Debian trixie amd64 `Packages.xz`, downloads each official `Filename`, verifies its SHA-256 against that index, then unpacks into this local directory. `raw/package-manifest.jsonl` contains exact versions, paths, checksums and declared dependencies. Existing host libraries resolve the remainder. The package selection includes tmux, screen, qemu-system-x86/common/data, SeaBIOS, iPXE, busybox-static, and QEMU's missing libraries. Original third-party docs/attribution remain in the unpacked tree. No local or system package database was modified.

Official sources retained:

- `https://deb.debian.org/debian/dists/trixie/main/binary-amd64/Packages.xz` and `.../trixie/InRelease`.
- Kernel: `https://deb.debian.org/debian/dists/trixie/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux`.
- Kernel checksum list: `https://deb.debian.org/debian/dists/trixie/main/installer-amd64/current/images/SHA256SUMS`; its `./netboot/debian-installer/amd64/linux` entry matches the downloaded kernel.

The downloaded `InRelease` is retained for provenance; this environment has no gpgv executable, so no separate OpenPGP signature verification is claimed. Official HTTPS transport plus comparison to the published official checksums is the performed validation. Future reproduction must retain the current package/kernel bytes or refresh and re-record versions; upstream `current` paths are not immutable.

## Reuse commands

Run from this directory as the current user. All probes and Python helpers are disposable development infrastructure, not product runtime dependencies.

Multiplexer binaries are directly runnable:

```sh
hosts/debian/usr/bin/tmux -V
hosts/debian/usr/bin/screen --version
python3 probes/probe-mux.py
probes/run-mux-x11.sh
```

The latter commands overwrite the named readiness outputs; copy evidence or use a separate directory before a new run. `run-mux-x11.sh` references the existing independent `/workspace/work/cross-terminal-recon` xterm binary, Xorg dummy configuration and XTEST helper; it uses fresh display `:71`, which must be free. It cleans its Xorg and terminal on exit. The raw originals from this run remain here. That directory is only a development host prerequisite.

For a product test, replace the readiness child's path in the launch with the fixed application command. A real XTerm or VTE invocation should wrap either actual command, inheriting the outer host's real TERM:

```sh
hosts/debian/usr/bin/tmux -L UNIQUE_SOCKET -f /dev/null new-session -s app /absolute/path/to/fixed-app
SCREENDIR=/absolute/path/to/private-mode700-dir hosts/debian/usr/bin/screen -c /dev/null -S app /absolute/path/to/fixed-app
```

The tmux default status row changes the app viewport; use the observed child size, not the outer terminal size. User-owned SCREENDIR must exist with mode 0700. Do not reuse readiness's active socket/session names concurrently.

VT launch/control, in two terminal sessions or with the launcher as a supervised background child:

```sh
VT_RUN_DIR=/workspace/work/linux-console-hosts/raw/FRESH_RUN probes/start-vt.sh
# after vt-serial.log reports a complete READY line:
VT_RUN_DIR=/workspace/work/linux-console-hosts/raw/FRESH_RUN python3 probes/control-vt.py
```

The launcher refuses to overwrite an existing serial log. `control-vt.py` queries version/status/KVM, captures ready and input displays, injects p/Up/q, waits for the actual input and exit acknowledgements, and captures the final display before init's three-second shutdown. Guest poweroff stops QEMU normally. Generic fresh-directory reuse was separately exercised in `raw/reuse-smoke/`; the original invocation sources are preserved as `probes/start-vt-recorded.sh` and `probes/control-vt-recorded.py`.

To run the future fixed product binary in the guest, copy it and its complete Linux x86-64 dynamic loader/shared-library closure into `guest-root` at the exact absolute paths expected by ELF. Replace `guest-root/init`'s child command with a controlling tty1 session and keep the mounts and controlled exit reporting. Then `python3 probes/build-initramfs.py --keep-init` packs the current guest-root (without overwriting custom init) to `packages/vt-initramfs.cpio.gz`. The default invocation instead regenerates the readiness init and copies `/vt-probe`. `gcc -static -O2 -Wall -Wextra probes/vt-probe.c -o probes/vt-probe` rebuilds only the readiness binary.

This guest initially includes only static BusyBox and the readiness binary, no Cangjie SDK or product runtime. The product runtime's actual guest execution is still pending. Use a separate frozen initramfs/kernel hash per product run and adapt the controller to that program's real acknowledgement/exit protocol; do not pretend the readiness program's success accepts a different binary. Keep the fixed kernel/VGA profile, QMP input, direct display capture and mode restoration evidence.

## Evidence hashes

`raw/SHA256SUMS` indexes the original artifacts, packages and probe sources (relative to this directory). Selected SHA-256 values:

| Artifact | SHA-256 |
|---|---|
| `packages/linux` | `2b2358b37674d2505350528875bb17afae2a36522a9e8a9417eaca65a7da0e08` |
| `packages/vt-initramfs.cpio.gz` | `a0ad0d658053eb310fabef39213642b43a2b49f0785a1f34fc13704af66d83d4` |
| `probes/vt-probe.c` | `a446ec36514920902c521fe169a32c1ed65a9d4ea53792a246275938ceb27402` |
| `raw/vt-ready.png` | `b2cedd44a759b588fa5df6f51372d80b332a549d4f3fce0b99c052f57f8bcb58` |
| `raw/vt-input.png` | `465ca112358bf21147f5608da603d07b42322b620884410b00fd2840d918e340` |
| `raw/vt-exit.png` | `ab000755262530b28fddada43cfa1105beb6582c2ff6af8f0f2f014b43fabd12` |
| `raw/tmux-x11.png` | `35ee8f9d3d88e6a06194d282a0f045cc8074023091019241cb8a329357e914d1` |
| `raw/screen-x11.png` | `adbbf3968b428968cb0706dbec15f2c739d5b276642c98a6b61c3560ae44e15f` |

## Remaining work / actual blockers

There is no remaining privilege/tool blocker for these three development host profiles. The actual kernel VT/keyboard/fixed viewport/normal exit path is demonstrated. The complete framework matrix, frozen product app in the guest, product's Unicode fallback, all cleanup/error cases, optional OSC behavior, and independent acceptance remain the next executor's work. This reconnaissance changes no product capability status to passed. QEMU, Xorg, capture helpers, Python and multiplexers are test hosts only and must not become hidden product dependencies.
