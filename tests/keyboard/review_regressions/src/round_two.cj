package keyboard_review_regressions
import cjtui.*
func roundTwoTimeout():Bool {
    let decoder=KeyboardDecoder(limits:KeyboardLimits(maxSequenceBytes:1))
    let prefix=decoder.feed([27,0xc2])
    let timed=decoder.timeout()
    let tail=decoder.feed([49,65,66])
    let end=decoder.finish()
    var events="";var issues=""
    for(batch in [prefix,timed,tail,end]){
        for(key in batch.events){events+="${key.code}:${key.text}:${key.ctrl}/${key.alt}/${key.shift}|"}
        for(issue in batch.diagnostics){issues+="${issueName(issue.kind)}@${issue.offset};"}
    }
    println("fixed timeout prefix=1b c2 limit=1 tail=31 41 42 events=${events} issues=${issues}")
    return events=="text:B:false/false/false|" && issues=="SequenceTooLong@0;"
}
func roundTwo():Unit {
    // ESC+E4 exceeds raw budget1 before bad continuation31. Remain in
    // ordinary error isolation through final41; only following42 is text.
    let literal=vector([27,0xe4,49,65,66],1,"text:B:false/false/false|","SequenceTooLong@0;")
    // Complete observations for the fixed timeout control before asserting.
    let timed=roundTwoTimeout()
    check(literal && timed,"K115-R1-01 oversized Alt remains isolated through invalid continuation and timeout")
}
