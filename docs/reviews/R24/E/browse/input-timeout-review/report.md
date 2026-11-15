Independent fixed review: c8624c1de5ab7ec6727ef59d9f2897f9cf6b7960 → d7e9d1445f98021a798d223de97b97b45239de93; tests independently frozen at 555a0a127a485f6ac8498bb31e5257ece69e2367.
SPEC: PASS for the scoped source repair; ready input is fed before any expiry, matching public keyboard-input.md real-idle/control-payload contract.
QUALITY: PASS; no blocking or ranked source finding. Minimal 2-insert/10-delete change, no API/parser/native/workload fork or unrelated formatting.
The deleted guard formerly expired a pending decoder after a ready read; rendering elapsed time could therefore synthesize Escape before '[' was fed.
Now only actual readByte -1 reaches expiry: native -2/-3/-4/-5 handling precedes it; interrupted reads do not spend fallback idle budget, EOF still finish()es before stopping.
100 ms policy, monotonic failure fallback, polling bounds, partial-sequence expiry, Unicode/ANSI single decoder, event/focus/shortcut ordering and session/raw-mode cleanup remain intact.
A zero-timeout poll after a busy interval first drains ready input; an empty result can expire pending state, preventing a permanent zero-timeout spin. Genuine idle still dispatches Escape.
FROZEN TEST LEGITIMACY: PASS; actual controlling PTY, complete atomic report/readiness, geometry change and >=100 ms pressure gate; strict public benchmark unchanged; no implementation-specific pending-byte ordering required.
Formal baseline: all 9 report bytes queued; ESC→'[' 162.320 ms across 161.891 ms resize render; test/product exit 1. Frozen fixed run: 145.194 ms gap/144.825 ms render, full packet consumed and normal protocol/end/CSV exit 0.
Both frozen idle controls show native poll(...,100)=0 and observable Escape (test exit 0/product exit 1); baseline and fixed cases restore termios. Non-exercise exit 77 and forced-cleanup failure cannot count as PASS.
Actual author checks: normal cjpm build -j 1 and bundle succeed; default test count 0; lint retains 834 warning lines. Unsupported --release attempt remains exit 1, never a passed build.
Those author facts support source review, not independent affected-suite or final clean-package acceptance; F1/F2 in reuse-admission.json remain assigned execution work.
REUSE PREFLIGHT: ADMIT UNCHANGED SCOPES WITH FINITE FRESH OBLIGATIONS under AGENTS11.1, original AC022/031 and M013; this is not performance acceptance.
Product src/native/macros/cjpm.toml f48→c862 is unchanged; c862→fixed changes only run(). Eight selected benchmark call-scope files match original admission SHA256 exactly.
1,150 headless repetitions (350 old snapshot +350 pre-fix M2 snapshot +350 M2 diagnostic +100 eligible M1 diagnostic) bypass run(); unchanged render-window/work/Cell-slot/heap-GC evidence remains reusable with original identities.
Headless wait4 CPU/wall/RSS includes process startup, warmup, sampling/export/disposal; preserve that whole-process scope and original ELF identity. It is not fresh new-ELF measurement or isolated render CPU.
216 headless correctness runs/144 Cell-caret comparisons/216 joins remain reusable for unchanged rendering/business semantics; they prove neither device input nor final package consumption.
176 successful unchanged M1 TTY CPU rows remain reusable. The 175 successful pre-fix M2 rows and original VTE failure remain valid historical observations, not final M2 cost measurements.
The removed guard evaluated waitingIdle() even on ordinary ready ASCII; pending reports additionally invoked clock/timeout logic. Thus final TTY whole-process CPU is affected beyond the one failing scenario.
F1: bind final source/CJP/normal clean-package compat+diagnostic consumers and dependencies/configuration freshly; NEW fix CJP is 05c99476961be72022f0ea98adb3d283453b9b41fd7adcbf428880d24d6de86f.
F2/F3: independently execute frozen queued/idle and affected device/runtime integration; reuse unchanged decoder/native checks and headless matrix after documented artifact/configuration continuity, without a mechanical 1,150/216 rerun.
F4: refresh existing final-M2 TTY CPU table: 2 hosts ×2 sizes ×(34 ordinary runs +5 initial +5 idle)=176; retain old M1 baseline. Include original VTE 160x48 vertical_panels path, fresh initial lifecycles and stabilized normal-run idle.
F5: complete existing 288-case two-version native output table with valid all-thread/FD/phase attribution; final M2 needs 144 newly bound cases, M1 only still-missing/invalid evidence. CPU and tracing remain separate processes.
Encoder/native source invariance does not prove final startup cursor/output ordering. Native attribution repair and broader real-host/Linux obligations are separate from this product source-quality verdict.
Custody receipt records 6,900 fully verified archived members/1,150 physical record.json files; selected receipt/indices are bound here, no archive decompression or full raw revalidation performed.
Selected checks and exact scopes are in index.json/reuse-admission.json; no edits to source/tests, builds, test execution, GUI/TTY/probes or quarantined trace access. Review fixed scope once; subsequent review only fixes/deltas.
