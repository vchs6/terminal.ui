package keyboard_malformed_drain
import cjtui.*
import std.collection.*
func check(ok:Bool,name:String):Unit{if(!ok){throw Exception("FAIL K-DRAIN ${name}")}}
func observe(bytes:Array<UInt8>,split:Int64,compat:Bool):Bool {
    let decoder=KeyboardDecoder(limits:KeyboardLimits(maxSequenceBytes:8))
    let first=decoder.feed(bytes.slice(0,split))
    let second=decoder.feed(bytes.slice(split,bytes.size-split))
    let last=decoder.finish()
    let events=ArrayList<KeyEvent>();let issues=ArrayList<KeyboardDiagnostic>()
    for(batch in [first,second,last]){events.add(all:batch.events);issues.add(all:batch.diagnostics)}
    var diagnostics=""
    for(issue in issues){
        let name=if(issue.kind==KeyboardIssue.MalformedSequence){"MalformedSequence"}else if(issue.kind==KeyboardIssue.SequenceTooLong){"SequenceTooLong"}else if(issue.kind==KeyboardIssue.InvalidUtf8){"InvalidUtf8"}else{"Other"}
        diagnostics+="${name}@${issue.offset};"
    }
    println("compat=${compat} split=${split} events=${events.size} issues=${diagnostics}")
    if(compat){
        return events.size==1 && events[0].code=="up" && events[0].text=="" && !events[0].ctrl && !events[0].alt && !events[0].shift && issues.size==1 && issues[0].kind==KeyboardIssue.InvalidUtf8 && issues[0].offset==1
    }
    return events.size==2 && events[0].code=="text" && events[0].text=="A" && events[1].code=="text" && events[1].text=="B" && issues.size==1 && issues[0].kind==KeyboardIssue.MalformedSequence && issues[0].offset==1
}
main():Int64 {
    // Root's K002/F007 compatibility reading: bad UTF8 prefix keeps its own
    // InvalidUtf8@1; new ESC starts up, adding no cancel Incomplete/Malformed.
    let compat=observe([27,0xe4,27,91,65],5,true)
    // Sequence starts at1: ESC [ 1 SP 2 is already malformed at length5,
    // before max8. Five more parameter bytes exceed8 while draining, then
    // final A ends discard. Only outer text A/B survive, first issue only.
    let bytes:Array<UInt8>=[65,27,91,49,32,50,50,50,50,50,50,65,66]
    var drain=true
    for(split in 0..(bytes.size+1)){let good=observe(bytes,split,false);drain=drain && good}
    check(compat,"UTF8 cancellation preserves InvalidUtf8@1 and new up only")
    check(drain,"malformed first issue remains single while overlimit payload drains at all splits")
    println("PASS K-DRAIN")
    0
}
