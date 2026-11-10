package keyboard_contract
import cjtui.*
import std.collection.*

// Collection only: no parsing or normalization in the test harness.
class Observed {
    let events = ArrayList<KeyEvent>()
    let issues = ArrayList<KeyboardDiagnostic>()
    func add(batch: KeyboardBatch): Unit {
        events.add(all: batch.events); issues.add(all: batch.diagnostics)
    }
    func expect(wantEvents: Array<KeyEvent>, wantIssues: Array<ExpectedIssue>, name: String): Unit {
        check(events.size == wantEvents.size, "${name}: event count ${events.size}/${wantEvents.size}")
        for (i in 0..wantEvents.size) {
            let got = events[i]; let want = wantEvents[i]
            check(got.code == want.code && got.text == want.text && got.ctrl == want.ctrl &&
                got.alt == want.alt && got.shift == want.shift, "${name}: event ${i}")
        }
        check(issues.size == wantIssues.size, "${name}: diagnostic count ${issues.size}/${wantIssues.size}")
        for (i in 0..wantIssues.size) {
            check(issues[i].kind == wantIssues[i].kind && issues[i].offset == wantIssues[i].offset,
                "${name}: diagnostic ${i} kind/offset")
        }
    }
}
