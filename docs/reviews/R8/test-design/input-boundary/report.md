# Independent public input/coordinate regressions and runner exit propagation

Fixed product baseline actually built/run: 2794136e45aee98300f4b16456dfa6b605cfdf74.
Prior cancellation tests retained: 56bc01b430e3541a3c7babd32c7cfa68159c6525.
New test commit: 9119615c69bf2afa7991536a757ab15e75dec288.
Checkout: /workspace/work/first-slice-tests/repo.

Only tests/test documentation changed. Expected results follow the frozen public
contract (Unicode text events, no text fabricated from unknown controls, clipped
out-of-range Frame writes), not product implementation behavior. Product source,
native/build implementation, API and design were not modified. Test author did
not read implementation-author working directories or reasoning.

## Actual commands/results

SDK 1.2.0 was sourced using /workspace/work/validation/sdk/cangjie/envsetup.sh.
CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip.
Ignored local configs use read-only official cache at
/workspace/work/validation/replay-dependencies/cache and registry relay
http://127.0.0.1:18972. No ad hoc FFI flags or substitute product implementations.

```sh
(cd tests/integration/fixture && cjpm build)
node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main utf8-fragmented
node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main sos-ignore
./tests/run-slice.sh coordinates
```

| Command | Actual exit | Result / raw log |
| --- | --- | --- |
| Fixture cjpm build | 0 | input-boundary-build.log |
| utf8-fragmented | 1 | RED: event list only text/q; expected text/中 then text/q. input-boundary-utf8-fragmented.log |
| sos-ignore | 1 | RED: events text/s,e,c,r,e,t,q; expected only text/q. input-boundary-sos-ignore.log |
| coordinates via final direct runner | 1 | RED: Max throws OverflowException:add; Min clips and preserves frame. coordinate-boundary-red-direct.log |

Each PTY regression received actual first-frame output and passed unchanged idle
and non-TTY checks. Both ended normally on q with process exit 0 and exact termios
restoration; their test exit 1 comes from the independently asserted incorrect
public event list, not a timeout or process-start problem. Input is real PTY data:
UTF-8 e4 b8 ad sent in three writes 160ms apart, or SOS 1b587365637265741b5c,
followed separately by q. The optional fixture recorder prints only actual public
KeyEvent fields and contains no input parser. Original behavior is unchanged when
the recorder is disabled.

## Runner failure-status fix

The initial coordinate run used cjpm run and exposed a facility defect: it printed
an uncaught assertion exception yet cjpm returned zero (coordinate-boundary-red.log).
The coordinator authorized fixing every executable consumer entry. All now perform
normal cjpm build and execute the actual binary directly; existing native/contract
assertions are untouched. The new coordinate consumer explicitly returns 1 after
reporting both boundary outcomes.

A standalone SDK-only program outside the repository throws an intentional
Exception; direct execution exits 1 (binary-exception-status.log), so SDK runtime
itself propagates an uncaught exception. No catch wrappers or weakened expectations
were required in the original consumers. The real Max-coordinate failure proves
the final runner returns 1 rather than a false green.

Positive controls after the final runner/fixture changes:

- ./tests/run-slice.sh native-smoke: exit 0, all original nine checks passed;
  runner-native-smoke-positive.log.
- node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main q exception:
  exit 0; original q exits 0, original callback exception exits 1, both restore
  exact termios; input-boundary-fixture-positive.log.
- node --check tests/integration/pty.mjs, bash -n tests/run-slice.sh, git diff --check
  and staged diff check exited 0.

This is independent test-author RED/facility evidence, not complete-suite execution
or product acceptance. The earlier two Ctrl-C regressions remain frozen and were
not weakened. Separate C-session tests are delivered in their own commit/report.
