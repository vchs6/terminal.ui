package keyboard_contract
import cjtui.*

// F006/I015: the standalone public decoder has no device reply contact.
// Exact 9-byte mode25 reports remain ordinary unsupported framed CSI here.
func protocolReportCases():Unit {
    for(status in ["0","1","2","3","4"]){
        for(limit in [9,64]){
            allSplits(GoldenCase("public report ${status} budget${limit}",("a\u{1b}[?25;${status}$yb").toArray(),
                [KeyEvent("text",text:"a"),KeyEvent("text",text:"b")],
                issues:[ExpectedIssue(KeyboardIssue.UnsupportedSequence,1)]),limits:KeyboardLimits(maxSequenceBytes:limit))
        }
        allSplits(GoldenCase("public report not budget exempt ${status}",("a\u{1b}[?25;${status}$yb").toArray(),
            [KeyEvent("text",text:"a"),KeyEvent("text",text:"b")],
            issues:[ExpectedIssue(KeyboardIssue.SequenceTooLong,1)]),limits:KeyboardLimits(maxSequenceBytes:8))
    }
    allSplits(GoldenCase("UTF8 C1 cancels unfinished CSI without extra issue",[27,91,49,0xc2,0x9b,65],[KeyEvent("up")]))
}
