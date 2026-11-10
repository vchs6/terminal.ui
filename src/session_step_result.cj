package cjtui

public class SessionStepResult {
    public let operation: SessionOperation
    public let status: SessionStatus
    public let emittedBytes: Int64
    public let issue: SessionIssue

    init(operation: SessionOperation, status: SessionStatus, emittedBytes: Int64, issue: SessionIssue) {
        this.operation = operation
        this.status = status
        this.emittedBytes = emittedBytes
        this.issue = issue
    }
}
