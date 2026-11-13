package row_fill_proof

import cjtui.{Application, Color, Row, Style, Text, Theme, ThemeRole}

func check(ok: Bool, name: String): Unit {
    if (!ok) { throw IllegalStateException(name) }
}

func assertFill(theme: Theme, expected: Style): Unit {
    let app = Application(Row { Text("A") }.themeRole(ThemeRole.HorizontalMenu), theme: theme)
    app.startHeadless()
    try {
        let frame = app.snapshot(4, 1)
        check(frame.toPlainText() == "A   ", "literal finite Row grid")
        check(frame.cellAt(0, 0).style == Style(foreground: Color.Red, background: Color.Black), "role text remains full RedBlack Style")
        check(frame.cellAt(3, 0).style == expected, "exact eight-field hand-authored fill Style")
    } finally { app.dispose() }
}

main(): Int64 {
    let local = Theme.readFile("/workspace/work/widgets-composite-tests/theme-fill-fix/source/tests/widgets_composite/fixtures/local-theme.toml")
    assertFill(local, Style(foreground: Color.Red, background: Color.Black))
    let seed = Theme.parse("schema_version = 1\nname = \"M-seed-only\"\n[text]\nforeground = \"white\"\nbackground = \"black\"\n[components.horizontal_menu.text]\nforeground = \"red\"\n")
    assertFill(seed, Style(background: Color.Black))
    println("ACCEPTED_PUBLIC_ROW_LOCAL_FILL_AND_GLOBAL_SEED_PASS")
    0
}
