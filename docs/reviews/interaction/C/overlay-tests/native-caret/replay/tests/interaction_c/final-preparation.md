# Final preparation applicability (620 source; B107 pending)

This is a new preparation snapshot, not a rewrite of the old PREPARATION
record. Original `admission.tsv` and old evidence are historical and unchanged.
A102 accepted source is f8a028b39daf8a341576f304335d262544b9cca5.
This preparation uses 62039552a26da295dcd710d7cfc40cb9e43ca5fd, which has
source review evidence but is **not yet B107 accepted**. TASK108 formal admission
and TASK109 implementation remain pending root's handoff. No C behavior ran.

The actual A/B/Theme/Frame/SDK public positive is `baseline/`; it is separate
from the C consumer and has no overlay declarations or namespace substitute.
`bash tests/interaction_c/run.sh api-probe` is an ordinary `cjpm build` only,
permitted during preparation to capture the missing-C API compiler RED.
`formal`/`device` still require the admission table; there is no environment
bypass. With real C admitted, formal builds normally and directly executes the
resulting binary. The device mode likewise builds first and then runs the real
fixture through the existing B PTY primitives. A build failure never runs an old
binary. Use `fixture-controls` for tools-only negative controls.

Frozen-before-formal corrections/limits, by canonical authority:

- D08's old recipe said the explicit host was absent from the logical path.
  C.2 requires a host to be owner/ancestor; an ancestor already on the owner
  chain legitimately appears once in its original position. The fixed vector
  is `L;O;H;R;APP;LEGACY;`: host adds/replaces no parent edge. This is a correction
  of old recipe wording, not a claim that wording was retained byte for byte.
- P05 uses public WeakRef(EAGER), gc/getGCCount, and a bounded wait. EAGER does
  not guarantee collection. Only terminal handles/resources are asserted;
  weak-clear/progress are observations, neither a strong leak PASS nor product
  failure on absent collection. Ownership/weak-handle source review belongs to
  TASK110. There are no private GC hooks or manual `WeakRef.clear` calls.
- C callbacks are not forbidden during ordinary invalidation. No M2 callback
  count is imposed. Focus restoration checks public outcomes; no private
  transient focus hook is invented.
- B's deferred M01 getter-axes-onMount behavior is not a positive dependency:
  C fixtures query geometry after snapshots, never assume Both onMount.
- H02 remains future Keyboard117 integration, outside this unit. H01's real
  native/host results and original host PNGs remain UNEXECUTED until C exists.
  The device driver records native domain/interrupt/cleanup/termios; it does not
  simulate a terminal, claim host support, or make ANSI bytes into screenshots.
