# TASK008.d independent deterministic execution
Status: PASS_DETERMINISTIC_338_PTY_MATRIX.
Source: 80d21e071537898cde27f1c7de4328ab6f27d991; fixed tests: 9d224da8f74997fa8329a84c798c61e5a57d2fc9.
Public normal consumer build: exit 0; frozen tests/output_recovery/run.sh run: exit 0.
338 real-PTY cases, 338 direct consumer wait exits 0, 0 failures, 0 forced kills.
Additional pure direct consumer: exit 0.
Own binary SHA256: 09b5f6597cb4edbc773020552ed7a98bf69a8384354210c2c518e7901546c76c.
All 338: literal transaction assertions passed; exact termios restored; native close and three restored signal checks present; no poll-after-fault.
Fault records retain raw PTY/wire/candidate transactions, byte count/unsafe state, exact primary/cleanup errors and same-process reopen outcomes.
Direct exit chain: consumer PID wait status → launch.sh exit → util-linux script -e; exit.json confirms finished/no signal.
SDK1.2/stdx/pinned UCD and archive symlink provenance, public registry/warm cache config, tools/source/tests/binary hashes recorded in index.
Source worktree clean; source-only change versus base: Application 8 lines; fixed tests unchanged.
Normal bundle exit0 reused under AGENTS11.1; known archive-boundary themes/light.toml failure retained for T087/finalTASK023.
No relay, SDK/cache/archive copy, source/test edit, main mutation or push.
No actual current GUI/host PNGs; this deterministic evidence does not establish fullLinux/fullrelease or final AC008 acceptance.
Final free space: 267886592 bytes.
Evidence: index.json; raw/audit.json; raw/run/summary.json; raw/build.log; raw/run.log.
