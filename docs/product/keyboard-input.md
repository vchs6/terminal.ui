# Linux keyboard input

`Application.onKeyEvent` receives a `UIKeyEvent` with a normalized `key`. Its
`code`, `text`, `ctrl`, `alt` and `shift` fields describe the input. The older
`Application.onKey` and `KeyEvent(code, text: ...)` forms remain available.
Ordinary text does not report the physical Shift state. Tab and backtab move
focus unless their default action is prevented; interrupt can likewise be
prevented. External termination signals end the session rather than producing
an interceptable key.

The Linux adapter recognizes ASCII and UTF-8 text, control letters, arrows,
Home, End, Insert, Delete, Page Up and Page Down, F1–F12, Alt text, and the
supported CSI modifier forms. Terminal protocols cannot distinguish every
physical key: key release, repeat, scan codes, Kitty/CSI-u, Ctrl+Enter and
Ctrl+Backspace are not supported. Unsupported or malformed sequences are
reported through `onKeyboardIssue` without exposing their control payload.

Bracketed paste is delivered as one `paste` event to the target captured at
its start. A target that becomes unavailable causes a diagnostic instead of
retargeting the paste. The default maximum payload is 1 MiB; oversized pastes
are discarded through their closing marker. There is no paste timeout. An
actual EOF reports incomplete input while the session is active and then ends
it. The terminal's bracketed-paste mode and its original terminal settings are
restored on ordinary session exit; if output has become unsafe after a partial
write, the framework stops output and cannot promise display-mode recovery.
Unmarked terminal input is ordinary keys, not an atomic paste.

Advanced adapters can use `KeyboardDecoder` with `feed`, `timeout`, and
`finish` to normalize byte streams without a device. `KeyboardLimits` sets
bounded paste and sequence sizes; diagnostics carry a kind and raw byte
offset. After `finish` the decoder is closed. The adapter calls `timeout` only
after a real input-idle interval; it does not sleep itself. See
`examples/keyboard` for a public application using keyboard events.
