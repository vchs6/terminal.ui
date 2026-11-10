# Persistent runtime public consumers (TASK-071)

Frozen contract: `a947857c1ba89ce088c7fe4909239e8a2a85089d`,
`openspec/changes/implement-reactive-runtime/design.md`, section 6 R001–R015.
This execution task adds A+B consumers only. No dynamic-group/manual-tree C API
is consumed. Each Cangjie class is in its own file.

Source SDK 1.2.0, configure an ignored `cangjie-repo.toml` with your own cache
and registry as described in `tests/README.md`, then run:

```sh
./tests/run-slice.sh runtime
# Core consumer independently:
./tests/runtime/run.sh core
./tests/runtime/run.sh macros
./tests/runtime/run.sh session
```

The ordinary external CJPM consumer imports only the public product package.
The runner builds and directly executes the binary under a 45-second bound,
with stdin detached, `TERM=dumb`, and empty `COLORTERM`. Compile/link failure,
nonzero binary exit, and timeout fail. It never uses `cjpm run` or a product
stub. All grids and event traces are independently hand-authored literals.

| Source | Breaks caught |
| --- | --- |
| lifetime | eager/repeated build, wrong Column root box, stale-generation resurrection, dual mounting, collector leakage/thread crossover |
| bindings | frozen binding values, leaked branch subscriptions, lost multi-view updates, stale replacement dependencies, untargeted notify, equal target frame work, idle layout/paint |
| bindings / subscriptionRace | real background `set` precisely after a getter's `get` and before its return/subscription installation; version recheck must retain latest value |
| contexts | background `get` polluting UI collector, wrong UI/session entry, invalid capacities, node/dependency/binding/depth limits, getter reentry |
| scheduler | non-FIFO order, recursive same-turn draining, queue-full loss of state invalidation, stale owner work, extra batch frames, hidden business rollback |
| events | capture/bubble/app ordering, consume/prevent/stop differences, expired mutation, hidden ancestors/targets, route altered mid-event, legacy interrupt compatibility |
| cleanup | tokens/subscriptions/queue revoked before effects, child-before-parent cleanup, exception aborting remaining cleanup, duplicate cleanup, partial mount leak |
| export | detached render effects/ref leaks, stale temporary binding, owner render failing to perform complete M1 generation, frame-copy ownership |

`Gate` is a real Mutex/Condition latch with a timeout used only to diagnose
deadlock. No sleep, random scheduling, implementation-generated golden, private
runtime imports, or test hooks determine an expected result. Local `Box<T>`
holds values captured by escaping Cangjie callbacks; it is not unsynchronized
cross-thread storage. Two background handshakes are explicitly joined.

Missing public API at the frozen input is intended RED. A temporary, external
declaration-only syntax check can validate language syntax, but is never run and
cannot count as product compilation or behavioral GREEN. Product authors report
test defects through the coordinator; expected results do not change to fit an
implementation. Subsequent independent execution owns actual product GREEN and
real TTY idle/cleanup evidence.

The macro positive consumer preserves explicit parameter initialization, generic
parameters, two interfaces, public/private State visibility, generated no-arg
constructors, throw paths, and nested lambda returns. Local classes named
`Component` and `Observable` deliberately shadow names to expose unhygienic
generated references; all macro consumers use the three required imports.

`macros/negative/cases.tsv` enumerates independent fixtures for constructor
return, open/abstract components, custom superclass, constructor delegation,
illegal State declarations, private-state access, reserved finishConstruction,
and a wrong typed Bind. Every fixture builds as an ordinary CJPM consumer.
The positive consumer must first build and execute successfully; then every
negative must fail with a source-located compiler diagnostic about its forbidden
construct. Dependency/network/link failures cannot pass. Shared target output
reuses product dependencies; no ad hoc FFI flags or skipped product hooks are
added. Raw stdout/stderr/status are retained in the printed fresh artifact
directory. `CJTUI_RUNTIME_ARTIFACTS` may select an existing artifact parent.

The session fixture is a public ordinary application with a test-local linker
wrapper reused from the existing D027 facility. It always calls the actual
product `cjt_close` before optional failure injection; it never restores termios
for the product. Real Linux PTYs test idle counter stability across three poll
windows, hidden-root routing (legacy non-interrupt preserved), preventDefault
on Ctrl-C, default Ctrl-C, binding/mount/callback/cleanup failures, and combined
callback+cleanup+restore failure. Every case requires exact termios restoration,
one actual successful close, direct binary status, and exactly-once registered
cleanup. Timeouts and SIGKILL are failure cleanup only. Node, GCC/ar, util-linux
script/stty, and rg for macro diagnostics are test facilities.

The idle timer measures the interval under test; public callback file
acknowledgements order both sides of it. All concurrent state races in the core
use deterministic Condition handshakes. Session raw bytes, stderr, before/after
termios, close records, callback acknowledgements, and result JSON remain in the
fresh directory printed by the harness. This author freezes missing-API RED;
the independent execution role supplies actual implementation/TTY results.

R017 supplement is frozen from design at `987dfde`: the public
`UICleanupException` constructor preserves the primary exception object/type,
defends both array boundaries, reports messages/counts/order, and flattens prior
aggregates. Additional runtime cases check mount plus two cleanup failures,
cleanup-only primary selection, and original exception identity/type when no
additional failure exists. Existing assertions remain unchanged. The PTY dual
cleanup/restore case also requires those failures in the returned exception
message after actual close, rather than only in stderr.

Review regressions under the original R004/R005/R011/R012 contracts have focused
case selection after the ordinary core build:

```sh
CJTUI_RUNTIME_CASE=cleanup-context tests/runtime/target/release/bin/main
CJTUI_RUNTIME_CASE=owner-render tests/runtime/target/release/bin/main
CJTUI_RUNTIME_CASE=owner-render-cleanup tests/runtime/target/release/bin/main
./tests/runtime/session/run.sh hidden-cross-session hidden-reentrant
```

Cleanup must install A's active UI context while invoking user effects, reject
entry into idle B with WrongUIContext, then restore TLS and leave B usable. An
owner-session global render getter failure must clean A like snapshot does,
release pending owner work/subscriptions, and preserve primary/cleanup errors.
The real PTY hidden legacy path must retain business callback execution and
default Ctrl-C while enforcing normal callback context/reentry rules and exact
terminal restoration. Each focused case runs independently so one RED cannot
hide evidence for the other failure exits. Existing assertions are retained.

Opt-in idle CPU evidence uses the same actual PTY fixture, outside default `all`:

```sh
./tests/runtime/session/run.sh idle-cpu
```

It requests a 512×256 viewport and 2048 extra pure getter nodes. After the first
frame and a public callback acknowledgement, it samples the actual application
PID's `/proc/PID/stat` user/system CPU ticks over an input-free two-second
window. Raw counters, clock-tick rate, wall duration and CPU-equivalent cores
are saved in `idle-cpu.json`. There is no absolute CPU pass threshold. Initialization
precedes the acknowledgement, while ordinary poll/GC/copy/diff work during the
window is included. This measures whole-process CPU on one host/configuration,
not attribution to a particular internal loop, thread-ID reuse, RSS, or a portable
performance guarantee. The original public idle counters remain checked.
The SDK `cjHeapSize` environment setting is recorded in each sample; the intended
comparison uses the default heap with that variable unset. Run samples sequentially
and use the same viewport/getters/heap setting for later comparisons. CPU-mode
initial-frame readiness allows 30 seconds; that interval is excluded from the
CPU sample. An earlier 1024×1024 default-heap attempt failed before a CPU window
could be established and is not a CPU baseline.
