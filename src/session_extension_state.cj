package cjtui

import std.collection.ArrayList

// Owned by the existing RuntimeSession. No device, thread or queue ownership.
class SessionExtensionState {
    let capabilities: SessionCapabilities
    private var titleScope = false
    private var unrestorableTitle = false
    private var closed = false
    private var cleanupResults = Array<SessionResult>()

    init(id: Int64, options: SessionOptions, device: Bool) {
        capabilities = createSessionCapabilities(id, options, device)
    }

    func capability(operation: SessionOperation): SessionCapability {
        match (operation) {
            case SessionOperation.CopyLocalText => capabilities.clipboard
            case SessionOperation.SetHostTitle => capabilities.title
            case SessionOperation.SaveHostTitle | SessionOperation.RestoreHostTitle => capabilities.titleStack
            case SessionOperation.SetHostImageIcon => capabilities.imageIcon
        }
    }

    func titleRestore(): TitleRestoreState {
        if (titleScope) {
            TitleRestoreState.SaveSentUnconfirmed
        } else if (unrestorableTitle) {
            TitleRestoreState.Unavailable
        } else {
            TitleRestoreState.NotNeeded
        }
    }

    func result(operation: SessionOperation, status: SessionStatus, issue: SessionIssue, offset!: Int64 = -1,
        restore!: TitleRestoreState = TitleRestoreState.NotNeeded,
        steps!: Array<SessionStepResult> = Array<SessionStepResult>()): SessionResult {
        var total: Int64 = 0
        for (step in steps) {
            total += step.emittedBytes
        }
        SessionResult(capabilities.sessionId, operation, status, capability(operation), total, issue, offset, restore,
            steps)
    }

    func failure(operation: SessionOperation, issue: SessionIssue, offset!: Int64 = -1): SessionResult {
        result(operation, SessionStatus.Failed, issue, offset: offset)
    }

    private func unsupported(operation: SessionOperation): ?SessionResult {
        let cap = capability(operation)
        if (cap.support == SessionSupport.Unsupported) {
            return Some(result(operation, SessionStatus.Unsupported, cap.reason))
        }
        None
    }

    private func send(session: RuntimeSession, wire: String, checkCancel: Bool): SessionWriteResult {
        if (checkCancel && session.isStopping()) {
            return SessionWriteResult(0, SessionIssue.Cancelled, false)
        }
        let output = writeTerminal(wire, session, checkCancel)
        if (output.issue == SessionIssue.WriteFailed || output.issue == SessionIssue.ParserUnsynchronized) {
            session.recordDeviceFailure()
        }
        output
    }

    private func appendStep(steps: ArrayList<SessionStepResult>, operation: SessionOperation, output: SessionWriteResult): Unit {
        if (output.attempted) {
            steps.add(
                SessionStepResult(operation, if (output.issue == SessionIssue.NoIssue) {
                    SessionStatus.SentUnconfirmed
                } else {
                    SessionStatus.Failed
                }, output.emittedBytes, output.issue))
        }
    }

    private func sendResult(operation: SessionOperation, output: SessionWriteResult,
        steps: ArrayList<SessionStepResult>, restore: TitleRestoreState): SessionResult {
        appendStep(steps, operation, output)
        let issue = if (output.issue == SessionIssue.WriteFailed && output.emittedBytes > 0) {
            SessionIssue.ParserUnsynchronized
        } else {
            output.issue
        }
        result(operation, if (issue == SessionIssue.NoIssue) {
            SessionStatus.SentUnconfirmed
        } else {
            SessionStatus.Failed
        }, issue, restore: restore, steps: steps.toArray())
    }

    func copyText(session: RuntimeSession, text: String): SessionResult {
        let operation = SessionOperation.CopyLocalText
        let (issue, offset) = validateSessionText(text, 65536, false)
        if (issue != SessionIssue.NoIssue) {
            return failure(operation, issue, offset: offset)
        }
        if (let Some(value) <- unsupported(operation)) {
            return value
        }
        let wire = wrapSessionSequence("\u{1b}]52;c;" + encodeSessionBase64(text.toArray()) + "\u{7}",
            capabilities.clipboard.route)
        if (wire.size > 90000) {
            return failure(operation, SessionIssue.WireTooLarge, offset: 90000)
        }
        let output = send(session, wire, true)
        sendResult(operation, output, ArrayList<SessionStepResult>(), TitleRestoreState.NotNeeded)
    }

    func setTitle(session: RuntimeSession, text: String): SessionResult {
        let operation = SessionOperation.SetHostTitle
        let (issue, offset) = validateSessionText(text, 1024, true)
        if (issue != SessionIssue.NoIssue) {
            return failure(operation, issue, offset: offset)
        }
        if (let Some(value) <- unsupported(operation)) {
            return value
        }
        let route = capabilities.title.route
        let setWire = wrapSessionSequence("\u{1b}]2;" + text + "\u{7}", route)
        let needsSave = !titleScope && capabilities.titleStack.support == SessionSupport.Supported
        let saveWire = if (needsSave) {
            wrapSessionSequence("\u{1b}[22;2t", route)
        } else {
            ""
        }
        if (setWire.size > 90000 || saveWire.size > 90000) {
            return failure(operation, SessionIssue.WireTooLarge, offset: 90000)
        }
        let steps = ArrayList<SessionStepResult>()
        if (session.isStopping()) {
            return failure(operation, SessionIssue.Cancelled)
        }
        if (needsSave) {
            if (!prepareTerminalSequence(if (setWire.size >= saveWire.size) {
                setWire
            } else {
                saveWire
            })) {
                return failure(operation, SessionIssue.AllocationFailed)
            }
            let saved = send(session, saveWire, true)
            appendStep(steps, SessionOperation.SaveHostTitle, saved)
            if (saved.issue != SessionIssue.NoIssue) {
                let problem = if (saved.issue == SessionIssue.WriteFailed && saved.emittedBytes > 0) {
                    SessionIssue.ParserUnsynchronized
                } else {
                    saved.issue
                }
                return result(operation, SessionStatus.Failed, problem, restore: TitleRestoreState.Failed,
                    steps: steps.toArray())
            }
            titleScope = true
        }
        let output = send(session, setWire, !needsSave)
        if (!titleScope && output.emittedBytes > 0) {
            unrestorableTitle = true
        }
        sendResult(operation, output, steps, titleRestore())
    }

    func restoreTitle(session: RuntimeSession, cleanup!: Bool = false): SessionResult {
        let operation = SessionOperation.RestoreHostTitle
        if (!cleanup) {
            if (let Some(value) <- unsupported(operation)) {
                return value
            }
            if (session.isStopping()) {
                return failure(operation, SessionIssue.Cancelled)
            }
        }
        if (!titleScope) {
            return result(operation, SessionStatus.Unknown, if (unrestorableTitle) {
                SessionIssue.RestoreUnavailable
            } else {
                SessionIssue.NoSavedTitle
            }, restore: titleRestore())
        }
        if (unsafe { cjt_output_unsafe() } != 0) {
            return result(operation, SessionStatus.Failed, SessionIssue.ParserUnsynchronized,
                restore: TitleRestoreState.Failed)
        }
        let wire = wrapSessionSequence("\u{1b}[23;2t", capabilities.titleStack.route)
        let output = send(session, wire, !cleanup)
        if (output.issue == SessionIssue.NoIssue) {
            titleScope = false
            unrestorableTitle = false
        }
        sendResult(operation, output, ArrayList<SessionStepResult>(), if (output.issue == SessionIssue.NoIssue) {
            TitleRestoreState.RestoreSentUnconfirmed
        } else {
            TitleRestoreState.Failed
        })
    }

    func setIcon(png: Array<UInt8>): SessionResult {
        if (png.size > 1048576) {
            return failure(SessionOperation.SetHostImageIcon, SessionIssue.PayloadTooLarge, offset: 1048576)
        }
        result(SessionOperation.SetHostImageIcon, SessionStatus.Unsupported, SessionIssue.NoImageAdapter)
    }

    func cleanupSnapshot(): Array<SessionResult> {
        Array<SessionResult>(cleanupResults.size, {index => cleanupResults[index].copy()})
    }

    func close(session: RuntimeSession): Unit {
        if (closed) {
            return
        }
        closed = true
        if (titleScope || unrestorableTitle) {
            let value = restoreTitle(session, cleanup: true)
            cleanupResults = [value.copy()]
            if (value.status == SessionStatus.Failed) {
                throw Exception("host title restore failed; visual title state not confirmed")
            }
        }
    }
}
