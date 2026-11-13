package overlay_review_round1
import cjtui.*
func ref(c:Component):NodeRef{c.reference().getOrThrow()}
func focusAfterOwnerRemoval():Unit {
    let first=Text("FIRST").focusable(true)
    let owner=Text("OWNER").focusable(true)
    let next=Text("NEXT").focusable(true)
    let root=Column{first;owner;next}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    try {
        app.batch({=>ref(owner).requestFocus()})
        app.batch({=>ref(owner).openOverlay(Text("P").focusable(true),options:OverlayOptions(mode:OverlayMode.Modal));()})
        app.batch({=>ref(root).remove(ref(owner))})
        let focused=app.focusedNode().getOrThrow()
        println("RESTORE first=${focused.sameNode(ref(first))} next=${focused.sameNode(ref(next))}")
    }finally{app.dispose()}
}
func explicitRootGeometry(explicit:Bool):Unit {
    let root=Text("B").width(1).height(1).viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    try {
        app.batch({=>ref(root).openOverlay(Text("P"),options:OverlayOptions(host:if(explicit){Some(ref(root))}else{Option<NodeRef>.None},takeFocus:false));()})
        println("ROOT explicit=${explicit} frame=[${app.snapshot(5,1).toPlainText()}]")
    }finally{app.dispose()}
}
main():Int64{focusAfterOwnerRemoval();explicitRootGeometry(false);explicitRootGeometry(true);0}
