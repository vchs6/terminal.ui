# Tasks and logs composition

With Cangjie SDK 1.2.0 and the cjtui dependencies available, run `cjpm build` in this directory, then `target/release/bin/main` in a terminal. The interface is comfortable at 40×12 or larger, but uses the actual terminal size below that as well. Color and glyph capabilities use the framework's automatic policy.

F1 and F2 select Tasks and Logs; F3 changes theme; F4 opens the shared job panel; F5 starts work and F6 continues after review. F9 closes the details tree and F10 exits. Tab and Shift-Tab move focus; controls and editors use the standard keyboard bindings. The Actions button opens a menu with a nested confirmation. The task and log filters and ordering belong to their respective business views.

`target/release/bin/main --smoke` starts headlessly and prints plain startup snapshots and state checks. It does not exercise live keyboard input or background work. Unrecognized arguments return a nonzero exit.
