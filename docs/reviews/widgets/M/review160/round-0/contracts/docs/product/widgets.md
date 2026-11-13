# Small widgets

`Label`, `Button`, `Checkbox`, `Radio`, and `Progress` compose with ordinary component blocks and attribute chains. See `examples/widgets_small` for a complete application; press Tab to move focus, Enter or Space to activate, and q to exit.

Captions are single logical lines of plain Unicode text. Text wrapping and clipping follow the normal Text rules. Checkbox and Radio receive getters and issue change requests; the application owns the values and any radio-group exclusivity. A rejected request leaves the display unchanged. Progress accepts a finite fraction from 0 through 1 and has a natural content size of 20 by 1; dimensions can be set by theme or component attributes.

Controls use the normal theme resolver and public `enabled` and `focusable` attributes. `visualStates` replaces the control's declared visual-state slot, so a later call can override Checkbox or Radio's selected appearance without changing its behavior. Similarly, a later Target `defaultAction` replaces the built-in activation action. Use `onKey` or `onKeyCapture` to observe or prevent an activation. Explicit style attributes override theme values. Simulated visual states do not change focus or enabled behavior.

StatusBar is outside this small-widget delivery. Its specified composition is a natural-height Row, placed by the application's layout rather than automatically fixed to the bottom.

Unsupported attributes keep the underlying primitive's error contract. On Text-root controls, the existing constant `gap`, `alignItems`, and `justifyContent` shortcuts throw `IllegalArgumentException` and leave the previous setting intact; the existing container `textAlign` and invalid Stretch boundaries also retain their original behavior. Unsupported typed `setStyle`, getter attributes, and resolved named or Inline styles throw `UIException` with code `InvalidProperty`; so does `wrap` on Progress. Unsupported fields in theme configuration report `UnsupportedProperty`, while invalid programmatic style values retain their `IllegalArgumentException` boundary. Invalid Progress fractions report `InvalidProperty`.

To supply an initial custom theme, pass it to `Application(root, theme: theme)` before starting the application. Use `loadTheme` for changes after a session is active; a pre-start load returns `SessionClosed`.
