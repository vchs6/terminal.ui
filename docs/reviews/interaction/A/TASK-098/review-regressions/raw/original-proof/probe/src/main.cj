package interaction_review_probe
import cjtui.*
import std.collection.ArrayList
import std.env.getCommandLine
func plain(): Theme {Theme.parse("schema_version=1\nname=\"probe\"\n")}
func measureDependencies(): Unit {
    let width=Observable<Int64>(1)
    let root=Row {
        Canvas({bounds=>if(bounds.maxWidth.isNone()){Size(width.get(),1)}else{bounds.constrain(Size(1,1))}}, {p=>p.put(0,0,"C")})
        Text("B")
    }
    let app=Application(root,theme:plain());app.startHeadless()
    let initial=app.snapshot(5,1).toPlainText()
    let subs=app.stats().subscriptions
    width.set(3)
    let actual=app.snapshot(5,1).toPlainText()
    let reference=render(root,5,1).toPlainText()
    println("MEASURE initial=[${initial}] subscriptions=${subs} after=[${actual}] M1=[${reference}]")
    app.dispose()
}
func focusGeometry(): Unit {
    let children=ArrayList<Component>()
    let root=Column {
        children.add(Text("A").focusable(true))
        children.add(Text("abcd").width(4).wrap(TextWrap.Grapheme).focusable(true)
            .setStyle(StyleKeys.width,StyleValue<Dimension>.Value(Dimension.Cells(1)),state:VisualState.Focused))
        Text("Z")
    }
    let app=Application(root,theme:plain());app.startHeadless();app.snapshot(4,6)
    app.batch({=>children[1].reference().getOrThrow().requestFocus()})
    println("FOCUS_GEOMETRY cached\n"+app.snapshot(4,6).toPlainText())
    println("FOCUS_GEOMETRY M1\n"+render(root,4,6).toPlainText())
    app.dispose()
}
func budgetAndQueries(): Unit {
    let nodes=ArrayList<Component>();let root=Column{nodes.add(Text("A").focusable(true));nodes.add(Text("B").focusable(true))}
    let app=Application(root,theme:plain(),limits:RuntimeLimits(structuralOpsPerBatch:1));app.startHeadless()
    try {app.batch({=>nodes[0].reference().getOrThrow().requestFocus();nodes[1].reference().getOrThrow().requestFocus()});println("FOCUS_BUDGET two_requests_accepted")}
    catch(e:UIException){println("FOCUS_BUDGET error=${e.code}")}
    app.dispose()
    let hidden=Text("x").visible(false).enabled(true);let other=Application(hidden,theme:plain());other.startHeadless()
    let ref=hidden.reference().getOrThrow();println("HIDDEN_QUERY visible=${ref.isVisible()} enabled=${ref.isEnabled()}");other.dispose()
}
func cancelledFocus(): Unit {
    let nodes=ArrayList<Component>();let root=Column { nodes.add(Text("A").focusable(true)); nodes.add(Text("B").focusable(true)) }
    let app=Application(root,theme:plain());app.startHeadless()
    try {app.batch({=>nodes[1].reference().getOrThrow().requestFocus();root.reference().getOrThrow().remove(nodes[1].reference().getOrThrow())});println("UNMOUNT_FOCUS cancelled_successfully")}
    catch(e:UIException){println("UNMOUNT_FOCUS error=${e.code}")}
    app.dispose()
}
func canvasLeaf(): Unit {
    let leaf=Canvas({_=>Size(1,1)},{p=>p.put(0,0,"C")});let child=Text("hidden child").focusable(true)
    let app=Application(leaf,theme:plain());app.startHeadless()
    try {app.batch({=>leaf.reference().getOrThrow().append(child)});println("CANVAS_LEAF children=${leaf.reference().getOrThrow().children().size} focused_child=${app.focusedNode().getOrThrow().sameNode(child.reference().getOrThrow())} frame=[${app.snapshot(5,1).toPlainText()}]")}
    catch(e:UIException){println("CANVAS_LEAF error=${e.code}")}
    app.dispose()
}
func clockFailure(): Unit {
    let trace=Box<String>("");let app=Application(Text("x"),theme:plain())
    app.onKey({e=>trace.value+=e.code+",";if(e.code=="escape"){app.stop()}})
    app.run()
    println("CLOCK_EVENTS="+trace.value)
    println("CLOCK_STATUS="+app.terminalCapabilities().getOrThrow().cursorVisibilityStatus)
}
main(): Int64 {
    if(getCommandLine().contains("--clock")){clockFailure()}
    else {measureDependencies();focusGeometry();budgetAndQueries();cancelledFocus();canvasLeaf()}
    0
}
