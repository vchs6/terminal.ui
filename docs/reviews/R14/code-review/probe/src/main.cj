package review_probe

import cjtui.*

func issueName(issue: AnsiTextIssue): String {
    match (issue) {
        case AnsiTextIssue.MalformedSequence => "MalformedSequence"
        case AnsiTextIssue.SequenceTooLong => "SequenceTooLong"
        case AnsiTextIssue.UnsupportedSequence => "UnsupportedSequence"
        case AnsiTextIssue.IncompleteSequence => "IncompleteSequence"
    }
}

func show(label: String, batch: AnsiTextBatch): Unit {
    println("${label}: diagnostics=${batch.diagnostics.size}")
    for (diagnostic in batch.diagnostics) {
        println("  ${issueName(diagnostic.kind)} offset=${diagnostic.offset}")
    }
}

main(): Int64 {
    let decoder = AnsiTextDecoder(limits: AnsiTextLimits(maxSequenceBytes: 3))
    show("prefix ESC [ C2 (non-ASCII lead)", decoder.feed([UInt8(27), 91, 0xc2]))
    show("continuation A0 then final m", decoder.feed([UInt8(0xa0), 109]))
    show("finish", decoder.finish())
    let decoder2 = AnsiTextDecoder(limits: AnsiTextLimits(maxSequenceBytes: 4))
    show("whole ESC [ C2 A0 m (budget 4)", decoder2.feed([UInt8(27), 91, 0xc2, 0xa0, 109]))
    decoder2.finish()
    0
}
