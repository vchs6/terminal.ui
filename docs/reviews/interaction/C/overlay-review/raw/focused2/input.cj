package overlay_review_probe
import cjtui.*
func ref(c:Component):NodeRef{c.reference().getOrThrow()}
func ownerRevocation():Unit {
    let owner=Box<?Component>(Option<Component>.None)
    let root=Column{owner.value=Some(Text("O"))}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless()
    let saved=ref(owner.value.getOrThrow());let valid=Box<Bool>(false);let posted=Box<Bool>(false)
    let layer=Text("P").onMount({_=>{=>valid.value=saved.isValid();posted.value=app.post(saved,{=>})}})
    try {
        app.batch({=>saved.openOverlay(layer,options:OverlayOptions(takeFocus:false));()})
        app.batch({=>ref(root).remove(saved)})
        println("REVOKE cleanupOwnerValid=${valid.value} cleanupPostAccepted=${posted.value} afterValid=${saved.isValid()}")
    }finally{app.dispose()}
}
func hiddenLayer():Unit {
    let root=Text("BBB").viewport(ScrollAxes.Off);let layer=Text("P")
    let app=Application(root);app.startHeadless()
    try {
        app.batch({=>ref(root).openOverlay(layer,options:OverlayOptions(takeFocus:false));()})
        println("HIDDEN before=[${app.snapshot(3,1).toPlainText()}]")
        app.batch({=>layer.visible(false)})
        println("HIDDEN after=[${app.snapshot(3,1).toPlainText()}] visible=${ref(layer).isVisible()}")
    }finally{app.dispose()}
}
func builtinHost():Unit {
    let root=Text("B").viewport(ScrollAxes.Off);let app=Application(root);app.startHeadless()
    let error=Box<String>("")
    try {
        app.batch({=>try{ref(root).openOverlay(Text("P"),options:OverlayOptions(host:ref(root),takeFocus:false));()}catch(e:UIException){error.value=e.code}})
        println("ROOT_HOST error=[${error.value}]")
    }finally{app.dispose()}
}
func revokedHost():Unit {
    let host=Box<?Component>(Option<Component>.None);let owner=Box<?Component>(Option<Component>.None)
    let root=Column{host.value=Some(Column{owner.value=Some(Text("O"))}.overlayHost(true))}.viewport(ScrollAxes.Off)
    let app=Application(root);app.startHeadless();let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    try {
        var error=""
        try{app.batch({=>handle.value=Some(ref(owner.value.getOrThrow()).openOverlay(Text("P"),options:OverlayOptions(host:ref(host.value.getOrThrow()),takeFocus:false)));host.value.getOrThrow().overlayHost(false);()})}catch(e:UIException){error=e.code}
        println("REVOKED_HOST error=[${error}] open=${handle.value.getOrThrow().isOpen()}")
    }finally{app.dispose()}
}
func ensureAnchor():Unit {
    let anchor=Box<?Component>(Option<Component>.None)
    let root=ScrollView{anchor.value=Some(Text("A"));Text("1\n2\n3\n4")}
    let app=Application(root);app.startHeadless();let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    try {
        app.snapshot(3,2)
        app.batch({=>handle.value=Some(ref(root).openOverlay(Text("P"),options:OverlayOptions(anchor:ref(anchor.value.getOrThrow()),placement:OverlayPlacement.BelowStart,takeFocus:false)))})
        app.snapshot(3,2)
        app.batch({=>ref(root).ensureVisible(rect:Rect(0,4,1,1))})
        let frame=app.snapshot(3,2);let v=ref(root).viewportSnapshot()
        println("ENSURE_ANCHOR offset=${v.offsetY} open=${handle.value.getOrThrow().isOpen()} frame=[${frame.toPlainText()}]")
    }finally{app.dispose()}
}
func resultTag(r:ThemeRequest):String {
    match(r.result()){case Some(ThemeResult.Applied(_))=>"Applied";case Some(ThemeResult.Failed(_))=>"Failed";case _=>"Other"}
}
func missedOverlayValidation():Unit {
    let old=Theme.parse("schema_version=1\nname='Old'\n[styles.grow.spacing]\nweight=0\nmin_width=0\n")
    let next=Theme.parse("schema_version=1\nname='Next'\n[styles.grow.spacing]\nweight=1\nmin_width=9223372036854775807\n")
    let root=Column{}.viewport(ScrollAxes.Off)
    let layer=Row{Text("a").styles([StyleUse.Named("grow")]);Text("b").styles([StyleUse.Named("grow")])}
    let app=Application(root,theme:old);app.startHeadless()
    try {
        app.batch({=>ref(root).openOverlay(layer,options:OverlayOptions(takeFocus:false));()})
        app.snapshot(Int64.Max,0)
        let request=app.loadTheme(ThemeSource.Prepared(next));var error=""
        try{app.snapshot(Int64.Max,0)}catch(e:Exception){error=e.message}
        println("THEME_MISSED result=${resultTag(request)} error=[${error}] info=${app.themeInfo().name} active=${app.post({=>})}")
    }finally{app.dispose()}
}
func spuriousOverlayWeight():Unit {
    let old=Theme.parse("schema_version=1\nname='Old'\n");let next=Theme.parse("schema_version=1\nname='Next'\n")
    let root=Row{Text("B").layoutWeight(Int64.Max)}.viewport(ScrollAxes.Off)
    let app=Application(root,theme:old);app.startHeadless()
    try {
        app.batch({=>ref(root).openOverlay(Text("P").layoutWeight(1),options:OverlayOptions(takeFocus:false));()})
        app.snapshot(3,1)
        let request=app.loadTheme(ThemeSource.Prepared(next));app.snapshot(3,1)
        println("THEME_WEIGHT result=${resultTag(request)} info=${app.themeInfo().name}")
    }finally{app.dispose()}
}
func passiveDispatch():Unit {
    let calls=Box<Int64>(0);let root=Text("B").onKey({_=>calls.value++})
    let app=Application(root);app.startHeadless();let layer=Text("P")
    try {
        app.batch({=>ref(root).openOverlay(layer,options:OverlayOptions(mode:OverlayMode.Passive,takeFocus:false));()})
        var error="";try{app.dispatch(ref(layer),KeyEvent("text",text:"x"))}catch(e:UIException){error=e.code}
        println("PASSIVE_TARGET error=[${error}] ownerKeyCalls=${calls.value}")
    }finally{app.dispose()}
}
main():Int64{ownerRevocation();passiveDispatch();0}
