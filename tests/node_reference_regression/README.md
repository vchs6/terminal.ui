# Active NodeRef lifetime / getter guard regression

Run `bash tests/node_reference_regression/run.sh` with normal SDK1.2/stdx/config.
One ordinary build, then two independent direct timeout60s consumers:

- controls: mounted queries, real unmount/new generation; public SDK gc with
  observed getGCCount advancement, then active Component.reference/same-node
  queries and NodeRef.application owner stats. GC progress timeout exits2 as
  environment-insufficient, never product RED.
- guard: the original public if-let Component.reference→requestFocus getter
  shape across at most500 natural mount cycles. Each active getter must receive
  ReentrantEvaluation, never StaleReference. No preceding forced GC changes its
  fresh-process allocation schedule.

Only public cjtui/SDK APIs; no private GC hook, FFI, implementation or host matrix.
