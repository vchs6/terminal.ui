package keyboard_contract
import cjtui.*

func illegal(action: () -> Unit, name: String): Unit {
    var rejected = false
    try { action() } catch (_: IllegalArgumentException) { rejected = true }
    check(rejected, name)
}

func closed(action: () -> Unit, name: String): Unit {
    var code = ""
    try { action() } catch (error: KeyboardException) { code = error.code }
    check(code == "DecoderClosed", name)
}

func publicApiCases(): Unit {
    for (value in [0, -1, 16777217]) {
        illegal({ => KeyboardLimits(maxPasteBytes: value); () }, "paste limit rejects ${value}")
    }
    for (value in [0, -1, 4097]) {
        illegal({ => KeyboardLimits(maxSequenceBytes: value); () }, "sequence limit rejects ${value}")
    }
    let upper = KeyboardDecoder(limits: KeyboardLimits(maxPasteBytes: 16777216, maxSequenceBytes: 4096))
    empty(upper.finish(), "upper valid limits")
    let decoder = KeyboardDecoder(); empty(decoder.finish(), "empty finish")
    closed({ => decoder.feed([]); () }, "feed after close")
    closed({ => decoder.timeout(); () }, "timeout after close")
    closed({ => decoder.finish(); () }, "repeat finish")
    let owned = KeyboardDecoder()
    let input: Array<UInt8> = [0xe4, 0xb8]
    empty(owned.feed(input), "pending UTF8 input")
    input[0] = 65; input[1] = 66
    let seen = Observed(); seen.add(owned.feed([0xad])); seen.add(owned.finish())
    seen.expect([KeyEvent("text", text: "中")], [], "feed does not retain mutable caller chunk")
    let arrays = KeyboardDecoder()
    let batch = arrays.feed([65, 0])
    let events = batch.events; let diagnostics = batch.diagnostics
    check(events.size == 1 && diagnostics.size == 1, "alias fixture shape")
    events[0] = KeyEvent("text", text: "changed")
    diagnostics[0] = arrays.feed([0]).diagnostics[0]
    check(batch.events[0].text == "A" && batch.diagnostics[0].offset == 1, "public arrays are defensive snapshots")
    let later = Observed(); later.add(arrays.feed([66])); later.add(arrays.finish())
    later.expect([KeyEvent("text", text: "B")], [], "historical output mutation does not affect decoder")
    let legacy = KeyEvent("interrupt"); let backwards = KeyEvent("backtab")
    check(legacy.text == "" && !legacy.ctrl && !legacy.alt && !legacy.shift && backwards.code == "backtab",
        "legacy named/default constructors remain source compatible")
    // Runtime interrupt/backtab behavior is listed separately as blocked integration.
}
