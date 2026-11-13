package cjtui

class SessionWriteResult {
    let emittedBytes: Int64
    let issue: SessionIssue
    let attempted: Bool

    init(emittedBytes: Int64, issue: SessionIssue, attempted: Bool) {
        this.emittedBytes = emittedBytes
        this.issue = issue
        this.attempted = attempted
    }
}
