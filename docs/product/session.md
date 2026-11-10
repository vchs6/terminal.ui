# Optional session operations

Import the public types from `cjtui`. Call `app.copyLocalText(text)`,
`app.setHostTitle(title)`, `app.restoreHostTitle()`, or
`app.setHostImageIcon(pngBytes)` from a UI event, an `app.post` closure,
an outer owner UI operation, or `app.batch`. Background callers must use
`app.post`; its Boolean result reports queuing only. Mount, cleanup, binding
getters, build evaluation, other sessions and direct background calls return
`Failed/InvalidContext`. An inactive session returns `Failed/SessionInactive`.

The [session example](../../examples/session/src/main.cj) uses the normal public
Application entry. Build with SDK 1.2.0 using `cd examples/session && cjpm build`;
run `target/release/bin/main` in a Linux ANSI TTY. Press c to copy, t to set the
title, r to request restoration, and q to quit.

`SessionResult` records the operation, session ID, capability, status, issue,
source error byte offset, restoration state, actual wire byte count and up to
two step results. A complete OSC write returns **SentUnconfirmed**: the host
may ignore or deny it. This version has no confirming adapter and never returns
Applied or RestoreConfirmed. A cut consumer must retain the source text and
selection on SentUnconfirmed. Future confirmed cut also needs matching editor,
revision, selection identity and session before deleting anything.

`app.sessionCapabilities()` is None before the first session, then an immutable
per-session snapshot retained after close. It can be read from another thread.
Clipboard, title, title stack and image icon are independent. Real TTY Auto
policies are Unknown/NoEvidence; explicit copy and title requests can still send
their fixed candidate. No request means no optional control sequence. Headless
operations are Unsupported/NoDevice; image icon is always
Unsupported/NoImageAdapter. The library does not decode PNG or substitute an
icon name for an actual image icon.

Configure inactive applications with `app.sessionOptions(SessionOptions(...))`.
The named options are `clipboard`, `title`, `titleStack` (Auto, Disabled, or
DeclaredSupported) and `route` (Direct, TmuxPassthrough, or ScreenPassthrough).
Direct and Auto are defaults. Active configuration throws
`UIException("LifecycleReentry", ...)`. DeclaredSupported reports
Supported/ExplicitConfiguration; it remains an application declaration and
cannot confirm host permissions or an operation's effect. TERM, COLORTERM,
TMUX and STY names never prove permission. The library runs no shell or host
configuration commands and makes no clipboard/title queries.

Advanced mux routes wrap exactly one fixed generated sequence in one DCS layer;
they are never inferred automatically. Permissions, passthrough configuration
and the target of title restoration remain properties of the complete route.
SSH uses the existing bound TTY; an OSC52 request targets the terminal user's
local CLIPBOARD, and does not run a clipboard utility on the remote host.

Copy accepts valid UTF-8 up to 65,536 bytes, including control scalars encoded
strictly as RFC4648 Base64 data. Empty text explicitly clears CLIPBOARD.
Title accepts at most 1,024 UTF-8 bytes and rejects C0, DEL and C1 scalars.
Image input is bounded at 1,048,576 bytes. Each complete wrapped sequence is
bounded at 90,000 bytes. These are framework resource budgets, not guarantees
that every terminal accepts that size. Invalid UTF-8 is rejected first, then
length, then title controls, before capability checks or any output.
`errorByteOffset` is zero based in source UTF-8; length failures use the first
disallowed byte position, and -1 means not applicable. No payload is included
in diagnostics. Inputs are never truncated, normalized or split into separate
clipboard writes.

The default unknown title stack sends no push/pop and reports restoration
Unavailable after a title change. Only explicit stack support allows one
window-title scope: push before the first valid set, reuse across sets, then
pop once on explicit restore or close. Complete push/pop are still unconfirmed.
Repeated restore after a complete pop returns Unknown/NoSavedTitle with
NotNeeded and emits nothing; a later set can create a new scope. Close does not
repeat an explicit completed pop. Unknown original titles are never replaced
with a guessed title. Read `app.sessionCleanupResults()` after close for a
defensive copy of the last session's bounded title cleanup record.

A native write failure stops the session even if the caller ignores Failed.
The synchronous result preserves exact emitted bytes and step WriteFailed;
partial output reports ParserUnsynchronized. All subsequent ordinary requests
are cancelled and pending posts are dropped. A complete save followed by a
zero-byte set failure retains its scope for a safe cleanup pop. Partial output
forbids every further device write, including pop, reset, BEL, CAN or ST.
UI cleanup, termios, signal handlers and buffer release still run; primary and
independent cleanup errors remain observable through UICleanupException.

The native output-unsafe latch covers screen and extension writes and lasts
until process exit. Close never clears it, and another Application cannot
reopen the device in that process. Zero-byte failures permit reopening after
close. Resource restoration does not prove visual state or parser recovery;
restore the terminal or connection before restarting after partial output.
Actual terminal/mux/SSH support is configuration specific and requires separate
host evidence. This API does not implement editor cut/paste or other OS backends.
