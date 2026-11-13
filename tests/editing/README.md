# TASK118 public editing contract

`cjpm.toml` is a normal public path-dependent executable consumer for E001–E005/F003–F005. At the TASK118 freeze, all upstream keyboard/session/Canvas/Theme/focus/viewport APIs exist and the editor API is absent. No editor assertion, actual editing PTY vector or real source race has executed. The future body is not yet fully typechecked against editor declarations.

With SDK1.2/stdx/UCD/registry configured normally for each consumer, run:

```sh
bash tests/editing/run.sh --prerequisites # positive public upstream build/direct execution
bash tests/editing/run.sh --red           # deliberately fails until editor APIs exist
bash tests/editing/run.sh --selftest      # fixture/schema checks only
bash tests/editing/run.sh                 # after119: body build/direct binary + actual PTY
```

The ordinary runner builds and directly runs its binary, then builds the accepted keyboard test's `native/pipe_remap.c` into its own artifact directory and launches the actual editing PTY vectors. Set `CJTUI_EDITING_ARTIFACTS` to a fresh output directory to preserve input/output/exit/termios/binary/shim receipts. The parent owns dispatcher wiring. A compile error, fixture selfcheck or pure policy table is not product behavior PASS.

`src/concurrent_source.cj` uses actual Cangjie `spawn` and Mutex/Condition startup/completion handshakes. A worker performs at most65536 monotonic legal `Observable.set`s while the UI performs a fixed256KiB unguarded transaction, for at most8 rounds. A round counts as a conflict only with one actual ConcurrentValueChanged, false return, zero onChange/new undo and final worker value preserved. Precise read→commit attribution additionally requires fixed119 proof that this issue's only reachable locus is the atomic expected-version commit failure. No conflict or ambiguous attribution is insufficient_evidence. Public APIs do not force that internal scheduling point; no sleeps, fake values or test hooks substitute for it.

`pty.mjs --selftest` and `fixtures/handshake.mjs` still test transport/tool mechanics only. Product vectors use real Application.run, actual PTY output/termios, and the accepted OSpipe input remap for read0 and consumed-prefix receipts. `cut-race` holds the actual PTY sink after the OSC52 prefix until a real background source write acknowledges through a FIFO. Only actual SessionResult outcomes are consumed; Direct Unknown may completely emit SentUnconfirmed and must preserve data. No system clipboard read/query or fake Applied backend exists. Applied policy is a manual golden table plus future fixed-source proof, not an executed integration assertion.

The per-requirement source/golden and remaining proof boundaries are in `recipes.md`. Test-only helpers carry no product declarations; types each have one lowercase file.
