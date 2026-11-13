package keyboard_malformed_drain
import cjtui.*
import std.collection.*
import std.env.*
func check(ok:Bool,name:String):Unit{if(!ok){throw Exception("FAIL K-DRAIN ${name}")}}
func observe(bytes:Array<UInt8>,split:Int64,compat:Bool,timeoutAfterMalformed!:Bool=false):Bool {
    let decoder=KeyboardDecoder(limits:KeyboardLimits(maxSequenceBytes:8))
    let first=decoder.feed(bytes.slice(0,split))
    let events=ArrayList<KeyEvent>();let issues=ArrayList<KeyboardDiagnostic>()
    events.add(all:first.events);issues.add(all:first.diagnostics)
    if(timeoutAfterMalformed){
        check(first.diagnostics.size==1 && first.diagnostics[0].kind==KeyboardIssue.MalformedSequence && first.diagnostics[0].offset==1,"fixed timeout position follows emitted Malformed before sequence budget8")
        let timed=decoder.timeout();events.add(all:timed.events);issues.add(all:timed.diagnostics)
    }
    let second=decoder.feed(bytes.slice(split,bytes.size-split))
    let last=decoder.finish()
    for(batch in [second,last]){events.add(all:batch.events);issues.add(all:batch.diagnostics)}
    var diagnostics=""
    for(issue in issues){
        let name=if(issue.kind==KeyboardIssue.MalformedSequence){"MalformedSequence"}else if(issue.kind==KeyboardIssue.SequenceTooLong){"SequenceTooLong"}else if(issue.kind==KeyboardIssue.InvalidUtf8){"InvalidUtf8"}else{"Other"}
        diagnostics+="${name}@${issue.offset};"
    }
    var eventTrace=""
    for(event in events){eventTrace+="${event.code}:${event.text}|"}
    println("compat=${compat} timeout=${timeoutAfterMalformed} split=${split} events=${eventTrace} issues=${diagnostics}")
    if(compat){
        return events.size==1 && events[0].code=="up" && events[0].text=="" && !events[0].ctrl && !events[0].alt && !events[0].shift && issues.size==1 && issues[0].kind==KeyboardIssue.InvalidUtf8 && issues[0].offset==1
    }
    return events.size==2 && events[0].code=="text" && events[0].text=="A" && events[1].code=="text" && events[1].text=="B" && issues.size==1 && issues[0].kind==KeyboardIssue.MalformedSequence && issues[0].offset==1
}
func altTimeoutControl():Bool {
    // Exact existing temporal-case control: A0, ESC1, UTF8 lead2/tail3;
    // timeout belongs to the whole Alt sequence and points at ESC1.
    let decoder=KeyboardDecoder()
    let first=decoder.feed([65,27,0xe4,0xb8]);let timed=decoder.timeout()
    let second=decoder.feed([66]);let last=decoder.finish()
    let events=ArrayList<KeyEvent>();let issues=ArrayList<KeyboardDiagnostic>()
    for(batch in [first,timed,second,last]){events.add(all:batch.events);issues.add(all:batch.diagnostics)}
    let offset=if(issues.size==1){issues[0].offset}else{-1}
    println("alt-timeout events=${events.size} issueCount=${issues.size} offset=${offset}")
    return events.size==2 && events[0].code=="text" && events[0].text=="A" && events[1].code=="text" && events[1].text=="B" && issues.size==1 && issues[0].kind==KeyboardIssue.IncompleteInput && issues[0].offset==1
}
main():Int64 {
    let selected=getVariable("CJTUI_KEYBOARD_I015_PURE_CASE") ?? "malformed-drain"
    match(selected){
        case "malformed-drain"=>
            // ESC [ 1 SP 2 is malformed at sequence length5 before max8.
            // Five more digits exceed8; final A ends drain, outer A/B survive.
            let bytes:Array<UInt8>=[65,27,91,49,32,50,50,50,50,50,50,65,66]
            var drain=true
            for(split in 0..(bytes.size+1)){let good=observe(bytes,split,false);drain=drain && good}
            let timed=observe(bytes,6,false,timeoutAfterMalformed:true)
            check(drain && timed,"malformed first issue remains single through overlimit and fixed-timeout drain")
        case "alt-invalid-offset"=>
            let timeoutControl=altTimeoutControl()
            // Root ruling: InvalidUtf8 names the bad UTF8 prefix E4 at byte1;
            // F007 adds no cancel Incomplete/Malformed and still permits new up.
            let invalid=observe([27,0xe4,27,91,65],5,true)
            check(timeoutControl,"existing Alt timeout keeps ESC offset and normal remainder")
            check(invalid,"UTF8 cancellation preserves InvalidUtf8@1 and new up only")
        case _=>throw Exception("unknown pure stage selector ${selected}")
    }
    println("PASS K-DRAIN ${selected}")
    0
}
