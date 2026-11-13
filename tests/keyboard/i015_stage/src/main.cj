package keyboard_i015_stage
import cjtui.*
import std.env.*
import std.fs.*
func check(ok:Bool,message:String):Unit{if(!ok){throw Exception("FAIL K-I015-STAGE ${message}")}}
main():Int64 {
    let directory=getVariable("CJTUI_KEYBOARD_I015_OUTPUT").getOrThrow()
    let report={name:String,text:String=>File.writeTo(directory+"/"+name,text.toArray())}
    let events=Box<String>("");let issues=Box<String>("");let queries=Box<Int64>(0);let cleanups=Box<Int64>(0)
    let root=Text("K-I015-STAGE-READY").focusable(true).viewport(ScrollAxes.Off).onMount({_=>{=>cleanups.value++;report("cleanup","${cleanups.value}")}})
    let app=Application(root)
    root.onKey({event=>
        events.value+="${event.key.code}:${event.key.text}|"
        if(event.key.text=="s"){
            queries.value++;let cap=app.terminalCapabilities().getOrThrow()
            report("state-${queries.value}","${cap.cursorVisibilityStatus}\n${issues.value}\n${events.value}")
        }
        if(event.key.text=="q"){app.stop();event.preventDefault()}
    })
    app.onKeyboardIssue({diagnostic=>
        let name=if(diagnostic.kind==KeyboardIssue.IncompleteInput){"IncompleteInput"}else{"Other"}
        issues.value+="${name}@${diagnostic.offset};"
        report("issues",issues.value)
        report("issue-cap",app.terminalCapabilities().getOrThrow().cursorVisibilityStatus)
    })
    app.run()
    let cap=app.terminalCapabilities().getOrThrow();let stats=app.stats()
    report("closed","${cap.cursorVisibilityStatus}\n${issues.value}\n${events.value}\ncleanup=${cleanups.value}\nresources=${stats.mountedNodes}/${stats.activeBindings}/${stats.subscriptions}/${stats.pendingPosts}\n")
    check(issues.value=="IncompleteInput@0;","exactly one real-idle issue, no deadline wakeup timeout")
    check(events.value=="text:1|text:$|text:y|text:s|text:s|text:q|","timed-out tail normal; cross-deadline tail swallowed, not rebuilt")
    check(cap.cursorVisibilityStatus=="unknown-timeout","no late authorization or report reconstruction")
    check(cleanups.value==1 && stats.mountedNodes==0 && stats.activeBindings==0 && stats.subscriptions==0 && stats.pendingPosts==0,"cleanup/resources")
    0
}
