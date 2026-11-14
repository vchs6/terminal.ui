TASK010.d independent review — fixed C003 public snapshot tests
SPEC: PASS for the fixed C003 test/source scope; QUALITY: PASS with one inherited Minor documentation finding.
Fixed range: ecbf0999a392e5298e6e5bd15bd796dd9d40e582 → 234a636900ac4476cf3c18e4b1d6be4b8a866ec5; 17 test-only files; no product delta.
Contracts: review brief C003/010.a–e; REQ-005.5/.6, AC-010; Glyph G002/G007/G009; interaction C.1/C.5/C.6; theme T015; AGENTS11.1/14.
Manual grids independently match public scene geometry: Unicode/Auto/Ascii ellipsis, preserved business Unicode, nested layers, holes/styled spaces, current covered base, viewport edges, moved/shrunk/closed decorated layers.
Every nonempty cell compares glyph, width, continuation, full Style and opacity; retained Frame objects are rechecked after state, policy, geometry and layer changes.
Fresh-grid ANSI oracle compares complete cells/styles and requires explicit coverage, positioned text, initial/final reset, legal finite glyphs and no device/erase controls; its negative controls exercise real rejection paths.
Actual UTF-8/plain bytes are literal goldens; truecolor and monochrome ANSI are independently consumed; 4096-byte preseeding verifies truncation, including zero-area files.
Source ordering: application.cj:346 pumps then produces without device output; runtime_session.cj:1515 returns a copied Frame; layout.cj:405 paints base/current overlays; frame.cj:258 forwards SDK errors.
Offline policy/profile owners preserve Unicode business text and independent color semantics; no product parser/renderer/Unicode kernel or extra public API was introduced.
Raw CLI04 exit 0 includes build, direct binary, real short-write launcher and file validator; CLI03 modal-focus fixture failure remains preserved and matches interaction C.1.
Both writers report actual directory/NUL/permission/post-open/short-write exceptions; UID1000 denied directory is mode0500; short.txt and short.ansi contain actual 32-byte expected prefixes.
Recorded SDK1.2.0/Node24.22.1/cc14.2; evidence index SHA256 cc495d55f1a566f36344e49d73739403b1ee655ebad27b545e94ac62a3d853d4 verified directly.
Finding VS-REVIEW-001 (Minor, inherited): docs/product/README.md:22 lacks ANSI-file viewing conditions required by REQ-005.6; add concise UTF-8/CUP/SGR, dimensions and viewing instructions before complete documentation acceptance.
No Critical or Important behavioral/test-quality findings; no C003 test/source change requested.
Declined: actual host display/session recovery/full Linux/M2/release — explicitly outside this review.
Declined: rerunning unchanged bundle/consumer checks or certifying final AC010 — AGENTS11.1 reuse and separate 010.e acceptance apply.
Limits: read-only source/tests; no builds, test reruns, subagents, source/spec edits or pushes. Standalone author reports were not read; README assertions were excluded as proof.
Skills used: requesting-code-review/code-reviewer checklist and verification-before-completion, with the assigned no-rerun rule and AGENTS11.1 controlling evidence reuse.
Input bindings and output hashes are in index.json; exact finding and scope are in findings.json. Index self-hash is returned with delivery.
