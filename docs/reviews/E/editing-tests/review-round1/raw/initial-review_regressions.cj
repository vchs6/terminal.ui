package editing_contract
import cjtui.*
import std.collection.ArrayList

func reviewSnapshotBinding(): Unit {
    let source=Observable<String>("abc");let ctl=TextEditController()
    let label=Box<String>("")
    let root=Column {
        TextInput(source,controller:Some(ctl)).height(1)
        Text({=>if(ctl.isValid()){
            let s=ctl.snapshot();label.value=s.text+"@${s.selection.caret}";label.value
        }else{"detached"}}).height(1)
    }
    let app=Application(root,theme:plainTheme());app.startHeadless()
    try {
        app.snapshot(8,2)
        app.batch({=>ctl.select(TextSelection(2,2));source.set("Z")})
        let committed=ctl.snapshot();let frame=app.snapshot(8,2).toPlainText()
        println("I01 controller=${committed.text}@${committed.selection.caret} getter=${label.value} frame=[${frame}]")
        check(committed.text=="Z" && committed.selection==TextSelection(1,1),"E120-I01 committed source synchronization")
        check(label.value=="Z@1" && frame=="Z       \nZ@1     ","E120-I01 samebatch dependent getter/frame see committed Z@1")
    }finally{app.dispose()}
}

func reviewDetachedEditors(): Unit {
    let mounts=Box<Int64>(0);let cleanups=Box<Int64>(0)
    let a=TextEditController();let b=TextEditController()
    let one=Observable<String>("abc");let two=Observable<String>("a\nb")
    let input=TextInput(one,controller:Some(a)).onMount({_=>mounts.value++;{=>cleanups.value++}})
    let area=TextArea(two,controller:Some(b)).onMount({_=>mounts.value++;{=>cleanups.value++}})
    let before=input.reference().isNone() && area.reference().isNone() && !a.isValid() && !b.isValid()
    let first=render(input,3,1).toPlainText();let second=render(area,3,2).toPlainText()
    let after=input.reference().isNone() && area.reference().isNone() && !a.isValid() && !b.isValid()
    println("I02 input=[${first}] area=[${second}] mounts=${mounts.value} cleanup=${cleanups.value} detachedBefore=${before} detachedAfter=${after}")
    check(first=="abc" && second=="a  \nb  ","E120-I02 detached input/area paint literal text through pure render")
    check(before && after && mounts.value==0 && cleanups.value==0 && one.get()=="abc" && two.get()=="a\nb",
        "E120-I02 detached export publishes no handles and runs no lifecycle effects")
}

func reviewHistoryDirection(direction:String): Bool {
    let source=Observable<String>("ab\n12345\nXY");let ctl=TextEditController()
    let area=TextArea(source,controller:Some(ctl));let app=Application(area);app.startHeadless()
    try {
        app.snapshot(12,3)
        ui(app,{=>ctl.select(TextSelection(1,1));ctl.replaceSelection("!")})
        if(direction=="undo"){
            ui(app,{=>ctl.select(TextSelection(8,8))});key(app,area,"down")
            let prior=ctl.snapshot();let changed=ui(app,{=>ctl.undo()});let restored=ctl.snapshot()
            key(app,area,"down");let next=ctl.snapshot()
            println("I03 undo prior=${prior.selection.caret} changed=${changed} restored=${restored.selection.caret} down=${next.selection.caret}")
            return prior.selection==TextSelection(12,12) && changed && restored.text=="ab\n12345\nXY" &&
                restored.selection==TextSelection(1,1) && next.selection==TextSelection(4,4)
        }
        let undone=ui(app,{=>ctl.undo()})
        ui(app,{=>ctl.select(TextSelection(7,7))});key(app,area,"down")
        let prior=ctl.snapshot();let changed=ui(app,{=>ctl.redo()});let restored=ctl.snapshot()
        key(app,area,"down");let next=ctl.snapshot()
        println("I03 redo prior=${prior.selection.caret} undone=${undone} changed=${changed} restored=${restored.selection.caret} down=${next.selection.caret}")
        return undone && prior.selection==TextSelection(11,11) && changed && restored.text=="a!b\n12345\nXY" &&
            restored.selection==TextSelection(2,2) && next.selection==TextSelection(6,6)
    }finally{app.dispose()}
}
func reviewHistoryColumn(): Unit {
    let undo=reviewHistoryDirection("undo");let redo=reviewHistoryDirection("redo")
    check(undo && redo,"E120-I03 undo and redo reset preferred display column before Down")
}

// Only public scheduling: one worker write after a key-handler GO, no sleep/hook.
// A non-hit does not identify the private early planning window or prove it fixed.
func reviewKeyboardPlanningRace(): Unit {
    let initial=ascii(65536);let oldAfter=ascii(65535)
    var bad=false;var rounds:Int64=0
    for(attempt in 0..4){
        let source=Observable<String>(initial);let ctl=TextEditController()
        let changes=ArrayList<String>();let issues=ArrayList<TextEditIssue>()
        let ready=Gate();let go=Gate();let owner=Thread.currentThread.id
        let area=TextInput(source,controller:Some(ctl),onChange:{text=>changes.add(text)},onIssue:{issue=>issues.add(issue)})
            .onKey({event=>if(event.key.code=="backspace"){println("I04 attempt=${attempt} public-key-GO");go.open()}})
        let app=Application(area);app.startHeadless()
        ui(app,{=>ctl.select(TextSelection(65536,65536))})
        let worker=spawn{
            let distinct=Thread.currentThread.id!=owner
            ready.open();go.awaitOpen();source.set("YZ")
            println("I04 attempt=${attempt} worker committed YZ distinct=${distinct}")
            distinct
        }
        var errorType="none";var errorMessage="";var good=false
        try {
            ready.awaitOpen()
            try{key(app,area,"backspace")}
            catch(error:IllegalArgumentException){errorType="IllegalArgumentException";errorMessage=error.message}
            catch(error:Exception){errorType="Exception";errorMessage=error.message}
            let distinct=worker.get(Duration.second*10)
            if(ctl.isValid()){
                app.batch({=>})
                let final=source.get();let local=ctl.snapshot()
                let conflict=issues.size==1 && issues[0]==TextEditIssue.ConcurrentValueChanged
                let success=issues.size==0 && changes.size==1 && (changes[0]==oldAfter || changes[0]=="Y")
                let rejected=conflict && changes.size==0 && final=="YZ" && !local.canUndo && !local.canRedo
                good=distinct && errorType=="none" && (success || rejected) &&
                    (final=="YZ" || final=="Y") && local.text==final
                let changedTag=if(changes.size==1){if(changes[0]==oldAfter){"oldTruncated"}else if(changes[0]=="Y"){"newY"}else{"OTHER"}}else{"none/multiple"}
                println("I04 attempt=${attempt} error=${errorType} changes=${changes.size}/${changedTag} issues=${issues.size} conflict=${conflict} final=${final} undo=${local.canUndo} redo=${local.canRedo} validOutcome=${good}")
            }else{println("I04 attempt=${attempt} error=${errorType} message=${errorMessage} changes=${changes.size} issues=${issues.size} controllerRevoked=true")}
        }finally{worker.get(Duration.second*10);app.dispose()}
        rounds++;bad=bad || !good
        if(bad){break}
    }
    println("I04 rounds=${rounds} publicFailure=${bad}; exact early-window attribution requires fixed-source proof, not normal timings/lateCAS")
    check(!bad,"E120-I04 valid public keyboard/worker interleaving must not throw or apply an invalid stale deletion")
    println("INSUFFICIENT_EVIDENCE E120-I04 specific early planning window not forced by public API; source-only interleaving remains distinct")
}
func reviewRegression(selected:String): Unit {
    match(selected){
        case "E120-I01"=>reviewSnapshotBinding()
        case "E120-I02"=>reviewDetachedEditors()
        case "E120-I03"=>reviewHistoryColumn()
        case "E120-I04"=>reviewKeyboardPlanningRace()
        case _=>throw Exception("unknown editing review selector ${selected}")
    }
    println("PASS ${selected}")
}
