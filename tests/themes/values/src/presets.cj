package theme_values_contract
import cjtui.style.*
import cjtui.theme.*
func presetCase(preset: ThemePreset, slug: String, label: String, fg: Color, bg: Color, accent: Color, modalBorder: BorderStyle, shadow: Bool): Unit {
    let built = Theme.preset(preset)
    let file = Theme.readFile("../fixtures/" + slug + ".toml")
    let expectedText = StyleRule()
        .withValue(StyleKeys.foreground, StyleValue<Color>.Value(fg))
        .withValue(StyleKeys.background, StyleValue<Color>.Value(bg))
        .withValue(StyleKeys.textWrap, StyleValue<TextWrap>.Value(TextWrap.None))
        .withValue(StyleKeys.textOverflow, StyleValue<TextOverflow>.Value(TextOverflow.Clip))
    let expectedDecoration = StyleRule()
        .withValue(StyleKeys.border, StyleValue<BorderStyle>.Value(BorderStyle.None))
        .withValue(StyleKeys.shadowEnabled, StyleValue<Bool>.Value(false))
    let expectedSpacing = StyleRule()
        .withValue(StyleKeys.paddingLeft, StyleValue<Int64>.Value(0))
        .withValue(StyleKeys.paddingTop, StyleValue<Int64>.Value(0))
        .withValue(StyleKeys.paddingRight, StyleValue<Int64>.Value(0))
        .withValue(StyleKeys.paddingBottom, StyleValue<Int64>.Value(0))
    let expectedModal = StyleRule()
        .withValue(StyleKeys.border, StyleValue<BorderStyle>.Value(modalBorder))
        .withValue(StyleKeys.shadowEnabled, StyleValue<Bool>.Value(shadow))
        .withValue(StyleKeys.paddingLeft, StyleValue<Int64>.Value(1))
        .withValue(StyleKeys.paddingRight, StyleValue<Int64>.Value(1))
    let expectedInteractive = StyleRule()
        .withValue(StyleKeys.foreground, StyleValue<Color>.Value(accent), state: VisualState.Focused)
        .withValue(StyleKeys.underline, StyleValue<Bool>.Value(true), state: VisualState.Focused)
        .withValue(StyleKeys.inverse, StyleValue<Bool>.Value(true), state: VisualState.Selected)
        .withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.BrightBlack), state: VisualState.Disabled)
        .withValue(StyleKeys.dim, StyleValue<Bool>.Value(true), state: VisualState.Disabled)
    for (value in [built, file]) {
        check(value.name == label && value.schemaVersion == 1, "${slug} identity")
        check(value.textDefaults() == expectedText, "${slug} manually authored text defaults")
        check(value.decorationDefaults() == expectedDecoration, "${slug} manually authored decoration defaults")
        check(value.spacingDefaults() == expectedSpacing, "${slug} manually authored spacing defaults")
        check(value.componentRule(ThemeRole.Modal) == expectedModal, "${slug} modal rule")
        for (role in [ThemeRole.Button, ThemeRole.Radio, ThemeRole.Checkbox, ThemeRole.TextInput, ThemeRole.TextArea, ThemeRole.MenuItem, ThemeRole.HorizontalMenu, ThemeRole.PopupMenu]) {
            check(value.componentRule(role) == expectedInteractive, "${slug} state rule, with non-color focus/selected/disabled hints")
        }
        for (role in [ThemeRole.Generic, ThemeRole.Text, ThemeRole.Row, ThemeRole.Column, ThemeRole.Label, ThemeRole.Progress, ThemeRole.StatusBar, ThemeRole.SplitPane]) {
            check(value.componentRule(role) == StyleRule(), "${slug} absent role is empty, not generic wildcard")
        }
        check(named(value, "accent") == StyleRule().withValue(StyleKeys.foreground, StyleValue<Color>.Value(accent)).withValue(StyleKeys.bold, StyleValue<Bool>.Value(true)), "${slug} accent rule")
        check(named(value, "title") == StyleRule().withValue(StyleKeys.bold, StyleValue<Bool>.Value(true)), "${slug} title rule")
        check(named(value, "muted") == StyleRule().withValue(StyleKeys.dim, StyleValue<Bool>.Value(true)), "${slug} muted rule")
        check(named(value, "danger") == StyleRule().withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.BrightRed)).withValue(StyleKeys.bold, StyleValue<Bool>.Value(true)), "${slug} danger rule")
        check(value.namedStyle("Accent").isNone(), "${slug} names remain case-sensitive")
    }
    check(built.sourcePath.isNone() && built.sourceName == "<preset:" + slug + ">", "preset does not invent File source")
}
func presets(): Unit {
    presetCase(ThemePreset.Dark, "dark", "Dark", Color.Rgb(232,237,242), Color.Rgb(16,24,32), Color.Rgb(102,204,255), BorderStyle.Rounded, true)
    presetCase(ThemePreset.Light, "light", "Light", Color.Rgb(24,32,40), Color.Rgb(255,255,255), Color.Rgb(0,90,156), BorderStyle.Rounded, true)
    presetCase(ThemePreset.HighContrast, "high-contrast", "High contrast", Color.BrightWhite, Color.Black, Color.BrightYellow, BorderStyle.Ascii, false)
    presetCase(ThemePreset.Classic, "classic", "Classic", Color.Default, Color.Default, Color.Cyan, BorderStyle.Ascii, false)
}
