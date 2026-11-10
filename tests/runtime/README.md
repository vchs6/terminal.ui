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
