package cjtui

public class SessionResult {
    public let sessionId: Int64
    public let operation: SessionOperation
    public let status: SessionStatus
    public let capability: SessionCapability
    public let emittedBytes: Int64
    public let issue: SessionIssue
    public let errorByteOffset: Int64
    public let restore: TitleRestoreState
    public let steps: Array<SessionStepResult>

    init(sessionId: Int64, operation: SessionOperation, status: SessionStatus, capability: SessionCapability,
        emittedBytes: Int64, issue: SessionIssue, errorByteOffset: Int64, restore: TitleRestoreState,
        steps: Array<SessionStepResult>) {
        this.sessionId = sessionId
        this.operation = operation
        this.status = status
        this.capability = capability
        this.emittedBytes = emittedBytes
        this.issue = issue
        this.errorByteOffset = errorByteOffset
        this.restore = restore
        this.steps = steps.clone()
    }

    func copy(): SessionResult {
        SessionResult(
            sessionId,
            operation,
            status,
            capability,
            emittedBytes,
            issue,
            errorByteOffset,
            restore,
            Array<SessionStepResult>(
                steps.size,
                {
                    i =>
                        let step = steps[i]
                        SessionStepResult(step.operation, step.status, step.emittedBytes, step.issue)
                }
            )
        )
    }
}
