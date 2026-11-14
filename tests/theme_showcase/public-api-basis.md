# TASK027.a public consumer basis (source 39d56c0)

This freezes a gallery fixture for the existing SDK, not a new framework API.
The complete scene is mounted once. Only `ThemeSource` changes during F1–F4,
F6 and F7. The application owns the file selection and calls the loader from an
event. No watcher, renderer coordinate access, or manual flush is involved.

| Use | Existing public signature |
| --- | --- |
| entry | `Application(root: Component, theme!: Theme = Theme.preset(ThemePreset.Classic))`, `run()`, `stop()`, `startHeadless()`, `batch`, `snapshot(width,height): Frame`, `dispose()` in `src/application.cj` |
| theme | `loadTheme(ThemeSource.Preset(ThemePreset.Dark))`, `loadTheme(ThemeSource.File(path))`, `reloadTheme()`, `themeInfo(): ThemeInfo` in `src/application.cj`; `ThemeRequest.result(): ?ThemeResult` in `src/theme_request.cj` |
| retained state | `NodeRef.sameNode`, `isValid`, `isFocused`, `viewportSnapshot`, `scrollBy`, `requestFocus` in `src/node_ref.cj`; `TextEditController.snapshot`, `select`, `undo` in `src/text_edit_controller.cj` |
| mounted scene | `Column`, `Row`, `Text(String/RichText)`, `Label`, `TextInput`, `TextArea`, `HorizontalMenu`, `PopupMenu`, `Button`, `Checkbox`, `Radio`, `Progress`, `StatusBar`, `SplitPane`, `ScrollView` in `src/` |
| content and style | `RichText([TextSpan(..., style: TextStylePatch(...))])`, `styles([StyleUse.Named(...)])`, `visualStates(VisualStates(...))`, `enabled(false)`, `themeRole(ThemeRole.Modal)`, `onMount`, `onKey` |
| popup/modal | `NodeRef.openOverlay(content, options: OverlayOptions(mode: OverlayMode.Modal))`, `OverlayHandle.close()` |

`main [--theme-file PATH]` starts at Classic; F6 loads the configured file and
F7 calls `app.reloadTheme()` against the current accepted theme's File source.
If a later preset was accepted, F7 yields `Failed(NoFileSource)`.
`main --smoke` emits finite startup
snapshots for the four presets at 80×24, 40×12 and 16×6. Missing path,
incompatible forms and unknown switches diagnose with a direct nonzero exit.
Without a configured path F6 gives a nonfatal visible diagnostic. The smoke
mode does not claim live transitions, which the PTY suite covers.

## Fixed scene and input order

At 80×24, row 0 is the horizontal menu with labels `Classic Dark Light
Contrast File Reload Preview Disabled Quit`; its `Disabled` entry is disabled.
Row 23 is StatusBar. Rows 1–22 are a two pane SplitPane, 40 columns each.
Left rows 1–9 are Gallery title, `Label é 中 👩‍💻`, Find label, TextInput,
Pin Checkbox, ID and Name Radio, Run Button, 20-column Progress. Left rows
10–22 are a vertical ScrollView of 24 `NNN INFO record NN` rows. Right rows
1–9 are Notes title, rich `Ready • accent`, Edit label, two-row TextArea,
Actions Button, disabled Button, Selected label and Pending label. Initial
input is `Query`, notes are `Check input`, Pin=false, ID=true, progress=0/2,
pending=false (`Idle`), record order ascending. No node is replaced to change a theme.

At 40×12 the SplitPane columns are 20/20 and the ScrollView exposes one record.
At 16×6 the actual viewport has 8/8 columns, body rows 1–4, and a StatusBar
at row 5. It clips naturally; nothing auto-hides or imposes a virtual minimum.
The fixture JSON contains complete manually specified rows for every preset,
size and the 80×24 pending state. It is not recorded application output.

The TextInput receives initial focus after mount. Tab order follows mounted
widgets: TextInput, Pin, ID, Name, Run, ScrollView, TextArea, Actions; disabled
controls and menu entry cannot receive focus. F1/F2/F3/F4 request Classic,
Dark, Light, HighContrast; F5 opens the modal, F6 loads the selected file, F7
reloads, F8 scrolls the mounted log `NodeRef` by 12 rows (clamped to offset 11),
F9 closes the modal, F10 exits. F-keys are global; printable keys remain editor
data. Modal is 32×9 centered at x24,y7. Classic and High contrast use an
ASCII border without shadow; Dark and Light use a rounded border and a one-cell
shadow. Every preset adds one cell of left and right padding inside the border,
leaving 28 content columns. The preset controls border, padding and shadow;
its lines are `Preview`, `Theme sample`, `é 中 👩‍💻`, `Select action`, two blanks,
`Actions`. It offers a PopupMenu with Inspect, disabled Delete, Confirm.
F2 must accept Dark while Preview remains open, and also while its owned
PopupMenu remains open; popup navigation still skips disabled Delete afterward.
Failed file load/reload shows `Load failed` at right y9 without altering
accepted theme or business state; F6 without a configured file shows `No theme
file`. The next success restores the business `Idle`/`Pending` label.

For live acceptance, completion means a visible complete palette and the
accepted name, never the requested business label alone. Public `themeInfo`
and saved `ThemeRequest.result` are tracked reads in view getters: the footer
reads accepted `ThemeInfo.name`, while `Load failed` follows the terminal
`ThemeResult.Failed` case. The example must not manufacture a requested name
as acceptance or poll from another thread. Selection uses grapheme gaps; undo
and viewport offsets
are retained. The initial and post-action grid oracles include every visible
row and compare the full text, with separate cell style expectations.
Smoke stdout has `BEGIN <name> <width>x<height>`, the literal rows, `END <name>`
for each size and preset, then `INFO <name> revision=0 request=0` for that
preset, and a final `PASS theme showcase`.
