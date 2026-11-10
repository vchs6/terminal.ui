# TASK-062 fixround1 scoped re-review — product and partial tests

## Scope and current verdict

Product target: **`f8b194eadce879e8fe3a8c900c0bd7aa8d9bd8c2`**. This is a scoped re-review of F1/F2/M1/M2 and tests F3/F4/F5, not a new whole-slice review. The first-round FAIL report remains byte-for-byte in both `review.md` and `round-1.md` (SHA256 `8b697ba70e84cc1f27d26ed4f035efc9db7fefde1be2a8dcbd7034a0a6849000`). Original probe sources, binary and result files remain in `probe/`; new fixed-source checks are separate in `probe-round1/`.

**Product repair scope: spec PASS; quality PASS with the expressly adjudicated localized row-emission duplication deferred.** F1/F2/M1 are closed. M2's unused-wrapper portion is closed; its localized duplication portion is deferred by the controller's ledger ruling. No new product finding in this delta. **Whole technical review is still NOT CLEARED:** final combined spec/quality verdict is pending fixed F6/F7 plus the ordinary-colors capture delta and their scoped review. This document does not certify TASK063 execution or final acceptance.

Independent checkout was advanced from `96a8c4b` to the exact product target. Model dispatch remains `gpt-6-astra/high`; no subagents were used, no author analysis or self-assessment was read, no product/frozen test source was edited.

Reviewed supplied deltas:

- `round-1-product-fix.diff`, SHA256 `15b5adac9ad9683c4e9b40466b59ad885f84a72da48b3f2e0be2128306d5de80`, exactly the scoped `96a8..f8` changes in native/src.
- `round-1-tests-partial.diff`, SHA256 `c11f25e461a10f1e773aaa5b4d930757619d76eaca6693c50aded5025ce1146a`, capability tool/path/argument/ASCII-case fixes and the fixture attachment fix.

## Finding disposition

| Finding | Disposition | Source/evidence judgment |
|---|---|---|
| F1 unknown NCV | **Closed** | `attributesAllowed = !(hasColor && unknownColorVideo)` gates every one of the six attributes after color projection. Unknown NCV on Default/Default and on Monochrome projection leaves the normal support gates effective. NCV18's dim/underline mask behavior is unchanged. The original ncv19 colored-style counterexample now produces the required six false values. |
| F2 cleanup fence | **Closed** | `running=true`, capability detection, diagnostic assignment and initial mode selection now occur inside the original `try`; the existing catch/finally/error propagation and `cjt_close` remain unchanged. Detection remains once per successful run, within the session lifetime. |
| M1 named ABI/NCV constants | **Closed** | C bit/shift names and Cangjie decode/mode/reason names preserve all previous numeric values and the documented packing. NCV names express underline2/inverse4/dim16/bold32 and the combined mask. No ABI or reason/source semantic change was introduced. |
| M2 unused wrappers | **Closed** | Unused `projectStyle` and mode-only `Frame.changesSince` are removed. `rg` finds neither remaining definition/reference. Active frame/profile/encoding paths remain in place. |
| M2 localized row emission duplication | **Adjudicated/deferred** | Controller expressly defers this minor consolidation to preserve existing reset boundaries and avoid unrelated change. This ruling applies: the repaired Frame delta deletes only the unused wrapper, not either active row loop; no prior reset emission is modified. It does not create or endorse a second Frame/ANSI kernel. |
| F3 capability cwd | **Closed** | Defaults use the module URL's repository root and no longer depend on `run.sh`'s cwd. Absolute binary overrides remain absolute through `resolve`. Already closed in `226886a` source re-review; the supplied complete raw capability log now reaches suite success. |
| F4 override call | **Closed** | `runCase(...,'a')` supplies the proper key; the expected profile assertion is separate. All subsequent isolation/loader cases are reached in the supplied raw log. |
| F5 missing fixture nodes | **Closed by source review** | Rich/fence `Text` constructors now run inside the Column block and assign the same state holders later modified by callbacks. Public `CJTUI_TERMINAL_VALIDATE=1` checks the visible text plus mutability through `render`/`cellAt`. No product special case or private hook was added. This reviewer did not re-run the separately evidenced fixture validation. |
| F6 real-host SGR/provenance oracle | **Open, awaiting fixed delta** | No repair supplied in this partial scope. |
| F7 recorded-byte barrier | **Open, awaiting fixed delta** | No repair supplied in this partial scope. |

The non-ASCII TERM regression is consistent with the existing strict ASCII product validator. It requires unknown/Monochrome and `term-invalid` even with a direct-color COLORTERM declaration. No broader environment or hardware-detection claim follows from this branch test.

## Verification actually performed and reused

1. Read the supplied product and partial-test diffs in full. Compared each modified product file (`native/cjtui_capabilities.c`, `src/application.cj`, `src/color_mapping.cj`, `src/frame.cj`, `src/terminal_capabilities.cj`) with the corresponding `/workspace/work/auto-implementation/repo` file using `cmp`; all matched. `git diff --check 96a8c4b f8b194e -- src native` produced no errors. A reference search for removed wrappers returned no matches (expected `rg` exit1).
2. Read raw `/workspace/work/auto-implementation/capabilities-round1.log`, SHA256 `a8e2f39baedf2f0955bdad54ac0b10885f8d91f2ed5776f47a92263cd971e9b5`: SDK1.2.0, both ordinary consumer builds succeeded, pure snapshot/public API checks passed, and synthetic capability branches completed successfully. This is supplied implementer development evidence, not a substituted independent final execution.
3. Read raw `/workspace/work/auto-implementation/lifecycle-round1-configured.log`, SHA256 `767fcdc15a60ebdbff57b7b9bc0f94d2fb918138d4b6513493321d29838a56b0`: q-success, q-close-failure, callback-success, callback-close-failure, ctrl-c-success, resize-success all report expected process/close status and exact termios restoration, with failures0. No capability-detection exception was injected; F2 closure is specifically the corrected source fence plus retained normal failure/recovery coverage.
4. Inspected retained `/tmp/cjtui-capabilities-TTNcdC` raw results, output bytes and before/after terminal states. `ncv-unknown` has diagnostic ncv19 and only reset/foreground/background SGR, no six attribute codes; `ncv18` has 1/3/7/9 and no 2/4. Isolation reports seededColors16/baseColors16 while the detected profile is Indexed256. Loader failure reports unknown/Monochrome, no attribute support, reason `terminfo-library-unavailable`, and output SGR0 only. All four before/after termios files compare equal.
5. Re-ran only the original projection defect and closely related repair boundaries, using unchanged fixed implementation bodies with style package declarations unified in the isolated compilation unit. Command: `source /workspace/work/validation/sdk/cangjie/envsetup.sh && cjc /workspace/work/auto-final-review/probe-round1/*.cj -o /workspace/work/auto-final-review/probe-round1/counterexamples`, then direct binary execution. Exit0. Retained `probe-round1/build.log` and `result.txt` contain four passes: ncv19 colored all attrs removed, ncv19 uncolored attrs retained, ncv19 Monochrome attrs retained, ncv18 exactly dim/underline removed. This is a scoped reviewer probe, not a public package or real-terminal acceptance run.

No complete suite was repeated. No whole product/package/bundle/cold consumer build or real-window capture was newly run. The first-round whole-scope findings and limitations continue to apply outside this exact repair delta. Final combined verdict must wait for the fixed remaining test/capture input, as requested by the controller.
