# TASK020.a formal author tests

Fixed base `13e7880ce96d1331fc9e12a2b62275a307183e9a`; original prepared commit
`4c6bf48dc849b92cb72ae842b2eec9c933854838` preserved in its original worktree.
Classification: execution within C004 and frozen public contracts, no new API.
Only this test directory changed. Author proof is separate from independent
review, execution, acceptance, final020/M1/M2/Linux/release completion.

The public Application consumer covers21 scenarios ×3 caret states ×2 runs
in each of normal Auto/no-title and explicit declared-title stress configurations,
using one process per row, plus actual endpoint destruction without fake restart.
`cases.json` and `manual-coverage.md` fix literal outcomes. No second writer,
parser, renderer, Unicode data or runtime; no product test hooks. The Box type
holds UI-thread fixture state, and business-owned Future.get joins workers.
Normal consumer code never emits ANSI or manually flushes. PTY DECRQM reply
injection is explicitly protocol-wire emulation, never actual host acknowledgement.

`native/lifecycle_native.c` composes the unchanged accepted Session152 helper.
It observes real native raw flags, custom original signal handler/mask/flags,
realloc/free lifetime, competing native ownership and actual read0. Fault-close
injection occurs after real close/restoration. OSpipe transport changes only
read/poll endpoints after actual TTY startup; termios/output remain the original
PTY. `tty-eof` sets ICANON/VEOF externally to obtain a real kernel TTY read0,
then product cleanup restores exact original termios; it is not spontaneous
EOF of an untouched raw TTY. `endpoint_hup.py` closes the last real master,
records read0/EIO/cleanup failures and forbids same-endpoint restart. It never
repairs a descriptor or claims termios restored on the destroyed endpoint.

Build once with pinned SDK1.2.0, official registry and readonly warm cache.
The ignored root/consumer cangjie-repo.toml references the supplied cache.
Native Unicode archive/library may reference the exact pinned existing content;
no SDK/cache/CJP copies or18973 relay. Preserve direct exits and failed first logs.

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CANGJIE_STDX_PATH=/workspace/work/linux-build-recon/stdx-env
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
export CJTUI_020_ROOT_GO=1
export CJTUI_020_ADMISSION=/workspace/work/terminal.ui/.superpowers/sdd/tasks-complete-linux-integration/task-020-input-manifest.json
bash tests/session_lifecycle/run.sh prepare-check
bash tests/session_lifecycle/run.sh build
bash tests/session_lifecycle/run.sh run --output /absolute/new-evidence-directory
```

`run --case ID` runs three caret rows for one scenario; default also runs the
separate endpoint HUP case. `host_run.sh`, `host_probe.py`, `host_verify.py` and
`host-plan.md` fix actual XTerm/VTE/VM-VT protocol/keys/baseline/PNG expectations
for independent host execution. Probe helpers read actual /dev/tty replies,
never supply them. These host fixtures are syntax-checked, not host-executed.
Normal host runs keep Auto and make no optional title request; explicit
CJTUI_020_HOST_TITLE_STRESS=1 is a separate opt-in. Real host identity/config/
PNG/title property observations remain required.

`reuse-map.json` pins accepted008/010 and finite152/117/122/112/162/I015 evidence.
Unchanged production code/deps/env/config/scope reuses prior valid proof under
AGENTS11.1. No008338 bytecut rerun; old captures never become this binary's
host proof. RuntimeStats.frames is never a device commit/success counter.

Review fix R1 (020R1–020R4): endpoint HUP now honors and records the requested
Auto/declared policy, with separate exact first-error lists. The native observer
records every Linux termios field (including raw speed fields) and endpoint
identity before native open and after each close. The host oracle requires
same-child equality; outer script stty is supplementary only. A destroyed
endpoint must retain EIO/unavailable, never a repaired state. Combined-error
lists are exact/ordered; mode25 restoration is checked for each managed run.

`python tests/session_lifecycle/host_transport_check.py --binary BINARY --output NEW_DIR`
validates the host runner/probes/oracle using real nested kernel PTYs and
explicitly emulated protocol replies. Its wrong-child-ECHO negative control
must fail the host runner despite direct child exit0 and restored outer stty.
It is transport validation, not actual XTerm/VTE/VM-VT evidence. The negative
mutation is opt-in test fixture code; it never repairs state to pass an oracle.
