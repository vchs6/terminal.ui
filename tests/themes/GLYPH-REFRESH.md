# TASK085 append: actual Glyph policy / ellipsis consumers

Execution-class work from the frozen T001–T016, G001–G012 and A001–A008
contracts. Fixed base: `b3b24f896672336797cec009cfe0cd830a955aa7`.
This file supplements README.md; every original TASK085 source, 16 negative
fixtures, budgets, cascades and four preset fixture bytes remains unchanged.
No task status or product source is changed. Theme013/025 admission still waits
for accepted097 and the final independent085 evidence.

## Run

Use SDK1.2.0 and the normal product native/UCD/registry configuration. Each
consumer needs its own ignored `cangjie-repo.toml` (the runner never selects an
author target/cache). Supply an existing registry relay; do not launch another.

```sh
source /workspace/work/theme-glyph-tests/env.sh
node tests/themes/run-glyph-refresh.mjs control /tmp/theme-glyph-control
node tests/themes/run-glyph-refresh.mjs target /tmp/theme-glyph-target
node tests/themes/run-glyph-refresh.mjs offline /tmp/theme-glyph-offline
node tests/themes/run-glyph-refresh.mjs session /tmp/theme-glyph-session
# Both future groups, after real Theme exists:
node tests/themes/run-glyph-refresh.mjs all /tmp/theme-glyph-all
# Existing typed/schema/preset/negative suite, unchanged:
./tests/themes/run.sh all --logs /tmp/theme-foundation
```

All refresh modes first build the actual root and existing public Glyph API,
execute that API binary, compile/execute the current-only language consumer,
and run three actual current-API PTY controls. A failure stops the runner with
the process exit. It records argv/cwd/UTC/SHA/stdout/stderr/exit and refresh
source hashes. New run/PTY scripts select only this refresh; they never add
other task suites to their scope. Existing run.py remains the authority for
the original positive-gated 16 compile-negative cases. These negatives are
**unexecuted**, not passing, until both original real Theme positives pass.

## File map and oracle

| File | Contract / regression caught |
|---|---|
| glyph-language/src/main.cj | Actual current Glyph signatures; Observable.get/set; legal let Array reference captured by onKey; map/diagnostic input control contains no future Theme names |
| glyph-target/src/main.cj | Isolated real Theme package/constructor admission, free of future layout symbols; missing Theme is distinct from missing Glyph |
| glyph-refresh/src/marker_widths.cj | T005/G006 widths0/1/2/3/4, no-wrap, Unicode/default/offline Auto vs ASCII prefix budgeting; exact fit/Clip; CRLF/wrap/vertical hiding; Unicode body/CJK/combining integrity |
| glyph-refresh/src/layout_context.cj | Actual Row allocation and asymmetric padding before budget; hard-line heights/sibling; zero width/hidden; cross-span whole grapheme and first-scalar style; component explicit style mask |
| glyph-refresh/src/cache_context.cj | Same mounted root alternating snapshot profiles, content-equivalent Auto/Unicode cache, Ascii invalidation, render defaults, device config independence, original business source, logical plain/ANSI export |
| glyph-session/src/main.cj + glyph-pty.mjs | Normal public Application.run, actual device context, width0–4, Row allocation, unknown AutoConservative, explicit Unicode/Ascii, mapped marker present/missing, setter wake/cache/no remount, post-run offline context |
| glyph-session/native/theme_glyph_wrap.c | Include existing tests/glyphs/session/native/glyph_syscall_wrap.c; only filter returned U+2026 mapping to A, preserve ASCII/dots/?/é. No second fontmap engine or product hook |

Goldens are explicitly typed from the contract, never read from the marker
helper, parser, renderer, or captured product output. For ABCDE width4 they are
`ABC…` / `A...`. The native missing-marker fixture retains ASCII/dots/? and é:
this makes `A...` distinguish correct three-column reservation from wrong
`ABC?`. Its current-API input controls first prove literal `é …` becomes
`é ?` under that fixture, versus `é …` with the original mapped fixture.
The adapter preserves 104 pairs, normal source/reason, one actual map query and
one filtered ellipsis; these facts and actual write bytes are checked.

The PTY tests use a real PTY with **synthetic** stdout VT metadata/map via the
existing linker syscall fixture. They are controlled branch tests, never
actual-kernel VT or physical-font evidence. They must not substitute for
096/097, GUI width evidence, or complete AC041. Unknown Auto uses the frozen
G012/A003 conservative rule (raw ZWJ width2 becomes exactly `??`), while default
and Auto offline frames retain the original ZWJ body.

## Evidence limits

Against the fixed base the real Theme/TextOverflow/TextWrap APIs are absent.
The appended future consumers therefore cannot execute. Current Glyph/API,
language facts and native-input controls can pass independently; they do not
prove actual ellipsis layout. Missing-target compiler RED is recorded separately
from unexecuted assertions. No fake Theme/policy/renderer, declaration scratch
execution, expected-output generator or test-only public override is used.
The runtime has no new public ambiguousWide mode; the existing package-local
G006 tests retain that branch. This refresh does not invent one.
