# Rendering benchmark

The public rendering benchmark is under development and does not yet produce
measurements. Its draft source is in `benchmarks/rendering`; do not interpret
an unavailable workload as a zero cost or a successful sample.

The intended comparison uses the same business workload and ordinary public
snapshot API with the frozen complete M1 and final M2 packages. The final-only
diagnostic is separate because the three additional RuntimeStats counters are
not present in M1. Compatibility reports must mark arrange, Cell writes and
allocated Cell storage slots as `not_available` in both versions.

Cell storage slots are not allocated bytes, object counts, total heap allocation,
or RSS. Process CPU, wall time, RSS and actual successful terminal output require
independent external observation; SDK heap occupancy and cumulative GC values
have their own scopes. No measurement or improvement is claimed here.
