# Building a composed application

The runnable `examples/minimal` and `examples/composition` projects consume cjtui through an ordinary relative CJPM dependency. Their READMEs give build and launch commands, keyboard bindings and the scope of their finite `--smoke` checks. The composition example brings together a task board and a log viewer, a shared job panel, editing, overlays, and a background calculation.

Describe each view with component blocks and attribute chains. Keep business data in observables and bind component getters to those values; event callbacks update the business model. The two scenes decide their own filtering and ordering. A custom `Component` can receive the same model in multiple fresh instances while each instance owns its own editor controller. The example uses this for the ordinary and modal job panel.

Use `NodeRef.openOverlay` with `OverlayOptions(mode: OverlayMode.Modal)` to create a centered modal. A child overlay opened from a control in that modal belongs to the same overlay tree, and closing the parent closes its descendants. Focus is requested through mounted references. Theme changes use `Application.loadTheme`, preserving the mounted component tree. A Cangjie worker computes bounded results away from the UI thread, then submits the model update through `Application.post`; UI code does not manually flush the terminal.

See [keyboard input](keyboard-input.md), [text editing](text-editing.md), [widgets](widgets.md), [interaction](interaction.md), and [themes](theme.md) for the individual public contracts and limitations.
