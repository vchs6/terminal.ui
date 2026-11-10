package rich_text_contract

import cjtui.*

func componentContract(): Unit {
    let rich = RichText([TextSpan("e", style: TextStylePatch(foreground: Some(Color.Red), bold: Some(true))),
        TextSpan("\u{301}", style: TextStylePatch(foreground: Some(Color.Blue))), TextSpan("界")])
    let high = render(Column { Text(rich).foreground(Color.Green).bold(false) }
        .background(Color.Blue).dim(true), 4, 1)
    let expected = Style(foreground: Color.Green, background: Color.Blue, bold: false, dim: true)
    cell(high, 0, 0, "e\u{301}", 1, false, expected, "component explicit fields outrank span patch")
    cell(high, 1, 0, "界", 2, false, expected, "inherited fields still fill unset span")
    cell(high, 2, 0, "", 0, true, expected, "component wide continuation style")
    let low = Frame(4, 1)
    low.put(0, 0, rich, style: Style(foreground: Color.Green, background: Color.Blue, dim: true))
    cell(low, 0, 0, "e\u{301}", 1, false, Style(foreground: Color.Red, background: Color.Blue, bold: true, dim: true),
        "Frame base has lower precedence than span")
    let same = render(Text(rich).background(Color.Blue).dim(true), 4, 1)
    let sameLow = Frame(4, 1)
    sameLow.put(0, 0, rich, style: Style(background: Color.Blue, dim: true))
    for (x in 0..3) {
        let a = same.cellAt(x, 0)
        let b = sameLow.cellAt(x, 0)
        check(a.grapheme == b.grapheme && a.width == b.width && a.continuation == b.continuation && a.style == b.style,
            "same base high and low paths agree for cell ${x}")
    }
    // Explicit false must suppress only the chosen attribute, retaining the other span fields.
    let selective = render(Text(RichText([TextSpan("X", style: TextStylePatch(foreground: Some(Color.Red),
        background: Some(Color.Yellow), bold: Some(true), italic: Some(true), underline: Some(true),
        inverse: Some(true), strikethrough: Some(true)))] )).foreground(Color.Cyan).bold(false), 1, 1)
    cell(selective, 0, 0, "X", 1, false, Style(foreground: Color.Cyan, background: Color.Yellow,
        italic: true, underline: true, inverse: true, strikethrough: true), "explicit override preserves other span attributes")
    check(render(Text(RichText([TextSpan("A\r"), TextSpan("\nB")])), 2, 2).toPlainText() == "A \nB ",
        "component whole-document CRLF measurement and paint")
    check(render(Row { Text(RichText("界")); Text("X") }, 3, 1).toPlainText() == "界X",
        "typed measurement shares ordinary layout")
    let wrapped = render(Text(RichText([TextSpan("A界", style: TextStylePatch(foreground: Some(Color.Red))),
        TextSpan("B")])).width(2), 2, 2)
    // Existing Text clips by rows rather than enabling a new rich-text-only wrapping policy.
    check(wrapped.toPlainText() == "A \n  ", "typed text keeps String overflow policy")
    let nonText = Column { Text("x") }
    uiError("InvalidProperty", { => nonText.text(RichText("bad")); () }, "RichText setter rejects non-Text")
    uiError("InvalidProperty", { => nonText.text({ => RichText("bad") }); () }, "RichText getter rejects non-Text")
    println("PASS: component/Frame precedence and shared measurement")
}
