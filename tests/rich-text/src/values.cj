package rich_text_contract

import cjtui.*

// Catches None treated as reset, whole-style resolution, per-span validation,
// retained mutable arrays, and equality that drops style.
func valueContract(): Unit {
    let base = Style(foreground: Color.Red, background: Color.Blue, bold: true, dim: true,
        italic: true, underline: true, inverse: true, strikethrough: true)
    check(TextStylePatch().resolve(base) == base, "unset inherits all base fields")
    let reset = TextStylePatch(foreground: Some(Color.Default), background: Some(Color.Default),
        bold: Some(false), dim: Some(false), italic: Some(false), underline: Some(false),
        inverse: Some(false), strikethrough: Some(false))
    check(reset.resolve(base) == Style(), "explicit Default and false replace every field")
    check(TextStylePatch(foreground: Some(Color.Green), bold: Some(false)).resolve(base) ==
        Style(foreground: Color.Green, background: Color.Blue, dim: true, italic: true,
            underline: true, inverse: true, strikethrough: true), "patch resolves fields independently")
    check(TextStylePatch() != reset, "unset differs from explicit reset")
    let red = TextStylePatch(foreground: Some(Color.Red))
    let source = [TextSpan(""), TextSpan("A", style: red), TextSpan("", style: reset),
        TextSpan("B", style: red), TextSpan("C")]
    let value = RichText(source)
    check(value.spans.size == 2 && value.spans[0] == TextSpan("AB", style: red) &&
        value.spans[1] == TextSpan("C"), "empty spans removed and adjacent equal patches merged")
    source[1] = TextSpan("evil")
    let view = value.spans
    view[0] = TextSpan("evil")
    check(value.toPlainText() == "ABC" && value.spans[0] == TextSpan("AB", style: red),
        "RichText input and getter arrays are snapshots")
    check(value == RichText([TextSpan("AB", style: red), TextSpan("C")]), "normalized equality")
    check(value != RichText("ABC"), "equality retains patch semantics")
    check(RichText("") == RichText(Array<TextSpan>()) && RichText("AB") ==
        RichText([TextSpan("A"), TextSpan("B")]), "String constructor shares normalization")
    let crlf = RichText([TextSpan("A\r", style: red), TextSpan("\nB")])
    check(crlf.toPlainText() == "A\r\nB", "validate concatenated CRLF across spans")
    illegal({ => RichText([TextSpan("A\r"), TextSpan("B")]); () }, "lone CR rejected after concatenate")
    for (bad in ["\u{1b}[31m", "\t", "\u{7}", "\u{7f}", "\u{9b}", "\r"]) {
        illegal({ => RichText(bad); () }, "RichText remains strict plain text")
        illegal({ => validatePlainText(bad) }, "public shared strict validator")
        illegal({ => Text(bad); () }, "String Text does not accept ANSI")
        let frame = Frame(3, 1)
        frame.put(0, 0, "OLD")
        illegal({ => frame.put(0, 0, "A" + bad) }, "String Frame does not accept controls")
        check(frame.toPlainText() == "OLD", "String validation is atomic before Frame write")
    }
    validatePlainText("e\u{301}\r\n界")
    println("PASS: rich text values and strict compatibility")
}
