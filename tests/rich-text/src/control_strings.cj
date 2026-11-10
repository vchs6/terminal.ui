package rich_text_contract

import cjtui.*

func controlStringContract(): Unit {
    let green = RichText([TextSpan("AB", style: TextStylePatch(foreground: Some(Color.Green)))])
    // All control strings: OSC has BEL or ST; DCS/SOS/PM/APC have only ST.
    let introductions = ["\u{1b}]", "\u{1b}P", "\u{1b}X", "\u{1b}^", "\u{1b}_",
        "\u{9d}", "\u{90}", "\u{98}", "\u{9e}", "\u{9f}"]
    for (i in 0..introductions.size) {
        let intro = introductions[i]
        let osc = i == 0 || i == 5
        let terminators = if (osc) { ["\u{7}", "\u{1b}\\", "\u{9c}"] } else { ["\u{1b}\\", "\u{9c}"] }
        for (terminator in terminators) {
            let payload = if (osc) { "secretҜ\u{1b}[31m\u{18}\u{1a}\u{1b}Ztail" }
                else { "secretҜ\u{7}\u{1b}[31m\u{18}\u{1a}\u{1b}Ztail" }
            ansiCase("\u{1b}[32mA" + intro + payload + terminator + "B", green,
                [(AnsiTextIssue.UnsupportedSequence, 6)], "bounded nested control string ${i}")
            ansiCase("\u{1b}[32mA" + intro + payload + terminator + "B", green,
                [(AnsiTextIssue.SequenceTooLong, 6)], "overlong string retains isolation ${i}",
                limits: AnsiTextLimits(maxSequenceBytes: 8))
        }
        ansiCase("A" + intro + "payload\u{18}\u{1a}\u{1b}[31m", RichText("A"),
            [(AnsiTextIssue.IncompleteSequence, 1)], "finish discards unfinished control payload ${i}")
        ansiCase("A" + intro + "payload\u{18}\u{1a}\u{1b}[31m", RichText("A"),
            [(AnsiTextIssue.SequenceTooLong, 1), (AnsiTextIssue.IncompleteSequence, 1)],
            "overlong unfinished string reports only first resource plus incomplete ${i}",
            limits: AnsiTextLimits(maxSequenceBytes: 4))
    }
    // Raw C1 forms exercise scalar-boundary framing independently of String input.
    for (intro in [UInt8(0x90), UInt8(0x98), UInt8(0x9d), UInt8(0x9e), UInt8(0x9f)]) {
        everySplit([UInt8(0x41), intro, UInt8(0x78), UInt8(0x1b), UInt8(0x5b), UInt8(0x33), UInt8(0x31), UInt8(0x6d), UInt8(0x18), UInt8(0x1a), UInt8(0x9c), UInt8(0x42)],
            RichText("AB"), [(AnsiTextIssue.UnsupportedSequence, 1)], "raw C1 string ${intro}")
    }
    ansiCase("A\u{1b}Ppayload\u{7}LEAK\u{1b}\\B", RichText("AB"),
        [(AnsiTextIssue.UnsupportedSequence, 1)], "DCS BEL cannot end isolation")
    ansiCase("A\u{1b}]payload\u{1b}\u{1b}\\B", RichText("AB"),
        [(AnsiTextIssue.UnsupportedSequence, 1)], "nested ESC still recognizes following ST")
    let long = AnsiTextDecoder()
    let actual = DecodedStream()
    actual.append(long.feed(("A\u{1b}P" + repeated("x", 4094)).toArray()))
    let firstOver = long.feed(repeated("x", 1024).toArray())
    check(firstOver.diagnostics.size == 1 && firstOver.diagnostics[0].kind == AnsiTextIssue.SequenceTooLong &&
        firstOver.diagnostics[0].offset == 1, "large DCS reports once after exact budget")
    actual.append(firstOver)
    for (_ in 0..128) {
        let drained = long.feed((repeated("x", 1024) + "\u{1b}[31m\u{18}\u{1a}\u{7}").toArray())
        check(drained.spans.isEmpty() && drained.diagnostics.isEmpty(), "long failed DCS stays isolated across later feeds")
        actual.append(drained)
    }
    actual.append(long.feed("\u{1b}\\Z".toArray()))
    actual.append(long.finish())
    actual.verify(RichText("AZ"), [(AnsiTextIssue.SequenceTooLong, 1)], "long control string drain does not leak")
    println("PASS: OSC/DCS/SOS/PM/APC bounded drain and legal terminators")
}
