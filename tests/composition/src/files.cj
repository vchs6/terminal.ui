package composition_contract

import cjtui.*
import std.env.*
import std.fs.*
import std.io.*

func fileFailure(action: () -> Unit, name: String): Unit {
    var caught = false
    try { action() } catch (_: FSException) { caught = true }
    check(caught, name)
}

func writeFailure(action: () -> Unit, name: String): Unit {
    var caught = false
    try { action() }
    catch (_: FSException) { caught = true }
    catch (_: IOException) { caught = true }
    check(caught, name)
}

func files(): Unit {
    let directory = getVariable("CJTUI_COMPOSITION_ARTIFACTS").getOrThrow()
    let base = Frame(4, 2)
    base.put(0, 0, "ABCD\nWXYZ")
    let layer = Frame(4, 2, transparent: true)
    layer.put(0, 0, "中")
    layer.put(0, 1, " ")
    layer.put(1, 1, "e\u{301}", style: Style(foreground: Color.Rgb(255, 0, 0)))
    layer.fillRect(Rect(2, 1, 2, 1))
    base.composite(layer)
    snapshot(base, "中CD\n e\u{301}  ", "file scene is full composed grid with wide and combining clusters")
    base.writePlainText(directory + "/plain-created.txt")
    base.writePlainText(directory + "/plain-replaced.txt")
    base.writeAnsi(directory + "/ansi-default.txt")
    base.writeAnsi(directory + "/ansi-true.txt", colorMode: ColorMode.TrueColor)
    base.writeAnsi(directory + "/ansi-basic8.txt", colorMode: ColorMode.Basic8)
    base.writeAnsi(directory + "/ansi-mono.txt", colorMode: ColorMode.Monochrome)
    let transparent = Frame(2, 1, transparent: true)
    transparent.writePlainText(directory + "/transparent-plain.txt")
    transparent.writeAnsi(directory + "/transparent-ansi.txt")
    let empty = Frame(Int64.Max, 0)
    empty.writePlainText(directory + "/empty-plain.txt")
    empty.writeAnsi(directory + "/empty-ansi.txt")
    Frame(0, 4, maxCells: 3).writePlainText(directory + "/zero-width-plain.txt")
    Frame(0, 5, maxCells: 3).writeAnsi(directory + "/zero-width-ansi.txt")
    fileFailure({ => base.writePlainText(directory + "/missing-parent/plain.txt") },
        "plain file missing parent throws standard file exception")
    fileFailure({ => base.writeAnsi(directory + "/missing-parent/ansi.txt") },
        "ANSI file missing parent throws standard file exception")
    fileFailure({ => base.writePlainText(directory + "/existing-directory") },
        "plain directory target throws standard file exception")
    fileFailure({ => base.writeAnsi(directory + "/existing-directory") },
        "ANSI directory target throws standard file exception")
    illegal({ => Frame(0, 5, maxCells: 3).writePlainText(directory + "/budget-sentinel.txt") },
        "plain LF budget rejected before opening existing target")
    illegal({ => Frame(0, 5, maxCells: 3).writePlainText(directory + "/budget-created.txt") },
        "plain LF budget rejected before creating target")
    if (getVariable("CJTUI_COMPOSITION_DEV_FULL") == Some("1")) {
        writeFailure({ => base.writePlainText("/dev/full") }, "plain actual write failure propagates from /dev/full")
        writeFailure({ => base.writeAnsi("/dev/full") }, "ANSI actual write failure propagates from /dev/full")
    } else {
        println("SKIP: /dev/full unavailable; deterministic open failures still required")
    }
    invariants(base, "file scene")
}
