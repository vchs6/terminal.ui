package output_recovery

import cjtui.*
import std.env.*
import std.fs.*
import std.convert.*

func live(directory: String): Unit {
    let scenario = getVariable("CJTUI_RECOVERY_CASE") ?? "frame"
    let text = Observable<String>("Aé")
    let emphasis = Observable<Bool>(false)
    let pos = Observable<Int64>(0)
    let dirty = Observable<Int64>(0)
    let cleaned = Box<Int64>(0)
    let root = Canvas({ _ => Size(4, 1) }, { p =>
        dirty.get()
        p.put(0, 0, text.get(), patch: if (emphasis.get()) {
            TextStylePatch(foreground: Some(Color.Rgb(1, 128, 254)), bold: Some(true))
        } else { TextStylePatch() })
        if (scenario == "caret") { p.caret(pos.get(), 0) }
    }).focusable(true)
    root.onMount({ _ => { =>
        cleaned.value++
        if (getVariable("CJTUI_RECOVERY_UI_FAIL") == Some("1")) { throw Exception("OUTPUT_UI_CLEANUP_SENTINEL") }
    } })
    let app = Application(root, theme: plainTheme()).sessionOptions(SessionOptions(
        title: SessionPolicy.DeclaredSupported, titleStack: SessionPolicy.DeclaredSupported,
        clipboard: SessionPolicy.DeclaredSupported))
    app.onKey({ e =>
        if (e.text == "x") {
            unsafe { cjt_test_arm(Int32.parse(getVariable("CJTUI_RECOVERY_MODE") ?? "0"),
                Int64.parse(getVariable("CJTUI_RECOVERY_OFFSET") ?? "0"),
                Int32.parse(getVariable("CJTUI_RECOVERY_TARGET") ?? "1")) }
            if (scenario == "caret") { pos.set(2) }
            else if (scenario == "title") { app.setHostTitle("é") }
            else if (scenario == "clipboard") { app.copyLocalText("é") }
            else if (scenario == "style") { emphasis.set(true) }
            else { text.set("é") }
        }
        if (e.text == "s") { dirty.set(dirty.get() + 1) }
        if (e.text == "c") { app.colorMode(ColorMode.Monochrome) }
        if (e.text == "h") { File.writeTo(directory + "/ack", "yes".toArray()) }
        if (e.text == "e") { throw Exception("OUTPUT_CALLBACK_SENTINEL") }
        if (e.text == "q") { app.stop() }
    })
    var failed = false
    var primary = ""
    var extras = ""
    try { app.run() } catch (error: Exception) {
        failed = true
        primary = error.message
        if (let Some(aggregate) <- (error as UICleanupException)) {
            primary = aggregate.primary.message
            for (item in aggregate.cleanupFailures) { extras += item.message + "\n" }
        }
    }
    let stats = app.stats()
    File.writeTo(directory + "/result", "${failed}\n${primary}\n${cleaned.value}\n${stats.mountedNodes}/${stats.activeBindings}/${stats.subscriptions}/${stats.pendingPosts}\n${extras}".toArray())
    if (failed && getVariable("CJTUI_RECOVERY_REOPEN") == Some("1")) {
        let nextRoot = Text("SECOND_RUN")
        let next = Application(nextRoot, theme: plainTheme())
        nextRoot.onMount({ _ => next.post({ => next.stop() }); { => } })
        var refused = false
        var errorMessage = ""
        try { next.run() } catch (error: Exception) { refused = true; errorMessage = error.message }
        File.writeTo(directory + "/reopen", "${refused}\n${errorMessage}".toArray())
    }
}
