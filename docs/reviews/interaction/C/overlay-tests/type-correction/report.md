# TASK108 equivalent optional-constructor type correction
Test-only `2165212a417bd3a5c8900a694a7727440704631c`; prior syntax fd2861747912f9778582ea3968c2be48cca296b5 preserved; frozen semantic oracle b134171cfc9c242844b37eb05853811837179f5c unchanged.
Fixed product WIP `00db2babc840e2a5be00525e0b16f98b944d0f22`; actual SDK1.2 ordinary cjpm build only, never binary execution.
Fresh original normal build exit1 reproduced exactly83 bare None enum-constructor ambiguity diagnostics; supplied original83 diagnostics/prehash were also preserved.
Only83 Box<?T>(None) expressions across15 Cj files became Box<?T>(Option<T>.None); no API/assertion/grid/trace/layout/domain/lifecycle semantics changed.
Every Cj file reverse-normalizes byte for byte to fd286, including all original assertion literals; equivalence.json records per-file hashes.
Current admission JSON only appends a read-only correction note separating frozen semantic oracle, prior syntax, containing corrected commit and historical typecheck context.
Corrected ordinary normal build exit0; no errors, one existing unused std.sync import warning. No other SDK/API/contract conflict appeared.
The actual generated consumer binary is hashed but NOT EXECUTED; all C behavior remains UNEXECUTED and no product PASS/acceptance is claimed.
Product tracked runtime source diff0; corrected source/replay/prehash inputs match after build. Original historical prep/admission evidence was not rewritten.
raw/commands.json records exact two build commands/cwd/UTC/exits; raw/{original-build,corrected-build}.{stdout,stderr,exit} preserves both fresh outcomes.
raw/original/ retains only the explicitly supplied historical pure diagnostics/stdout/exit/inputs.sha256; its results are separate from this fresh reproduction.
raw/manifest.json SHA256 `662c09d3e115222dd5e694c9c5efb82b90c15391d92fcabc43978cf1a2f6d67c` binds test/source/prehash/output/binary hashes and compile-only scope.
No product/spec/main/old oracle changes, author contact, subagents, product run, new review or archive layer.
