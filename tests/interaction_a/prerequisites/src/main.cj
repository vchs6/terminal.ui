package interaction_a_contract
import cjtui.*
main():Int64 {
    let inactive=Application(Text("inactive"))
    if(inactive.copyLocalText("x").issue!=SessionIssue.SessionInactive){throw Exception("accepted Session152 API positive")}
    let text=Observable<RichText>(RichText([TextSpan("e\u{301}X",style:TextStylePatch(bold:Some(true)))]))
    let root=Column {Text({=>text.get()})}
    let value=Theme.parse("schema_version=1\nname=\"Real prerequisite\"\n[text]\nforeground=\"red\"\n")
    let app=Application(root,theme:value);app.startHeadless()
    try {
        let frame=app.snapshot(2,1)
        if(frame.cellAt(0,0).grapheme!="e\u{301}" || frame.cellAt(0,0).style.foreground!=Color.Red || !frame.cellAt(0,0).style.bold){throw Exception("actual RichText/theme/frame positive")}
        let node=root.reference().getOrThrow()
        if(!node.isValid() || node.children().size!=1){throw Exception("actual dynamic-runtime public reference positive")}
        text.set(RichText("Q"))
        if(app.snapshot(2,1).cellAt(0,0).grapheme!="Q"){throw Exception("existing Observable binding positive")}
    } finally {app.dispose()}
    if(app.stats().mountedNodes!=0 || app.stats().subscriptions!=0){throw Exception("existing cleanup positive")}
    println("PASS actual080/084/088/152 public prerequisite consumer; no A standins")
    0
}
