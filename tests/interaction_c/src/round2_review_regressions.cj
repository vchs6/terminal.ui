package interaction_c
import cjtui.*

// Ordinary removal follows A; closing an owned modal follows C.4 first.
func round2OwnerRemovalFocus(withModal:Bool):Unit {
    let first=Box<?Component>(Option<Component>.None)
    let owner=Box<?Component>(Option<Component>.None)
    let next=Box<?Component>(Option<Component>.None)
    let root=Column{
        first.value=Some(Text("FIRST").focusable(true))
        owner.value=Some(Text("OWNER").focusable(true))
        next.value=Some(Text("NEXT").focusable(true))
    }.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    let ownerRef=node(owner.value.getOrThrow())
    let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    let modal=Text("P").focusable(true)
    try {
        app.batch({=>ownerRef.requestFocus()})
        focused(app,ownerRef,"R1-I01 explicit OWNER focus control modal=${withModal}")
        if(withModal){
            app.batch({=>handle.value=Some(ownerRef.openOverlay(modal,options:OverlayOptions(mode:OverlayMode.Modal)))})
            focused(app,node(modal),"R1-I01 modal content has focus before owner removal")
        }
        app.batch({=>node(root).remove(ownerRef)})
        let actual=app.focusedNode().getOrThrow()
        println("R1-I01 modal=${withModal} first=${actual.sameNode(node(first.value.getOrThrow()))} next=${actual.sameNode(node(next.value.getOrThrow()))} ownerValid=${ownerRef.isValid()}")
        check(!ownerRef.isValid() && node(root).children().size==2,"R1-I01 ordinary owner generation removed")
        if(withModal){
            check(!handle.value.getOrThrow().isOpen() && reason(handle.value.getOrThrow())=="OwnerGone","R1-I01 removal closes owned modal OwnerGone")
            focused(app,node(first.value.getOrThrow()),"R1-I01 invalid saved focus restores nearest surviving owner ancestor first eligible FIRST before physical NEXT")
        }else{
            focused(app,node(next.value.getOrThrow()),"R1-I01 ordinary removal without overlay retains A physical successor NEXT")
        }
    }finally{app.dispose()}
}
func round2ModalOwnerRestoration():Unit {
    round2OwnerRemovalFocus(false)
    round2OwnerRemovalFocus(true)
}

func round2RootHostPicture(explicitRoot:Bool):String {
    let root=Text("B").width(1).height(1).viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    var output=""
    try {
        picture(app.snapshot(5,1),"B    ","R1-I02 actual terminal5x1 with ordinary root1x1 control explicit=${explicitRoot}")
        app.batch({=>handle.value=Some(node(root).openOverlay(Text("P"),options:OverlayOptions(host:if(explicitRoot){Some(node(root))}else{Option<NodeRef>.None},takeFocus:false)))})
        check(handle.value.getOrThrow().isOpen() && handle.value.getOrThrow().content().isSome(),"R1-I02 root host accepts and mounts natural1x1 P explicit=${explicitRoot}")
        output=app.snapshot(5,1).toPlainText()
        println("R1-I02 explicit=${explicitRoot} frame=[${output}]")
    }finally{app.dispose()}
    return output
}
func round2ExplicitRootBounds():Unit {
    let implicit=round2RootHostPicture(false)
    check(implicit=="B P  ","R1-I02 default built-in root host centers P in actual5x1 terminal")
    let explicit=round2RootHostPicture(true)
    check(explicit=="B P  " && explicit==implicit,"R1-I02 explicit built-in root host uses terminal bounds rather than ordinary1x1 root box; actual [${explicit}]")
}

func round2ReviewRegression(name:String):Int64 {
    match(name){
        case "R1-I01"=>round2ModalOwnerRestoration()
        case "R1-I02"=>round2ExplicitRootBounds()
        case _=>throw Exception("unknown round2 overlay regression ${name}")
    }
    return 0
}
