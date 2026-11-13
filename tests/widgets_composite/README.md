# TASK158 independent M formal tests

This is a normal public CJPM consumer for frozen W001–W007, W006-S, LEGACY-PROP-001 and M01–M05 plus affected S02. The fixed baseline is main `d78e0a85523c34da352aba266df044b78add414c`, with accepted product source `1df1325f7b51777d8adab62f950c936051aa5876`. `input-manifest.json` is the coordinator's verbatim M admission published on main `60653f18bd8cc3411ae0a8601bedc2c0137d1ea5`; it records accepted prerequisites, not acceptance of these tests or TASK159. Original preparation remains preserved in `/workspace/work/widgets-composite-tests/source` and its original report/logs.

Only public `cjtui` APIs are consumed. There are no local widget declarations, fake Runtime/decoder/types, private imports, replacement layout/renderer, target helper-derived expectations, or hidden target-symbol gate. `SharedPanel` is an ordinary user component. Business arrays, requests, explicit overlay close, and shared model remain owned by the application. `prerequisite` checks accepted primitives and S-only modifier regression; it is never linked into the M consumer as a substitute implementation.

From the repository root:

```sh
bash tests/widgets_composite/run.sh self-test
bash tests/widgets_composite/run.sh formal
CJTUI_COMPOSITE_RED_OUTPUT=/tmp/M-red-NEW bash tests/widgets_composite/target-red.sh
```

The scripts source SDK `/workspace/work/validation/sdk/cangjie/envsetup.sh`, use `CANGJIE_STDX_PATH=/workspace/work/linux-build-recon/stdx-env` and `CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip`. Reuse the existing cache without copying it. Each consumer and source root needs this ignored `cangjie-repo.toml`:

```toml
[repository.cache]
path = "/workspace/work/viewport-tests/cache"
[repository.home]
registry = "https://pkg.cangjie-lang.cn/registry"
```

`formal` normally builds/runs the accepted prerequisite, builds/runs the complete headless consumer, then builds the device consumer and drives three real PTY modes. It returns the actual first failing build/binary status. There is no old exit77 admission gate. On the pre-TASK159 baseline the M factories/types are absent, so headless M execution and native PTY execution remain blocked. Missing-API compiler RED proves that boundary only; it does not prove M runtime behavior or full consumer type correctness after M becomes available.

`target-red.sh` isolates only six absent public targets in a tiny normal consumer. At this fixed baseline it requires compiler exit1 and exactly six attributed diagnostics: undeclared MenuEntry/SplitAxis, and non-callable HorizontalMenu/PopupMenu/StatusBar/SplitPane (the existing imported ThemeRole variants have those spellings). The classifier rejects any extra diagnostic, package/import/macro/syntax/setup contamination, or non-target source location. Wrapper exit0 means the actual RED was correctly classified. TASK159 must make this historical RED recipe cease to succeed; the formal runner must then pass instead.

`src/*.cj` contains executable assertions over public frame cells and exact styles, refs, physical children, focus, events, error codes, overlay handles/reasons, and resource stats. Expectations are literal and hand authored. `expected.json` is a matching observation catalogue, not synthetic actual output. `oracle.py --self-test` only checks that catalogue and mutation rejection; direct CJPM consumer assertions are the runtime oracle. `COVERAGE.md` maps each condition to its executable fixture and remaining execution obligation.

The real PTY driver uses `os.openpty()` with a fixed 40×6 terminal, direct `Application.run`, and public callback/focus files. It waits for the actual first frame and event fences, sends arrows/Home/End/HT/CR/Space/Alt+Space/bracketed paste/standalone Escape, and asserts exact focus/request/layer traces. It exercises nested modal Escape, explicit callback close, latest shared model, callback/getter failures, exact termios recovery and native cleanup bytes. This PTY fixture sends no DECRQM report: it requires exactly one mode25 query, zero mode25 h/l/s/r commands, zero alternate-screen1049 h/l commands, and one ordered bracketed-paste2004 enable/disable pair. Pending/Unknown caret visibility is unmanaged; no cursor-show or alternate-screen-exit command is invented as a restore requirement. Known-mode restore coverage remains the accepted upstream contract/final020 scope. Raw input/output, stderr, process status, binary hash and metadata are saved to `CJTUI_COMPOSITE_PTY_OUTPUT` (a new directory). PTY tool self-test uses a tiny plumbing child and never counts as product execution.

After TASK159, run `formal` on its fixed source, preserve actual headless/PTY logs, then run affected S and TASK011/interaction B/C/117 regressions using their accepted entrypoints. Produce a normal source bundle via the producer's documented `cjpm bundle` flow and run this unchanged consumer against that extracted cjtui path in a fresh package workspace. Native host routes and screenshots remain the independent execution role's work; no PTY result is claimed here from an absent binary. This scope does not close TASK027, TASK041, all Linux, TASK019 or the parent layout task.
