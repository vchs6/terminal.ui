package keyboard_formal_device
import cjtui.*
import std.env.*
import std.fs.*
func check(ok:Bool,name:String):Unit{if(!ok){throw Exception("FAIL keyboard formal ${name}")}}
func ref(c:Component):NodeRef{c.reference().getOrThrow()}
func issueName(kind:KeyboardIssue):String {
    match(kind){
        case KeyboardIssue.UnsupportedSequence=>"UnsupportedSequence"
        case KeyboardIssue.MalformedSequence=>"MalformedSequence"
        case KeyboardIssue.SequenceTooLong=>"SequenceTooLong"
        case KeyboardIssue.InvalidUtf8=>"InvalidUtf8"
        case KeyboardIssue.IncompleteInput=>"IncompleteInput"
        case KeyboardIssue.PasteTooLarge=>"PasteTooLarge"
        case KeyboardIssue.InvalidPasteEncoding=>"InvalidPasteEncoding"
        case KeyboardIssue.IncompletePaste=>"IncompletePaste"
        case KeyboardIssue.PasteTargetUnavailable=>"PasteTargetUnavailable"
    }
}
main():Int64 {
    let directory=getVariable("CJTUI_KEYBOARD_FORMAL_OUTPUT").getOrThrow()
    let mode=getVariable("CJTUI_KEYBOARD_FORMAL_MODE").getOrThrow()
    let report={n:String,v:String=>File.writeTo(directory+"/"+n,v.toArray())}
    let trace=Box<String>("");let keys=Box<String>("");let issues=Box<String>("");let appPaste=Box<Int64>(0);let legacyPaste=Box<Int64>(0);let interrupts=Box<Int64>(0)
    let textCount=Box<Int64>(0);let issueCount=Box<Int64>(0);let postRan=Box<Bool>(false)
    let a=Box<?Component>(Option<Component>.None);let b=Box<?Component>(Option<Component>.None)
    let rootBox=Box<?Component>(Option<Component>.None);let appBox=Box<?Application>(Option<Application>.None)
    let modal=Box<?OverlayHandle>(Option<OverlayHandle>.None)
    let label=Observable<String>("CJTUI_KEYBOARD_FORMAL_READY")
    let primary=Exception("KEYBOARD_FORMAL_ISSUE_SENTINEL")
    let receive={tag:String,e:UIKeyEvent=>
        let app=appBox.value.getOrThrow()
        keys.value+="${e.key.code}:${e.key.text};"
        if(e.key.code=="interrupt"){interrupts.value++}
        if(e.key.code=="paste"){
            trace.value+="${tag}:${e.key.text};";report("paste",trace.value)
            check(!e.key.ctrl && !e.key.alt && !e.key.shift,"paste modifier normal form")
        }
        if(e.key.code=="text"){
            match(e.key.text){
                case "q"=>app.stop();e.preventDefault()
                case "a"=>ref(a.value.getOrThrow()).requestFocus()
                case "b"=>ref(b.value.getOrThrow()).requestFocus()
                case "x"=>
                    textCount.value++
                    if(textCount.value==1 && (mode=="fair-normal" || mode=="fair-paste" || mode=="fair-drain")){
                        check(app.post({=>postRan.value=true;report("post-at","${textCount.value}")}),"fair queued post accepted")
                        report("gate","first-x");let release=String.fromUtf8(File.readFrom(directory+"/release.fifo"));check(release=="release","real callback FIFO gate")
                    }
                case _=>()
            }
        }
    }
    let root=Column{
        Text({=>label.get()})
        a.value=Some(Text("A").height(1).focusable(true).enabled(mode!="no-target").onKey({e=>receive("A",e)}))
        b.value=Some(Text("B").height(1).focusable(true).enabled(mode!="no-target").onKey({e=>receive("B",e)}))
    }.viewport(if(mode=="scroll"){ScrollAxes.Vertical}else{ScrollAxes.Off}).enabled(mode!="no-target")
    if(mode=="scroll"){root.height(1)}
    rootBox.value=Some(root)
    let app=Application(root,keyboardLimits:KeyboardLimits(maxPasteBytes:if(mode.contains("drain")){4}else{1048576}))
    appBox.value=Some(app)
    app.onKeyEvent({e=>if(e.key.code=="paste"){appPaste.value++}})
    app.onKey({key=>if(key.code=="paste"){legacyPaste.value++}})
    app.onKeyboardIssue({diagnostic=>
        issueCount.value++;issues.value+="${issueName(diagnostic.kind)}@${diagnostic.offset};";report("issues",issues.value)
        if(mode=="diag-begin" || mode=="diag-context"){
            label.set("DIAGNOSTIC_COMMITTED");ref(b.value.getOrThrow()).requestFocus()
        }
        if(mode=="diag-context"){
            var rejected:Int64=0
            try{app.snapshot(1,1)}catch(e:UIException){check(e.code=="LifecycleReentry","issue snapshot context");rejected++}
            try{app.dispatch(ref(a.value.getOrThrow()),KeyEvent("text",text:"!"))}catch(e:UIException){check(e.code=="LifecycleReentry","issue dispatch context");rejected++}
            try{app.dispose()}catch(e:UIException){check(e.code=="LifecycleReentry","issue dispose context");rejected++}
            let extra=Text("T");ref(root).append(extra)
            check(app.post({=>ref(root).remove(ref(extra));postRan.value=true;report("issue-post","ran")}),"issue post accepted")
            check(rejected==3,"three recursive boundaries rejected");report("issue-context","ok")
        }
        if(mode=="eof-input" || mode=="eof-paste"){
            check(ref(root).isValid(),"EOF diagnostic before revocation")
            label.set("EOF_COMMITTED")
            check(app.post({=>postRan.value=true}),"EOF callback may enqueue post")
            report("eof-callback","active/committed/post-accepted")
        }
        if(mode=="issue-throws"){throw primary}
        if(mode=="issue-stop"){app.stop()}
    })
    let worker=spawn{
        for(_ in 0..15000){
            if(exists(directory+"/worker-stop")){break}
            if(exists(directory+"/mutate")){
                check(app.post({=>
                    match(mode){
                        case "focus"=>ref(b.value.getOrThrow()).requestFocus()
                        case "hide"=>a.value.getOrThrow().visible(false)
                        case "disable"=>a.value.getOrThrow().enabled(false)
                        case "unmount"=>ref(root).remove(ref(a.value.getOrThrow()))
                        case "remount"=>
                            let old=ref(a.value.getOrThrow());ref(root).remove(old)
                            check(app.post({=>ref(root).insertBefore(ref(b.value.getOrThrow()),a.value.getOrThrow());report("mutated",mode)}),"remount after prior unmount commit")
                        case "modal"=>modal.value=Some(ref(root).openOverlay(Text("P").focusable(true).onKey({e=>receive("P",e)}),options:OverlayOptions(mode:OverlayMode.Modal)))
                        case "no-target"=>root.enabled(true);b.value.getOrThrow().enabled(true);ref(b.value.getOrThrow()).requestFocus()
                        case "scroll"=>ref(root).scrollTo(0,2);()
                        case "cancel-paste" | "cancel-drain"=>app.stop()
                        case "fair-paste" | "fair-drain"=>postRan.value=true;report("pending-post","ran")
                        case _=>()
                    }
                    if(mode!="remount"){report("mutated",mode)}
                }),"background mutation post accepted")
                break
            }
            sleep(Duration.millisecond)
        }
    }
    var caught=false
    try{app.run()}catch(error:Exception){
        caught=true
        if(mode=="issue-throws"){
            let same=if(let Some(clean)<-(error as UICleanupException)){refEq(clean.primary,primary)}else{refEq(error,primary)}
            check(same,"original issue exception identity")
        }else{check(mode.startsWith("fault-"),"unexpected native failure")}
        report("error",error.message)
    }finally{report("worker-stop","stop");worker.get(Duration.second*5)}
    check(caught==(mode=="issue-throws" || mode.startsWith("fault-")),"expected callback/writer failure path")
    let stats=app.stats();check(stats.mountedNodes==0 && stats.activeBindings==0 && stats.subscriptions==0 && stats.pendingPosts==0,"native resources released")
    if(mode=="eof-input" || mode=="eof-paste"){check(!postRan.value,"EOF cancels unrun post")}
    report("summary","paste=${trace.value}\nkeys=${keys.value}\nissues=${issues.value}\nappPaste=${appPaste.value}\nlegacyPaste=${legacyPaste.value}\ntextCount=${textCount.value}\ninterrupts=${interrupts.value}\npostRan=${postRan.value}\nresources=0/0/0/0\n")
    report("returned","normal")
    0
}
