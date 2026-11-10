# Commands and scope

All development commands used the independent /workspace/work/auto-harness-repair clone. Parent checkout /workspace/work/terminal.ui was read only by this author. Product validation clone /workspace/work/auto-harness-repair-validation was detached at the stated fixed product revisions; only independently authored test fixture content was copied there.

## Host root cause

At test base 04271d4:

```sh
node tests/capabilities/pty.mjs  # RED: exit 1, tic available
# Actual upstream tools:
tic --version                 # exit 1; usage documents -V
tic -V                        # exit 0, ncurses 6.5.20250216
script --version              # exit 0, util-linux 2.41.5
stty --version                # exit 0, GNU coreutils 9.7
```

GREEN probe command used Node spawnSync for these same real commands, requiring status === 0, with ['--version'] for script/stty and ['-V'] for tic. Output is tool-green.log; node --check tests/capabilities/pty.mjs and git diff --check exited 0.

## SDK and normal build

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
cjc --version
cjpm --version
# SDK and CJPM 1.2.0
cd /workspace/work/auto-harness-repair-validation/tests/capabilities
mkdir -p generated-terminfo
tic -x -o generated-terminfo fixture/terminfo.src
cc -std=c11 -Wall -Wextra -Werror -fPIC -O2 -c session/native/capability_test_native.c -o session/native/capability_test_native.o
ar rcs session/native/libcapability_test_native.a session/native/capability_test_native.o
cjpm build
./target/release/bin/main      # 0e202f9 product/test-base mismatch RED, report.md
cd session
cjpm build
# Later product validation checkout: git checkout --detach 0568a09; cjpm build
```

Ignored cangjie-repo.toml files pointed to the existing /workspace/work/auto-tests/cache and local relay http://127.0.0.1:18972. Cache sources/native artifacts were never patched.

## Focused F3/F4 and non-ASCII checks

Temporary .mjs diagnostic files consisted of the actual current/original pty.mjs prefix through runCase/profile declarations, followed by only the literal selected runCase call and its original assertions. They were removed after execution. No fake binary or alternative terminal backend was supplied.

- F3 RED: from tests/capabilities, old prefix and `await runCase('eight', { TERM:'cap-8' })`; correct generated-terminfo and session/target symlinks existed, yet the old duplicated default paths timed out.
- F3 GREEN: same cwd, corrected module-root defaults, eight case plus original profile fields and exact SGR31-present/SGR91-absent checks passed. Symlinks resolved to the normally built fixed validation clone's test artifacts and were removed afterward.
- F4 RED: original `runCase('override-auto', {TERM:'cap-direct', CJTUI_CAPABILITY_OVERRIDE:'1'}, {colorMode:'TrueColor'}, 'a')` raised ERR_INVALID_ARG_TYPE.
- F4 GREEN: corrected third parameter 'a', explicit profile TrueColor check, original Basic8-then-Auto raw SGR31/91 assertions passed against 0568a09.
- Non-ASCII RED: `runCase('non-ascii', {TERM:'cap-é', COLORTERM:'truecolor'})` followed by literal frozen profile and forbidden-SGR assertions failed at profile colorMode, actual TrueColor versus Monochrome, on 0568a09.

Absolute CJTUI_CAPABILITY_BIN and CJTUI_CAPABILITY_TERMINFO selected the normally built fixture/database for F4 and non-ASCII checks. The F3 GREEN used actual defaults to test the corrected cwd behavior.

## Fixture F5

```sh
# Independently authored fixture test copied into fixed-product validation clone:
cp /workspace/work/auto-harness-repair/tests/terminals/fixture/src/main.cj /workspace/work/auto-harness-repair-validation/tests/terminals/fixture/src/main.cj
cd /workspace/work/auto-harness-repair-validation/tests/terminals/fixture
cjpm build
CJTUI_TERMINAL_VALIDATE=1 target/release/bin/main
```

Before moving the Text constructions into Column: compiled normally, then RED missing AUTO RGB scene text. After correction: normal compile and GREEN scene/reference check. The same check compiled/passed again with F7 recognized-command filtering and independent fence toggles. These build/self-check outputs were returned directly by the execution tool; the report quotes them and does not claim a redirected raw compiler log exists.

## Oracle/observer test-first checks

```sh
node --test tests/terminals/verify-sgr.test.mjs  # old verifier RED; fixed GREEN 7/7
node --test tests/terminals/wait-fence.test.mjs  # absent helper RED; fixed GREEN 6/6
node --test tests/terminals/wait-output.test.mjs # absent helper RED; fixed GREEN 5/5
node --test tests/terminals/*.test.mjs          # final GREEN 18/18
sh -n tests/terminals/run.sh tests/terminals/inner-recorder.sh tests/terminals/outer-recorder.sh
node --check tests/terminals/verify-sgr.mjs
node --check tests/terminals/wait-fence.mjs
node --check tests/terminals/wait-output.mjs
git diff --check
```

## Targeted real PTY check (not emulator-host acceptance)

```sh
cd /workspace/work/auto-harness-repair
source /workspace/work/validation/sdk/cangjie/envsetup.sh
node evidence/check-real-pty.mjs > evidence/pty-fence-green.log 2>&1
```

The complete diagnostic script is retained. It starts the real normally built consumer with util-linux script, removes inherited COLORTERM, records raw/before/after/tty, performs c/c/c/t/resize/n with action+p events, calls actual wait-fence and strict verifier, sends q and compares exact nonempty termios. Product 0568a09 and current independently authored test fixture; not a real xterm/VTE window and no PNG claim.

## Future independent GUI run

The ordinary scene entry and full default fixture entry are documented in tests/terminals/README.md and report.md. No GUI execution was performed by this test author, per coordinator instructions. The independent executor must normally build integrated product/tests and retain actual original PNGs; missing/failing tools never invoke a fake-image fallback.
