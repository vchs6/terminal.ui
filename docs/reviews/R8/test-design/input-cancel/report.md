# Independent input cancellation regressions

Product revision actually built/run: 2794136e45aee98300f4b16456dfa6b605cfdf74.
Frozen independent regression test commit: 56bc01b430e3541a3c7babd32c7cfa68159c6525.
Checkout: /workspace/work/first-slice-tests/repo, branch task048-input-cancel-regression.

Only tests/integration/pty.mjs and tests/README.md changed. No API, product source,
build hook, prior assertion, or implementation-author reasoning was changed/read.
The expected behavior comes from design.md: default Ctrl-C exits, unknown control
sequences are bounded/ignored, UTF-8 bytes are not separate text events, and normal
cancellation restores terminal mode. Existing six PTY cases remain unchanged.

Build environment/command:

```sh
cd /workspace/work/first-slice-tests/repo
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_UCD_ARCHIVE=/workspace/work/validation/replay-dependencies/UCD-17.0.0.zip
(cd tests/integration/fixture && cjpm build)
```

Ignored fixture-local cangjie-repo.toml points repository.cache.path to
/workspace/work/validation/replay-dependencies/cache and repository.home.registry
to http://127.0.0.1:18972. No cache packages were patched. Actual build exit 0;
raw output is input-cancel-build.log. No extra FFI/compiler/link flags or stubs.

Actual independent commands (run after sourcing SDK):

```sh
node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main ctrl-c
node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main osc-ctrl-c
node tests/integration/pty.mjs tests/integration/fixture/target/release/bin/main utf8-ctrl-c
```

| Case | Exact input after first frame | Actual Node exit | Result / raw log |
| --- | --- | --- | --- |
| Existing direct Ctrl-C control | 03 | 0 | PASS normal exit 0, exact termios restored; input-cancel-ctrl-c.log |
| Unterminated OSC then Ctrl-C | 1b5d303b78797a78797a, 60ms later 03 | 1 | RED timeout: clean termination (osc-ctrl-c); input-cancel-osc-ctrl-c.log |
| Incomplete UTF-8 then Ctrl-C | c2, 60ms later 03 | 1 | RED timeout: clean termination (utf8-ctrl-c); input-cancel-utf8-ctrl-c.log |

Each command also independently passed the non-TTY/no-ESC precheck. Each real PTY
application displayed its actual first frame and passed unchanged idle/no-update
checks before the input was sent. Both regression logs record finished=false and
missing after-termios snapshot at the five-second deadline. Thus neither case
returned normally or produced restoration evidence. The harness then used SIGKILL
only to clean up; it did not call that cancellation success or claim restoration
failed after an orderly exit. Neither test supplies an OSC terminator, a UTF-8
continuation byte, an external signal, or a q key to rescue the blocked parser.

Verification: node --check tests/integration/pty.mjs, git diff --check, and staged
diff check all exited 0. Actual behavior remains RED. Product fix/independent
execution and acceptance are separate roles; this author did not modify product.
