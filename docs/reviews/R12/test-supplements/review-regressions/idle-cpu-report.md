# Opt-in f07 idle CPU baseline

Fixed test-only supplement: `13d4c85478159950ea912d6358dcb52a6c5063e3`, on top of semantic-regression test commit `d95803372871c89442f131e362f38aff97633779`. Only 3 test files changed. The opt-in mode is outside default all. Product remains the same frozen f07 dependency, whose product blobs match main candidate 4267b1138f70a9b51cc104719c8b38eb770748bc (hash `074bf5442595eaa30dfbc2a074bc2ea57c398510d36659264cf500c7646d0a3f`). No fixed or development repair was inspected/run.

## Selected baseline: one sequential process

Command prefix: `raw/review-idle-cpu-default-512x256.*`. Exact command uses `env -u cjHeapSize`, so the SDK heap configuration is default. The fixture binary was built by normal CJPM (`raw/review-idle-cpu-normal-build.*`, exit 0). The standalone Node harness directly launches the actual binary in a real PTY; no product hook is used.

- Actual application PID: 724352.
- Actual viewport: 512 columns × 256 rows = 131072 cells.
- Extra pure getter Text nodes: 2048 (in addition to the retained two text rows/root).
- CPU clock rate from getconf CLK_TCK: 100 ticks/second.
- The first real frame and public `a` callback acknowledgement complete before CPU sampling. No input is sent during the sample; then `b` acknowledges the ending boundary.
- Before ticks: user 154, system 310. After: user 272, system 322.
- Delta: user 118 + system 12 = 130 ticks = **1.30 CPU seconds**.
- Measured monotonic wall duration: **2.004029228 seconds**.
- Process CPU-equivalent cores: **0.6486931337310816** (about 64.9% of one CPU).
- Public a/b stats are both exactly `2051,2051,2051,1` (builds, measures, paints, frames).
- Harness exit 0, actual child exit 0, no forced signal. Exact termios restored; one real successful close; cleanup once. This is protocol/native/statistics success, **not a CPU-performance pass**. There is no absolute CPU threshold.

Raw selected artifacts: `/workspace/work/runtime-tests/review-cpu-artifacts/cjtui-runtime-pty-NiHuaI/idle-cpu/`. `idle-cpu.json` contains all counters/configuration. The directory also retains first/last stats, raw bytes, stderr, result, before/after termios and real-close record.

## Limits and excluded preparation

This is one whole-process CPU sample on one host, SDK/configuration and viewport. It includes poll/GC/copy/diff and any other work charged to that child; it does not attribute cost to a private loop or prove thread-ID reuse. Threads, CPU affinity, host load and pending asynchronous GC are not controlled. Tick granularity is 10ms. Initialization occurs before first-frame/ack, but residual asynchronous initialization GC cannot be separately identified. The four public counters staying unchanged does not prove zero tree/Frame work. The independent final execution role should compare the fixed repair with this exact viewport/getter/default-heap/2s probe, rather than inventing an absolute threshold.

Earlier attempts are retained and **excluded as CPU samples**:

- `raw/review-idle-cpu-run-{1,2,3}.*` launched at 1024×1024/default heap. The author initially failed to wait for yielded exec sessions to finish, so these attempts overlapped and cannot supply isolated performance evidence. All exit 1 without an idle-cpu.json. Two session.raw files explicitly show Cangjie Out of memory with a 268435456-byte runtime heap; the other times out before a frame. Original per-attempt session scripts/raw/results remain under `review-cpu-artifacts/cjtui-runtime-pty-{WJIk1q,BMoscV,6rG9Nf}/idle-cpu`.
- `raw/review-idle-cpu-sequential-1.*` is an isolated exploratory 1024×1024 attempt with `cjHeapSize=1GB`; it times out before the first frame and produces no CPU sample. It is not a default-heap success. Artifact directory is `cjtui-runtime-pty-PmvRUa/idle-cpu`.
- `raw/review-heap-{invalid,valid}-probe.*` only checks an existing SDK probe with runtime environment settings. The invalid value emits a runtime parameter warning even though the process exits 0; neither probe is product/CPU evidence.

The coordinator then selected the representative 512×256/default-heap workload. Exactly one such process was run, sequentially, and it produced the selected baseline above. No larger heap setting was used for that baseline and no failed attempt was replaced or hidden.

Fixed source manifest: `raw/idle-cpu-test-source.sha256`, SHA-256 `b87dee0f74ade9a7c46b1a24cfe7cccdb02cd96543b2ecca51ea22b5c806d765`. `raw/review-idle-cpu-facilities.*` records shell/Node/C syntax and whitespace checks, exit 0. Actual serving model remains independently unobservable; role configuration requested Sol/high. No old full suite was repeated for this optional measurement facility.
