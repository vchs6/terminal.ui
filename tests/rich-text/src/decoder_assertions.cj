package rich_text_contract

import cjtui.*

func repeated(value: String, count: Int64): String {
    var result = ""
    for (_ in 0..count) { result += value }
    result
}

func resetPatch(): TextStylePatch {
    TextStylePatch(foreground: Some(Color.Default), background: Some(Color.Default),
        bold: Some(false), dim: Some(false), italic: Some(false), underline: Some(false),
        inverse: Some(false), strikethrough: Some(false))
}

func decodeCuts(bytes: Array<UInt8>, cuts: Array<Int64>, expected: RichText,
    issues: Array<(AnsiTextIssue, Int64)>, name: String, limits!: AnsiTextLimits = AnsiTextLimits()): Unit {
    let decoder = AnsiTextDecoder(limits: limits)
    let actual = DecodedStream()
    var start = 0
    for (end in cuts) {
        actual.append(decoder.feed(bytes.slice(start, end - start)))
        start = end
    }
    actual.append(decoder.feed(bytes.slice(start, bytes.size - start)))
    actual.append(decoder.finish())
    actual.verify(expected, issues, name)
    ansiError("DecoderClosed", { => decoder.feed(Array<UInt8>()); () }, "${name}: feed after finish")
    ansiError("DecoderClosed", { => decoder.finish(); () }, "${name}: finish after finish")
}

// Each expected result is supplied by the test author, never by another decoder call.
// Enumerate every two-chunk boundary, plus an entirely bytewise stream and empty chunks.
func everySplit(bytes: Array<UInt8>, expected: RichText, issues: Array<(AnsiTextIssue, Int64)>, name: String,
    limits!: AnsiTextLimits = AnsiTextLimits()): Unit {
    for (cut in 0..(bytes.size + 1)) {
        decodeCuts(bytes, [cut], expected, issues, "${name} split ${cut}", limits: limits)
    }
    let byteCuts = Array<Int64>(bytes.size + 1, {i => i})
    decodeCuts(bytes, byteCuts, expected, issues, "${name} bytewise", limits: limits)
    decodeCuts(bytes, [0, 0, bytes.size, bytes.size], expected, issues, "${name} empty chunks", limits: limits)
}

func ansiCase(source: String, expected: RichText, issues: Array<(AnsiTextIssue, Int64)>, name: String,
    limits!: AnsiTextLimits = AnsiTextLimits()): Unit {
    everySplit(source.toArray(), expected, issues, name, limits: limits)
    let result = parseAnsiText(source, limits: limits)
    check(result.text == expected && result.diagnostics.size == issues.size, "${name}: one-shot literal golden")
    for (i in 0..issues.size) {
        check(result.diagnostics[i].kind == issues[i][0] && result.diagnostics[i].offset == issues[i][1],
            "${name}: one-shot issue ${i}")
    }
}
