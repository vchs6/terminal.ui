package widgets_small_device

import std.env.getVariable
import std.fs.File
import cjtui.{Application, Button, Checkbox, Column, Label, Observable, Radio}

main(): Int64 {
    let directory = getVariable("CJTUI_SMALL_OUTPUT").getOrThrow()
    let mode = getVariable("CJTUI_SMALL_MODE").getOrThrow()
    let report = {name: String, value: String => File.writeTo(directory + "/" + name, value.toArray())}
    let clicks = [0]
    let boxRequests = [0]
    let radioRequests = [0]
    let cleanups = [0]
    let checked = Observable<Bool>(false)
    let selected = Observable<Bool>(false)
    let caption = Observable<String>("S_WIDGETS_READY")
    let root = Column {
        Label(
            {
                =>
                    if (caption.get() == "bad") {
                        throw Exception("S_NATIVE_GETTER_SENTINEL")
                    }
                    caption.get()
            }
        )
        Button(
            "Go",
            {
                =>
                    if (mode == "callback-failure") {
                        throw Exception("S_NATIVE_CALLBACK_SENTINEL")
                    }
                    if (mode == "getter-failure") {
                        caption.set("bad")
                    }
                    clicks[0]++;
                    report("button", "${clicks[0]}")
            }
        )
        Checkbox(
            {=> checked.get()},
            {
                value =>
                    boxRequests[0]++;
                    checked.set(value);
                    report("checkbox", "${boxRequests[0]}")
            },
            label: "Box"
        )
        Radio(
            {=> selected.get()},
            {
                =>
                    radioRequests[0]++;
                    selected.set(true);
                    report("radio", "${radioRequests[0]}")
            },
            label: "Radio"
        )
    }.onMount({_ => {=> cleanups[0]++}})
    let app = Application(root)
    // The handler is installed after Application construction to capture a let
    // reference, without a mutable local or a second runtime.
    app.onKeyEvent({
        event => if (event.key.code == "text" && event.key.text == "q") {
            event.preventDefault();
            app.stop()
        }
    })
    var caught = ""
    try {
        app.run()
    } catch (error: Exception) {
        caught = error.message
        report("error", caught)
    }
    let stats = app.stats()
    report("summary",
        "clicks=${clicks[0]}\nboxRequests=${boxRequests[0]}\nchecked=${checked.get()}\nradioRequests=${radioRequests[0]}\nselected=${selected.get()}\ncleanups=${cleanups[0]}\nresources=${stats.mountedNodes}/${stats.activeBindings}/${stats.subscriptions}/${stats.pendingPosts}\n")
    if (mode == "normal") {
        if (!caught.isEmpty()) {
            throw Exception("unexpected native failure: " + caught)
        }
        return 0
    }
    if (mode == "callback-failure" && caught.contains("S_NATIVE_CALLBACK_SENTINEL")) {
        return 21
    }
    if (mode == "getter-failure" && caught.contains("S_NATIVE_GETTER_SENTINEL")) {
        return 22
    }
    throw Exception("native failure sentinel missing: " + mode + ": " + caught)
}
