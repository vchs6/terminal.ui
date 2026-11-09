# Targeted SOS embedded-ESC / UTF-8 regression

Product integration baseline actually rebuilt/run:
db94c6157088f9678f9d3d6dccd912509fc745ef (product repair source 49edfc5).
Independent test-only commit: 6c9681f3620ce858c644d7ece37e348c5794bd1c.
Checkout: /workspace/work/first-slice-tests/repo, branch task048-sos-escape-utf8.

Only tests/integration/pty.mjs and tests/README.md changed. The new
sos-escape-utf8 mode reuses the existing event-recording fixture and exact expected
list of only text/q. All prior assertions remain unchanged. Appending it to the
PTY default modes also includes it in existing run-slice.sh all / CI slice checks.
No product source, fixture source, native/build code, API, or design changed.
No implementation repair code/reasoning was read. No additional test requirement
was introduced: expected no-payload event behavior follows the original contract
"未知控制序列有界忽略，不执行或伪造文本".

Environment/build:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
cd /workspace/work/first-slice-tests/repo
(cd tests/integration/fixture && cjpm build)
```

Actual fixture build exit 0; raw sos-escape-utf8-build.log. It was rebuilt to avoid
reusing this clone's old 279-baseline binary. Only this fixture was built, not the
full SDK suite. Ignored fixture-local cache config uses existing official cache
/workspace/work/validation/replay-dependencies/cache and relay
http://127.0.0.1:18972. No package/cache source modifications or extra FFI flags.
Built actual fixture SHA-256:
8262fb35eb56df35033547a2e97dd4b38fe6e767ca0df62e03b4b69103af1aee.

Actual targeted command:

```sh
node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main sos-ignore sos-escape-utf8
```

Actual Node exit 1. Raw output: sos-escape-utf8-red.log.

- Existing sos-ignore control passed: actual event list only text/q; application
  exit 0 and exact termios restoration.
- New case sends exact hex 1b581be4b89c7365637265741b5c (ESC X ESC 东secret ST),
  waits 200ms, then sends q separately.
- Expected event list: [{code:text,text:q}].
- Actual list: text/s, text/e, text/c, text/r, text/e, text/t, text/q.
- New application exit 0, script signal null, and before/after termios equal.
  Test exit 1 comes from the real public callback event assertion, not timeout,
  startup, cleanup, or a forced signal. No SIGKILL cleanup was needed.

Both sessions also passed the harness's unchanged actual first-frame/idle checks;
non-TTY no-ESC precheck passed. Other regressions/full suite were not repeated.
node --check tests/integration/pty.mjs, git diff --check and staged diff check
exited 0. Product paths src/native/build.cj/cjpm.toml remain unchanged from the
fixed baseline; working tree clean after commit. This is independent regression
RED, not product acceptance or repair. No remote push or delegation was performed.
