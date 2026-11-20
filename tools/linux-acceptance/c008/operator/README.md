Status: NOTEXECUTED. Final acceptance: false. Source preparation only; E146 retains exclusive devices/CPU. These commands become admissible only after accepted147 and root's separate ACTUAL GO. No command below was executed against a host during preparation.

Required future inputs are final public source checkout, final147 admission and build provenance (SDK/dependency/native/source/ELF hashes), final `examples/theme_showcase` and `examples/composition` ELF paths, new output directories, owned DISPLAY/config/session/clipboard paths, frozen common input adapter/case manifest and original test-owner oracle bindings. A label or environment variable does not itself establish admission. Root must check the actual accepted147 record before setting `C008_ROOT_ACTUAL_GO=1`.

`record-public.sh` runs inside an actual host. Set absolute `C008_SOURCE`, `C008_BINARY`, `C008_OUT`, `C008_147_ADMISSION`, `C008_PROVENANCE`, and factual `C008_HOST_ID`. `C008_LAUNCHER` must name an executable owner-prepared shell launcher exporting those exact inputs and execing this recorder; it must not override TERM/COLORTERM. For a second application use a fresh output and launcher. The recorder reuses the existing `tests/terminals/inner-recorder.sh`, adding util-linux input/timing logs externally. It preserves direct exit, initial/final sizes, original ANSI, input, UTC and stty representations. It adds no oracle. Its outer snapshots are supplementary; exact same-child native termios fields and restoration obligations remain owned by the frozen session lifecycle fixture.

After GO, execute `bash /workspace/work/linux-final-host-execution/operator/launch-host.sh HOST` inside the admitted environment. Host-specific REQUIRED variables:

| HOST | Inputs and actual obligations |
|---|---|
| xterm | `C008_XTERM=/workspace/work/cross-terminal-recon/hosts/xterm/usr/bin/xterm`, owned DISPLAY; actual `-version` must establish398. |
| vte | `C008_XFCE=/usr/bin/xfce4-terminal`, owned DISPLAY and XDG_CONFIG_HOME/XDG_CACHE_HOME; isolated terminalrc forwards F-keys (existing ShortcutsNoMenukey=TRUE). Record frontend1.1.4 separately from actual loaded libvte0.80.1 path/hash and `/proc/FRONTEND_PID/maps`. |
| tmux | `C008_XTERM`, `C008_TMUX=/workspace/work/linux-console-hosts/hosts/debian/usr/bin/tmux`, `C008_TMUX_SOCKET`, `C008_TMUX_CONFIG`; unique socket, owned config, real server version3.5a/argv/config/source and inner PTY. |
| screen | `C008_XTERM`, `C008_SCREEN=/workspace/work/linux-console-hosts/hosts/debian/usr/bin/screen`, `SCREENDIR`, `C008_SCREEN_CONFIG`, `C008_SCREEN_SESSION`; owned0700 socket directory, actual4.9.1 and real inner process. |
| ssh | `C008_XTERM`, `C008_SSH`, `C008_SSH_HOST=127.0.0.1`, `C008_SSH_PORT`, `C008_SSH_USER`, `C008_SSH_OWNED_KEY`, `C008_SSH_OWNED_KNOWN_HOSTS`, `C008_REMOTE_LAUNCHER`; separately prepared owned OpenSSH server/config/user, no existing user keys/hosts. Remote launcher exports remote recorder/source/build/runtime paths. |
| vt | `VT_RUN_DIR`, `VT_INITRD`, `VT_SCENE`; existing QEMU launcher boots actual guest kernel tty1; new initramfs must contain final app plus necessary loader/DT_NEEDED and actual dlopen dependencies only. Existing setup-guest.py knows minimal/colors/fixture, so it is not a final showcase installer. The continuation below supplies source-specific public scene install and F10 control parameterization; root must still provide an admitted necessary closure manifest. |

Actual operator commands to retain raw metadata, run INSIDE the corresponding admitted host/guest and write to a NEW owned evidence directory:

```sh
# Existing GUI subset (creates its own isolated Xorg; does NOT cover complete C008):
python /workspace/work/incremental-composition-execution/capture-showcase.py xterm "$FINAL_SHOWCASE_ELF" "$NEW_XTERM_SUBSET_OUT" "$OWNED_DISPLAY"
python /workspace/work/incremental-composition-execution/capture-showcase.py vte "$FINAL_SHOWCASE_ELF" "$NEW_VTE_SUBSET_OUT" "$OTHER_OWNED_DISPLAY"
# Frozen lifecycle: separate controlled consumer, never mislabel it public showcase:
CJTUI_020_ROOT_GO=1 CJTUI_020_ADMISSION="$ACCEPTED_020_ADMISSION" bash "$FINAL_SOURCE/tests/session_lifecycle/host_run.sh" "$FINAL_020_ELF" "$NEW_LIFECYCLE_OUT" "$FROZEN_CASE_ID"
# Existing real VT control after guest is running (keys from accepted common manifest):
VT_RUN_DIR="$OWNED_VT_OUT" VT_ACTIONS="$ACCEPTED_QMP_KEY_LIST" python /workspace/work/linux-vt-product-probe/probes/control-vt.py
# Observe genuine host geometry before/after the operator resizes the OUTER window:
stty size
# Original X11 image of the VERIFIED owned terminal window, no reconstruction:
import -window "$OWNED_VERIFIED_WINDOW_ID" "$NEW_ORIGINAL_PNG"
```

The GUI subset is fixed to Gallery keys, 80x24→100x30→80x24, and F10; it cannot drive composition. Its current hardcoded recorder source is `/workspace/work/auto-final-execution/repo/tests/terminals`; compare that source to final frozen recorders before reuse and record the equality/hash. It does not certify full same-child native termios or live VTE engine. Do not modify its case sequence and call it an existing frozen complete script.

Shared source cases/oracles already exist: `tests/composition/application/{pty.mjs,fixtures.mjs,interaction-contract.md,goldens/}`; `tests/theme_showcase/{pty.mjs,modal-keys.mjs,fixtures.mjs,checks.mjs}`. Do NOT execute their Session backend as an actual-host adapter: `Session.start()` sets synthetic TERM/COLORTERM and synthesizes a DECRQM reply; resize additionally changes its nested PTY directly. Original independent test/operator owner must bind the existing cases/oracles to actual host inputs, without introducing new expectations/framework hooks/emulator. The external transport continuation below supplies an X11 backend while the original test owner still owns profile/dimension admissibility.

| Required scene | Existing public source / fixed test coverage | Actual remaining evidence |
|---|---|---|
| Initial state, keyboard/Unicode/emoji, paste-as-data | composition `src/{tasks_scene,job_panel}.cj`; application/pty.mjs `startup`/`interactions`, literal Unicode `review 中文 👩‍💻`, fixtures paste2004 | same bytes/events, observed actual host fallback/profile; no synthetic replies |
| Disabled/navigation/nested close/focus | composition `src/job_panel.cj`; application/pty.mjs interactions Inspect→Confirm?→Esc/F9 | genuine clipboard/key input, original PNGs and state/oracle binding |
| Scroll/background progress | composition `src/commands.cj` calculate spawn/post; application/pty.mjs interactions/work | F5 result50005000→review→F6 result333383335000; showcase Pending is not background work |
| Size/small view | application/pty.mjs startup80x24/40x12/16x6; GUI subset80x24↔100x30 | real OUTER resize and inner kernel readback, size-specific unchanged source expectations; VT fixed80x25 readback+VT ioctl |
| Four themes/Auto | theme_showcase src/commands.cj F1–F4/F8; theme_showcase/pty.mjs fullCycle/retainedState and fixtures | actual profile/capability sources; don't impose synthetic RGB/glyph goldens on real Auto profiles |
| Exit/failure/cancel/short write | tests/session_lifecycle/{host_run.sh,host_verify.py,cases.json}; existing output_recovery tests | original normal/error outcomes and exact native termios; finite fault matrix may be reused only for unchanged scope |

For mux and SSH capture the real outer XTerm PNG plus inner process/PTY/version/config, keeping their identity distinct. Give paste a dedicated operator-owned clipboard/selection containing the fixed literal; never inspect the user's clipboard. Own XDG settings and explicit forwarding config, capability replies/negative configurations and font/locale/terminfo sources must be preserved. Read original title/OSC52 protocol outcomes/rejection profiles: pixels do not certify that a host applied either. No actual image adapter remains Unsupported.

SSH window-change is UNPROVEN: old `ssh -T` plus remote script proves a remote PTY path only. Proposed `-tt` path above uses OpenSSH's PTY request. Acceptance requires resizing the real owned local outer XTerm, then independently recording local SSH controlling PTY size, remote allocated PTY size before/after, remote app repaint and unchanged process identity, plus server/client versions/config/FD topology. Nested script may fail to propagate window changes; retain that failure and route to original SSH/operator owner. Do not silently use remote stty as proof of SSH forwarding.

VT acceptance requires actual tty1 device/VT_GETSTATE/TIOCGWINSZ80x25, kernel/QEMU versions, QMP send-key events, original screendump PPM and lossless PNG retaining PPM, app original ANSI/input and exact restore through existing guest supervisor. `control-vt.py` expects supervisor PRODUCT_STARTED/GRID/PRODUCT_EXIT markers and its exit-key list is q/ctrl-c/e; it does not currently treat public F10 as an exit marker. The continuation below supplies the exact source-level scene/F10 adaptation; full live common-case VT transport remains unbound and no final VT run is claimed. Serial logs are evidence transport, never the application TTY.

Every final artifact needs source/SDK/dependency/native/ELF/input/operator/config hashes, exact argv/cwd/env allowlist/FD path, actual engine process/maps, UTC start/events/end, direct exit, before/after dimensions and precise termios, original wire/PNG, and independent literal oracle outcomes. No private authentication/environment or quarantined diagnostic trace enters the final archive. Final delivery remains `docs/development/linux-session.md` and `docs/reviews/Linux-final/linux-session-{m1,final}.json`, with one original041 card and planning_gaps until actual proof/review.

Transport continuation (all files still NOTEXECUTED; no new expected data):

`frozen-loader.mjs` appends only exports for existing case functions. `actual-session.mjs` overrides only Session start/send/resize/stop/save and captures after existing waits, retaining original WireScreen, predicates, assertions and fixtures. `x11-transport.py` uses the accepted Xlib/XTest mechanism for a uniquely titled owned real terminal, sends real F/navigation/edit keys, and owns PRIMARY selection for literal bracketed-paste payloads. It never writes keys directly to an application's PTY or changes TERM/COLORTERM. Resize changes the outer X11 window then reads the actual application's PTY dimensions; it does not set a nested PTY size or send SIGWINCH. Each successful original wait requests an original PNG. Unsupported keys, nonmatching dimensions and source assertions fail visibly. Preparation only supports an owned known keyboard map (ASCII letter keys, US `!`); record that map as an actual input dependency.

After147/root GO, with final checkout as cwd and parameter exports above:

```sh
# Runtime dependency inputs: existing Node, Python3, Xlib/XTest, xwininfo, import,
# util-linux script/stty and owned selection-owner executable (e.g. actual xclip).
export C008_DISPLAY_OWNED=1 C008_CLIPBOARD_OWNER="$OWNED_XCLIP_EXECUTABLE"
export C008_HOST_KIND=xterm C008_HOST_ID="$FACTUAL_HOST_LABEL"
# C008_LAUNCHER must preserve dynamic C008_BINARY/C008_OUT/C008_GEOMETRY inherited
# from the Session backend, rather than overwrite them with one fixed case path.
node --experimental-loader /workspace/work/linux-final-host-execution/operator/frozen-loader.mjs /workspace/work/linux-final-host-execution/operator/run-frozen.mjs composition interactions "$NEW_OUT"
node --experimental-loader /workspace/work/linux-final-host-execution/operator/frozen-loader.mjs /workspace/work/linux-final-host-execution/operator/run-frozen.mjs showcase fullCycle "$OTHER_NEW_OUT"
node --experimental-loader /workspace/work/linux-final-host-execution/operator/frozen-loader.mjs /workspace/work/linux-final-host-execution/operator/run-frozen.mjs modal popupSwitch "$THIRD_NEW_OUT"
```

Select `composition startup OUT WIDTH HEIGHT`, `showcase startup OUT WIDTH HEIGHT`, composition `minimal`, or other existing named functions in run-frozen.mjs. Repeat using `C008_HOST_KIND=vte|tmux|screen|ssh`, preserving independent process/config/engine metadata. This backend does not itself create Xorg or discover dependency closure. The caller supplies a dedicated admitted DISPLAY and owned configs. Original expected assertions remain profile-specific and may reject real Auto output; the separate original independent test-contract owner must deliver admissibility/projection contract before this can be acceptance evidence. No adaptations of expected data are included here. JS runtime/syntax checks are deferred because Node execution is prohibited during E146; Python AST and shell syntax checks only were performed.

SSH transport uses shared owned loopback test-host filesystem paths for the actual remote recorder artifacts. Remote launcher receives three shell-safe args: `BINARY OUT GEOMETRY`; it must export C008_BINARY/C008_OUT from those args plus its preadmitted C008_SOURCE/admission/provenance/host label and exec record-public.sh. For genuine non-shared remote machines, this backend is blocked until the existing operator supplies a file-transport binding; it does not silently substitute local PTY paths. Set `C008_DIMENSIONS_READER=/workspace/work/linux-final-host-execution/operator/ssh-dimensions.sh` for SSH, preventing local `/dev/pts/N` aliases from being read as remote geometry. This reader performs read-only `ssh -T ... stty -F REMOTE_TTY size`; it never sets size.

```sh
# Once actual owned ssh PID, shared recorder path and dedicated server facts exist:
export C008_SSH_CLIENT_PID="$ACTUAL_OWNED_SSH_PID"
export C008_REMOTE_SHARED_RECORDING="$ACTUAL_SHARED_REMOTE_RECORDING"
python3 /workspace/work/linux-final-host-execution/operator/ssh-resize-snapshot.py before > "$NEW_PROOF_BEFORE"
# Only actual outer X11 resize via x11-transport; no remote stty/ioctl/SIGWINCH.
python3 /workspace/work/linux-final-host-execution/operator/ssh-resize-snapshot.py after > "$NEW_PROOF_AFTER"
```

The SSH snapshot records local ssh fd0, kernel size, process stat identity, remote ssh-allocated PTY and nested application PTY sizes. Actual proof must show all three change to requested dimensions with the same ssh process and matching public repaint. `-tt` requests allocation; expected SSH window-change behavior is not execution evidence. No OpenSSH clientloop/session source or local ssh manpage was available at targeted prep paths, so this preparation does not claim source-verified forwarding or nested-script propagation. Preserve actual OpenSSH versions, owned server/client configs and resize observations; old `-T+script` evidence cannot establish this new property.

VT final public install is now source-specific: original `/init` accepts arbitrary kernel `scene=NAME`, and original supervisor constructs `/apps/NAME`; therefore `/apps/showcase` and `/apps/composition` need no new application, supervisor or guest-init behavior. `prepare-vt-guest.py` consumes a root-admitted explicit necessary file closure manifest, creates a NEW guest root and copies only listed individual files (no SDK/cache/tree copy). Required files include both final public app ELFs, original `/init`, original supervisor executable, BusyBox and strace; list loader, all transitive DT_NEEDED and actual dlopen runtime files/terminfo with reason and exact hash, plus original base symlinks. The caller must supply the complete verified minimal original base closure and runtime manifest; no ldd/build/copy occurred during prep.

```sh
# Required C008_VT_CLOSURE_MANIFEST schema shown below, fresh root/output paths:
python3 /workspace/work/linux-final-host-execution/operator/prepare-vt-guest.py
python3 /workspace/work/linux-final-host-execution/operator/pack-vt-guest.py
VT_SCENE=showcase bash /workspace/work/linux-final-host-execution/operator/launch-host.sh vt
# In the separate admitted controller, after actual guest start:
VT_ACTIONS=f2,f5,f9,f10 python3 /workspace/work/linux-final-host-execution/operator/control-vt-f10.py
```

Closure manifest shape: `{"status":"ROOT_ADMITTED_NECESSARY_RUNTIME_CLOSURE","admission147":"ABSOLUTE_ACCEPTED147_PATH","files":[{"source":"ABSOLUTE_EXISTING_FILE","destination":"/apps/showcase","sha256":"EXACT_FILE_HASH","reason":"final public showcase ELF"}],"symlinks":[{"destination":"/bin/sh","target":"busybox"}]}`; illustrative row is not a complete runtime. Required `C008_VT_NEW_GUEST_ROOT`, `VT_INITRD`, `VT_RUN_DIR` are new owned paths. Packer runs the original CPIO implementation with only guest-root/output paths parameterized. `control-vt-f10.py` executes original QMP controller with the sole text change adding `f10` to exit recognition, preserving send-key/PRODUCT_EXIT/original VGA capture. Source hashes/change descriptions are emitted at future execution. There is no full frozen Session live VT backend here: original controller has qcode keys and post-exit strace export, not a live app-wire feed or Unicode clipboard. Existing source `export-evidence.py` decodes actual strace after guest exit. Live common-case VT binding remains a precise transport gap for original VT operator; no ANSI reconstruction from a grid or synthesized host reply is introduced.

VT live-transport continuation supersedes the earlier unbound-live-feed gap (still NOTEXECUTED): `vt-supervisor-transport.h` plus `derive-vt-supervisor.py` derive the existing supervisor by six exact source substitutions; product/app/native UI code remains unchanged. The original strace command retains only read/write/ioctl tracing, without execve or environment expansion. Its `-o` target becomes an owned FIFO; the same supervisor drains original strace text to the original regular `.strace` artifact and hex-framed `TRACE` records over existing `/dev/ttyS0`. No extra guest driver, network, shared filesystem, emulator, ANSI emitter or screen parser is introduced. `vt-transport.py wire` uses the literal successful write(1)/read(0) extraction rule from original export-evidence.py; `vt-session.mjs` feeds those actual syscall bytes to the original WireScreen/Screen. After exit run original export-evidence.py and compare live-original.strace to archived guest `.strace`, stdout.raw to original stdout-raw.ansi, and actual-input.raw to original stdin-raw.bin. Any discrepancy is FAILED_TRANSPORT, never repaired.

Controlled kernel-keyboard test input uses installed Linux UAPI `/usr/include/linux/{kd.h,keyboard.h}`: KDGKBSENT/KDSKBSENT string slot11 (F12,512 bytes); KDGKBENT/KDSKBENT normal-table keycode88 (KEY_F12) set to K_F12. Before first mapping the supervisor archives originals and requires actual K_XLATE or K_UNICODE. A control-serial `mHEX\n` message accepts up to511 non-NUL fixed test bytes, including original UTF-8 emoji and bracketed-paste boundaries; it sets/readbacks both mappings and emits `MAP_READY seq=N ... controlled_bytes_hex=HEX`. Only after this ACK does vt-transport send genuine QMP `send-key f12`. Consequently the actual tty1 read comes from the guest kernel keyboard path, not serial stdin, TIOCSTI, a PTY, or an app hook. These are explicitly controlled test-input strings, not a claim of kernel VT clipboard/selection support. Original maps are restored/readback-checked at normal supervisor completion, with `KEYBOARD_RESTORED` evidence. Error/denied ioctls fail visibly; no privilege bypass or unsupported success fallback. These keymap ioctls mutate only the owned disposable guest, never host console configuration.

The transport captures actual stdout fd1 tty/device identity, VT_GETSTATE, KDGETMODE,80x25 TIOCGWINSZ, same-fd GIO_UNIMAP count/error/full binary map, and complete before/after termios representations with raw struct files. These supplement original supervisor kernel/restore and VGA evidence. Actual application stdin and stdout remain inherited `/dev/tty1`; only strace's diagnostic output channel uses the FIFO. No original app stdout identity is changed to a pipe or PTY. Required attributes/color/terminfo/profile facts and result interpretation remain the separate frozen independent contract's responsibility.

```sh
# FUTURE GO ONLY: derive and build external operator native supervisor with host cc.
# C008_VT_OPERATOR_BUILD must be a new owned build directory.
python3 /workspace/work/linux-final-host-execution/operator/derive-vt-supervisor.py
cc -std=c11 -Wall -Wextra "$C008_VT_OPERATOR_BUILD/vt-product-supervisor.c" -o "$C008_VT_OPERATOR_BUILD/vt-product-supervisor"
# Bind that exact executable/hash at /vt-product-supervisor in admitted closure.
# Then run prepare-vt-guest.py and original-path-parameterized pack-vt-guest.py.
export C008_HOST_KIND=vt
export C008_VT_SHOWCASE_ELF="$FINAL_SHOWCASE_ELF" C008_VT_COMPOSITION_ELF="$FINAL_COMPOSITION_ELF"
export C008_TEST_INPUT_ROOT=/workspace/work/linux-final-host-test-contract/inputs
# The separate independent binding must select fixed80x25 literal/profile
# expectations before common case execution; do not run raw80x24 tests on VT.
```

All VT additions are unbuilt/unexecuted. First admitted validation must establish ioctl permissions/readback, active concrete tty1/stdout identity, exact controlled F12 input versus actual read(0), complete/untruncated FIFO serial trace equivalence to original guest archive, map restoration and VGA capture. Existing UART/control channel behavior and new FIFO throughput must meet the original12-second case deadlines; if not, preserve failure rather than extend assertion deadlines. Fixed80x25 and smaller-case NOT_APPLICABLE selection comes only from frozen independent contract `/workspace/work/linux-final-host-test-contract/contract.md` (SHA2561db1c49ff757a39fd9cb70b078a7c34a190a05a67edc6a855c628fd777cd3ca5), literal-80x25.json, color-projections.json and copied inputs. The transport does not choose or rewrite expectations.

Independent executable binding is now the sole entrypoint: use `run-admitted-binding.sh GROUP CASE NEW_SESSION_DIR [WIDTH HEIGHT]`, which invokes the exact `/workspace/work/linux-final-host-test-contract/{frozen-loader.mjs,run-frozen.mjs}`. Set `C008_NODE` to the admitted existing Node executable. The local original run-frozen/frozen-loader files remain pinned interface references, not expectation authorities. The independent bundle index at handoff is SHA256 `bb653a9290defc7db0a8cced5a49cfd18209ca809380e42a70950425ec6a623c`; the actual runner verifies its fixed input and transport hashes. All four pinned transport-interface files remain byte-identical to frozen-transport-interfaces.json; wiring changes affect external recorders/helpers only.

Future raw profile commands, executed in the same actual app host/remote environment (or guest via its existing owned setup interface), before the common case and preserving that environment/config:

```sh
# Required known executables and actual source evidence; no discovery probe ran now.
export C008_INFOCMP="$ACTUAL_EXISTING_INFOCMP" C008_TPUT="$ACTUAL_EXISTING_TPUT"
export C008_LOCALE="$ACTUAL_EXISTING_LOCALE" C008_STTY="$ACTUAL_EXISTING_STTY"
export C008_ACTUAL_STDOUT_DEVICE="$ACTUAL_APP_STDOUT_DEVICE"
export C008_ACTUAL_HOST_IDENTITY_EVIDENCE="$ORIGINAL_IDENTITY_AND_UTF8_CONFIG_RECORD"
export C008_ACTUAL_TERMINFO_ENTRY="$ACTUAL_RESOLVED_TERMINFO_FILE"
# For actual failure only: C008_ACTUAL_TERMINFO_FAILURE_REASON from native evidence.
# For VT only: C008_VT_ACTUAL_SERIAL=actual supervisor serial from same fd1/map run.
python3 /workspace/work/linux-final-host-execution/operator/collect-profile-facts.py "$NEW_RAW_PROFILE_DIR"
export C008_EXPECTED_PROFILE="$NEW_RAW_PROFILE_DIR/profile-envelope.json"
bash /workspace/work/linux-final-host-execution/operator/run-admitted-binding.sh composition startup "$NEW_SESSION_DIR" 80 24
```

The collector archives exact `infocmp -1 -x -- TERM` output and exact `tput -T TERM` values for present colors/ncv/six capability strings; absent/cancelled entries stay raw unavailable. RGB/Tc booleans transcribe typed flag presence from infocmp, not product output. It records a narrow environment allowlist, actual resolved terminfo entry hash, identity/config/UTF8 evidence hash and complete VT stdout map records. It does not choose expected color mode, attributes, glyphs or grids. Missing executable, identity, failure reason, actual entry path, stdout/map proof or UTF8/config provenance remains INSUFFICIENT_EVIDENCE and blocks admission. The existing guest currently has no admitted infocmp/tput deployment; root's actual operator must provide their exact necessary runtime closure or an existing equivalent raw ncurses evidence capture, preserving original facts. No tools/dependencies are installed by this preparation.

Lifecycle materialization preserves the pinned Session interfaces. `record-public.sh` now derives `inner-evidence-recorder.sh` from the original frozen inner recorder with exact checked anchors. Existing `tests/session_lifecycle/host_probe.py` runs before/after on the SAME inherited inner `/dev/tty`, independently records literal mode25/2004 queries/replies/timeouts and restores its own exact termios. The ordinary public app retains that actual stdin/stdout, runs as an observed child with exact PID/start/exit UTC, and the original stty snapshots remain on that endpoint. `materialize-lifecycle.py pty` hashes those original files, recorded actual input/output, direct exit and cursor observations into the exact independent lifecycle schema before the original `exit_status=` readiness marker is published. It never supplies a DECRQM reply. Known before/after cursor must agree; Unknown requires no managed25 mutation. A missing/contradictory field fails rather than emitting success. Probe traffic is identified by its original before/after files/UTC/timing, separate from controlled app keyboard events.

For the minimal VT guest the external supervisor overlay ports only the existing host_probe query/poll/raw-restore mechanics to native collection: one literal mode25 query,650ms genuine response/timeout, exact probe-termios restore, before/after raw observations and UTC nanoseconds on tty1. This adds no app hook or capability policy. `vt-transport.py wire` transcribes those serial originals after real PRODUCT_EXIT, uses native wait status and full same-fd stdout termios strings, and calls materialize-lifecycle.py before exposing completed exit to the pinned Session backend. Its cursor-observations.json is derived only from actual CURSOR_OBSERVATION records; no record/no response evidence means INSUFFICIENT_EVIDENCE. Original serial/native files and successful-syscall input/output are the hashed lifecycle originals. The native cursor extension is source-only/unbuilt; its actual ioctl/query/timeout/restore behavior requires independent admitted execution review.

Review scope: this author executes no host work. `review-index.json` lists current transport source hashes, frozen interface equality, independent binding index reference, static source-only checks, and precise changes from the previous handoff. Root/independent review precedes a separate actual-host execution role after147/root GO. No product/test/independent expected file was modified, no expected-data resolver was added, and final acceptance remains false.

R1 correction (supersedes earlier completion/extraction/readiness claims): lifecycle schema is emitted only after the owned recorder/QEMU has closed; all links are immutable completed-original copies, with final-source/copy hashes rechecked during save. Live app-exit notification is separate from sealing. VT readiness waits every mandatory marker. The unchanged reviewed E146 syscall joiner is vendored by exact hash; a narrow PID/frame adapter inventories annotated read/write/readv/writev and captures only complete successful bytes, rejecting unresolved/truncated/ambiguous output. Strace has -f/-ttt/-yy/-xx/-v/-s0 and traces no exec/environment expansion. Old export-evidence.py's single-line decoder is no longer canonical for these R1 traces.

R1 cleanup always runs on failed checkpoints, including image loss. It requests ordinary quit, bounds owned app/VM completion, then targets only the spawned detached process group and exact recorded app identity/isolated mux endpoint; forced cleanup is recorded as failure finalization, never successful case completion. An unavailable post-exit window is optional only after normal completion; every live required wait captures or fails with persisted checkpoint/error. Clipboard ownership has a scoped foreground child and finally termination/reaping after actual input observation.

VT fileReload uses only the exact frozen launcher form, preserving admitted showcase ELF identity. The external scene `showcase-file` passes its ordinary public `--theme-file /evidence/selected.toml` argument. Initial and changed bytes of the one owned source fixture are sent over the existing control serial, written atomically, and acknowledged exactly before the original F6/F7 input. Other launchers/argv/paths fail closed. No case or assertion is skipped.

Executable guest fact path: admitted closure must include individual `/dlmopen-check`, `/usr/bin/{infocmp,tput,locale}`, `/usr/share/terminfo/l/linux`, their necessary ELF libraries, and existing init BusyBox applet links; `elfClosureEvidence` supplies path+sha256 of actual dependency evidence. The preparer copies guest-facts.sh, derives only explicit C.UTF-8/PATH init configuration, and the supervisor captures raw same-guest ncurses/locale/size files. After original archive export, invoke `python3 operator/guest-profile-facts.py EXPORTED_EVIDENCE/guest-profile FINAL_SERIAL NEW_PROFILE_DIR`; it transcribes/hash-binds raw facts only. Failure of UTF8, entry or same-stdout map proof blocks admission. No guest Python or whole SDK/cache copy is needed.

R1 immutable review handoff: ../fix-round1/{index.json,scoped.diff,snapshot/,fixreport.md,validation.json}. Four interface paths are retained; actual-session.mjs/vt-session.mjs have revised bytes. Independent binder's SHA-only forward rebind is required after scoped review; no actual-host GO is implied.
