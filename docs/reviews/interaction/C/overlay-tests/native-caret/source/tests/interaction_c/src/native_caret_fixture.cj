package interaction_c
import cjtui.*
import std.env.*
import std.fs.*

func nativeCaretCheck(value:Bool,message:String):Unit {
    if(!value){throw Exception("FAIL C03-native-caret ${message}")}
}

// One public native vector. Queries read the preceding completed frame; they
// never reenter snapshot/render from a run callback and never print to the TTY.
func nativeCaretOverlayFixture():Int64 {
    nativeCaretCheck(getVariable("CJTUI_OVERLAY_NATIVE_CARET").getOrThrow()=="opaque","unknown selector")
    let directory=getVariable("CJTUI_OVERLAY_CARET_OUTPUT").getOrThrow()
    let report={name:String,text:String=>File.writeTo(directory+"/"+name,text.toArray())}
    let base=Box<?Component>(Option<Component>.None)
    let stage=Box<String>("base");let observed=Box<String>("")
    let cleanups=Box<Int64>(0)
    let handle=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    let diagnostic=Box<?TerminalCapabilities>(Option<TerminalCapabilities>.None)
    let root=Column{
        base.value=Some(Canvas({_=>Size(8,3)},{p=>
            p.put(0,0,"ABCDEFGH");p.put(0,1,"ijklmnop");p.put(0,2,"QRSTUVWX");p.caret(3,1)
        }).width(8).height(3).viewport(ScrollAxes.Off).focusable(true).overlayHost(true)
          .onMount({_=>{=>cleanups.value++}}))
    }.viewport(ScrollAxes.Off)
    let cover=Text("   ").width(3).height(1).surface(SurfaceMode.Opaque)
    let app=Application(root)
    app.onKeyEvent({event=>
        let owner=node(base.value.getOrThrow())
        match(event.key.text){
            case "o"=>
                nativeCaretCheck(stage.value=="base","open follows base stage")
                handle.value=Some(owner.openOverlay(cover,options:OverlayOptions(mode:OverlayMode.Passive,host:owner,takeFocus:false)))
                stage.value="covered";report("action-open","queued; not a paint fence")
            case "c"=>
                nativeCaretCheck(stage.value=="covered","close follows covered stage")
                handle.value.getOrThrow().close();stage.value="restored";report("action-close","queued; not a paint fence")
            case "s"=>
                let caret=app.caretSnapshot();let caps=app.terminalCapabilities().getOrThrow()
                let focused=app.focusedNode().isSome() && app.focusedNode().getOrThrow().sameNode(owner)
                let isCovered=stage.value=="covered"
                nativeCaretCheck(focused,"Passive cover preserves base logical focus")
                if(isCovered){
                    nativeCaretCheck(!caret.visible && caret.owner.isNone() && caret.x==0 && caret.y==0,"opaque contribution canonical hidden logical caret")
                }else{
                    nativeCaretCheck(caret.visible && caret.owner.isSome() && caret.owner.getOrThrow().sameNode(owner) && caret.x==3 && caret.y==1,"base/restored completed caret is local3,1 with original owner")
                }
                let open=handle.value.isSome() && handle.value.getOrThrow().isOpen()
                nativeCaretCheck(open==isCovered,"handle state matches completed stage")
                if(caps.cursorVisibilityStatus!="pending" && caps.cursorVisibilityStatus!="not-probed" && diagnostic.value.isNone()){
                    diagnostic.value=Some(caps)
                }
                let saved=if(let Some(value)<-diagnostic.value){value.cursorVisibilityStatus}else{"pending"}
                observed.value=stage.value
                report("state-"+stage.value,
                    "stage=${stage.value}\nlogicalVisible=${caret.visible}\nowner=${if(caret.owner.isSome()){"base"}else{"None"}}\nx=${caret.x}\ny=${caret.y}\nfocusBase=${focused}\nhandleOpen=${open}\ncursorStatus=${caps.cursorVisibilityStatus}\nsavedCursorStatus=${saved}\n")
            case "q"=>
                nativeCaretCheck(stage.value=="restored" && observed.value=="restored","quit only after restored query")
                app.stop();event.preventDefault()
            case _=>()
        }
    })
    app.run()
    let stats=app.stats()
    nativeCaretCheck(stats.mountedNodes==0 && stats.activeBindings==0 && stats.subscriptions==0 && stats.pendingPosts==0 && cleanups.value==1,"native resources and base cleanup released once")
    report("returned","exit=0\ncleanup=1\nresources=0/0/0/0\ncursorStatus=${app.terminalCapabilities().getOrThrow().cursorVisibilityStatus}\n")
    return 0
}
