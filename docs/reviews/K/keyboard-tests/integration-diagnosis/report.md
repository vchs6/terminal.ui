Root cause: preexisting virtual-Unicode fixture/profile mismatch, not a newly observed K glyph regression; no product/test edits or reruns.
Fixed source c3c4642d84df57bbd9550d222ed22f602acd13ef; original integration exit1 times out waiting for unrequested Unicode output.
Original frames.json proves complete24×5 then8×3 with 中文 ??; atomic-resize.json readback8 3; session.raw has zero 👩‍💻 and two literal??.
Contract fix-uncertain-glyph-advance/design.md A003: 👩‍💻 scalar sum4≠logical2→??; implement-linux-vt-glyph-fallback/design.md G003 requires conservativeUnicode for unknown PTY Auto.
Fixture tests/integration/fixture/src/main.cj:7–11 uses default Auto; native/cjtui_glyphs.c:23–26 classifies non-concrete Linux VT stdout as unknown (PTY path).
Application.cj:553 detects glyph facts;627–631 selects detected policy for Auto;638 builds frame; terminal_projected_row.cj:14 applies projectTerminalGlyph.
terminal_glyph_detection.cj:28–31 selects conservativeUnicode; terminal_glyph_projection.cj:7–17 emits width2 question marks for that cluster, matching actual wire.
All16 glyph/native/Unicode/render/runtime/fixture/parser files and three App detection/selection/encoding blocks are byte-identical to accepted C7f431765; evidence.json holds exact hashes/text.
Actual original capability snapshot was not logged: unknown/profile values above are deterministic source/PTY derivation, clearly separate from observed wire/grid; no new host/font claim.
Parser tests/support/terminal_frames.mjs:27 explicitly models 👩‍💻 as2 logical columns; pty.mjs:47 keeps original wanted ['cjtui   ','中文 👩‍💻 ','01234567'].
Proposed minimal test-only fix: fixture app.glyphMode(GlyphMode.Unicode), documenting this virtual model's logical Unicode support; preserve exact clip oracle and default Auto regression tests in tests/glyph_advance.
Await root GO before formal fixture edit/commit; unchanged full integration was not rerun and product fallback remains untouched.
