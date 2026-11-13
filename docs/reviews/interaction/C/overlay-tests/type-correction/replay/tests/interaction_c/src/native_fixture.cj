package interaction_c
import cjtui.*
import std.env.*
import std.fs.*

func nativeOverlayFixture():Int64 {
    let directory=getVariable("CJTUI_OVERLAY_OUTPUT").getOrThrow()
    let mode=getVariable("CJTUI_OVERLAY_NATIVE").getOrThrow()
    let primary=Exception("H01 callback primary");let ce=Exception("H01 C cleanup");let me=Exception("H01 M cleanup")
    let cleanup=Box<String>("");let trace=Box<String>("");let apps=Box<Int64>(0);let legacy=Box<Int64>(0)
    let outer=Box<?OverlayHandle>(Option<OverlayHandle>.None);let popup=Box<?OverlayHandle>(Option<OverlayHandle>.None);let confirm=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    let appBox=Box<?Application>(Option<Application>.None)
    let report={name:String,value:String=>File.writeTo(directory+"/"+name,value.toArray())}
    let c=Column{
        Text("CONFIRM").focusable(true)
            .onKeyCapture({_=>trace.value+="Tc;"})
            .onKey({_=>trace.value+="Tb;"})
            .defaultAction({e=>trace.value+="Td;";if(e.key.text=="q"){appBox.value.getOrThrow().stop();e.preventDefault()};if(e.key.text=="!"){throw primary}})
    }.onKeyCapture({e=>trace.value="Cc;";if(mode=="prevent" && e.key.code=="interrupt"){e.preventDefault();report("prevent","active")}})
     .onKey({_=>trace.value+="Cb;"})
     .defaultAction({e=>trace.value+="Ca;";if(e.key.text=="x"){report("trace","${trace.value}|${apps.value}|${legacy.value}")}},phase:DefaultActionPhase.Ancestor)
     .onMount({_=>apps.value=0;legacy.value=0;report("C","mounted");{=>cleanup.value+="C;";report("C-clean","once");if(mode=="callback-error"){throw ce}}})
    let p=Text("POPUP").focusable(true).onKey({e=>
        if(e.key.text=="c"){confirm.value=Some(e.currentTarget.openOverlay(c,options:OverlayOptions(mode:OverlayMode.Modal)))}
        if(e.key.text=="s"){report("escape","${reason(confirm.value.getOrThrow())}|${outer.value.getOrThrow().isOpen()}|${popup.value.getOrThrow().isOpen()}")}
        if(e.key.text=="q"){appBox.value.getOrThrow().stop();e.preventDefault()}
    }).onMount({_=>report("P","mounted");{=>cleanup.value+="P;";report("P-clean","once")}})
    let m=Text("MODAL").focusable(true).onKey({e=>if(e.key.text=="p"){popup.value=Some(e.currentTarget.openOverlay(p))}})
        .onMount({_=>report("M","mounted");{=>cleanup.value+="M;";report("M-clean","once");if(mode=="callback-error"){throw me}}})
    let root=Text("BASE-OVERLAY-READY").focusable(true).onKey({e=>
        if(e.key.text=="m"){outer.value=Some(e.currentTarget.openOverlay(m,options:OverlayOptions(mode:OverlayMode.Modal)))}
    })
    let app=Application(root).onKeyEvent({_=>apps.value++}).onKey({_=>legacy.value++});appBox.value=Some(app)
    var caught=false
    try{app.run()}catch(e:UICleanupException){
        check(mode=="callback-error" && refEq(e.primary,primary) && e.cleanupFailures.size==2 && refEq(e.cleanupFailures[0],ce) && refEq(e.cleanupFailures[1],me),"H01 original callback and cleanup identity/order")
        caught=true
    }
    check(caught==(mode=="callback-error"),"H01 expected native callback exception path")
    check(cleanup.value=="C;P;M;","H01 actual deepest-first cleanup exactly once")
    released(app,"H01 native fixture cleanup");return 0
}
