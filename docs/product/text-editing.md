# Text editing

This release targets Linux ANSI terminals. Clipboard availability depends on the terminal and configured session capabilities.

`TextInput` edits one line and calls `onSubmit` on Enter. `TextArea` edits multiple logical lines; Enter inserts a line break. Both take an `Observable<String>` and an optional `TextEditController`. Controllers expose selection, snapshots, replacement, undo, redo, copy and cut. Selection positions count grapheme-cluster gaps, not bytes. They are local to each mounted view even when views share an observable. Controllers become stale on unmount and can be reused on a later mount. Read snapshots on the UI owner thread; perform mutations in an event handler, posted action, or application batch.

Arrow keys, Home, End, Shift selection, Ctrl-A, Ctrl-Z and Ctrl-Y provide basic editing. TextArea also handles Up, Down and Page keys. Tab changes focus and Escape is left to the application. Pasted CRLF and CR are normalized to LF; a multiline paste into TextInput is rejected as a whole. Other control characters and edits beyond the configured UTF-8 byte limit are rejected without changing the value. `onIssue` reports rejected terminal input.

| Clipboard result | Copy | Cut |
| --- | --- | --- |
| Applied | Completed | Deletes only if the captured source, selection and session still match |
| SentUnconfirmed | Sent without confirmation | Keeps text and reports `CutUnconfirmed` |
| Unsupported, Unknown or Failed | Reports `ClipboardUnavailable` | Keeps text and reports `ClipboardUnavailable` |

The terminal may intercept paste and send a paste event. Ctrl-V or Shift-Insert reaching the editor reports `PasteFromTerminalRequired`; the framework does not query the system clipboard. No current adapter confirms an Applied local-copy result.

Background `Observable.set` and `notify` remain allowed. An editor commits against the source version it read; if a background update wins the race, the edit is rejected with `ConcurrentValueChanged` rather than overwriting it. An external update clears that view's undo and redo history. For delayed work, capture `controller.snapshot()` and pass it as `ifUnchanged` to `replaceSelection`; a stale snapshot returns false without changing the selection or value.
