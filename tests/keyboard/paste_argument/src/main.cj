package keyboard_argument_regression
import cjtui.*
import std.env.*
import std.fs.*

func check(ok:Bool,message:String):Unit {
    if(!ok){throw Exception("FAIL K-ARG ${message}")}
}
func kind(diagnostic:KeyboardDiagnostic):String {
    if(diagnostic.kind==KeyboardIssue.UnsupportedSequence){return "UnsupportedSequence"}
    if(diagnostic.kind==KeyboardIssue.SequenceTooLong){return "SequenceTooLong"}
    if(diagnostic.kind==KeyboardIssue.InvalidPasteEncoding){return "InvalidPasteEncoding"}
    return "Other"
}
func c1Result(bytes:Array<UInt8>,limit:Int64,want:KeyboardIssue):Bool {
    let decoder=KeyboardDecoder(limits:KeyboardLimits(maxSequenceBytes:limit))
    let batch=decoder.feed(bytes);let tail=decoder.finish()
    let tag=if(batch.diagnostics.size==1){kind(batch.diagnostics[0])}else{"count${batch.diagnostics.size}"}
    let offset=if(batch.diagnostics.size==1){batch.diagnostics[0].offset}else{-1}
    println("C1 limit=${limit} bytes=${bytes.size} diagnostics=${tag}@${offset} events=${batch.events.size} tailEvents=${tail.events.size} tailIssues=${tail.diagnostics.size}")
    return batch.events.size==2 && batch.events[0].code=="text" && batch.events[0].text=="A" && batch.events[1].code=="text" && batch.events[1].text=="B" && batch.diagnostics.size==1 && batch.diagnostics[0].kind==want && batch.diagnostics[0].offset==1 && tail.events.size==0 && tail.diagnostics.size==0
}
func c1ByteBudget():Unit {
    // Manual raw byte counts exclude surrounding A/B: raw CSI1+ASCII7=8;
    // UTF8 C1 CSI2+ASCII7=9. Both diagnostics start at raw stream offset1.
    let raw:Array<UInt8>=[65,0x9b,63,50,53,59,49,36,121,66]
    let utf8:Array<UInt8>=[65,0xc2,0x9b,63,50,53,59,49,36,121,66]
    let raw8=c1Result(raw,8,KeyboardIssue.UnsupportedSequence)
    let utf8over=c1Result(utf8,8,KeyboardIssue.SequenceTooLong)
    let utf8exact=c1Result(utf8,9,KeyboardIssue.UnsupportedSequence)
    check(raw8,"C1 raw8 unsupported positive control and A/B offset1")
    check(utf8over,"C1 UTF8 two-byte introducer counts nine raw bytes at limit8")
    check(utf8exact,"C1 UTF8 nine bytes legal budget9 remains unsupported, A/B preserved")
}
func ctrlLetterText():Unit {
    let calls=Box<Int64>(0);let root=Text("target").focusable(true)
    let app=Application(root).onKeyEvent({_=>calls.value++});app.startHeadless()
    try {
        let target=root.reference().getOrThrow()
        app.dispatch(target,KeyEvent("a",ctrl:true))
        check(calls.value==1 && target.isValid(),"ctrl-letter empty text normal positive control")
        app.dispatch(target,KeyEvent("custom",text:"payload",ctrl:true))
        check(calls.value==2 && target.isValid(),"custom code retains legal payload positive control")
        let before=calls.value;var observed="NO_ERROR"
        try{app.dispatch(target,KeyEvent("a",text:"x",ctrl:true))}catch(_:IllegalArgumentException){observed="IllegalArgumentException"}
        let alive=target.isValid() && app.post({=>})
        println("CTRL nonempty code=${observed} callbackDelta=${calls.value-before} healthy=${alive}")
        check(observed=="IllegalArgumentException" && calls.value==before && alive,"ctrl-letter nonempty reserved text rejected before callbacks, healthy session")
    }finally{app.dispose()}
}
func pasteNative():Unit {
    let directory=getVariable("CJTUI_KEYBOARD_ARGUMENT_OUTPUT").getOrThrow()
    let report={name:String,value:String=>File.writeTo(directory+"/"+name,value.toArray())}
    let primary=IllegalArgumentException("PASTE_CALLBACK_ILLEGAL_ARGUMENT_SENTINEL_113")
    let pastes=Box<Int64>(0);let cleanup=Box<Int64>(0);let issues=Box<Int64>(0);let invalid=Box<Int64>(0);let fallback=Box<Int64>(0)
    let root=Text("K-PASTE-ARGUMENT-READY").focusable(true).viewport(ScrollAxes.Off)
        .onMount({_=>{=>cleanup.value++;report("cleanup","${cleanup.value}")}})
    let app=Application(root)
    root.onKey({event=>
        if(event.key.code=="paste"){
            check(event.key.text=="ASCII_OK" && !event.key.ctrl && !event.key.alt && !event.key.shift,"native fixture valid ASCII paste")
            check(app.focusedNode().getOrThrow().sameNode(root.reference().getOrThrow()),"native base focus control")
            pastes.value++;report("entered","ASCII_OK");throw primary
        }
        if(event.key.text=="q"){fallback.value++;app.stop();event.preventDefault()}
    })
    app.onKeyboardIssue({diagnostic=>
        issues.value++;if(diagnostic.kind==KeyboardIssue.InvalidPasteEncoding){invalid.value++}
        report("issues","${kind(diagnostic)}@${diagnostic.offset};count=${issues.value}")
    })
    var caught=false;var same=false;var message="";var nestedSame=false
    try{app.run()}catch(error:Exception){
        caught=true;same=refEq(error,primary);message=error.message
        if(let Some(wrapper)<-(error as UICleanupException)){nestedSame=refEq(wrapper.primary,primary)}
    }
    let stats=app.stats();let released=stats.mountedNodes==0 && stats.activeBindings==0 && stats.subscriptions==0 && stats.pendingPosts==0
    report("summary","pastes=${pastes.value}\ncaught=${caught}\nsame=${same}\nnestedSame=${nestedSame}\nmessage=${message}\nissues=${issues.value}\ninvalidEncoding=${invalid.value}\nfallbackQuit=${fallback.value}\ncleanup=${cleanup.value}\nreleased=${released}\n")
    check(pastes.value==1 && cleanup.value==1 && released,"native callback reached once and cleanup/resources control")
    check(caught && same && message==primary.message,"native paste callback preserves original IllegalArgumentException sentinel and stops run")
    check(issues.value==0 && invalid.value==0,"native callback failure is not InvalidPasteEncoding or another issue")
    check(fallback.value==0,"native callback failure cancels following fallback q")
}
main():Int64 {
    let selected=getVariable("CJTUI_KEYBOARD_ARGUMENT_CASE").getOrThrow()
    match(selected){
        case "paste-native"=>pasteNative()
        case "c1-byte-budget"=>c1ByteBudget()
        case "ctrl-text"=>ctrlLetterText()
        case _=>throw Exception("unknown keyboard argument selector ${selected}")
    }
    println("PASS ${selected}")
    0
}
