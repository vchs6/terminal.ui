package overlay_review_round1
import cjtui.*
func ref(c:Component):NodeRef{c.reference().getOrThrow()}
func focusAfterOwnerRemoval():Unit {
    let firstBox=Box<?Component>(Option<Component>.None)
    let ownerBox=Box<?Component>(Option<Component>.None)
    let nextBox=Box<?Component>(Option<Component>.None)
    let root=Column{firstBox.value=Some(Text("FIRST").focusable(true));ownerBox.value=Some(Text("OWNER").focusable(true));nextBox.value=Some(Text("NEXT").focusable(true))}.viewport(ScrollAxes.Off)
    let first=firstBox.value.getOrThrow();let owner=ownerBox.value.getOrThrow();let next=nextBox.value.getOrThrow()
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
