TASK021 supplemental TESTONLY PTY fixture review — 2026-11-14
BASE 2e5e998d00f2f60e45376bca4ada8376273d339a → HEAD 6dbece66e2989849d87729a5da10d95b4fbb0a24.
SPEC: passed for this bounded fixture correction; full ordinary application/actual-host AC021 evidence remains insufficient/pending.
QUALITY: passed for the five-file test delta (80 additions/12 deletions); no confirmed findings, findings.json is [].
Reviewed the fixed diff package, complete affected parser/selftests, unchanged Screen oracle and encoder/glyph policy source. No builds, reruns, application launches, source edits, subagents or standalone author report.
Frame.toAnsiForTerminal resets the frame, while encodeTerminalRow omits an end reset when the row finishes default; accepting the next CUP/native-control boundary corrects an invalid fixture assumption.
WireScreen probes exact row width through existing Screen.flush, then feeds/flushes the unchanged actual row bytes. It neither pads/truncates text nor injects a style reset; actual inherited SGR remains observable.
Short/long rows fail at a following boundary; incomplete records block Session.wait. Added finish checks reject truncated row/control/UTF-8 and invoke existing final style/resize validation.
Existing Screen retains glyph segmentation, supported-SGR checking, in-bounds row checking and complete sequential resize-target validation; its source is unchanged.
New literal controls cover byte chunking, non-reset row boundaries, colored prefix/default tail, inherited color, dirty rows, unsupported SGR, truncation and 4×2→2×3 resize. Stored infrastructure RED/after records were inspected and hashes verified, not rerun.
Unknown PTY Auto selects conservativeUnicode: CJK retains its two-column scalars; 👩‍💻 logical2 versus scalar2+0+2 projects to two ASCII question marks. The separate 16×3 golden follows this existing policy, with exactly nine trailing spaces.
The headless Unicode golden and actual Unicode paste bytes are unchanged. Only the two device-visible glyph expectations changed; selection/undo, focus, menus, modal isolation/ancestry, workers, progress/color, scroll, resize, exits and termios assertions remain present.
No examples/src/native or existing Screen/support changes occur in this diff. Original fixed-product source review is reused unchanged at index SHA0aa511da9cf52025f0467aac29f2fea5e3171156ea82f1ba7c0e8fa2a0fd388c.
Factual index SHA805afd1936fe84bc413b4e094b5e94a13faf7fc66751c34888f73ef5ee0877ee and its 38 file bindings/10 Git source proofs were verified; raw replay is fixture evidence, never ordinary application acceptance.
Independent ordinary PTY execution and actual-host raw/PNG/profile/restoration proof still require their separate gates. Historical nonadopted metadata limitation remains as recorded in the immutable original review.
