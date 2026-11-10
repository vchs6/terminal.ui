# TASK-067 independent preparation

Input repository 31a7017; no product changes, no author implementation/report read.
Contract pending coordinator ready SHA. No final assertions frozen yet.

Execution classification: tests-only execution against exact public contract. Existing runner/assertions preserved. Private copied dependency cache is read-only; ignored registry configs point to independent relay 127.0.0.1:18973. SDK 1.2.0, original UCD17 archive. TDD and verification-before-completion skills read and applied: normal old-product build precedes genuine missing-API compilation RED. Compile errors must be feature-missing, not source typos; raw stdout/stderr/actual status and source/test hashes retained. No GREEN/acceptance claimed by test author.

Hand-derived planned grids:
- transparent top 4x2 with X at (1,0), styled opaque blank (2,1) over abcd/efgh -> aXcd/ef h; later Y at (1,0) -> aYcd/ef h; transparent-only source cell leaves old wide cluster intact.
- source a中bc (5 columns), copy Rect(2,0,3,1) -> ' bc' (clipped continuation becomes styled space); Rect(0,0,2,1) -> 'a ' (clipped leader).
- source a中b over target uvwxy at x=-2 -> ' bcxy' (clipped continuation at col0; b,c at col1,2).
- target a中bc, source X at destination continuation x=2 -> 'a Xbc'; source X at leader x=1 -> 'aX bc'. Partner cell cleanup follows target default transparency.
- source abcde self composite x=1 -> aabcd; x=-1 -> bcdee; y=1 on ab/cd/ef -> ab/ab/cd.
- source a中bc resize width2 -> 'a '; resize width7 -> 'a中bc  '; original remains exact.
- copy Rect(-1,-1,4,3) from 2x1 AB -> four blanks / ' AB ' / four blanks. Default source transparency inherited outside; snapshots flatten transparency.
- clear touching either wide half clears entire cluster to explicit chosen blank kind and Style(), even partner outside rectangle; clear transparent does not change frame default for later put cleanup.
- extreme offsets Min/Max in x/y leave bounded target unchanged; extreme clear clips before iteration; invalid allocation/copy/resize tested using small explicit maxCells and overflowing Max-by-2 without real huge allocation.
- ambiguous wide source . policy preserved in copy/resize; mismatch throws before any target mutation (including zero-sized sources if contract confirms).
- independent file bytes computed from literals using external Node Buffer UTF8: composed 4x2 UTF8 (CJK, e+combining), styled plain and ANSI at explicit capabilities. No BOM/trailing LF. Destination prefilled to prove overwrite/truncation. Missing parent and existing-directory paths must throw standard file exception.

Observed pending conflict: old decoration has Frame(0,Int64.Max)/Frame(Int64.Max,0), contract initially constrained each axis by maxCells. Reported to coordinator before freezing tests. Old tests not modified.

Additional test-utility decisions (still pending contract freeze):
- Scan each small final grid for complete leaders/continuations and normalized transparent blanks; never implement compositing/width calculations in the consumer.
- Check public Cell style, width, continuation and isTransparent separately from literal text snapshots, because identical plain text can conceal wrong opacity/style.
- File-error clauses catch SDK-tested std.fs.FSException rather than arbitrary Exception; throwaway syntax/runtime test is separate from product RED.
- File verifier compares bytes using independently authored literal UTF8 strings/SGR escapes, not frame.toPlainText()/toAnsi() as its sole oracle. Test-local Node checks BOM, exact no-extra-LF, explicit monochrome/Basic8/TrueColor exports and zero-area files. Existing Node test dependency reused.
- Runner builds normally then directly executes binary under 30s; any compiler/link/status/timeout fails. Per-run mktemp artifacts prevent stale-file success, preseed long files to verify truncation.
