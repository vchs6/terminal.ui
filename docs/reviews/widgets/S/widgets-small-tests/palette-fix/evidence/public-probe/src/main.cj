package palette_public_probe

import std.fs.File
import cjtui.{Application, Color, Style, StyleKeys, StyleRule, StyleUse, StyleValue, Text, Theme, ThemeRole, VisualStates, render}

func check(value: Bool, name: String): Unit {
    if (!value) { throw Exception(name) }
}

main(): Int64 {
    let colorOnly = StyleRule()
        .withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.Yellow))
        .withValue(StyleKeys.background, StyleValue<Color>.Value(Color.Black))
    let inherited = render(Text("T").themeRole(ThemeRole.Checkbox)
        .visualStates(VisualStates(selected: true)).styles([StyleUse.Inline(colorOnly)]), 1, 1)
    check(inherited.cellAt(0, 0).style == Style(foreground: Color.Yellow, background: Color.Black, inverse: true),
        "color-only Inline inherits Classic selected inverse exactly")
    println("COLOR_ONLY_INHERITS_CLASSIC_INVERSE")
    let complete = colorOnly
        .withValue(StyleKeys.bold, StyleValue<Bool>.Value(false))
        .withValue(StyleKeys.dim, StyleValue<Bool>.Value(false))
        .withValue(StyleKeys.italic, StyleValue<Bool>.Value(false))
        .withValue(StyleKeys.underline, StyleValue<Bool>.Value(false))
        .withValue(StyleKeys.inverse, StyleValue<Bool>.Value(false))
        .withValue(StyleKeys.strikethrough, StyleValue<Bool>.Value(false))
    let explicit = render(Text("T").themeRole(ThemeRole.Checkbox)
        .visualStates(VisualStates(selected: true)).styles([StyleUse.Inline(complete)]), 1, 1)
    check(explicit.cellAt(0, 0).style == Style(foreground: Color.Yellow, background: Color.Black),
        "complete Inline false palette overrides Classic selected inverse exactly")
    println("FULL_INLINE_FALSE_OVERRIDES_CLASSIC_ATTRIBUTES")
    let classic = String.fromUtf8(File.readFrom("/workspace/work/terminal.ui/themes/classic.toml"))
    let named = Theme.parse(classic + "\n[styles.test.text]\nforeground = \"yellow\"\nbackground = \"black\"\nbold = false\ndim = false\nitalic = false\nunderline = false\ninverse = false\nstrikethrough = false\n")
    let app = Application(Text("T").themeRole(ThemeRole.Checkbox)
        .visualStates(VisualStates(selected: true)).styles([StyleUse.Named("test")]), theme: named)
    app.startHeadless()
    check(app.snapshot(1, 1).cellAt(0, 0).style == Style(foreground: Color.Yellow, background: Color.Black),
        "complete Named false palette overrides Classic selected inverse exactly")
    app.dispose()
    println("FULL_NAMED_FALSE_OVERRIDES_CLASSIC_ATTRIBUTES")
    0
}
