# Unit E: public rendering benchmark proof

Independent E147 accepted original AC-022/031 for fixed Linux M2 source `d7e9d1445f98021a798d223de97b97b45239de93`; specification and quality/evidence PASS, zero blockers. Version remains 0.0.0; this archive performs no new execution.

[Acceptance report](browse/rendering-benchmark-acceptance/report.md) · [Detailed findings](browse/rendering-benchmark-acceptance/findings.md) · [Execution report](browse/rendering-benchmark-execution/finalreport.md) · [Archive index](archive-index.json) · [Original manifest](original-manifest.json.gz) · [Lossless raw evidence](raw-evidence.tar.gz).

Original headless 1150 repetitions and 216 correctness joins retain their historical f48/c862 ELF labels. Final M2 TTY CPU176 and native144 have fresh affected evidence; unchanged M1 reuse keeps its independent admission and exact scope. All failures, global/negative cases, noise and adverse metric distributions remain available.

No blanket speedup: final TTY CPU has21/144 higher medians and system CPU rises57/144. Native VTE resize80 bytes10355→13777/calls8→9; resize160 bytes26559→15460/calls7→6. Headless initial80=1.028×, theme_color80=1.033×, theme_four_sides160=1.004×; eligible ellipsis=1.129/1.111×. Whole-process CPU includes startup/warmup/sampling/disposal; heap occupancy/GC/RSS do not establish total allocated bytes.

The [original final M2 gallery](gallery.md) covers both genuine hosts and sizes. [Full capture metadata](capture-metadata.json) binds run/PID/source/ELF/time/hash; all640 accepted+212 historical PNGs remain in the archive. Screenshots alone do not prove correctness or presentation timing.

[xterm 80×24 initial](captures/xterm/80x24/initial.png) [xterm 80×24 unicode_cells](captures/xterm/80x24/unicode_cells.png) [xterm 80×24 overlay_nested_close](captures/xterm/80x24/overlay_nested_close.png) [xterm 160×48 glyph_projection](captures/xterm/160x48/glyph_projection.png) [xterm 160×48 scroll_multistep](captures/xterm/160x48/scroll_multistep.png) [xterm 160×48 root_fallback](captures/xterm/160x48/root_fallback.png) [vte 80×24 initial](captures/vte/80x24/initial.png) [vte 80×24 unicode_cells](captures/vte/80x24/unicode_cells.png) [vte 80×24 overlay_nested_close](captures/vte/80x24/overlay_nested_close.png) [vte 160×48 glyph_projection](captures/vte/160x48/glyph_projection.png) [vte 160×48 scroll_multistep](captures/vte/160x48/scroll_multistep.png) [vte 160×48 root_fallback](captures/vte/160x48/root_fallback.png)

Logical originals compressed earlier remain present through the exact gzip/headless custody maps; archived proofs are not missing. Historical source snapshots and distinct CJP versions preserve bytes and Git identities. Prior M1/D packages use existing repository publications; runtime/SDK/cache/ELF payloads and the quarantined expanded-environment startup127 trace are excluded.

Pending: final001/002/003/004/041, six-host C008, release023 including known T087-G01, and whole024. E147 acceptance and publication do not certify these scopes.
