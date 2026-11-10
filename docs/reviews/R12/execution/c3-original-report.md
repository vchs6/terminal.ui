# TASK-074 independent execution — FAIL, one unresolved regression

Fixed candidate `c3d743d2dd5cb125e4ca435b2842d1b10c501281`; `tests/runtime` exactly equals independent author freeze `fc690c68`. TASK073 final PASS was explicitly conveyed before any product build/run. This role made no tracked product/test/contract/metadata edits and spawned no agents. Requested Sol/medium; actual serving variant/effort cannot be independently verified.

Final audit: `evidence/final-verification.json`. Command stdout/stderr/true exit/UTC timestamps are retained in each named evidence directory; `env.sh`, `run-logged.sh`, execution scripts and `preparation.md` give reproduction/setup. SDK cjc/cjpm1.2.0, x86_64 Linux, Node24.22.1; own official-seed dependency cache, existing public-byte registry relay18973, read-only UCD17 zip. Normal hooks compile product native archives. Dependency source comparison confirms all113 source/config files equal official seed. No copied product target/native artifact, special compiler flag or skipped lint rescues any build.

## Results

| Check | Actual result |
| --- | --- |
| Ordinary root build/check | Both exit0 |
| Entire runtime core normal build/direct binary | Exit0,255 PASS records including F007 owner/post/getter/context/cleanup regressions |
| Candidate macro-positive normal build/direct binary | Both exit0 |
| Fifteen frozen macro-negative fixtures | Valid existing results reused; every status/location/concept/hash independently checked |
| Runtime session normal build +12 real PTY scenarios | Exit0,failures0; expected app failures exit1; exact restoration/once-only close/cleanup checks passed |
| Contract,coordinate,colors,layout,decoration,complete composition/file consumers | All normal builds/direct assertions completed successfully |
| Application-lifecycle | Five scenarios passed; resize-success failed; combined regressions command exit1 |
| Normal cjpm bundle | Exit0; SDK build/test/lint actually ran, unsuppressed warnings retained |
| Archive completeness checker | Exit1: missing `examples/composition/cjpm.toml` (known full-release gap) |
| Clean extraction ordinary root build/check | Both exit0 |
| Same frozen core consumer against clean product | Normal build/direct exit0,255 PASS records |
| Same frozen macro-positive against clean product | Normal build/direct exit0 |
| Clean packaged reactive example | Normal build and direct real PTY exit0; Count0→1,Ctrl-C,exact termios |
| Actual reactive example in two GUI terminal implementations | Both passed positive state/real resize/exit/restoration; original PNG/raw retained |

Macro reuse follows AGENTS11: no changes from `f07ff63303071764ea4acef5ba547d617e9d9a7c` to macro sources/negative fixtures/runner/root manifest/native/build hook; public declaration diff changes only a visible(Bool) body, not its signature; same SDK/config. Original evidence/artifact SHA256 manifests validated. Each negative independently has nonzero compiler exit, relevant source-located forbidden-construct diagnostic, and no resolution/network/link failure (`macro-negative-independent-audit.json`). Positive behavior was built/run anew on candidate and clean package.

## Unresolved lifecycle resize failure

Unmodified runner: `./tests/run-slice.sh application-lifecycle`; error at `tests/application-lifecycle/pty.mjs:48`, "resize honors actual width". Raw copied from `/tmp/cjtui-lifecycle-9TyB0R` to `evidence/lifecycle-raw`; all six result JSON files retained. Other five cases verify normal q/default Ctrl-C and callback/restore failure exits with exact restoration.

Failed306-byte stream: initial24×5 frame, intermediate24×3 frame still containing `0123456789ABCDEFGHIJKLMN`, then correctly clipped8×3 frame with `01234567`. The assertion excludes the longer string throughout the post-resize interval, so the intermediate frame triggers failure. Application.run reads width and height through separate `cjt_size(0)`/`cjt_size(1)` ioctls; a resize between those calls is consistent with mixed dimensions. This is a raw/source-based triage hypothesis, not a unilateral product/test attribution or fix. Coordinator was notified immediately. No rerun-to-green or assertion weakening occurred. Harness forcibly cleaned up this failed scenario; it has no successful normal-exit/restoration claim.

## Idle process CPU

Frozen optional PTY measurement: actual PID810044; viewport512×256,2048 pure getters,cjHeapSize unset/default,CLK_TCK100. Over2.003816325s, user ticks168→168,system329→330: **0.01 CPU seconds**,0.004990477358247892 equivalent cores. Public idle work counters, true exit and exact restoration passed. Raw JSON at `evidence/cjtui-runtime-pty-qFhn8c/idle-cpu/idle-cpu.json`.

Independent fixed-f07 baseline JSON copied from test-author raw to `evidence/baseline-idle-cpu.json`: identical parameters/default heap,1.30 CPU seconds over2.004029228s. One-host observations show lower idle process CPU after the fix; no absolute threshold, private-subsystem attribution or portable performance guarantee. Initialization precedes public acknowledgement; normal process activity in the window is included. One tick is10ms resolution; a zero-tick sample would mean below resolution. Earlier1024² OOM is not a CPU sample.

## Real hosts and clean source artifact

Original public reactive example ran in **XTerm398** and **xfce4-terminal1.1.4/Xfce4.20 (VTE)** on separate genuine Xorg instances. Independent raw CUP/SGR reconstruction confirmed each Count0→1→2→3, with actual100×28→120×34 PTY resize. Default Ctrl-C app/inner/outer statuses all0; exact termios before/after. Original increment-two PNGs were viewed and visibly show Count2 and the public instruction text. Full versions/config/window/grid/source/binary/hash/UTC/raw/exit/original PNG evidence: `evidence/gui-reactive/{xterm-default,xfce-vte}/interrupt`.

External `gui-reactive.sh` adapts frozen R10 host/recorder/capture methods outside the checkout. `gui-key.c` sends one XTEST key instead of R10's automatic key+Return, because every key increments this example. Compile with `gcc -O2 -Wall -Wextra -Werror gui-key.c -ldl -o gui-key`, then `execute-gui.sh`. No image editing/redrawing. The ordinary example has no acknowledgement fence: these positive output checks do not establish silent/no-op processing. Successful GUI resizing does not erase the lifecycle race failure.

Normal source bundle retained as `evidence/cjtui-0.0.0.cjp`, SHA256 `e3e72bd8f60550fb30671dfb240b06854924a4086b8a828755374fbfbbfbec53`. Extracted src equals candidate src. Copied frozen public consumers differ only in two manifest cjtui.path values; packaged reactive source stays unchanged (`clean-source-comparison.json`). Ordinary clean root/native hook and public consumer builds/direct binaries all succeed. Binary hashes retained in `executed-binaries.json`.

**Finite TASK074 verdict remains FAIL pending lifecycle resize resolution.** The separate archive completeness failure remains a full-release delivery gap; `check-product.sh release` was not run or claimed. No dynamic C,focus/overlay/theme/M2,parent AC,all-Linux-host or full release completion is asserted. Console/tmux/screen and other hosts remain outside this evidence.
