package widgets_composite_device

import std.env.getVariable
import std.fs.File
import cjtui.*

main(): Int64 {
    let directory = getVariable("CJTUI_COMPOSITE_OUTPUT").getOrThrow()
    let mode = getVariable("CJTUI_COMPOSITE_MODE").getOrThrow()
    let report = {name: String, value: String => File.writeTo(directory + "/" + name, value.toArray())}
    let model = Observable<String>("old")
    let escapes = [0]
    let cleanups = [0];
    let calls = [0];
    let chosen = [""];
    let focusTrace = [""]
    let held = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
    let nested = Array<?OverlayHandle>(1, repeat: Option<OverlayHandle>.None)
    let popupRoot = Array<?Component>(1, repeat: Option<Component>.None)
    let nestedRoot = Array<?Component>(1, repeat: Option<Component>.None)
    let menuSlot = Array<?Component>(1, repeat: Option<Component>.None)
    let root = SplitPane(axis: SplitAxis.Vertical) {
        Text("M_WIDGETS_READY")
        menuSlot[0] = Some(
            HorizontalMenu(
                [MenuEntry("a", "A"), MenuEntry("b", "B", enabled: false), MenuEntry("c", "C")],
                {
                    key =>
                        calls[0]++
                        if (mode == "callback-failure") {
                            throw Exception("M_NATIVE_CALLBACK_SENTINEL")
                        }
                        chosen[0] += "h:" + key + ";"
                        report("chosen", chosen[0])
                }
            )
        )
        ScrollView {
            Text(
                {
                    =>
                        if (model.get() == "bad") {
                            throw Exception("M_NATIVE_GETTER_SENTINEL")
                        }
                        model.get()
                }
            )
        }.height(1)
        StatusBar {Text({=> model.get()})}
    }.onMount({_ => {=> cleanups[0]++}})
    let menu = menuSlot[0].getOrThrow()
    let app = Application(root)
    app.onKeyEvent(
        {
            event =>
                if (event.key.code == "escape") {
                    escapes[0]++;
                    report("escape_seen", "${escapes[0]}")
                }
                if (event.key.code == "text") {
                    match (event.key.text) {
                        case "q" =>
                            event.preventDefault();
                            app.stop()
                        case "u" =>
                            event.preventDefault();
                            model.set("NEW")
                        case "g" =>
                            event.preventDefault();
                            model.set("bad")
                        case "o" | "e" =>
                            event.preventDefault()
                            let explicitClose = event.key.text == "e"
                            let popup = PopupMenu(
                                [MenuEntry("p", "P"), MenuEntry("x", "X", enabled: false), MenuEntry("r", "R")],
                                {
                                    key =>
                                        calls[0]++;
                                        chosen[0] += "p:" + key + ";"
                                        report("chosen", chosen[0])
                                        if (explicitClose) {
                                            held[0].getOrThrow().close()
                                        }
                                }
                            )
                            popupRoot[0] = Some(popup)
                            held[0] = Some(
                                root
                                    .reference()
                                    .getOrThrow()
                                    .openOverlay(popup, options: OverlayOptions(mode: OverlayMode.Modal)))
                        case "n" =>
                            event.preventDefault()
                            let child = PopupMenu([MenuEntry("n", "N")], {_ => ()})
                            nestedRoot[0] = Some(child)
                            nested[0] = Some(
                                popupRoot[0]
                                    .getOrThrow()
                                    .reference()
                                    .getOrThrow()
                                    .openOverlay(child, options: OverlayOptions(mode: OverlayMode.Modal)))
                        case "c" =>
                            event.preventDefault();
                            held[0].getOrThrow().close()
                        case "#" =>
                            event.preventDefault()
                            var name = "none"
                            if (let Some(current) <- app.focusedNode()) {
                                let base = menu.reference().getOrThrow().children()
                                if (current.sameNode(base[0])) {
                                    name = "a"
                                }
                                if (current.sameNode(base[2])) {
                                    name = "c"
                                }
                                if (let Some(popup) <- popupRoot[0]) {
                                    if (let Some(ref) <- popup.reference()) {
                                        let children = ref.children()
                                        if (current.sameNode(children[0])) {
                                            name = "p"
                                        }
                                        if (current.sameNode(children[2])) {
                                            name = "r"
                                        }
                                    }
                                }
                                if (let Some(child) <- nestedRoot[0]) {
                                    if (let Some(ref) <- child.reference()) {
                                        if (current.sameNode(ref.children()[0])) {
                                            name = "n"
                                        }
                                    }
                                }
                            }
                            focusTrace[0] += name + ";"
                            report("focus", focusTrace[0])
                            if (let Some(handle) <- held[0]) {
                                report("open", "${handle.isOpen()}")
                                if (let Some(reason) <- handle.closeReason()) {
                                    report("reason", if (reason == OverlayCloseReason.Requested) {
                                        "Requested"
                                    } else {
                                        "Escape"
                                    })
                                }
                            }
                        case _ => ()
                    }
                }
        }
    )
    var caught = ""
    try {
        app.run()
    } catch (error: Exception) {
        caught = error.message
        report("error", caught)
    }
    let stats = app.stats()
    report("summary",
        "calls=${calls[0]}\nchosen=${chosen[0]}\nmodel=${model.get()}\ncleanups=${cleanups[0]}\nresources=${stats.mountedNodes}/${stats.activeBindings}/${stats.subscriptions}/${stats.pendingPosts}\n")
    if (mode == "normal" && caught.isEmpty()) {
        return 0
    }
    if (mode == "callback-failure" && caught.contains("M_NATIVE_CALLBACK_SENTINEL")) {
        return 21
    }
    if (mode == "getter-failure" && caught.contains("M_NATIVE_GETTER_SENTINEL")) {
        return 22
    }
    throw Exception("native mode failed: " + mode + ": " + caught)
}
