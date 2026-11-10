# TASK148 independent session-extension tests

Test-only contract at `d0657194529747da9dd2494f84c2fbbea0e16378`, SDK **1.2.0**, package **0.0.0**. Old product base: `9bc493fe9c1943b8608be0969c0b2d5e4cfdd924`. These are ordinary CJPM path consumers of `cjtui`, with real Application lifecycle and the existing native writer. No private session encoder/API or declaration-only implementation supplies a successful result. Old-product RED is a missing-public-API build failure; future-product runtime execution is a separate role.

```sh
source /path/to/cangjie/envsetup.sh
# Configure each consumer's ignored cangjie-repo.toml with its OWN writable cache:
# [repository.cache]
# path = "/absolute/private/cache"
# [repository.home]
# registry = "http://127.0.0.1:18973"
# Seed that cache by COPYING the fixed dependency cache, never writing the seed.
export CJTUI_UCD_ARCHIVE=/path/to/UCD-17.0.0.zip
# From repository root:
tests/session_extensions/run.sh selftest  # no Cangjie/product session execution
tests/session_extensions/run.sh build     # ordinary consumer, real old-library RED
tests/session_extensions/run.sh all       # selftest + build + direct actual binary
# With a previously built fixed actual product consumer:
CJTUI_SESSION_ARTIFACTS=/absolute/NEW-artifact-dir tests/session_extensions/run.sh run all
# Targeted runtime cases, repeated on all applicable routes:
tests/session_extensions/run.sh run headless ledger fault-copy
```

`build` uses the caller's selected SDK and CJPM config; never starts another registry relay. `all` stops on build failure. The runner invokes `target/release/bin/main` directly, preserving exit status rather than relying on `cjpm run`. The test consumer catches expected `run()` exceptions to record public aggregation fields and attempt same-process reopening; the oracle requires those failure records, so process exit 0 alone is never a pass. New native archives and the selftest executable are ignored and test-local. Test tools do not belong to the product bundle. Only a private PTY/X display and self-owned clipboard seed may be used. Existing R10/native/application tests are preserved unchanged.

## Executable assertions and named breaks

| Contract | Consumer / oracle and regression caught |
|---|---|
| S002/S011 | `src/record.cj` consumes all fields, eight enums/all cases, seven Application additions. `headless.cj` retains typed bare `None`; per-type declarations/factories are never forged. Wrong/missing public signatures fail the normal CJPM build. |
| S003 | `headless`, `no-request`, `disabled`, `declared`, two independent-policy cases: first snapshot absent, headless NoDevice, last snapshot retained/new ID, Auto Unknown/NoEvidence despite TERM/TMUX/STY names, ExplicitConfiguration stays unconfirmed, image NoImageAdapter, no spontaneous session sequences. |
| S004 | `wire`, `bounds`, `invalid`, `disabled`: empty clipboard/title, RFC4648 f/fo/foo/foob/fooba/foobar, Unicode and C0/C1 clipboard data, no normalization. 65,535/65,536/65,537 copy bytes; 1,023/1,024/1,025 title bytes; exact multibyte budgets; 1,048,575/1,048,576/1,048,577 icon bytes. Nine malformed UTF8 classes after a 2-byte prefix; all 65 forbidden title scalars C0/DEL/C1 at byte offset 2. Invalid input wins over disabled policy, no truncation or output. |
| S004/S005 | Manual `fixtures/wire.json`: fixed OSC52 selection c/BEL, OSC2 only, window-title push/pop only. Every vector on Direct/Tmux/Screen; doubled ESC and two-byte ST compared exactly. Direct maximum 87,392; tmux 87,402; screen 87,396, all below 90,000. |
| S006 | `headless`: every operation in inactive/getter/mount/cleanup/cross-session/thread contexts; event/post/batch/outer owner calls, active option rejection, FIFO and next-turn cutoff, 4,096 accepted posts then rejection, stopped closures dropped, copy leaves frame count unchanged. `fifo`, `cancel-before` and ignored-Failed live cases preserve existing scheduling and safe boundary. |
| S007 | `ledger`, `ledger-close/error/cancel`, `unknown-title`: zero-scope restore, one push across repeated set, explicit pop, repeated restore Unknown/NoSavedTitle+NotNeeded, set creates new scope, explicit-pop close has zero cleanup, normal/error/cancel scope closes once, unknown stack never pushes. UI and native cleanup failures remain observable. |
| S008 | Five small sequences (copy/save/set/pop/multibyte title), every incomplete byte offset on three routes. Native EIO/EAGAIN/write=0, one EINTR followed by success, repeated successful one-byte writes, and pre-write buffer allocation fault. Exact byte sums/steps; save failure skips set; set fault includes save bytes; partial faults have result ParserUnsynchronized and actual-step WriteFailed. First device failure wins even if ignored or followed by callback/UI/native failures. No later poll or output; real close restores termios and signal handlers/masks; second Application reopening is refused after partial writes and allowed after zero-byte failures. Existing screen writer partial offsets 1/2/5 exercise the same process latch. |
| S009 | Every actual result and step consumes the public honest status; Applied and RestoreConfirmed are prohibited. The current OSC result therefore cannot authorize default cut deletion. Editor revision/selection/undo and input paste integration remain TASK028/041, not a fabricated editor here. |
| S012 | Mutate returned set steps then restore; mutate cleanup outer entries and nested steps, requery and compare original values. Readonly fields alone are not considered proof of deep isolation. |

`cases.mjs` is the authoritative runnable matrix. There are 277 runtime configurations, including 211 per-byte extension faults and three screen faults; host profiles are additional separate real runs. Each configuration contains many public result/byte assertions, not one purported test per compiler error.

Wire expectations are independent literals and hand-derived repeating RFC4648 groups, never generated by the product encoder. Astral boundary payload is independently encoded by Node's standard Base64. `selftest` compiles C fixtures with `-Wall -Wextra -Werror`, exercises the real existing native writer, and checks literal goldens; corrupt padding/query selector/OSC selector/extra pop and corrupt result fields must be rejected. Four additional synthetic observation negatives check the host oracle. Selftest PASS is solely a test-fixture result.

## Native seam and artifacts

`native/session_fault.c` links `--wrap` around existing C symbols/syscall `write`. It delegates the actual writer/open/close and replaces one chosen native return, without changing production sources/caches. Allocation injection is an existing `cjt_buffer_add` failure before its first byte, not a claim to exhaust the Cangjie heap. Errors on each generated sequence are selected after the initial frame, so protocol prefixes, wrappers and multibyte UTF8 boundaries are all covered. A partial-write case always gets its own process because the unsafe latch lasts to process exit.

Artifacts per run: exact `results.tsv` public fields, native syscall/sequence/open/close/signal log, `wire.bin` for fixed session transactions, `all-wire.bin` for all post-arm output, full real PTY `session.raw`, before/after termios, actual TTY path, PID, launch/time/config and check result. The oracle separates session transactions from ordinary UI/caret protocols. Startup screen frames and future independently contracted caret queries are outside session golden bytes. After a partial fault, **all-wire** must stop at the exact failing prefix, including zero blind CAN/SUB/ST/BEL/reset/pop/screen/mode cleanup. Test assertion diagnostics use files, never terminal output after unsafe failure.

The suite deliberately inspects healthy zero-byte reopens and same-process partial refusal; it never opens another writer or repairs parser state. It asserts no device writes for disabled/headless/invalid operations. No shell, clipboard read, query or host-control process is added to product behavior. Shell/PTY/X11 tools below are private development fixtures.

## Real host fixture/oracle entry

`run.sh host /absolute/manifest.json` validates a **fresh actual public consumer run**, using `fixtures/host-manifest.example.json` as schema. FILL values cannot pass. Do not point it at host-only protocol experiments.

`host-consumer.sh /absolute/normal-consumer /absolute/NEW-dir [route] [auto|declared]` is the real terminal child entry: it requires actual input/output TTYs, refuses an existing artifact directory, records binary hash, actual TERM/mux/grid/TTY/time and before/after termios, and invokes the actual binary. For example, a private XTerm launcher can use `-geometry 100x28 -e /absolute/tests/session_extensions/host-consumer.sh /absolute/main /absolute/new-run Direct declared`; outer capture and XTEST remain controlled by the independent private-display fixture. The script starts no shared host processes and reads no keys or clipboard. Launch the built consumer with `CJTUI_SESSION_CASE=host`, `CJTUI_SESSION_ROUTE=Direct|TmuxPassthrough|ScreenPassthrough`, optionally `CJTUI_SESSION_DECLARE_STACK=1`, and the results/native/wire/all-wire paths above. Use real XTEST/keyboard events **c → a → b → r → q**, capturing actual host state/PNG/native grid between each phase; `x` is not used. `c` arms transaction recording and sends the fixed self-owned test payload `CJTUI_HOST_中😀\nLOCAL`; a/b set fixed titles, r restores. Save the full raw outer stream independently. Result files update after each event and finally after close. For error/cancel restoration, use the lifecycle modes in the runtime matrix and capture actual host state before/after those runs too.

Reuse the independently frozen private Xorg/XTerm398, VTE0.80.1, tmux3.5a and screen4.09.01 launch/config/clipboard observation mechanisms from the recon handoff; replace the protocol child with this actual normal CJ consumer. Preserve original raw evidence and choose fresh run directories. Required permission controls are XTerm default denied vs SetSelection enabled and title-disabled, VTE dynamic-title mode, tmux default/clipboard-on/outer-denied/passthrough-off/on, screen default/passthrough. Compare the **specified target** (pane title vs outer caption), not interchangeable title values. Declare stack only for an intentionally selected complete path; application declaration never changes SentUnconfirmed to Applied.

`observations.json` contains actual clipboard-before/after hex, title map initial/A/B/restored, icon property before/after SHA256, exact termios before/after and exitCode. Manifest `expected` holds independently chosen expected values from that profile's frozen configuration, not values copied from observation. Include measured dimensions/time, binary+source SHA, original configs, actual PNG hashes/capture command/window ID and native-grid path. A capture from a private X server may read only its self-owned seed/payload; no user's clipboard is inspected. Actual host screenshots are never rendered from ANSI or synthesized by this suite. If a host has no native-grid export (current VTE recon), retain that limitation and obtain evidence before claiming this strict host oracle passed.

For SSH, reuse the private stock sshd readiness handoff's real `ssh -T` + remote `script` PTY topology, fixed keys via the existing launcher only, without reading/copying private keys. Add `ssh` object `{topology, remoteTty, remoteGrid, clientLog, remoteCommand}` to the manifest. The oracle requires real publickey auth, negotiated kex, exit status, actual remote PTY/grid and the recorded script command. Loopback is explicitly loopback; no claim of arbitrary remote network/resize/Wayland coverage. The host-only SSH reports never count as this product consumer passing.

## Boundaries and open execution work

This task freezes tests and old-product RED, not future-product GREEN or AC030 acceptance. Impossible public inputs (an unknown enum route, Int64-overflow Array allocation, >90,000 generated wire after the stricter payload caps) are not fabricated through private encoder calls. Those constants are bounded by reachable maximum wire assertions; unreachable enum outcomes are compile-consumed. Heap/OOM coverage is the existing native allocation seam only. Host execution, SSH product evidence, resize/disconnect, independent code review and acceptance are separate roles. This suite does not replace R10 or the full AC008/020/030/041 scope.

## Headless record namespaces

The headless capability snapshot uses `headless.capabilities.*`; operation
results retain `headless.copy/title/restore/icon`. The original `headless.title`
capability/result key collision is preserved in `fixtures/headless-key-collision.tsv`
as fixture-only evidence. `node tests/session_extensions/key_selftest.mjs` checks
the original collision and both5-field/6-field orderings, then renames only those
capability keys in the original records to verify unchanged field expectations.
`parseResults` rejects a duplicate key that changes pipe-delimited record shape;
legitimate same-shape getter/mount repeats retain the original last-value
behavior. It does not validate every repeated invocation separately or reject
all duplicate keys. The control checks that behavior against the real supplied
fixture. Its PASS is solely an oracle/record-namespace check, not product or
headless runtime GREEN. Normal `selftest` includes this control.
