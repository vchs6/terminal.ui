package keyboard_contract
import cjtui.*

func empty(batch: KeyboardBatch, name: String): Unit {
    check(batch.events.size == 0 && batch.diagnostics.size == 0, name)
}

// Direct timeout calls model contract timers, with no wall-clock ordering.
func temporalCases(): Unit {
    let escape = KeyboardDecoder()
    empty(escape.feed([27]), "ESC held")
    let escaped = Observed(); escaped.add(escape.timeout()); escaped.add(escape.finish())
    escaped.expect([KeyEvent("escape")], [], "bare ESC timeout")
    for (bytes in [[UInt8(27)], [UInt8(27), UInt8(91)], [UInt8(0xe4), UInt8(0xb8)]]) {
        let decoder = KeyboardDecoder(); empty(decoder.feed(bytes), "incomplete held")
        let seen = Observed(); seen.add(decoder.finish())
        seen.expect([], [ExpectedIssue(KeyboardIssue.IncompleteInput, 0)], "EOF never synthesizes partial key")
    }
    let utf8 = KeyboardDecoder()
    empty(utf8.feed([0xe4, 0xb8]), "normal UTF8 lead held")
    for (_ in 0..3) { empty(utf8.timeout(), "ordinary UTF8 survives timeout") }
    let complete = Observed(); complete.add(utf8.feed([0xad])); complete.add(utf8.finish())
    complete.expect([KeyEvent("text", text: "中")], [], "UTF8 completion after timeout")
    timeoutRemainderCases()
}

func timeoutRemainderCases(): Unit {
    let alt = KeyboardDecoder(); let altSeen = Observed()
    altSeen.add(alt.feed([65, 27, 0xe4, 0xb8])); altSeen.add(alt.timeout())
    altSeen.add(alt.feed([66])); altSeen.add(alt.finish())
    altSeen.expect([KeyEvent("text", text: "A"), KeyEvent("text", text: "B")],
        [ExpectedIssue(KeyboardIssue.IncompleteInput, 1)], "Alt partial timeout drops whole candidate")
    let csi = KeyboardDecoder(); empty(csi.feed([27, 91, 49]), "CSI held")
    let csiSeen = Observed(); csiSeen.add(csi.timeout()); csiSeen.add(csi.feed([66])); csiSeen.add(csi.finish())
    csiSeen.expect([KeyEvent("text", text: "B")], [ExpectedIssue(KeyboardIssue.IncompleteInput, 0)], "CSI idle recovers")
    let string = KeyboardDecoder(); let seen = Observed()
    seen.add(string.feed("a\u{1b}]secret".toArray()))
    for (_ in 0..5) { empty(string.timeout(), "OSC timeout cannot leak payload") }
    seen.add(string.feed("HIDDEN\u{7}b".toArray())); seen.add(string.finish())
    seen.expect([KeyEvent("text", text: "a"), KeyEvent("text", text: "b")],
        [ExpectedIssue(KeyboardIssue.UnsupportedSequence, 1)], "OSC quarantine survives many polls")
}
