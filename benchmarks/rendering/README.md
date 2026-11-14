# Rendering benchmark (implementation in progress)

This benchmark is incomplete. The compatibility and diagnostic projects have
working draft runners for seven text scenarios; other correctness scenes can
emit draft Cell/caret observations but return nonzero until their scene facts are
implemented. Timing, terminal, first-generation and old/new package coverage
are not complete. Do not use these drafts for performance conclusions.

The intended projects are `workloads` (public API source shared by both
libraries), `compat` (old and new libraries), and the root diagnostic project
(final library only). Their dependencies use normal relative CJPM paths. For a
comparison, use identical `workloads` and `compat` sources in clean consumers and
adjust only the library dependency path. Three final-only diagnostic counters are
always `not_available` in compat; the executable never imports those fields.

## Draft terminal protocol

The draft normal `Application.run` entry supports text scenarios and `idle`.
The driver sets the requested terminal dimensions, launches with `--mode tty`
and uses `<csv path>.ack` as a replace-in-place UTF-8 business side channel.
Allow capability and caret probes to settle before beginning. Keys are processed
in normal input/render order:

1. Send `r`; wait for `ready`. The first normal target has preceded that input.
2. Send exactly `--warmup` `w` keys; each yields `warmup:N`. Follow the final
   warmup by `r` and `ready` to acknowledge its preceding render.
3. Send `b`; wait for `begin`. The callback samples Stats and SDK values before
   the acknowledgement, and starts the idle/measurement interval after it.
4. For a non-idle workload, send `a` for each business action. A subsequent
   `f` changes the dedicated last-row fence and writes `fence:N`; observe the
   corresponding terminal bytes, then send `k` and wait for `presented:N`.
   The `k` callback occurs after the fence render. Fence work belongs to the
   process and must be identified separately when attributing output.
5. For idle, send no keys, mutations, exports, Stats queries, or fence changes
   between `begin` and `e`. Send `e` to close the interval; wait for `end` and
   normal process exit. The end callback takes ending observations before stop.

A side-file write acknowledges business ordering only; it does not assert that
its own callback's frame has appeared. Handle partial/truncated reads by retrying
until the entire expected acknowledgement is present. The normal terminal
backend owns rendering and cleanup. This protocol is not yet available for all
scenarios, and a PTY smoke test is not real-terminal performance evidence.
Native successful writes, process CPU, RSS, external provenance and trace phase
attribution are the independent operator's responsibility.
