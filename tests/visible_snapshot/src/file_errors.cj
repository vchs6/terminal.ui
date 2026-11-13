package visible_snapshot

import cjtui.*
import std.env.*
import std.fs.*
import std.io.*

func fileError(action: () -> Unit, name: String): Unit {
    var result = "NO_ERROR"
    try { action() }
    catch (error: IllegalArgumentException) { result = "IllegalArgumentException: ${error}" }
    catch (error: FSException) { result = "FSException: ${error}" }
    catch (error: IOException) { result = "IOException: ${error}" }
    check(result != "NO_ERROR", "${name} must throw actual SDK file error")
    println("FILE_ERROR ${name} ${result}")
}

func fileErrors(): Unit {
    let app = Application(Text("é中"), theme: bareTheme()); app.startHeadless()
    try {
        let frame = app.snapshot(3, 1)
        let output = getVariable("CJTUI_VISIBLE_SNAPSHOT_FILES").getOrThrow()
        for (ansi in [false, true]) {
            let label = if (ansi) { "ANSI" } else { "plain" }
            for (path in [output + "/existing-directory", output + "/missing-parent/out", output + "/nul\u{0}suffix"]) {
                fileError({ => if (ansi) { frame.writeAnsi(path) } else { frame.writePlainText(path) } }, "${label} invalid path")
            }
            let denied = getVariable("CJTUI_VISIBLE_SNAPSHOT_DENIED").getOrThrow()
            fileError({ => if (ansi) { frame.writeAnsi(denied) } else { frame.writePlainText(denied) } }, "${label} unwritable real path")
            // Linux /dev/full exercises a real post-open write failure, not a mock.
            fileError({ => if (ansi) { frame.writeAnsi("/dev/full") } else { frame.writePlainText("/dev/full") } }, "${label} actual write failure")
        }
    } finally { app.dispose() }
}

func zeroSnapshots(): Unit {
    let app = Application(Text("x"), theme: bareTheme()); app.startHeadless()
    try {
        let zeroWidth = app.snapshot(0, 2)
        save(zeroWidth, "\n", [Array<ExpectedCell>(), Array<ExpectedCell>()], "zero-width")
        let zeroHeight = app.snapshot(3, 0)
        check(zeroHeight.width == 3 && zeroHeight.height == 0, "zero height keeps requested dimensions")
        save(zeroHeight, "", Array<Array<ExpectedCell>>(), "zero-height")
        save(app.snapshot(0, 0), "", Array<Array<ExpectedCell>>(), "zero-both")
    } finally { app.dispose() }
}

// The test launcher applies RLIMIT_FSIZE=32 and ignores SIGXFSZ, so real regular
// files accept a positive prefix and then fail. No SDK/product writer is mocked.
func shortFileErrors(): Unit {
    let app = Application(Text("short write fixture").width(256), theme: bareTheme()); app.startHeadless()
    try {
        let frame = app.snapshot(256, 1)
        let output = getVariable("CJTUI_VISIBLE_SNAPSHOT_FILES").getOrThrow()
        fileError({ => frame.writePlainText(output + "/short.txt") }, "plain positive-prefix short write")
        fileError({ => frame.writeAnsi(output + "/short.ansi") }, "ANSI positive-prefix short write")
    } finally { app.dispose() }
}
