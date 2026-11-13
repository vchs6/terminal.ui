package editing_review_probe
import cjtui.*

class Trace { var value: String = "" }
main(): Int64 {
    let plain = render(TextInput(Observable<String>("abc")), 3, 1).toPlainText()
    println("DETACHED expected=[abc] actual=[${plain}]")
    let source = Observable<String>("abc")
    let ctl = TextEditController()
    let trace = Trace()
    let root = Column {
        TextInput(source, controller: Some(ctl)).height(1)
        Text({ =>
            if (ctl.isValid()) {
                let s = ctl.snapshot()
                trace.value = s.text + "@${s.selection.caret}"
                trace.value
            } else { "detached" }
        }).height(1)
    }
    let app = Application(root)
    app.startHeadless()
    try {
        app.snapshot(12, 2)
        app.batch({ => ctl.select(TextSelection(2,2)); source.set("Z") })
        let stable = ctl.snapshot()
        println("TRACKING expected=[Z@1] getter=[${trace.value}] controller=[${stable.text}@${stable.selection.caret}]")
        println("TRACKING_FRAME=[${app.snapshot(12,2).toPlainText()}]")
    } finally { app.dispose() }
    let navigation = TextEditController()
    let area = TextArea(Observable<String>("ab\n12345\nXY"), controller: Some(navigation))
    let navApp = Application(area)
    navApp.startHeadless()
    try {
        navApp.snapshot(12,3)
        navApp.batch({ => navigation.select(TextSelection(1,1)); navigation.replaceSelection("!"); navigation.select(TextSelection(8,8)) })
        navApp.dispatch(area.reference().getOrThrow(), KeyEvent("down"))
        navApp.batch({ => navigation.undo() })
        println("UNDO_RESTORED caret=${navigation.snapshot().selection.caret}")
        navApp.dispatch(area.reference().getOrThrow(), KeyEvent("down"))
        println("UNDO_DOWN expected=4 actual=${navigation.snapshot().selection.caret}")
    } finally { navApp.dispose() }
    0
}
