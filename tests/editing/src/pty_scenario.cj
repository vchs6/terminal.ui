package editing_contract
import cjtui.*
import std.env.getVariable
import std.fs.File

// Actual Application.run only: the driver owns real PTY/OSpipe/FIFO handshakes.
func liveEditing(mode: String): Unit {
    let directory = getVariable("CJTUI_EDITING_OUTPUT").getOrThrow()
    let report = {name: String, text: String => File.writeTo(directory + "/" + name, text.toArray())}
    let source = Observable<String>(if (mode == "cut-race") { ascii(65536) } else if (mode == "sent") { "copy me" } else { "" })
    let other = Observable<String>(""); let c = TextEditController(); let b = TextEditController()
    let first = Box<?Component>(Option<Component>.None); let second = Box<?Component>(Option<Component>.None); let holder = Box<?Application>(Option<Application>.None)
    let changes = Box<Int64>(0); let issues = Box<String>(""); let keyboard = Box<String>("")
    let results = Box<String>("")
    let receive = {e: UIKeyEvent =>
        if (e.key.code == "text" && e.key.text == "q") { e.preventDefault(); holder.value.getOrThrow().stop() }
        if (e.key.code == "text" && e.key.text == "u" && mode == "paste") {
            e.preventDefault()
            check(c.undo(), "one complete paste undo")
            state(c, "", 0, 0, false, true, "paste undo restores original selection")
            check(c.redo(), "one complete paste redo")
            state(c, "A\n中", 3, 3, true, false, "paste redo restores transaction")
            report("undone", "one undo and redo")
        }
        if (e.key.code == "text" && e.key.text == "c" && (mode == "sent" || mode == "cut-race")) {
            e.preventDefault(); c.select(if (mode == "sent") { TextSelection(0, 4) } else { TextSelection(0, 65536) })
            let app = holder.value.getOrThrow()
            if (mode == "sent") {
                let copied = c.copy().getOrThrow()
                check(copied.status == SessionStatus.SentUnconfirmed && isCopy(copied) && issues.value == "", "real Direct copy Sent no issue")
                let cut = c.cut().getOrThrow()
                let ordinary = app.copyLocalText("direct")
                check(cut.status == SessionStatus.SentUnconfirmed && ordinary.status == SessionStatus.SentUnconfirmed,
                    "actual Direct cut and independent copy")
                state(c, "copy me", 0, 4, false, false, "Sent retains selection/history")
                check(issues.value == "CutUnconfirmed;" && changes.value == 0, "one cut issue no copy issue")
                results.value = "SentUnconfirmed/SentUnconfirmed/SentUnconfirmed"
            } else {
                let cut = c.cut().getOrThrow()
                report("copy-returned", "returned")
                check(cut.status == SessionStatus.SentUnconfirmed && source.get() == "worker", "actual blocked writer source changed")
                check(issues.value == "CutUnconfirmed;" && changes.value == 0,
                    "Sent priority no CutStale/ConcurrentValueChanged overlay")
                results.value = "SentUnconfirmed/source-changed"
            }
            check(app.post({ => report("completed", "copy"); app.stop() }), "copy result later-turn completion")
        }
    }
    let root = Column {
        Text("CJTUI_EDITING_READY")
        first.value = Some(TextArea(source, controller: Some(c), onChange: {_ => changes.value++; report("changed", "yes")},
            onIssue: {issue =>
                issues.value += if (issue == TextEditIssue.CutUnconfirmed) { "CutUnconfirmed;" }
                    else if (issue == TextEditIssue.ControlCharacterRejected) { "ControlCharacterRejected;" } else { "unexpected;" }
                report("editor-issue", issues.value)
            }).height(2).onKey(receive))
        second.value = Some(TextArea(other, controller: Some(b), onChange: {_ => changes.value++; report("changed", "yes")}).height(2).onKey(receive))
    }.viewport(ScrollAxes.Off)
    let app = Application(root).sessionOptions(SessionOptions(route: SessionRoute.Direct))
    holder.value = Some(app)
    app.onKeyboardIssue({d =>
        keyboard.value += match (d.kind) { case KeyboardIssue.PasteTargetUnavailable => "PasteTargetUnavailable;"
            case KeyboardIssue.IncompletePaste => "IncompletePaste;"; case _ => "unexpected;" }
        report("keyboard-issue", keyboard.value)
    })
    let needsWorker = mode == "focus" || mode == "unmount" || mode == "modal" || mode == "cut-race"
    let worker = spawn {
        if (needsWorker) {
            let command = String.fromUtf8(File.readFrom(directory + "/release.fifo"))
            if (mode == "cut-race") {
                check(command == "source", "real sink-released source writer")
                source.set("worker")
                File.writeTo(directory + "/ack.fifo", "set".toArray())
            } else {
                check(command == "mutate", "real prefix-consumed mutation request")
                check(app.post({ =>
                    if (mode == "focus") { ref(second.value.getOrThrow()).requestFocus() }
                    else if (mode == "unmount") { ref(root).remove(ref(first.value.getOrThrow())) }
                    else { ref(root).openOverlay(Text("modal").focusable(true).onKey(receive),
                        options: OverlayOptions(mode: OverlayMode.Modal)); () }
                    report("mutated", mode)
                }), "real worker posts UI mutation")
            }
        }
    }
    try { app.run() }
    finally { worker.get(Duration.second * 10) }
    if (mode == "paste") { check(source.get() == "A\n中" && changes.value == 3 && issues.value == "", "PTY paste plus one undo/redo notifications") }
    if (mode == "focus") { check(source.get() == "X" && other.get() == "" && changes.value == 1, "paste retains begin target despite focus change") }
    if (mode == "unmount" || mode == "modal") { check(source.get() == "" && other.get() == "" && changes.value == 0 && keyboard.value == "PasteTargetUnavailable;", "invalidated target never falls through") }
    if (mode == "reject") { check(source.get() == "" && changes.value == 0 && issues.value == "ControlCharacterRejected;", "bad paste rejected once") }
    if (mode == "eof") { check(source.get() == "" && changes.value == 0 && keyboard.value == "IncompletePaste;", "EOF incomplete paste no editor transaction") }
    if (mode == "cut-race") { check(source.get() == "worker" && changes.value == 0, "unconfirmed cut cannot delete concurrent source") }
    report("summary", "source=" + source.get() + "\nother=" + other.get() + "\nchanges=${changes.value}\nissues=${issues.value}\nkeyboard=${keyboard.value}\nresults=${results.value}\n")
    let stats = app.stats()
    check(stats.mountedNodes == 0 && stats.activeBindings == 0 && stats.subscriptions == 0 && stats.pendingPosts == 0, "actual run cleanup")
    report("returned", "normal")
}
