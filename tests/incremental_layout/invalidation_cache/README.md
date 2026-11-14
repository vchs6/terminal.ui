# Node invalidation and layout cache public consumer (TASK133)

Prepare-only source at c2f57414; normal SDK1.2 compilation and baseline RED evidence await fixed B132 admission and root build GO. No passing claim accompanies preparation.

From this directory, with the normal SDK/dependencies available:

```sh
cjpm build
target/release/bin/main
```

The executable runs every case and returns nonzero when any case fails. It imports only `cjtui.*`; no test hooks, extra dependencies, or product mode switches. Existing suites remain unchanged. It is also an ordinary consumer when its `cjtui` dependency path targets an unpacked product bundle.

Each paired step uses the same mounted root, dimensions, glyph policy and synchronous business epoch. Full `Cell` equality (including raw Style, grapheme, width, continuation, transparency and frame dimensions) is checked against public full `render`; literal layouts give an independent expectation for the shared algorithm. Snapshot work is captured before reference work and both measure/arrange/paint deltas are printed. Transient different-size references are deliberately outside pairs.

Coverage: constants replacing getters; typed String/Int64/Bool/enum/RichText/StyleUse equality; Observable and every NodeRef notify category; separated nested panels; Row flex remainder and sibling allocation; Column justification and following-child movement; actual wrap widths and four inset keys; ForEach key identity and manual slots, moves/removal/Structure restoration; hidden pending updates and If; span-only style versus text; pure theme colors, explicit/reset masks, same-valued source/fill changes, theme geometry; independent Canvas measure/draw and readonly inputs; M1 cache isolation; implicit root fallback, explicit viewport wrapping/clamping; Unicode/Ascii/Auto generated markers.

Work assertions use no elapsed-time thresholds. Pure style and equal effective inputs require zero measure/arrange work. Changed-path and position-only scenarios require fewer measured nodes than a full reference of the same tree; separated panels also require fewer arrangements. No paint-locality assertion belongs to C; D owns local composition. Diagnostic allocation counts are not treated as bytes or CPU measurements.

Preparation plan: `/workspace/work/incremental-cache-tests/plan.md`; final source/raw/pin index is supplied after the admitted baseline execution. Assigned independent test designer Sol/high; serving configuration cannot be independently verified.
