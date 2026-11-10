package rich_text_contract

import cjtui.*
import std.collection.ArrayList

// Collect independent checks so a delayed first issue cannot hide drain/closure
// failures in the remaining cases. Expected spans/issues are hand-written below.
class CsiUtf8Checks {
    var failures: Int64 = 0

    func expect(value: Bool, name: String): Unit {
        if (!value) {
            failures++
            println("FAIL: CSI UTF8 ${name}")
        }
    }

    func batch(actual: AnsiTextBatch, expected: RichText,
        issues: Array<(AnsiTextIssue, Int64)>, name: String): Unit {
        expect(RichText(actual.spans) == expected, "${name}: literal batch spans")
        diagnostics(actual.diagnostics, issues, name)
    }

    func diagnostics(actual: Array<AnsiTextDiagnostic>, issues: Array<(AnsiTextIssue, Int64)>,
        name: String): Unit {
        expect(actual.size == issues.size, "${name}: issue count ${actual.size}/${issues.size}")
        for (i in 0..issues.size) {
            if (i < actual.size) {
                expect(actual[i].kind == issues[i][0] && actual[i].offset == issues[i][1],
                    "${name}: issue ${i} expected ${issueName(issues[i][0])}@${issues[i][1]}, " +
                    "actual ${issueName(actual[i].kind)}@${actual[i].offset}")
            }
        }
    }

    func closed(decoder: AnsiTextDecoder, name: String): Unit {
        ansiError("DecoderClosed", { => decoder.feed([UInt8(0x58)]); () }, "${name}: feed closed")
        ansiError("DecoderClosed", { => decoder.finish(); () }, "${name}: finish closed")
    }

    func run(name: String, action: () -> Unit): Unit {
        let before = failures
        try { action() } catch (error: Exception) {
            failures++
            println("FAIL: CSI UTF8 ${name}: ${error.message}")
        }
        if (failures == before) { println("PASS: CSI UTF8 ${name}") }
    }

    func issueName(issue: AnsiTextIssue): String {
        match (issue) {
            case AnsiTextIssue.MalformedSequence => "MalformedSequence"
            case AnsiTextIssue.SequenceTooLong => "SequenceTooLong"
            case AnsiTextIssue.UnsupportedSequence => "UnsupportedSequence"
            case AnsiTextIssue.IncompleteSequence => "IncompleteSequence"
        }
    }
}

func csiUtf8Immediate(checks: CsiUtf8Checks): Unit {
    for (budget in [Int64(3), 4]) {
        checks.run("immediate prefix budget ${budget}", { =>
            let decoder = AnsiTextDecoder(limits: AnsiTextLimits(maxSequenceBytes: budget))
            checks.batch(decoder.feed([UInt8(0x1b), 0x5b, 0xc2]), RichText(""),
                [(AnsiTextIssue.MalformedSequence, 0)], "ESC [ C2 budget ${budget}: immediate malformed")
            checks.batch(decoder.feed([UInt8(0xa0), 0x6d, 0x58]), RichText("X"), [],
                "budget ${budget}: valid scalar tail and final drain without second resource")
            checks.batch(decoder.finish(), RichText(""), [], "budget ${budget}: completed finish")
            checks.closed(decoder, "budget ${budget}")
        })
    }
    // C2 itself exceeds this budget: same-byte resource priority remains intact.
    checks.run("same-byte resource priority", { =>
        let decoder = AnsiTextDecoder(limits: AnsiTextLimits(maxSequenceBytes: 2))
        checks.batch(decoder.feed([UInt8(0x1b), 0x5b, 0xc2]), RichText(""),
            [(AnsiTextIssue.SequenceTooLong, 0)], "C2 crosses budget on same byte")
        checks.batch(decoder.feed([UInt8(0xa0), 0x6d, 0x58]), RichText("X"), [], "resource drain")
        checks.batch(decoder.finish(), RichText(""), [], "resource finish")
        checks.closed(decoder, "resource finish")
    })
}

func csiUtf8Cuts(checks: CsiUtf8Checks, bytes: Array<UInt8>, expected: RichText,
    offset: Int64, budget: Int64, name: String): Unit {
    let cuts = ArrayList<Array<Int64>>()
    for (cut in 0..(bytes.size + 1)) { cuts.add([cut]) }
    cuts.add(Array<Int64>(bytes.size + 1, {i => i}))
    cuts.add([0, 0, bytes.size, bytes.size])
    var caseIndex: Int64 = 0
    for (boundaries in cuts) {
        let label = "${name} budget ${budget} cuts case ${caseIndex}"
        checks.run(label, { =>
            let decoder = AnsiTextDecoder(limits: AnsiTextLimits(maxSequenceBytes: budget))
            let spans = ArrayList<TextSpan>()
            let issues = ArrayList<AnsiTextDiagnostic>()
            var start: Int64 = 0
            for (end in boundaries) {
                let batch = decoder.feed(bytes.slice(start, end - start))
                for (span in batch.spans) { spans.add(span) }
                for (issue in batch.diagnostics) { issues.add(issue) }
                start = end
            }
            let tail = decoder.feed(bytes.slice(start, bytes.size - start))
            for (span in tail.spans) { spans.add(span) }
            for (issue in tail.diagnostics) { issues.add(issue) }
            let finish = decoder.finish()
            for (span in finish.spans) { spans.add(span) }
            for (issue in finish.diagnostics) { issues.add(issue) }
            checks.expect(RichText(spans.toArray()) == expected, "${label}: literal normalized spans")
            checks.diagnostics(issues.toArray(), [(AnsiTextIssue.MalformedSequence, offset)], label)
            checks.closed(decoder, label)
        })
        caseIndex++
    }
}

func csiUtf8FirstFault(checks: CsiUtf8Checks): Unit {
    for (budget in [Int64(3), 4]) {
        csiUtf8Cuts(checks, [UInt8(0x1b), 0x5b, 0xc2, 0xa0, 0x6d, 0x58],
            RichText("X"), 0, budget, "valid non-ASCII scalar stays in CSI drain")
        csiUtf8Cuts(checks, "界A\u{1b}[\u{a0}mZ".toArray(), RichText("界AZ"),
            4, budget, "absolute introducer offset after UTF8 text")
        csiUtf8Cuts(checks, [UInt8(0x1b), 0x5b, 0xc2, 0x9b, 0x33, 0x31, 0x6d, 0x58],
            RichText("X"), 0, budget, "UTF8 C1 inside failed CSI cannot restart SGR")
        csiUtf8Cuts(checks, [UInt8(0x1b), 0x5b, 0xd2, 0x9b, 0x33, 0x31, 0x6d, 0x58],
            RichText("X"), 0, budget, "non-C1 continuation inside failed CSI cannot release body")
    }
}

func csiUtf8Validation(checks: CsiUtf8Checks): Unit {
    for (budget in [Int64(3), 4]) {
        for (incomplete in [false, true]) {
            checks.run("UTF8 validation budget ${budget} incomplete ${incomplete}", { =>
                let decoder = AnsiTextDecoder(limits: AnsiTextLimits(maxSequenceBytes: budget))
                checks.batch(decoder.feed([UInt8(0x1b), 0x5b, 0xc2]), RichText(""),
                    [(AnsiTextIssue.MalformedSequence, 0)], "failure prefix before invalid UTF8")
                if (incomplete) {
                    ansiError("InvalidUtf8", { => decoder.finish(); () }, "incomplete scalar in CSI drain")
                } else {
                    ansiError("InvalidUtf8", { => decoder.feed([UInt8(0x41)]); () },
                        "invalid continuation in CSI drain")
                }
                checks.closed(decoder, "UTF8 failure budget ${budget}")
            })
        }
        checks.run("malformed incomplete sequence budget ${budget}", { =>
            let decoder = AnsiTextDecoder(limits: AnsiTextLimits(maxSequenceBytes: budget))
            checks.batch(decoder.feed([UInt8(0x1b), 0x5b, 0xc2]), RichText(""),
                [(AnsiTextIssue.MalformedSequence, 0)], "incomplete sequence prefix")
            checks.batch(decoder.feed([UInt8(0xa0)]), RichText(""), [], "complete scalar still quarantined")
            checks.batch(decoder.finish(), RichText(""), [(AnsiTextIssue.IncompleteSequence, 0)],
                "finish appends incomplete only after first malformed")
            checks.closed(decoder, "incomplete sequence finish")
        })
    }
}

func csiUtf8Normal(checks: CsiUtf8Checks): Unit {
    checks.run("normal UTF8 C1 introducer and ordinary continuation", { =>
        let decoder = AnsiTextDecoder()
        checks.batch(decoder.feed([UInt8(0xc2)]), RichText(""), [], "Normal pending C2 is not CSI syntax")
        checks.batch(decoder.feed([UInt8(0x9b), 0x33, 0x31, 0x6d, 0x58]),
            RichText([TextSpan("X", style: TextStylePatch(foreground: Some(Color.Red)))]), [],
            "Normal UTF8 C1 applies red SGR")
        checks.batch(decoder.finish(), RichText(""), [], "normal C1 finish")
        checks.closed(decoder, "normal C1")
        everySplit([UInt8(0xd2), 0x9b, 0x33, 0x31, 0x6d, 0x58], RichText("қ31mX"), [],
            "Normal non-C1 continuation never starts SGR")
        everySplit([UInt8(0xc2), 0x9b, 0x33, 0x31, 0x6d, 0x58],
            RichText([TextSpan("X", style: TextStylePatch(foreground: Some(Color.Red)))]), [],
            "Normal UTF8 C1 remains valid at every cut")
    })
}

func csiUtf8FirstFaultContract(): Unit {
    let checks = CsiUtf8Checks()
    csiUtf8Immediate(checks)
    csiUtf8FirstFault(checks)
    csiUtf8Validation(checks)
    csiUtf8Normal(checks)
    println("CSI UTF8 first-fault regression failures: ${checks.failures}")
    check(checks.failures == 0, "CSI UTF8 first-fault regression")
    println("PASS: CSI UTF8 immediate first fault, quarantine and validation")
}
