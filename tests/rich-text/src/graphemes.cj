package rich_text_contract

import cjtui.*

// Literal cells, including continuation metadata: no product width/segmentation oracle.
func graphemeContract(): Unit {
    let red = TextStylePatch(foreground: Some(Color.Red), bold: Some(true))
    let blue = TextStylePatch(foreground: Some(Color.Blue), italic: Some(true))
    let value = RichText([TextSpan("e", style: red), TextSpan("\u{301}👩", style: blue),
        TextSpan("\u{200d}💻🇨", style: red), TextSpan("🇳\r", style: blue), TextSpan("\n界")])
    let frame = Frame(8, 2)
    let base = Style(background: Color.Green, dim: true)
    frame.put(0, 0, value, style: base)
    let r = Style(foreground: Color.Red, background: Color.Green, bold: true, dim: true)
    let b = Style(foreground: Color.Blue, background: Color.Green, dim: true, italic: true)
    cell(frame, 0, 0, "e\u{301}", 1, false, r, "combining cluster takes first scalar patch")
    cell(frame, 1, 0, "👩\u{200d}💻", 2, false, b, "ZWJ cluster spans patch boundary")
    cell(frame, 2, 0, "", 0, true, b, "ZWJ continuation style")
    cell(frame, 3, 0, "🇨🇳", 2, false, r, "flag uses first regional indicator patch")
    cell(frame, 4, 0, "", 0, true, r, "flag continuation style")
    cell(frame, 0, 1, "界", 2, false, base, "CRLF across spans is one line break")
    cell(frame, 1, 1, "", 0, true, base, "CJK continuation")
    check(frame.toPlainText() == "e\u{301}👩\u{200d}💻🇨🇳   \n界      ", "whole-document literal picture")
    let clip = Frame(3, 1)
    clip.put(0, 0, RichText([TextSpan("A"), TextSpan("界", style: red)]))
    clip.put(2, 0, RichText("Z"))
    check(clip.toPlainText() == "A Z", "overwrite continuation clears entire old wide cluster")
    cell(clip, 1, 0, " ", 1, false, Style(), "wide lead cleared")
    let edge = Frame(2, 1)
    edge.put(1, 0, RichText([TextSpan("界", style: red)]))
    check(edge.toPlainText() == "  ", "right edge never writes half wide cluster")
    edge.put(-1, 0, RichText("界A"))
    check(edge.toPlainText() == " A", "left edge clips entire wide cluster")
    println("PASS: cross-span graphemes and literal Frame cells")
}
