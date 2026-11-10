package keyboard_device
import cjtui.*
import std.env.*
import std.fs.*

func record(directory: String, name: String, value: String): Unit {
    File.writeTo(directory + "/" + name, value.toArray())
}

// No focus/modal imitation: these root-level device cases are only a subset.
// The gate is a real FIFO. Driver acknowledgement orders burst writes before
// the callback returns; timers only bound deadlocks.
main(): Int64 {
    let directory = getVariable("CJTUI_KEYBOARD_HANDSHAKE").getOrThrow()
    let mode = getVariable("CJTUI_KEYBOARD_MODE").getOrThrow()
    let count = [Int64(0)]; let postedAt = [Int64(-1)]
    let root = Text("CJTUI_KEYBOARD_READY")
    let app = Application(root, keyboardLimits: KeyboardLimits())
    root.onMount({ _ => { => record(directory, "cleanup", "once") } })
    app.onKeyboardIssue({ issue =>
        record(directory, "issue", "${issue.offset}")
        if (mode == "issue-throws") { throw Exception("KEYBOARD_ISSUE_SENTINEL") }
    }).onKeyEvent({ event =>
        let key = event.key
        if (key.code == "paste") {
            checkDevice(key.text == "a\u{3}\u{1b}[A\nb" && !key.ctrl && !key.alt && !key.shift,
                "paste raw payload and modifiers")
            count[0]++
            record(directory, "paste", "${count[0]}")
        }
        if (key.code == "interrupt" && (mode == "prevent" || mode == "signal" || mode == "signal-term")) {
            event.preventDefault(); record(directory, "prevent", "alive")
        }
        if (key.code == "text" && key.text == "a" && mode == "fairness") {
            count[0]++
            if (count[0] == 1) {
                checkDevice(app.post({ => postedAt[0] = count[0]; record(directory, "post", "${postedAt[0]}") }), "post accepted")
                record(directory, "gate-entered", "first-a")
                let release = String.fromUtf8(File.readFrom(directory + "/release.fifo"))
                checkDevice(release == "release", "FIFO ordering handshake")
            }
        }
        if (key.code == "text" && key.text == "g") {
            record(directory, "gate-entered", "g")
            let release = String.fromUtf8(File.readFrom(directory + "/release.fifo"))
            checkDevice(release == "release", "FIFO release")
        }
        if (key.code == "text" && key.text == "q") {
            if (mode == "fairness") {
                checkDevice(count[0] == 8193 && postedAt[0] >= 1 && postedAt[0] <= 4096,
                    "4096 byte turn permits queued post before remaining flood")
            }
            if (mode == "paste") { checkDevice(count[0] == 1, "one atomic paste") }
            app.stop()
        }
        if (key.code == "text" && key.text == "e") { throw Exception("KEYBOARD_CALLBACK_SENTINEL") }
    })
    try { app.run() } catch (error: Exception) {
        record(directory, "error", error.message)
        throw error
    }
    let stats = app.stats()
    checkDevice(stats.mountedNodes == 0 && stats.activeBindings == 0 && stats.subscriptions == 0 && stats.pendingPosts == 0,
        "session resources released")
    record(directory, "returned", "normal")
    0
}

func checkDevice(value: Bool, message: String): Unit {
    if (!value) { throw Exception("FAIL keyboard device ${message}") }
}
