package rich_text_contract

import cjtui.*

func limitContract(): Unit {
    check(AnsiTextLimits().maxSequenceBytes == 4096 && AnsiTextLimits().maxParameters == 64,
        "published default limits use maxParameters for all CSI")
    for (value in [Int64(-1), 0, 1048577]) {
        illegal({ => AnsiTextLimits(maxSequenceBytes: value); () }, "sequence limit range")
    }
    for (value in [Int64(-1), 0, 4097]) {
        illegal({ => AnsiTextLimits(maxParameters: value); () }, "parameter limit range")
    }
    let ceiling = AnsiTextLimits(maxSequenceBytes: 1048576, maxParameters: 4096)
    check(ceiling.maxSequenceBytes == 1048576 && ceiling.maxParameters == 4096, "inclusive upper limits")
    for (fields in [Int64(63), 64, 65]) {
        let params = repeated(";", fields - 1)
        let expected = if (fields <= 64) { RichText([TextSpan("X", style: resetPatch())]) } else { RichText("X") }
        let issues: Array<(AnsiTextIssue, Int64)> = if (fields <= 64) { [] } else { [(AnsiTextIssue.SequenceTooLong, 0)] }
        ansiCase("\u{1b}[${params}mX", expected, issues, "63/64/65 SGR fields ${fields}")
        let unknownIssues = if (fields <= 64) { [(AnsiTextIssue.UnsupportedSequence, Int64(0))] }
            else { [(AnsiTextIssue.SequenceTooLong, Int64(0))] }
        ansiCase("\u{1b}[${params}KX", RichText("X"), unknownIssues, "parameter limit applies to non-m ${fields}")
    }
    // Extended color operands and empty fields all consume parameter slots.
    ansiCase("\u{1b}[38;2;1;2;3mX", RichText("X"), [(AnsiTextIssue.SequenceTooLong, 0)],
        "RGB operand field budget", limits: AnsiTextLimits(maxParameters: 4))
    ansiCase("\u{1b}[;mX", RichText("X"), [(AnsiTextIssue.SequenceTooLong, 0)],
        "empty fields consume budget", limits: AnsiTextLimits(maxParameters: 1))
    ansiCase("\u{1b}[mX", RichText([TextSpan("X", style: resetPatch())]), [],
        "no parameter is one implicit zero", limits: AnsiTextLimits(maxParameters: 1))
    for (finalByte in ["m", "K"]) {
        ansiCase("\u{1b}[123${finalByte}X", RichText("X"), [(AnsiTextIssue.UnsupportedSequence, 0)],
            "three-digit token allowed ${finalByte}")
        ansiCase("\u{1b}[0000${finalByte}X", RichText("X"), [(AnsiTextIssue.SequenceTooLong, 0)],
            "four-digit token resource before final ${finalByte}")
    }
    // At 4095/4096/4097 the introducer and terminating BEL are included.
    for (length in [Int64(4095), 4096, 4097]) {
        let bytes = ("A\u{1b}]" + repeated("x", length - 3) + "\u{7}B").toArray()
        let kind = if (length <= 4096) { AnsiTextIssue.UnsupportedSequence } else { AnsiTextIssue.SequenceTooLong }
        decodeCuts(bytes, [0, 1, 2, 3, 4095, 4096], RichText("AB"), [(kind, 1)], "sequence bytes ${length}")
        decodeCuts(bytes, Array<Int64>(bytes.size + 1, {i => i}), RichText("AB"), [(kind, 1)],
            "sequence bytes ${length} bytewise")
    }
    let red = RichText([TextSpan("X", style: TextStylePatch(foreground: Some(Color.Red)))])
    everySplit([UInt8(0x9b), UInt8(0x33), UInt8(0x31), UInt8(0x6d), UInt8(0x58)], red, [], "raw CSI actual bytes four",
        limits: AnsiTextLimits(maxSequenceBytes: 4))
    everySplit([UInt8(0xc2), UInt8(0x9b), UInt8(0x33), UInt8(0x31), UInt8(0x6d), UInt8(0x58)], RichText("X"),
        [(AnsiTextIssue.SequenceTooLong, 0)], "UTF8 CSI actual bytes five", limits: AnsiTextLimits(maxSequenceBytes: 4))
    ansiCase("\u{1b}[31mX", RichText("X"), [(AnsiTextIssue.SequenceTooLong, 0)],
        "ESC CSI actual bytes five", limits: AnsiTextLimits(maxSequenceBytes: 4))
    ansiCase("\u{1b}[1mX", RichText([TextSpan("X", style: TextStylePatch(bold: Some(true)))]), [],
        "terminator exactly at byte budget", limits: AnsiTextLimits(maxSequenceBytes: 4))
    ansiCase("\u{1b}[1mX", RichText("X"), [(AnsiTextIssue.SequenceTooLong, 0)],
        "terminator exceeds byte budget", limits: AnsiTextLimits(maxSequenceBytes: 3))
    // Resource fault on the same byte wins over malformed ordering/control.
    ansiCase("\u{1b}[\tmX", RichText("X"), [(AnsiTextIssue.SequenceTooLong, 0)],
        "resource before syntax on same byte", limits: AnsiTextLimits(maxSequenceBytes: 2))
    ansiCase("\u{1b}[1 2" + repeated("0", 10) + "mX", RichText("X"),
        [(AnsiTextIssue.MalformedSequence, 0)], "first malformed not overwritten by later resource",
        limits: AnsiTextLimits(maxSequenceBytes: 8))
    // Resource issue is delivered immediately, once; finish can add incomplete.
    let digits = AnsiTextDecoder()
    let batch = digits.feed("A\u{1b}[1234".toArray())
    check(batch.diagnostics.size == 1 && batch.diagnostics[0].kind == AnsiTextIssue.SequenceTooLong &&
        batch.diagnostics[0].offset == 1, "fourth digit reports before any final")
    check(digits.feed("5;9999".toArray()).diagnostics.isEmpty(), "already failed CSI not reported again")
    let ending = digits.finish()
    check(ending.diagnostics.size == 1 && ending.diagnostics[0].kind == AnsiTextIssue.IncompleteSequence &&
        ending.diagnostics[0].offset == 1, "finish adds incomplete to resource-failed residual")
    let fields = AnsiTextDecoder(limits: AnsiTextLimits(maxParameters: 2))
    check(fields.feed("\u{1b}[1;2".toArray()).diagnostics.isEmpty(), "at field budget remains pending")
    let over = fields.feed(";".toArray())
    check(over.diagnostics.size == 1 && over.diagnostics[0].kind == AnsiTextIssue.SequenceTooLong,
        "first excess semicolon reports immediately before unknown final")
    check(fields.feed("KX".toArray()).diagnostics.isEmpty(), "unknown final cannot replace first resource issue")
    fields.finish()
    for (length in [Int64(4095), 4096, 4097]) {
        let bytes = ("A\u{1b}[" + repeated(" ", length - 3) + "KB").toArray()
        let kind = if (length <= 4096) { AnsiTextIssue.UnsupportedSequence } else { AnsiTextIssue.SequenceTooLong }
        decodeCuts(bytes, Array<Int64>(bytes.size + 1, {i => i}), RichText("AB"), [(kind, 1)],
            "unknown CSI byte boundary ${length}")
    }
    everySplit([UInt8(0x9d), UInt8(0x78), UInt8(0x9c), UInt8(0x58)], RichText("X"),
        [(AnsiTextIssue.UnsupportedSequence, 0)], "raw C1 OSC and ST actual bytes",
        limits: AnsiTextLimits(maxSequenceBytes: 4))
    ansiCase("\u{9d}x\u{9c}X", RichText("X"), [(AnsiTextIssue.SequenceTooLong, 0)],
        "UTF8 C1 OSC and ST actual bytes", limits: AnsiTextLimits(maxSequenceBytes: 4))
    println("PASS: all-CSI count/token/byte boundaries and immediate first faults")
}
