# Independent TASK145 public CLI counterexamples

These are new regression facilities; the sealed TASK143 files and existing test
assertions are unchanged. No product source, private hook, reflection, source-text
assertion, new runtime dependency or cold build is used. Python uses its standard
library only and is an external test driver, never a benchmark dependency.

Run `counterexamples.py --compat NORMAL_ELF --compat-sha256 ACTUAL_EXPECTED_SHA
--diagnostic NORMAL_ELF --diagnostic-sha256 ACTUAL_EXPECTED_SHA --out NEW_DIRECTORY`
after setting the ordinary SDK runtime environment. Both normal files are checked
before runtime. Exit0 means the regressions pass; exit1 is assertion RED; exit2 is
an infrastructure/protocol failure and cannot be reported as a product RED.

F145-02 uses a synthetic controlling PTY with actual TIOCGWINSZ80×24. It replies
only to an observed cursor-status query, records the initial first-row wire before
any setup/warmup/mutation key, then follows normal `r,r,b,a/f/k×3,e`. Warmup is
exactly0. The initial target must be two question columns and78 blanks. Logical
中→文→??→中 all have that same Ascii projection, so actions must not emit business
row1 updates. Complete fence row24 is separately observed before the later key
acknowledges its normal render. Raw bytes, input/replies, offsets, side-channel
acknowledgements, sample, actual dimensions and normal exit are retained. PTY read
chunks are never counted as native writes, and this is not real-host/cost evidence.

F145-01 checks public normal sample fields, not source tokens. With only one
changing first-width input and up to two optional first-leaf text/color bindings,
seven unchanged weighted siblings add no subscriptions to that input. The expected
public subscription/active-binding range is1–3 before/after; `dirty_leaves` is1
business input, rather than counting dependent geometry as seven extra mutations.
Independent first-row Cell expectations use literal equal-weight allocations
10×8 →20,9,9,9,9,8,8,8 →10×8 and the literal mixed Unicode Cells. Geometry can pass
even for an explicit manual allocator; the dependency check distinguishes the
current extra subscribed widths. Neither runtime check alone proves use of the
weighted allocator against every possible imitation: fixed-source145 review must
still confirm the actual public Row/flex construction. `same_row_columns` remains
under its unchanged original contract; this narrow driver does not rerun it.

The watchdogs are transport bounds, not FPS/latency requirements. Each invocation
keeps one bounded80×24 wire/Cell capture and compresses its own raw losslessly.
It stops before12MiB free plus its capture reserve; no compiler/cache/dependency
copy or broad scenario matrix is invoked.
