package keyboard_contract
import cjtui.*

class ExpectedIssue {
    let kind: KeyboardIssue
    let offset: Int64
    init(kind: KeyboardIssue, offset: Int64) { this.kind = kind; this.offset = offset }
}
