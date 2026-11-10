package interaction_a_contract
import cjtui.*
import std.env.*
import std.fs.*
// No protocol input or ANSI output here: all device traffic goes through Application.run.
func deviceConsumer(): Int64 {
    let directory=getVariable("CJTUI_INTERACTION_A_DEVICE").getOrThrow()
    let exitMode=getVariable("CJTUI_INTERACTION_A_EXIT") ?? "normal"
    let appBox=Box<?Application>(Option<Application>.None)
    let pos=Observable<Int64>(0); let show=Observable<Bool>(true); let events=Box<String>(""); let cleaned=Box<Int64>(0)
    let firstFactory={=>Canvas({_=>Size(4,1)},{p=>if(exitMode=="draw-error"){throw Exception("DEVICE_DRAW_SENTINEL")};p.put(0,0,"AAAA");p.caret(pos.get(),0,visible:show.get())}).focusable(true) }
    let secondFactory={=>Canvas({_=>Size(4,1)},{p=>p.put(0,0,"BBBB");p.caret(0,0)}).focusable(true) }
    let (root,nodes)=group([firstFactory,secondFactory]);let first=nodes[0]
    root.onMount({_=>
        if(exitMode=="mount-stop"){appBox.value.getOrThrow().stop()}
        {=>cleaned.value++;File.writeTo(directory+"/cleanup","${cleaned.value}".toArray());if(exitMode=="cleanup-error"){throw Exception("DEVICE_CLEANUP_SENTINEL")}}
    })
    let app=Application(root,colorMode:ColorMode.Basic16)
    appBox.value=Some(app)
    app.onKeyEvent({e=>
        events.value+="${e.key.code}:${e.key.text}|"
        if(e.key.text=="m"){pos.set(2)}
        if(e.key.text=="h"){show.set(false)}
        if(e.key.text=="v"){show.set(true)}
        if(e.key.text=="e"){throw Exception("DEVICE_CALLBACK_SENTINEL")}
        if(e.key.text=="q"){app.stop()}
        app.post({=>
            let cap=app.terminalCapabilities().getOrThrow();let s=app.caretSnapshot()
            let focused=if(app.focusedNode().getOrThrow().sameNode(ref(first))){"A"}else{"B"}
            File.writeTo(directory+"/state","${cap.cursorVisibilityStatus}\n${focused}\n${s.x},${s.y},${s.visible}\n${events.value}".toArray())
        }); ()
    })
    try { app.run() } catch(e:Exception){File.writeTo(directory+"/error",e.message.toArray());throw e}
    if(exitMode=="mount-stop"){empty(app);return 0}
    let cap=app.terminalCapabilities().getOrThrow()
    File.writeTo(directory+"/closed-status",cap.cursorVisibilityStatus.toArray())
    check(cleaned.value==1,"device mount cleanup exactly once")
    File.writeTo(directory+"/closed-cleanup","${cleaned.value}".toArray())
    app.startHeadless()
    check(app.terminalCapabilities().getOrThrow().cursorVisibilityStatus==cap.cursorVisibilityStatus,"headless retains last device capabilities")
    app.dispose();empty(app)
    check(cleaned.value==2,"new headless mount gets its own once-only cleanup")
    if(getVariable("CJTUI_INTERACTION_A_RERUN").isSome()){
        File.writeTo(directory+"/rerun-ready","ready".toArray())
        app.run()
        File.writeTo(directory+"/second-closed-status",app.terminalCapabilities().getOrThrow().cursorVisibilityStatus.toArray())
    }
    return 0
}
