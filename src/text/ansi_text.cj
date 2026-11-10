package cjtui.text

import std.collection.ArrayList

public func parseAnsiText(value: String, limits!: AnsiTextLimits = AnsiTextLimits()): AnsiTextResult {
    let decoder = AnsiTextDecoder(limits: limits)
    let content = ArrayList<TextSpan>()
    let diagnostics = ArrayList<AnsiTextDiagnostic>()
    let first = decoder.feed(value.toArray())
    let last = decoder.finish()
    content.add(all: first.spans)
    content.add(all: last.spans)
    diagnostics.add(all: first.diagnostics)
    diagnostics.add(all: last.diagnostics)
    AnsiTextResult(RichText(content.toArray()), diagnostics.toArray())
}
