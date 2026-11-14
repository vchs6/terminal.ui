# Rendering benchmark (implementation in progress)

This directory is not yet an executable benchmark: the compatibility entry point contains draft text workloads and the diagnostic entry point
rejects workload requests. The common project defines the frozen
mode eligibility and CLI boundary; these sources have not been compiled or validated.
Do not use this draft for performance claims.

The intended projects are `workloads` (the same public API source for both
libraries), `compat` (old and new libraries), and the root diagnostic project
(final library only). Their dependencies use normal relative CJPM paths. To
compare ordinary old and new packages, use identical `workloads` and `compat`
sources in clean consumers and adjust only the library dependency path.
