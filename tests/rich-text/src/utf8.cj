package rich_text_contract

import cjtui.*

func utf8Contract(): Unit {
    let red = RichText([TextSpan("X", style: TextStylePatch(foreground: Some(Color.Red)))])
    everySplit([UInt8(0x9b), UInt8(0x33), UInt8(0x31), UInt8(0x6d), UInt8(0x58)], red, [], "raw C1 CSI")
    everySplit([UInt8(0xc2), UInt8(0x9b), UInt8(0x33), UInt8(0x31), UInt8(0x6d), UInt8(0x58)], red, [], "UTF8 C1 CSI")
    ansiCase("қ31mЖ\u{1b}[31m界👩\u{200d}💻", RichText([TextSpan("қ31mЖ"),
        TextSpan("界👩\u{200d}💻", style: TextStylePatch(foreground: Some(Color.Red)))]), [],
        "D2 9B continuation remains text and never CSI")
    // U+049C = D2 9C, so its continuation must not terminate this OSC.
    everySplit([UInt8(0x41), UInt8(0x1b), UInt8(0x5d), UInt8(0xd2), UInt8(0x9c), UInt8(0x58), UInt8(0x07), UInt8(0x42)], RichText("AB"),
        [(AnsiTextIssue.UnsupportedSequence, 1)], "OSC UTF8 continuation is not ST")
    for (tail in [[UInt8(0x9c)], [UInt8(0xc2), UInt8(0x9c)], [UInt8(0x1b), UInt8(0x5c)]]) {
        let bytes = [UInt8(0x41), UInt8(0x9d), UInt8(0x78)].concat(tail).concat([UInt8(0x42)])
        everySplit(bytes, RichText("AB"), [(AnsiTextIssue.UnsupportedSequence, 1)], "all ST scalar forms")
    }
    ansiCase("界\u{9b}2JX\u{7}Y", RichText("界XY"),
        [(AnsiTextIssue.UnsupportedSequence, 3), (AnsiTextIssue.UnsupportedSequence, 8)], "absolute offsets count UTF8 bytes")
    ansiCase("A\r\nB\rC\tD\u{8}E\u{7f}F\u{85}G", RichText("A\r\nBCDEFG"),
        [(AnsiTextIssue.UnsupportedSequence, 4), (AnsiTextIssue.UnsupportedSequence, 6),
         (AnsiTextIssue.UnsupportedSequence, 8), (AnsiTextIssue.UnsupportedSequence, 10),
         (AnsiTextIssue.UnsupportedSequence, 12)], "CRLF and rejected scalar controls")
    for (value in 0..32) {
        if (value == 10 || value == 13 || value == 27) { continue }
        everySplit([UInt8(0x41), UInt8(value), UInt8(0x42)], RichText("AB"),
            [(AnsiTextIssue.UnsupportedSequence, 1)], "all isolated C0 ${value}")
    }
    for (value in 128..160) {
        // Introducers begin incomplete sequences; tested separately with their own rules.
        if (value == 144 || value == 152 || value == 155 || value == 157 || value == 158 || value == 159) { continue }
        everySplit([UInt8(0x41), UInt8(value), UInt8(0x42)], RichText("AB"),
            [(AnsiTextIssue.UnsupportedSequence, 1)], "all isolated raw C1 ${value}")
        everySplit([UInt8(0x41), UInt8(0xc2), UInt8(value), UInt8(0x42)], RichText("AB"),
            [(AnsiTextIssue.UnsupportedSequence, 1)], "all isolated UTF8 C1 ${value}")
    }
    println("PASS: every UTF8/C1 split, scalar boundaries and literal byte offsets")
}
