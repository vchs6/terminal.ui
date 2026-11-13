# TASK-153 independent S test delivery

Fixed prerequisite source: `8053274ad8bb7b40d35f36eac80f07745531c729` (accepted product scope `b71cb2eb`, E22ca byte-equal). Formal upstream admission is recorded by `docs/reviews/widgets/S/input-manifest.json`; the historical wording in the design and the old preparation report does not supersede that manifest. W001–W004, common failure rules and W007 are the contract. M tests and whole-Linux acceptance are outside this delivery.

This is a normal public CJPM consumer. Only `tests/widgets_small/**` changes. It reuses the existing hand-authored preparation frames/events/lifecycle cases and `expected.json`/`oracle.mjs`, corrects escaping local-var captures with let-held arrays, and appends the missing cases. There are no widget declarations, substitute runtime/backend, private imports, ANSI output, or product helper-derived expectations. Counters and fixture palettes are test data. Collector assertions require exactly five factory roots plus their enclosing Column.

## Reproduce

Source `/workspace/work/validation/sdk/cangjie/envsetup.sh`; use SDK1.2. Export `CANGJIE_STDX_PATH=/workspace/work/linux-build-recon/stdx-env` and `CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip`. Do not copy the SDK or cache. Put this ignored configuration in the source root and every consumer package run below:

```toml
[repository.cache]
path = "/workspace/work/viewport-tests/cache"
[repository.home]
registry = "https://pkg.cangjie-lang.cn/registry"
```

From the source root:

```sh
bash tests/widgets_small/run.sh --oracle
bash tests/widgets_small/run.sh
CJTUI_SMALL_RED_OUTPUT=/tmp/small-red-NEW bash tests/widgets_small/target-red.sh
```

The ordinary runner builds/runs `prerequisite`, builds/runs the full headless consumer **directly**, then builds the device consumer, drives its real PTY normal/callback-failure/getter-failure modes, and checks the two independent forbidden Bool constructors. It propagates the real CJPM/direct-binary exit. Current source lacks all five factories, so the full target build fails before headless or PTY execution. A failed import is not a behavioral test or Bool-signature rejection. `target-red.sh` is the intentional RED verifier: after prerequisite build/direct0, each tiny public `red_*` package must independently produce compiler exit1 naming its own missing factory; the wrapper's exit0 means only that RED classification was checked.

The obsolete synthetic gate tool is retired from this final suite. Its original source/logs/report remain untouched in `/workspace/work/widgets-small-tests/source` and `/workspace/work/widgets-small-tests/evidence`. The normal runner has no symbol gate, synthetic list, stub, or target-as-prerequisite check. Old77 and synthetic gate controls are not used as current RED evidence.

## Coverage and literal observations

| AC | Normal test source | Independent observations |
|---|---|---|
| S01 | `main.cj`, `construction_cases.cj`, five `red_*` packages | All constant/getter/default-label/named-label overloads; raw component block and chains; exact `L/B/[ ] C/(*) R/===---` five-row frame; public stats6 and children5 detect duplicate collectors/wrappers; invalid Text-gap/Canvas-wrap must raise InvalidProperty. |
| S02 | `event_cases.cj`, `event_boundaries.cj`, `device/src/main.cj` | All seven ctrl/alt/shift combinations for Enter and Space on Button/Checkbox/Radio; paste/multi-space0; capture/bubble/app prevent0; consume0; stop-only1; legal unfocused0; disabled ancestor rejected; committed enabled timing versus explicit prevent; exact `root-capture;target-capture;target-bubble;root-bubble;app;legacy;callback;` trace; prevent before callback; ancestor default0; later same-phase defaultAction replaces builtin. Checkbox reads once/requests once without model write, latest checked read, selected Radio once-read/zero-request/consumed, duplicate labels with distinct application IDs. Native sequence: Enter, HT+Space, HT+Enter, selected Space, q. |
| S03 | `main.cj`, `caption_matrix.cj`, `theme_cases.cj` | Latest Unicode captions long→short→empty for all caption getters; combining/ZWJ/CJK exact whole-cluster frames; all C0, DEL, C1 and LF/CR/CRLF/U+2028/U+2029 rejected for every caption factory constant/getter. Literal structured Style palette: focused blue, selected yellow, disabled red, explicit foreground green, black background and all attributes false. Detached uses public inline StyleRule because render has no theme argument; mounted uses named Theme.parse rules. Ancestor/late-enabled/getter-disabled, false cannot suppress real disabled/focus, true appearance changes no behavior/focus, later visualStates replaces builtin selected slot. Theme width/wrap remains effective. |
| S04 | `main.cj`, `progress_geometry.cj` | Literal bars at 0/.5/1/-0, widths0/1/20, heights0/1/2; natural Row20 and Column1; padding, theme dimensions versus explicit dimensions; both segments exact defaultStyle; every invalid finite/range value in constant/getter and zero/nonzero extents. Viewport logical20, visible5=`=====`, offset8=`==---`. Fraction-only public stats: one subscription, unchanged builds, increased paints; no assertion that M1 measures stay unchanged. |
| S05 | `lifecycle_cases.cj`, `remount_cases.cj`, device+`pty.py` | Callback/getter sentinel preserved; cleanup once, stale refs invalid; unmount/new-instance remount preserves business data; queued old-generation owner post discarded; live worker post updates next UI boundary; spawn Future.get establishes handshake (no timing sleep); two applications share latest business model; dispose/failure public resources0/0/0/0. PTY records input/output/stderr, direct0/21/22, sentinel error, cleanup1, exact stty before/after and paired native paste modes. |

`expected.json` and `oracle.mjs` remain the original literal fixture sanity checks, not the complete coverage index or product execution. `cjfmt` parsing/format output, Python byte compilation, shell syntax and fixture sanity are tooling evidence only. With missing target imports, full-body target type checking, overload acceptance, headless behavior, PTY behavior and clean-bundle target execution remain pending; do not infer them from parser success.

For S04, public subscription cardinality catches a fraction observable added to both measure and paint readsets and combines with literal repaint/no-rebuild checks. The test never reads private binding records or assumes a measure-call count. Independent product review must additionally check that the measure closure reads no fraction and returns only constrained natural20×1; one public subscription alone cannot identify which binding owns it.

## Clean bundle consumer and handoff

After TASK-154 supplies the factories and a real `cjpm bundle` archive, run:

```sh
python3 tests/widgets_small/bundle-run.py /ABS/PATH/cjtui-0.0.0.cjp --output /tmp/small-bundle-NEW
```

This extracts only regular source archive entries into a new directory, copies this test suite there without targets/locks/registry/SDK/cache, binds dependencies to that extracted product, and invokes the same normal runner. It prints the actual archive SHA. No clean-bundle target PASS is claimed now.

Formal test delivery evidence belongs to `/workspace/work/widgets-small-tests/final/evidence/index.json` and `report.md` beside that directory: fixed test SHA, input/source/SDK/prerequisite-binary hashes, exact commands/cwd/exits and raw hashes. Those are independent test-author facts only. TASK-154 product, later independent review/execution/acceptance, M and Linux completion are still outstanding.
