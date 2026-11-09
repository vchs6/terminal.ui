# Independent execution retest — fixed transitive FFI path

Fixed commit: `e2c122de616207c9e5166a9c89416233b8b81268`. Only `run-transitive.sh` was re-executed. It exited **0**. This records execution evidence and does not give overall acceptance.

## Version, scope and preconditions

The independent clone fetched and checked out the fixed SHA (exit 0). No author development logs/reasoning were read. The script was inspected without editing. [retest-execute.sh](retest-execute.sh) contains the exact restoration/execution commands; [retest-execution.log](retest-execution.log) records their trace, SDK details, hashes and overall status. Run interval: 2026-11-09T15:31:05Z–2026-11-09T15:33:23Z. SDK/CJPM 1.2.0 and the original envsetup.sh were reused.

The initial failure directory/logs were preserved. A new `retest-native-probe` directory copied only this role's original unicode source/native outputs and the explicitly reused conformance log. The original official unicode manifest was extracted again, then the same `[ffi.c] unicodedata = { path = "./lib" }` declaration present at successful run-native completion was appended. The direct consumer source/manifest were restored. No prior middle directory or consumer target was copied. Native archive bytes matched the first run by cmp (exit 0), SHA256 `96f0552e197c0f02a7860f13cd0174617df639315252221828785103628e0c03`.

Git diff (exit 0) confirms run-native.sh, generator and all templates unchanged. Hashes independently confirm both inputs unchanged. Therefore the original 766/0 official grapheme result, separate empty-input observation and original native build/direct-link/dependency-owned FFI results are reused from [report.md](report.md) and [results.json](results.json); they were not rerun. The copied conformance log is reused evidence, not a new execution.

## Observations

- Static adapter with dependency-owned FFI: build/run exit 0; one five-cluster fixture.
- Adapter-owned FFI: normal build/run exit 0 in new `/workspace/work/r7-independent-test/retest-native-probe/adapter-owned-target.lQE8CF`; one five-cluster fixture.
- The fixed script observed no executable before build, an executable after build, a consumer compile/link line with `-lunicodedata`, and the fresh executable path in the log; all assertions returned 0.
- Final unicode manifest matches the official input archive (cmp exit 0). Consumer manifest has no link-option/FFI declaration; its source imports only the adapter. The adapter owns the FFI declaration.

Actual final consumer command:

```text
Compiling package `native_probe`: LD_LIBRARY_PATH=/workspace/work/r7-independent-test/retest-native-probe/unicode-0.1.0/lib:$LD_LIBRARY_PATH cjc -p /workspace/work/r7-independent-test/retest-native-probe/consumer/src --import-path=/workspace/work/r7-independent-test/retest-native-probe/adapter-owned-target.lQE8CF/release --no-sub-pkg --output-dir=/workspace/work/r7-independent-test/retest-native-probe/adapter-owned-target.lQE8CF/release/bin/ -L /workspace/work/r7-independent-test/retest-native-probe/adapter-owned-target.lQE8CF/release/native_adapter/ -lnative_adapter -L /workspace/work/r7-independent-test/retest-native-probe/adapter-owned-target.lQE8CF/release/unicode/ -lunicode -lunicode.utf -lunicode.types -lunicode.constants -L /workspace/work/r7-independent-test/retest-native-probe/unicode-0.1.0/lib -lunicodedata --output-type=exe -o=main
```

The raw log then records `Run current project` using `/workspace/work/r7-independent-test/retest-native-probe/adapter-owned-target.lQE8CF/release/bin/main`, followed by `PASS transitive FFI through intermediate static adapter`. The former ITE-001 missing-relink observation is not reproduced in the repaired path. The original failure remains documented. A compiler warning for U+FE0F remains nonfatal. No broader product, hook, normalization-conformance or platform result is inferred.

## Minimal raw evidence index

- [retest-execution.log](retest-execution.log)
- [retest-run-transitive.trace.log](retest-run-transitive.trace.log)
- [retest-native-probe/logs/transitive-input-checksum.log](retest-native-probe/logs/transitive-input-checksum.log)
- [retest-native-probe/logs/intermediate-ffi.log](retest-native-probe/logs/intermediate-ffi.log)
- [retest-native-probe/logs/adapter-owned-ffi-relink.log](retest-native-probe/logs/adapter-owned-ffi-relink.log)
- [retest-final-state.log](retest-final-state.log)

Machine-readable results include raw-log hashes and all fixed script/template/input hashes: [retest-results.json](retest-results.json). Main repository and fixed artifacts were not edited; no commits/pushes were made.
