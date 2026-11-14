# Independent covered-caret regression preparation

Fixed candidate input `e1244b2144e8df0695aab08db3339acc435d9f9f`; frozen prior
sixteen cases and product bytes remain unchanged. This new isolated workspace
does not touch any sealed earlier test tree/index/raw/runtime. No product source
or author plans/reasoning were read to design this public case.

Append one case and registry entry. The focused Canvas spans three local rows,
placed between one-row anchors in a literal 6×5 scene. Its local caret (1,0) maps
to screen (1,1). A passive 2×1 overlay anchored BelowStart the first row covers
that caret with an opaque identical `b`/Style. A second 2×1 passive overlay,
AboveStart the final anchor, occupies screen row 3 / owner local row 2. Only its
observable X→Y glyph changes. Hand expectation: caret remains canonically hidden,
because the upper opaque source still covers screen (1,1).

Use the existing public same-epoch complete Cell/M1/literal pairing first, then
independently assert public caret visibility/identity. The expected target draw
counts for the changed turn are owner=1, cover=0, lower=1; each callback must keep
its original complete allocation/local clip. M1 callbacks remain separate work
observations and do not supply a caret oracle. Root/anchor placement, owner focus,
actual callback counts and contexts are explicit fixture assumptions that normal
execution must verify honestly before interpreting a caret failure.

SOURCE PREP ONLY until root capacity GO. More independently reported findings may
be batched before the final normal build/direct run. No product changes, private
hooks, source reflection, other suites, copied/unpacked ELF, TTY or subagents.
After GO retain actual SDK/config/source/raw/exit/ELF evidence and freeze only a
test commit/index; no unobserved correctness failure is claimed during preparation.

## Actual normal baseline after root GO

Root authorized this one consumer build with 157679616 bytes of verified free
space (explicit 150 MiB budget exception). SDK/CJPM 1.2.0 ordinary build succeeded;
direct in-place execution completed all seventeen cases. Prior sixteen cases
retain zero correctness/work failures. New case has one correctness failure and
zero work failures; process exits 1. No compiler, fixture or oracle correction was
needed. Complete Cells/M1/literals, owner focus, original contexts and the expected
owner=1/cover=0/lower=1 changed-turn callback counts all passed. After lower X→Y,
the public caret wrongly becomes visible at screen (1,1), with owner present,
despite the unchanged opaque cover at that cell. Full M1 preserved that published
Application caret rather than being used as a second caret oracle. Raw output,
config/source/ELF hashes and this actual failing baseline are sealed in the new
workspace index. The result confirms a public correctness counterexample; it
does not prescribe a product fix or claim unit acceptance.
