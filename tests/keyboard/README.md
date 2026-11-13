# Current TASK113 formal admission

See [formal-admission.md](formal-admission.md) and [formal-integration-ledger.md](formal-integration-ledger.md) for root ACTUALGO, current fixed prerequisites, entry, manual oracles and exact UNEXECUTED limits. The original preparation text below is immutable historical context, not the current admission status.

---

# TASK113 keyboard test preparation

This is test-only **PREPARATION**, frozen against input design
`88ed5f7866fae04c0459ab7310f927b02fb59c29`, K001–K004 and F002/F003/F005,
TASK113 L4. Product base is `57403cec0af422d9b8bbd201f2e9faeb6adea32d`.
It does not complete TASK113 or admit TASK114. Existing tests are retained.

With the project SDK environment and ordinary registry configuration:

```sh
bash tests/keyboard/run.sh
# After real upstream integration is admitted, build and run the prepared subset:
bash tests/keyboard/run.sh --pty
```

`run.sh` builds an ordinary CJPM consumer through `cjtui = { path = "../.." }`,
then invokes the actual binary, preserving its exit. The current old product
builds normally; the consumer is genuinely RED because the frozen public
KeyboardDecoder/KeyboardLimits/KeyboardIssue/KeyboardBatch/diagnostic API and
KeyEvent modifiers are absent. A missing focus/modal/session framework is
**blocked integration**, not a new keyboard behavior failure.

`src/` holds manual protocol goldens and literal byte offsets, not a second
decoder. Short vectors are fed at every two-chunk byte split, including both
empty endpoints, and one byte at a time. Timed states use explicit `timeout()`
calls without sleeps. Large paste vectors use fixed 4096-byte chunks; a whole
1 MiB vector is not redundantly split one million times. Coverage includes
navigation/function keys, all eight modifier masks, C0 aliases, raw/UTF8 C1,
true scalar-boundary ST, malformed/unknown framing, string quarantine, Alt
and normal partial UTF8, sequence drain, exact/+1 paste limits, no idle paste
timeout, EOF, decoder closure and defensive batch arrays.

`check-api.sh` runs only after the positive consumer executes; it checks four
negative consumers for zero-argument construction and property reassignment.
It cannot prove the absence of every possible public constructor signature;
the complete constructor visibility obligation also requires source/API review.
It never interprets an undeclared whole product API as a successful negative test.

`device/` and `pty.mjs` prepare a real Application.run subset: atomic paste with
03/ESC/LF, a FIFO-gated >8192-byte fairness burst, preventable ordinary 03,
external SIGINT/SIGTERM, callback/issue failure, actual direct exit, exact before/after
termios, resource release, and the requested 2004 enable/restore. The marker in
the actual first frame gates input. File acknowledgements plus the FIFO gate
order callbacks and writes; the polling deadline only detects a deadlock.
This subset has not been built or run against the missing product API and
does not exercise a fake framework. It must be checked on real fixed upstream
APIs before it is accepted. No I015 private cursor-query behavior is assumed.

See [integration-ledger.md](integration-ledger.md) for the required target-lock,
modal, EOF, callback-stage and writer fault paths that remain blocked. A PTY
and TERM branch are not evidence for different real terminal hosts. Linux
console and actual ANSI host validation remain insufficient evidence here.
