# Queued control input during resize rendering

This external Linux PTY regression uses the existing, normally compiled rendering
benchmark compatibility executable. It tests the public `Application.run` input
contract: control-protocol payload must not become a key, and decoder timeout must
represent real input idle. It adds no product hook, library import, build, cache
change or runtime dependency to the application. Python uses only its standard
library; `strace` observes the owned normal process and its threads.

After setting the ordinary SDK runtime environment, run:

```sh
python3 tests/keyboard/queued_input/regression.py \
  --binary /absolute/path/to/normal-compat \
  --binary-sha256 ACTUAL_EXPECTED_ELF_SHA256 \
  --case queued --out /absolute/path/to/new-artifacts
```

The driver starts an actual controlling PTY at 126x40 and runs the unchanged normal
CLI: `--mode tty --scenario vertical_panels --width 160 --height 48 --seed 143
--warmup 2 --updates 2 --repetition 0`, plus fresh run/output identities. Only after
observing the cursor query does it write the literal complete `ESC[?25;1$y` report
in one write. Actual `FIONREAD` and descriptor readiness prove the whole report
queued; a correct implementation that already consumed the complete report is
also admitted by the actual native input bytes. Native evidence must show the initial 126x40 snapshot before the
driver changes actual geometry to 160x48. No scheduling signal, synthetic decoder,
fault shim or private API forces application behavior.

The expensive resized full-frame interval must span at least 100 ms, reproducing
the diagnosed processing-pressure condition. This is a fixture-exercise gate,
not an application performance threshold. If it is not reached, exit 77 means
`FIXTURE_NOT_EXERCISED`, never PASS or product RED. The gate permits a correct
implementation to drain the complete packet before expensive rendering; it does
not require one-byte reads, Escape to remain pending across the render, or any
particular post-fix input/render ordering. A shorter rendering workload can need a
different suitable fixture rather than a weaker assertion.

The benchmark's existing strict `onKey` protocol rejects unexpected Escape/control
payload; the test does not filter keys or relax that protocol. After the first
frame, the driver follows the published setup, ready, two warmups and two measured
action/fence/presented steps, then end. PASS requires normal completion, the end
acknowledgement and the normal CSV. Exit 1 after the named protocol failure with
all exercise gates met is the queued-control behavioral RED. Other unexpected
process/setup/watchdog failures use exit 2 and cannot be called that RED.

Run the separate true-idle control with a fresh artifact directory:

```sh
python3 tests/keyboard/queued_input/regression.py \
  --binary /absolute/path/to/normal-compat \
  --binary-sha256 ACTUAL_EXPECTED_ELF_SHA256 \
  --case idle-escape --out /absolute/path/to/new-idle-artifacts
```

This uses 160x48 from the start, completes setup/ready, then sends only bare ESC.
A real positive-timeout native poll must return idle; the unchanged strict
benchmark must then observe Escape and reject it with exit 1. The control itself
passes with exit 0 only for that expected observable Escape. This complements the
unchanged pure `tests/keyboard/src/temporal_cases.cj` bare-ESC timeout assertion;
neither case authorizes swallowing genuine Escape to make the queued case pass.

Fresh artifact directories retain exact CLI/ELF/fixture identity, actual PTY
device/dimensions, atomic input/readiness events, original annotated native streams
with thread lineage and exits, normal wire/CSV and before/after termios. `-v` is
followed by explicit execve/execveat abbreviation so environments are not dumped.
Native timestamps and original ordinals remain available; PTY chunks are not
native-write counts. This is a controlled PTY regression, not real-host, CPU,
latency, rendering-quality or whole-suite acceptance. Bounded watchdogs are
transport limits; forced cleanup is never success.
