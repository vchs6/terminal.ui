package keyboard_contract
import cjtui.*

class GoldenCase {
    let name: String
    let bytes: Array<UInt8>
    let events: Array<KeyEvent>
    let issues: Array<ExpectedIssue>
    init(name: String, bytes: Array<UInt8>, events: Array<KeyEvent>, issues!: Array<ExpectedIssue> = []) {
        this.name = name; this.bytes = bytes; this.events = events; this.issues = issues
    }
}
