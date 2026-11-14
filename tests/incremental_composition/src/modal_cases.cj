package incremental_composition

import cjtui.*

func nestedModalClose(): Unit {
    let epoch = [Int64(0)]; let baseText = Observable<String>("bbbbbb"); let outerText = Observable<String>("OUT")
    let base = DrawProbe("modal-base",6,3); let parent = DrawProbe("outer-modal",4,1); let child = DrawProbe("inner-modal",2,1)
    let root = Canvas({_ => Size(6,3)},{p => base.record(p); p.put(0,0,"aaaaaa"); p.put(0,1,baseText.get()); p.put(0,2,"cccccc"); p.caret(0,0) }).focusable(true).viewport(ScrollAxes.Off)
    let outer = Canvas({_ => Size(4,1)},{p => parent.record(p); p.put(0,0,outerText.get()); p.caret(3,0) }).focusable(true)
    let inner = Canvas({_ => Size(2,1)},{p => child.record(p); p.put(0,0,"IN"); p.caret(0,0) }).focusable(true)
    let h1 = [Option<OverlayHandle>.None]; let h2 = [Option<OverlayHandle>.None]
    let app = Application(root,theme:plainTheme()); app.startHeadless()
    let first = row(["a","a","a","a","a","a"]); let last = row(["c","c","c","c","c","c"])
    try {
        paired(app,root,epoch,6,3,[first,row(["b","b","b","b","b","b"]),last],[base,parent,child],[1,0,0],"modal base initial")
        caret(app,root,0,0,"modal base caret")
        advance(app,epoch,{ => h1[0] = Some(node(root).openOverlay(outer,options:OverlayOptions(mode:OverlayMode.Modal))) })
        paired(app,root,epoch,6,3,[first,row(["b","O","U","T"," ","b"]),last],[base,parent,child],[1,1,0],"outer modal opaque surface")
        caret(app,outer,4,1,"outer modal caret transform")
        advance(app,epoch,{ => h2[0] = Some(node(outer).openOverlay(inner,options:OverlayOptions(mode:OverlayMode.Modal))) })
        paired(app,root,epoch,6,3,[first,row(["b","O","I","N"," ","b"]),last],[base,parent,child],[1,1,1],"nested modal paints above parent")
        caret(app,inner,2,1,"inner modal caret transform")
        advance(app,epoch,{ => baseText.set("BBBBBB"); outerText.set("NEW") })
        paired(app,root,epoch,6,3,[first,row(["B","N","I","N"," ","B"]),last],[base,parent,child],[1,1,1],"covered lower layers update to latest")
        caret(app,inner,2,1,"lower changes preserve top caret")
        advance(app,epoch,{ => h2[0].getOrThrow().close() })
        paired(app,root,epoch,6,3,[first,row(["B","N","E","W"," ","B"]),last],[base,parent,child],[1,1,0],"child close exposes latest parent")
        caret(app,outer,4,1,"child close restores parent caret")
        let replacement = Canvas({_ => Size(2,1)},{p => child.record(p); p.put(0,0,"OK"); p.caret(1,0) }).focusable(true)
        advance(app,epoch,{ => h2[0] = Some(node(outer).openOverlay(replacement,options:OverlayOptions(mode:OverlayMode.Modal))) })
        paired(app,root,epoch,6,3,[first,row(["B","N","O","K"," ","B"]),last],[base,parent,child],[1,1,1],"new nested modal")
        caret(app,replacement,3,1,"replacement layer caret")
        let parentRef = node(outer); let childRef = node(replacement)
        advance(app,epoch,{ => h1[0].getOrThrow().close() })
        paired(app,root,epoch,6,3,[first,row(["B","B","B","B","B","B"]),last],[base,parent,child],[1,0,0],"parent close clears every attached layer")
        Checks.equal(!h1[0].getOrThrow().isOpen() && !h2[0].getOrThrow().isOpen(),"parent closes complete layer subtree")
        Checks.equal(!parentRef.isValid() && !childRef.isValid(),"closed layer identities stale")
        caret(app,root,0,0,"closed modal cached requests cannot resurrect")
        paired(app,root,epoch,6,3,[first,row(["B","B","B","B","B","B"]),last],[base,parent,child],[0,0,0],"clean after parent close")
        caret(app,root,0,0,"clean target retains surviving base caret")
    } finally { app.dispose() }
}
