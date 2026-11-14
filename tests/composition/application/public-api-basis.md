# Signature basis at fixed e35d407a

The contract uses these existing APIs. This is a source-reading basis, not a
claim that the absent application compiles. No public signature is proposed.

| Use | Existing source / exact public surface |
| --- | --- |
| ordinary entry | src/application.cj: `Application(root: Component, limits!: RuntimeLimits = RuntimeLimits(), glyphMode!: GlyphMode = GlyphMode.Auto, theme!: Theme = Theme.preset(ThemePreset.Classic), keyboardLimits!: KeyboardLimits = KeyboardLimits())`; `run(): Unit`; `stop(): Unit` |
| smoke | same: `startHeadless(): Unit`, `batch(action: () -> Unit): Unit`, `snapshot(width: Int64, height: Int64, glyphMode!: GlyphMode = GlyphMode.Unicode): Frame`, `dispose(): Unit`; src/frame.cj `toPlainText(): String` |
| callbacks/posting | same: `onKeyEvent(handler: (UIKeyEvent) -> Unit): Application`, `post(action: () -> Unit): Bool`, `post(owner: NodeRef, action: () -> Unit): Bool` |
| overlay | src/node_ref.cj `openOverlay(content: Component, options!: OverlayOptions = OverlayOptions()): OverlayHandle`; src/overlay_options.cj defaults mode NonModal, placement Center, closeOnEscape true, takeFocus true; src/overlay_handle.cj `close(): Unit` |
| reusable component | src/component.cj public open Component; examples/overlay/src/settings_panel.cj uses `finishConstruction()` and override `build(): Unit` with a shared Observable; clone neither component source nor renderer |
| editors | src/text_input.cj `TextInput(value: Observable<String>, controller!: ?TextEditController = None, limits!: TextEditLimits = TextEditLimits(), onChange!: (String) -> Unit = {_ =>}, onSubmit!: (String) -> Unit = {_ =>}, onIssue!: (TextEditIssue) -> Unit = {_ =>}): Component`; TextArea same without onSubmit |
| controls | src/{button,checkbox,radio,progress}.cj use string/getter label, getter model/callback and Float64 fraction/getter; enabled/focusable/theme/style attributes are ordinary Component chains |
| menus | src/{horizontal_menu,popup_menu}.cj `(items: Array<MenuEntry>, onChoose: (String) -> Unit): Component`, getter overload; MenuEntry(key: String, label: String, enabled!: Bool = true) |
| layout | src/component.cj `Column(body: () -> Unit): Component`, Row; src/split_pane.cj `SplitPane(axis!: SplitAxis = SplitAxis.Horizontal, body!: () -> Unit): Component`; src/status_bar.cj `StatusBar(body: () -> Unit): Component`; src/scroll_view.cj `ScrollView(body: () -> Unit): Component` and axes overload |
| style/focus/viewport | src/component.cj width/height/layoutWeight/minWidth/minHeight/foreground/background/border/shadow/viewport/onMount chains; src/node_ref.cj `requestFocus(): Unit`, `scrollBy(dx: Int64, dy: Int64): Bool`; no private coordinates or manual flush |
| theme | src/application.cj `loadTheme(source: ThemeSource): ThemeRequest`; src/theme/theme_source.cj `Preset(ThemePreset)`, `File(String)`, `Prepared(Theme)`; initial Classic, toggle Light through existing request lifecycle |
| keyboard/editor | docs/product/{keyboard-input,text-editing,widgets}.md; normalized f1..f12, ctrl/alt/shift, ordinary editing and bracketed paste already accepted. No global printable shortcut may steal editor keys. |

Independent review checks source accessibility and build through the ordinary
relative dependency, default automatic capabilities, worker/post lifecycle,
view state ownership, same-type reuse and ergonomics. Test output alone cannot
certify these construction obligations.
