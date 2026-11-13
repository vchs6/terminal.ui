Test-only fixedSHA daf99aa1f323929d09907d558623b3bb6a74cbbb; BASE430eb63fef4ca1d2cf2370d8b5c4c8d9931d3de8.
Only tests/integration/fixture/src/main.cj changes: app.glyphMode(GlyphMode.Unicode) plus one virtual-model comment.
The virtual Unicode grid now explicitly selects its supported logical profile; no real-host font capability is claimed.
Exact original8×3 emoji oracle, all input cases, parser, other fixtures, product Auto/conservative fallback and specs are unchanged.
Evidence: immutable ../integration-diagnosis/report.md and manifest a42506295318db020c64dcadfed19b7e990f90afd64465e4e65f32cecd14a998.
Original c3c integration actualRED/raw retained byte-identical; no standalone RED, compiler or unchanged integration rerun performed.
Verified exact two-line-only diff, clean source and unchanged oracle hashes; execution116 owns compile/targeted integration on unchangedc3c.
