# Rendering benchmark

The public rendering benchmark under `benchmarks/rendering` is being validated.
It provides ordinary Cangjie workloads for comparing frozen complete M1 and
final M2 packages through the same public application and snapshot APIs. A
separate final-library diagnostic exposes the additional arrange, Cell-write and
allocated-Cell-slot counters; compatibility runs report those three values as
`not_available` in both versions. The benchmark does not add a library mode,
reset counter or private instrumentation hook.

The scenarios cover mixed Unicode, local and broad edits, dependent layout,
viewport and focus/caret state, overlays, themes, first generation, normal idle
and actual terminal output. Correctness exports every structured Cell and an
independent caret observation. Timing uses separate processes and excludes the
reference render and equality checks; it retains the normal return and required
business synchronization costs. The benchmark README specifies eligibility,
CLI, lifecycle windows and the ordinary terminal driver protocol.

Cell storage slots are not allocated bytes, object counts, total heap allocation,
or RSS. SDK heap occupancy and cumulative GC measurements have distinct scopes;
whole-process CPU/wall/RSS and successful terminal writes require independent
external observation. The run ID joins these observations to an externally
verified provenance manifest. No improvement, complete package coverage or
performance acceptance is claimed until independent fixed-artifact execution
and review are complete.
