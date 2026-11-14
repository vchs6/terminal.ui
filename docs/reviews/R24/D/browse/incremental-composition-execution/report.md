# TASK141 independent execution — 2026-11-14

Fixed input: D139 `f48ca45608247f52a6876ad5c27b4ca36867f406`; TASK140 R1 PASS index `d36cec40…`; host cases SHA `a15a14fe…`. Own source remains clean at f48.
Admission: root capacity GO at 157.03 MiB; warm continuation and bounded ended-compiler reclaim receipts are pinned in [index.json](index.json). No SDK/cache copies or product/test edits.
SDK Cangjie 1.2.0 with pinned stdx/UCD and isolated official CJPM cache/registry; ordinary `run.sh build` for public composition and native recovery, ordinary `cjpm build` for theme showcase.
Public composition: direct executable SHA `1ec08019…`, `run.sh run` exit 0; 17 cases, zero correctness failures, zero work failures, including root visibility and covered caret across damage rows.
Recovery executable SHA `bb2600f8…`: `run.sh run --normal` 5/0, `--supplement` 45/0, full `run` 338/0 against real util-linux PTYs/native fault writer; raw per-case bytes and summaries retained.
The first normal invocation failed before test execution because sparse checkout lacked tracked `tests/colors/pty.mjs`; expanded that fixed path, reran 5/0, retained the failed log.
Normal package CJP SHA `1110d0ff…`: independently compared 205 archived `src/native/build.cj/cjpm.toml/theme_showcase` files byte-for-byte with fixed f48 source, zero mismatches. Reused pinned same-source bundle default checks (0 failed, lint completed), unpacked consumer 17/0, Frame baseline/cow 7/0 each under AGENTS 11.1; no duplicate build.
Real XTerm 398 and xfce4-terminal 1.1.4/VTE 0.80.1: final `hosts/xterm-r3` and `hosts/vte-r3` each recorded ten original 80×24→100×30→80×24 PNG checkpoints, raw output intervals and input, exact keys, host versions/config, dimensions, and F10 exit.
Both final host processes, inner scripts and outer scripts exited 0; inner/outer termios restored. Input raw records one DECRQM visible reply and fixed End/Z/F5/F9/Q/six Tabs/End/N/Enter/M/F5/resize/F9/P/resize/F10 sequence.
Observed QueryZ then QueryZQ, Notes `Check inputN`/`M` then `MP`, centered preview at both sizes, and no stale preview after close; sampled caret gaps and modal focus match fixed host cases. Original PNG/raw hashes, host configuration, timing and exit records are in the index.
VTE first attempt is retained as failure: default F10 was intercepted by the host menu and no normal exit occurred. Installed binary identifies `ShortcutsNoMenukey`; final VTE run used isolated `ShortcutsNoMenukey=TRUE` and the same F10 key, which reached the app and exited 0.
XTerm first capture ended with a metadata script error after normal application exit, and an intermediate capture raced the host; both attempts remain retained. Final r3 runs use input/output recording and event-based capture stabilization.
PNG cannot prove private caret owner, opacity, row sharing or baseline commit. CPU/heap cost, complete six-host C008 matrix, full M2 and Linux acceptance remain later obligations.
