package rich_text_contract

import cjtui.*

func aliasContract(): Unit {
    let decoder = AnsiTextDecoder()
    let batch = decoder.feed("A\u{7}B\tC".toArray())
    let spans = batch.spans
    check(!spans.isEmpty(), "batch owns safe output")
    let original = RichText(spans)
    spans[0] = TextSpan("evil")
    check(RichText(batch.spans) == original, "batch spans getter returns copy")
    let issues = batch.diagnostics
    check(issues.size == 2 && issues[0].offset == 1 && issues[1].offset == 3, "two distinct issue objects")
    issues[0] = issues[1]
    check(batch.diagnostics[0].offset == 1, "batch diagnostics getter returns copy")
    decoder.feed("D".toArray())
    decoder.finish()
    check(RichText(batch.spans) == original && batch.diagnostics[0].offset == 1, "later feed retains no batch aliases")
    let result = parseAnsiText("A\u{7}B\tC")
    let diagnostics = result.diagnostics
    diagnostics[0] = diagnostics[1]
    check(result.diagnostics[0].offset == 1 && result.text.toPlainText() == "ABC", "result diagnostics defensive copy")
    let pending = AnsiTextDecoder()
    let bytes = "\u{1b}[3".toArray()
    pending.feed(bytes)
    bytes[0] = UInt8(0x58)
    bytes[2] = UInt8(0x39)
    let actual = DecodedStream()
    actual.append(pending.feed("1mX".toArray()))
    actual.append(pending.finish())
    actual.verify(RichText([TextSpan("X", style: TextStylePatch(foreground: Some(Color.Red)))]), [],
        "pending CSI does not retain mutable caller chunk")
    let unicode = AnsiTextDecoder()
    let prefix: Array<UInt8> = [UInt8(0xe7), UInt8(0x95)]
    unicode.feed(prefix)
    prefix[0] = UInt8(0x41)
    prefix[1] = UInt8(0x42)
    let text = DecodedStream()
    text.append(unicode.feed([UInt8(0x8c)]))
    text.append(unicode.finish())
    text.verify(RichText("界"), [], "pending UTF8 does not retain caller array")
    println("PASS: decoder batch/result/chunk array ownership")
}
