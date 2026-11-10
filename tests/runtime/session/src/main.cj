package runtime_session

import cjtui.*
import std.env.*
import std.fs.*

func writeStats(directory: String, name: String, value: RuntimeStats): Unit {
    File.writeTo(directory + "/" + name,
        "${value.builds},${value.measures},${value.paints},${value.frames}".toArray())
}

func writeCounts(directory: String, name: String, counts: Array<Int64>): Unit {
    File.writeTo(directory + "/" + name,
        "${counts[0]},${counts[1]},${counts[2]},${counts[3]}".toArray())
}

main(): Int64 {
    let directory = getVariable("CJTUI_RUNTIME_HANDSHAKE").getOrThrow()
    let mode = getVariable("CJTUI_RUNTIME_MODE").getOrThrow()
    let counts: Array<Int64> = [0, 0, 0, 0]
    let cleaned = [0]
    let root = Column {
        Text({ =>
            if (mode == "bind") { throw Exception("CJTUI_BIND_SENTINEL") }
            "CJTUI_RUNTIME_READY"
        })
        Text("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        if (mode == "idle-cpu") {
            for (_ in 0..2048) { Text({ => "pure-getter" }) }
        }
    }.onKeyCapture({ _ => counts[0]++ }).onKey({ _ => counts[1]++ })
    let app = Application(root, colorMode: ColorMode.Basic16)
    let otherRoot = Text("other")
    let other = Application(otherRoot)
    if (mode == "hidden-cross-session") { other.startHeadless() }
    root.onMount({ _ =>
        if (mode == "mount") { throw Exception("CJTUI_MOUNT_SENTINEL") }
        { =>
            cleaned[0]++
            File.writeTo(directory + "/cleanup", "${cleaned[0]}".toArray())
            if (mode.contains("cleanup")) { throw Exception("CJTUI_CLEANUP_SENTINEL") }
        }
    })
    app.onKeyEvent({ event =>
        counts[2]++
        if (event.key.code == "interrupt" && mode == "prevent") {
            event.preventDefault()
            writeCounts(directory, "prevent", counts)
        }
    }).onKey({ event =>
        counts[3]++
        if (event.code == "interrupt") { throw Exception("legacy received interrupt") }
        if (event.text == "a" || event.text == "b") { writeStats(directory, event.text, app.stats()) }
        if (event.text == "h") { root.visible(false); writeCounts(directory, "h", counts) }
        if (event.text == "x") {
            if (mode == "hidden-cross-session" || mode == "hidden-reentrant") {
                var observed = "accepted"
                try {
                    if (mode == "hidden-cross-session") { other.snapshot(5, 1) }
                    else { app.snapshot(5, 1) }
                } catch (error: UIException) { observed = error.code }
                File.writeTo(directory + "/context", observed.toArray())
            }
            writeCounts(directory, "x", counts)
        }
        if (event.text == "e") { throw Exception("CJTUI_CALLBACK_SENTINEL") }
        if (event.text == "q") { app.stop() }
    })
    try { app.run() } catch (error: Exception) {
        File.writeTo(directory + "/error", error.message.toArray())
        throw error
    }
    let after = app.stats()
    if (after.mountedNodes != 0 || after.activeBindings != 0 || after.subscriptions != 0 || after.pendingPosts != 0) {
        throw Exception("disposed run retained resources")
    }
    if (mode == "hidden-cross-session") {
        if (!otherRoot.reference().getOrThrow().isValid() || other.snapshot(5, 1).toPlainText() != "other") {
            throw Exception("rejected hidden callback damaged other session")
        }
        other.dispose()
        File.writeTo(directory + "/other-restored", "usable".toArray())
    }
    return 0
}
