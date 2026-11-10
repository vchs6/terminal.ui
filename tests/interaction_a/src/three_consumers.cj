package interaction_a_contract
import cjtui.*
// Three public compositions; no framework widget kind or terminal writes.
func threeConsumers(): Unit {
    let clicks = Box<Int64>(0)
    let buttonFactory = { => Text("B").focusable(true).enabled({ => true }).defaultAction({ e =>
        if (e.key.code == "enter" || e.key.text == " ") { clicks.value++; e.preventDefault() }
    }) }
    let progress = Observable<Int64>(1)
    let barFactory = { => Canvas({ c => c.constrain(Size(3,1)) }, { p =>
        p.fill(Rect(0,0,3,1)); p.put(0,0,if (progress.get() == 1) { "#.." } else { "##." })
    }) }
    let caretFactory = { => Canvas({ c => c.constrain(Size(3,1)) },{ p => p.put(0,0,"xy "); p.caret(2,0) })
        .focusable({ => true }).enabled(true) }
    let (root,nodes) = group([buttonFactory,barFactory,caretFactory])
    let button=nodes[0]; let caret=nodes[2]
    let app = Application(root, theme: plainTheme()); app.startHeadless()
    focus(app,button)
    app.dispatch(ref(button),KeyEvent("enter")); check(clicks.value == 1,"button activates once")
    app.snapshot(3,3)
    progress.set(2)
    check(app.snapshot(3,3).toPlainText() == "B  \n##.\nxy ","three compositions and automatic repaint")
    app.batch({ => ref(caret).requestFocus() }); app.snapshot(3,3)
    let s = app.caretSnapshot()
    check(s.visible && s.owner.getOrThrow().sameNode(ref(caret)) && s.x == 2 && s.y == 2,"input public caret")
    app.dispose(); empty(app)
}
