# Independent test execution — R7 native dependency probe

This report records execution results only; it does not give overall acceptance. Fixed commit: `9a5c7034d245a053ff4614c3b7f594689a5b1389`. Clone: `/workspace/work/r7-independent-test/repo`; fresh scratch: `/workspace/work/r7-independent-test/native-probe`. No author process messages, self-evaluations, logs or build artifacts were used as execution results. The required fixed README/scripts/templates/metadata were inspected; repository author log contents were not opened.

## Reproduction and environment

Commands are preserved in [execute.sh](execute.sh), [execution.log](execution.log), [run-native.trace.log](run-native.trace.log), [run-transitive.trace.log](run-transitive.trace.log), [final-checks.sh](final-checks.sh) and [final-checks.log](final-checks.log). Clone/checkout output is [clone.log](clone.log). Initial read/discovery commands were read-only (pwd/ls, cat AGENTS.md/README/scripts/metadata/SHA256SUMS/templates/cjpm.toml, git status/rev-parse); the optional `rg --files -g AGENTS.md docs` search returned 1 because there was no nested file. Main timed run: 2026-11-09T15:24:02Z–2026-11-09T15:26:27Z.

SDK environment was sourced exactly from `/workspace/work/validation/sdk/cangjie/envsetup.sh`. Source exit 0; CANGJIE_HOME points to its containing directory; PATH and LD_LIBRARY_PATH are captured in execution.log.

```text
Cangjie Compiler: 1.2.0 (cjnative)
Target: x86_64-unknown-linux-gnu
Cangjie Project Manager: 1.2.0
gcc (Debian 14.2.0-19) 14.2.0
GNU ar (GNU Binutils for Debian) 2.44
Linux 6.18.57 x86_64
v24.22.1
```

The ten non-log fixed handoff files matched SHA256SUMS (exit 0). Inputs were hashed independently before and after execution and remain unchanged:

- unicode cjp: `d810505f62b43417ce673fb9c811f740503d3df88665307557544eae6d073c4c`
- UCD zip: `2066d1909b2ea93916ce092da1c0ee4808ea3ef8407c94b4f14f5b7eb263d28e`

## Observed results

`run-native.sh` exited **0**. `run-transitive.sh` exited **1**. Final read-only consistency checks exited **0**; the independent clone is clean.

| Stage | Exit | Result | Raw evidence |
|---|---:|---|---|
| clean normal consumer build | 1 | expected failure | [log](native-probe/logs/normal-build-clean.log) |
| shipped generator build | 0 | observed success | [log](native-probe/logs/generator-build.log) |
| shipped generator execution | 0 | observed success | [log](native-probe/logs/generator-run.log) |
| native compilation/archive | 0 | observed success | [log](native-probe/logs/native-build.log) |
| explicit consumer link and run | 0 | observed success; 2 fixtures/vectors | [log](native-probe/logs/consumer-native-link.log) |
| dependency-owned ffi consumer link and run | 0 | observed success; 2 fixtures/vectors | [log](native-probe/logs/dependency-ffi-transitive.log) |
| official grapheme conformance | 0 | observed success; 766 fixtures/vectors; 0 failed | [log](native-probe/logs/grapheme-conformance.log) |
| static adapter with dependency-owned ffi | 0 | observed success; 1 fixtures/vectors | [log](native-probe/logs/intermediate-ffi.log) |
| adapter-owned ffi rebuild/run command | 0 | relink evidence missing | [log](native-probe/logs/adapter-owned-ffi-relink.log) |
| adapter-owned ffi actual relink assertion | 1 | unexpected failure | [log](run-transitive.trace.log) |

The expected clean build failed with undefined `getCodepointProperty`, `getDecompSequence`, `getCombinSequences` and `free_utf16array`; its compiler reported return code 1. Archive-list inspection found no build.cj/native archive. The shipped generator produced all seven tables; C/ASM built without changing their bytes. The explicit-link and dependency-owned FFI runs each checked a five-cluster fixture and NFD of é. The static adapter fixture checked five clusters. No aggregate test count combines these different stages.

The grapheme run reports `GraphemeBreakTest17 raw total=766 failed=0`. A separate empty-input observation reports one empty cluster; it is not included among those 766 vectors. Official file hash: `e2d134d2c52919bace503ebb6a551c1855fe1a1faec18478c78fff254a1793ec`; generated source hash: `08eee34893b887f996786649cb4e2ec05a7ed3f55c6a58082e2a7b81d07aef71`.

## Failure requiring author action

**ITE-001:** The final adapter-owned FFI stage did not actually relink the executable. Its cjpm command returned 0 and executed the existing binary, but its log has no `Compiling package native_probe` line. The fixed script's final rg assertion returned 1. Therefore the final ownership arrangement has **no fresh-link evidence in this independent run**. The earlier intermediate stage does have a consumer link command containing `-lunicodedata`.

The restored unicode manifest exactly matches the official archive. Consumer source mtime was 2026-11-09 15:26:26.944504883 UTC; executable mtime was 15:26:26.900504245 UTC. Both occur within one second; the cause of skipped recompilation is undetermined. No local fix or repeat was made; the issue was returned through the main agent for author repair.

## Actual FFI consumer link lines

```text
/workspace/work/r7-independent-test/native-probe/logs/intermediate-ffi.log:Compiling package `native_probe`: LD_LIBRARY_PATH=/workspace/work/r7-independent-test/native-probe/unicode-0.1.0/lib:$LD_LIBRARY_PATH cjc -p /workspace/work/r7-independent-test/native-probe/consumer/src --import-path=/workspace/work/r7-independent-test/native-probe/consumer/target/release --no-sub-pkg --output-dir=/workspace/work/r7-independent-test/native-probe/consumer/target/release/bin/ -L /workspace/work/r7-independent-test/native-probe/consumer/target/release/native_adapter/ -lnative_adapter -L /workspace/work/r7-independent-test/native-probe/consumer/target/release/unicode/ -lunicode -lunicode.utf -lunicode.types -lunicode.constants -L /workspace/work/r7-independent-test/native-probe/unicode-0.1.0/lib -lunicodedata --output-type=exe -o=main
/workspace/work/r7-independent-test/native-probe/logs/dependency-ffi-transitive.log:Compiling package `native_probe`: LD_LIBRARY_PATH=/workspace/work/r7-independent-test/native-probe/unicode-0.1.0/lib:$LD_LIBRARY_PATH cjc -p /workspace/work/r7-independent-test/native-probe/consumer/src --import-path=/workspace/work/r7-independent-test/native-probe/consumer/target/release --no-sub-pkg --output-dir=/workspace/work/r7-independent-test/native-probe/consumer/target/release/bin/ -L /workspace/work/r7-independent-test/native-probe/consumer/target/release/unicode/ -lunicode -lunicode.utf -lunicode.types -lunicode.constants -L /workspace/work/r7-independent-test/native-probe/unicode-0.1.0/lib -lunicodedata --output-type=exe -o=main
/workspace/work/r7-independent-test/native-probe/logs/consumer-native-link.log:Compiling package `native_probe`: cjc -p /workspace/work/r7-independent-test/native-probe/consumer/src --import-path=/workspace/work/r7-independent-test/native-probe/consumer/target/release --no-sub-pkg --output-dir=/workspace/work/r7-independent-test/native-probe/consumer/target/release/bin/ -L /workspace/work/r7-independent-test/native-probe/consumer/target/release/unicode/ -lunicode -lunicode.utf -lunicode.types -lunicode.constants --link-options "-L/workspace/work/r7-independent-test/native-probe/unicode-0.1.0/lib -lunicodedata" --output-type=exe -o=main
```

Full native symbol/table hash records remain in [native-build.log](native-probe/logs/native-build.log). All generated artifacts and raw run logs remain under this report's directory; no main repository files were edited.

## Boundaries

- No product integration, build hook, clean distributed cjp lifecycle, normalization conformance or other platform execution performed.
- No author logs or build outputs were used as test results; author logs inside cloned repository were not opened. Fixed README and metadata were read only as handoff context.
- No fixed scripts edited; no repository edits, commits or pushes. No repeated run of unchanged failure.
- Per-command numeric codes for successful nested commands are inferred from fixed scripts set -e continuation; the two script codes and final check code are captured explicitly. Clean failure code 1 is also reported by the compiler in its raw log.

The fixed scripts do not run a separate build-hook marker probe. No independent result is claimed for that README finding or static CMake observations. The remaining missing relink evidence is a test-execution finding for a separate verifier to assess against acceptance requirements.

## Handoff input hashes and reuse scope

- `run-native.sh`: `4470e67f35e5dafe8f6910d737f88345c792043c75a8df967ef54b80815a2742`
- `run-transitive.sh`: `0a9fe38e1916314d4f23f06f159e398d78b3a60ec23d6b76e9b712e8a861324f`
- `generate-conformance.mjs`: `202453714f7fe5a3f35d5bc2eb7a67765c8864f9d06d9ccdb2be579e2ba2ac0f`
- `templates/consumer-main.cj`: `ca37136319c522dcfdf4b51241f9ec70ec39a6b44c7cf7378d3a6af4321a19d5`
- `templates/consumer-middle.cj`: `33f28fdcd17a656369b3ce97bc5a012adb371003e91759fa5b3ba1c2d3c56d3e`
- `templates/middle-lib.cj`: `3c856740fd0006e4fb3d5b080618dcd9e11ca4bfb406c9a4abaa9ec913843d44`

Full successful run-native stage for identical script/generator/templates/input bytes/SDK/environment. Includes shipped generator, seven tables, native archive, explicit consumer link, dependency-owned FFI link, 766 grapheme vectors and separate empty observation. Intermediate static-adapter stage succeeded with dependency-owned FFI. Adapter-owned FFI fresh link is not established; only affected path needs rerun after fixed handoff.
