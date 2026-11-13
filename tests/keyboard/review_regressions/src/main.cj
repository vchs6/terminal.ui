package keyboard_review_regressions
import cjtui.*
import std.env.*
import std.fs.*
import std.collection.*
func check(ok:Bool,message:String):Unit{if(!ok){throw Exception("FAIL K115 ${message}")}}
func issueName(kind:KeyboardIssue):String {
    if(kind==KeyboardIssue.UnsupportedSequence){return "UnsupportedSequence"}
    if(kind==KeyboardIssue.MalformedSequence){return "MalformedSequence"}
    if(kind==KeyboardIssue.SequenceTooLong){return "SequenceTooLong"}
    if(kind==KeyboardIssue.InvalidUtf8){return "InvalidUtf8"}
    if(kind==KeyboardIssue.IncompleteInput){return "IncompleteInput"}
    return "Other"
}
func observed(bytes:Array<UInt8>,split:Int64,bytewise:Bool,limit:Int64,wantEvents:String,wantIssues:String):Bool {
    let decoder=KeyboardDecoder(limits:KeyboardLimits(maxSequenceBytes:limit))
    let batches=ArrayList<KeyboardBatch>()
    if(bytewise){for(byte in bytes){batches.add(decoder.feed([byte]))}}else{
        batches.add(decoder.feed(bytes.slice(0,split)));batches.add(decoder.feed(bytes.slice(split,bytes.size-split)))
    }
    batches.add(decoder.finish())
    var events="";var issues=""
    for(batch in batches){
        for(key in batch.events){events+="${key.code}:${key.text}:${key.ctrl}/${key.alt}/${key.shift}|"}
        for(issue in batch.diagnostics){issues+="${issueName(issue.kind)}@${issue.offset};"}
    }
    println("bytes=${bytes} split=${split} bytewise=${bytewise} limit=${limit} events=${events} issues=${issues}")
    return events==wantEvents && issues==wantIssues
}
func vector(bytes:Array<UInt8>,limit:Int64,events:String,issues:String):Bool {
    var good=true
    for(split in 0..(bytes.size+1)){let actual=observed(bytes,split,false,limit,events,issues);good=actual && good}
    let single=observed(bytes,0,true,limit,events,issues)
    return single && good
}
func pure(selected:String):Unit {
    let z="text:Z:false/false/false|";let b="text:B:false/false/false|";let up="up::false/false/false|"
    var good=true
    match(selected){
        case "K115-01"=>
            let utf=vector([27,93,27,0xc3,0x9c,113,7,90],64,z,"UnsupportedSequence@0;")
            let raw=vector([27,93,27,0x9c,90],64,z,"UnsupportedSequence@0;")
            good=utf && raw
        case "K115-02"=>
            let scalar=vector([27,91,32,49,0xc2,0xa0,50,65,66],64,b,"MalformedSequence@0;")
            let continuation=vector([27,91,0xe4,0xb8,0x9b,65,66],64,b,"MalformedSequence@0;")
            good=scalar && continuation
        case "K115-03"=>
            let rawCsi=vector([27,0x9b,65],64,up,"")
            let utfCsi=vector([27,0xc2,0x9b,65],64,up,"")
            let rawOsc=vector([27,0x9d,113,7,90],64,z,"UnsupportedSequence@1;")
            let utfOsc=vector([27,0xc2,0x9d,113,7,90],64,z,"UnsupportedSequence@1;")
            good=rawCsi && utfCsi && rawOsc && utfOsc
        case "K115-04"=>
            let asciiExact=vector([27,120,66],2,"text:x:false/true/false|"+b,"")
            let asciiOver=vector([27,120,66],1,b,"SequenceTooLong@0;")
            let utfExact=vector([27,0xc3,0x9c,66],3,"text:Ü:false/true/false|"+b,"")
            let utfOver=vector([27,0xc3,0x9c,66],2,b,"SequenceTooLong@0;")
            good=asciiExact && asciiOver && utfExact && utfOver
        case _=>throw Exception("unknown pure selector ${selected}")
    }
    check(good,selected+" literal vectors match manual oracle at every split and bytewise")
}
func nativeStop():Unit {
    let directory=getVariable("CJTUI_K115_OUTPUT").getOrThrow()
    let report={name:String,value:String=>File.writeTo(directory+"/"+name,value.toArray())}
    let issues=Box<Int64>(0);let xs=Box<Int64>(0);let cleanup=Box<Int64>(0)
    let root=Text("K115-ISSUE-STOP-READY").focusable(true).viewport(ScrollAxes.Off)
        .onMount({_=>{=>cleanup.value++;report("cleanup","${cleanup.value}")}})
    let app=Application(root)
    root.onKey({event=>if(event.key.text=="x"){xs.value++;report("x","${xs.value}")}})
    app.onKeyboardIssue({diagnostic=>
        issues.value++;report("issue","${issueName(diagnostic.kind)}@${diagnostic.offset};count=${issues.value}")
        check(app.focusedNode().getOrThrow().sameNode(root.reference().getOrThrow()),"native active base focus control")
        app.stop()
    })
    var caught=false;var message=""
    try{app.run()}catch(error:Exception){caught=true;message=error.message}
    let stats=app.stats();let released=stats.mountedNodes==0 && stats.activeBindings==0 && stats.subscriptions==0 && stats.pendingPosts==0
    report("summary","issues=${issues.value}\nx=${xs.value}\ncaught=${caught}\nmessage=${message}\ncleanup=${cleanup.value}\nreleased=${released}\n")
    check(issues.value==1 && cleanup.value==1 && released,"native issue reached once and cleanup/resources control")
    check(!caught && xs.value==0,"K115-05 diagnostic stop cancels same-byte retry and run returns normally")
}
main():Int64 {
    let selected=getVariable("CJTUI_K115_CASE").getOrThrow()
    if(selected=="K115-05"){nativeStop()}else{pure(selected)}
    println("PASS ${selected}");0
}
