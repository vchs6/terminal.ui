package keyboard_contract
import cjtui.*

// Breaks caught: per-chunk budget reset, counting terminators as payload,
// releasing drain on idle, committing partial/invalid paste, 03 escaping drain.
func resourceCases(): Unit {
    let start = "\u{1b}[200~".toArray(); let end = "\u{1b}[201~".toArray()
    for (payload in ["", "中😀", "a\u{3}\u{1b}[A\nb", "x\u{1b}[200~y", "\u{1b}[20X", "\u{90}\u{9b}\u{9c}\u{9d}"] ) {
        allSplits(GoldenCase("atomic paste", joined([start, payload.toArray(), end]),
            [KeyEvent("paste", text: payload)]))
    }
    allSplits(GoldenCase("paste boundaries ignore ordinary sequence budget", joined([start, [120], end]),
        [KeyEvent("paste", text: "x")]), limits: KeyboardLimits(maxSequenceBytes: 1))
    allSplits(GoldenCase("invalid UTF8 paste all or nothing", joined([[65], start, [120, 0xe2, 121], end, [66]]),
        [KeyEvent("text", text: "A"), KeyEvent("text", text: "B")],
        issues: [ExpectedIssue(KeyboardIssue.InvalidPasteEncoding, 1)]))
    allSplits(GoldenCase("raw C1 remains invalid paste data not CSI", joined([start, [0x9b, 65], end, [66]]),
        [KeyEvent("text", text: "B")], issues: [ExpectedIssue(KeyboardIssue.InvalidPasteEncoding, 0)]))
    allSplits(GoldenCase("small exact raw paste budget", joined([start, "中x".toArray(), end]),
        [KeyEvent("paste", text: "中x")]), limits: KeyboardLimits(maxPasteBytes: 4))
    allSplits(GoldenCase("small plus one drain no interrupt", joined([[65], start, [120, 120, 120, 120, 3, 10], end, [66]]),
        [KeyEvent("text", text: "A"), KeyEvent("text", text: "B")],
        issues: [ExpectedIssue(KeyboardIssue.PasteTooLarge, 1)]), limits: KeyboardLimits(maxPasteBytes: 4))
    allSplits(GoldenCase("false terminator prefix counts as payload", joined([start, "ab\u{1b}[20X".toArray(), end]), [],
        issues: [ExpectedIssue(KeyboardIssue.PasteTooLarge, 0)]), limits: KeyboardLimits(maxPasteBytes: 6))
    largePasteCases(start, end)
    sequenceBudgetCases()
    unfinishedPasteCases(start, end)
}

func largePasteCases(start: Array<UInt8>, end: Array<UInt8>): Unit {
    let exact = Array<UInt8>(1048576, repeat: 120)
    let decoder = KeyboardDecoder(); let seen = Observed()
    empty(decoder.feed(start), "1MiB begin")
    for (i in 0..256) { empty(decoder.feed(exact.slice(i * 4096, 4096)), "no partial paste") }
    seen.add(decoder.feed(end)); seen.add(decoder.finish())
    seen.expect([KeyEvent("paste", text: String.fromUtf8(exact))], [], "exact 1MiB accepted")
    let over = KeyboardDecoder(); let overSeen = Observed()
    overSeen.add(over.feed(start)); overSeen.add(over.feed(exact)); overSeen.add(over.feed([120]))
    for (_ in 0..12) { empty(over.timeout(), "overlimit paste never idle-releases") }
    overSeen.add(over.feed([3, 27, 10])); overSeen.add(over.feed(end)); overSeen.add(over.feed([65])); overSeen.add(over.finish())
    overSeen.expect([KeyEvent("text", text: "A")], [ExpectedIssue(KeyboardIssue.PasteTooLarge, 0)], "1MiB plus one drains")
}

func sequenceBudgetCases(): Unit {
    asciiCase("64-byte sequence limit ordinary vector", "\u{1b}[A", KeyEvent("up"))
    allSplits(GoldenCase("exact sequence bytes includes introducer and final", "\u{1b}[A".toArray(), [KeyEvent("up")]),
        limits: KeyboardLimits(maxSequenceBytes: 3))
    allSplits(GoldenCase("plus one sequence drains final", "a\u{1b}[12Ab".toArray(),
        [KeyEvent("text", text: "a"), KeyEvent("text", text: "b")],
        issues: [ExpectedIssue(KeyboardIssue.SequenceTooLong, 1)]), limits: KeyboardLimits(maxSequenceBytes: 4))
    let decoder = KeyboardDecoder(limits: KeyboardLimits(maxSequenceBytes: 4)); let seen = Observed()
    seen.add(decoder.feed("\u{1b}[123".toArray()))
    for (_ in 0..3) { empty(decoder.timeout(), "overlong CSI timeout retains drain") }
    seen.add(decoder.feed("456Ab".toArray())); seen.add(decoder.finish())
    seen.expect([KeyEvent("text", text: "b")], [ExpectedIssue(KeyboardIssue.SequenceTooLong, 0)], "drain does not leak digits/final")
    let string = KeyboardDecoder(limits: KeyboardLimits(maxSequenceBytes: 1)); let stringSeen = Observed()
    stringSeen.add(string.feed("\u{1b}]".toArray()))
    for (_ in 0..256) { stringSeen.add(string.feed(Array<UInt8>(4096, repeat: 120))) }
    stringSeen.add(string.feed([7, 65])); stringSeen.add(string.finish())
    stringSeen.expect([KeyEvent("text", text: "A")], [ExpectedIssue(KeyboardIssue.UnsupportedSequence, 0)], "large string one diagnostic no sequence budget")
}

func unfinishedPasteCases(start: Array<UInt8>, end: Array<UInt8>): Unit {
    for (prefixSize in 0..6) {
        let decoder = KeyboardDecoder(); let seen = Observed()
        seen.add(decoder.feed(joined([[65], start, "中\u{3}\n".toArray(), end.slice(0, prefixSize)])))
        for (_ in 0..10) { empty(decoder.timeout(), "unfinished paste never times out") }
        seen.add(decoder.finish())
        seen.expect([KeyEvent("text", text: "A")], [ExpectedIssue(KeyboardIssue.IncompletePaste, 1)], "EOF incomplete paste/end-prefix ${prefixSize}")
    }
    let decoder = KeyboardDecoder(); let seen = Observed()
    seen.add(decoder.feed("a\u{1b}]unfinished".toArray())); seen.add(decoder.finish())
    seen.expect([KeyEvent("text", text: "a")], [ExpectedIssue(KeyboardIssue.UnsupportedSequence, 1),
        ExpectedIssue(KeyboardIssue.IncompleteInput, 1)], "unfinished string adds only EOF diagnostic")
}
