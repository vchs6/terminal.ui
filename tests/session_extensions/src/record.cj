package session_extensions
import cjtui.*
import std.env.*
import std.fs.*
var records = ""
var aliasStep: ?SessionStepResult = Option<SessionStepResult>.None
func note(key: String, value: String): Unit { records += "${key}\t${value}\n" }
func check(value: Bool, label: String): Unit { if (!value) { throw Exception("ASSERT:${label}") } }
func saveRecords(): Unit {
    File.writeTo(getVariable("CJTUI_SESSION_RESULTS").getOrThrow(), records.toArray())
}
func operation(value: SessionOperation): String {
    match (value) {
        case SessionOperation.CopyLocalText => "CopyLocalText"
        case SessionOperation.SetHostTitle => "SetHostTitle"
        case SessionOperation.SaveHostTitle => "SaveHostTitle"
        case SessionOperation.RestoreHostTitle => "RestoreHostTitle"
        case SessionOperation.SetHostImageIcon => "SetHostImageIcon"
    }
}
func status(value: SessionStatus): String {
    match (value) {
        case SessionStatus.Applied => "Applied"
        case SessionStatus.SentUnconfirmed => "SentUnconfirmed"
        case SessionStatus.Unsupported => "Unsupported"
        case SessionStatus.Unknown => "Unknown"
        case SessionStatus.Failed => "Failed"
    }
}
func support(value: SessionSupport): String {
    match (value) { case SessionSupport.Supported => "Supported"; case SessionSupport.Unsupported => "Unsupported"; case SessionSupport.Unknown => "Unknown" }
}
func basis(value: SessionBasis): String {
    match (value) {
        case SessionBasis.NoEvidence => "NoEvidence"
        case SessionBasis.ExplicitConfiguration => "ExplicitConfiguration"
        case SessionBasis.KnownUnavailable => "KnownUnavailable"
        case SessionBasis.VerifiedAdapter => "VerifiedAdapter"
    }
}
func route(value: SessionRoute): String {
    match (value) { case SessionRoute.Direct => "Direct"; case SessionRoute.TmuxPassthrough => "TmuxPassthrough"; case SessionRoute.ScreenPassthrough => "ScreenPassthrough" }
}
func restore(value: TitleRestoreState): String {
    match (value) {
        case TitleRestoreState.NotNeeded => "NotNeeded"
        case TitleRestoreState.Unavailable => "Unavailable"
        case TitleRestoreState.SaveSentUnconfirmed => "SaveSentUnconfirmed"
        case TitleRestoreState.RestoreSentUnconfirmed => "RestoreSentUnconfirmed"
        case TitleRestoreState.RestoreConfirmed => "RestoreConfirmed"
        case TitleRestoreState.Failed => "Failed"
    }
}
func issue(value: SessionIssue): String {
    match (value) {
        case SessionIssue.NoIssue => "NoIssue"
        case SessionIssue.InvalidUtf8 => "InvalidUtf8"
        case SessionIssue.ForbiddenControl => "ForbiddenControl"
        case SessionIssue.PayloadTooLarge => "PayloadTooLarge"
        case SessionIssue.WireTooLarge => "WireTooLarge"
        case SessionIssue.Disabled => "Disabled"
        case SessionIssue.NoDevice => "NoDevice"
        case SessionIssue.NoImageAdapter => "NoImageAdapter"
        case SessionIssue.NoSavedTitle => "NoSavedTitle"
        case SessionIssue.InvalidContext => "InvalidContext"
        case SessionIssue.SessionInactive => "SessionInactive"
        case SessionIssue.Cancelled => "Cancelled"
        case SessionIssue.AllocationFailed => "AllocationFailed"
        case SessionIssue.WriteFailed => "WriteFailed"
        case SessionIssue.ParserUnsynchronized => "ParserUnsynchronized"
        case SessionIssue.RestoreUnavailable => "RestoreUnavailable"
        case SessionIssue.UnsupportedRoute => "UnsupportedRoute"
    }
}
func capability(key: String, value: SessionCapability): Unit {
    let candidate: String = value.candidate
    note(key, "${support(value.support)}|${basis(value.basis)}|${issue(value.reason)}|${route(value.route)}|${candidate}")
}
func result(key: String, value: SessionResult): Unit {
    let emitted: Int64 = value.emittedBytes
    let offset: Int64 = value.errorByteOffset
    let sessionId: Int64 = value.sessionId
    let steps: Array<SessionStepResult> = value.steps
    if (value.steps.size > 0 && aliasStep.isNone()) { aliasStep = Some(value.steps[0]) }
    check(status(value.status) != "Applied", "OSC cannot be Applied: ${key}")
    check(restore(value.restore) != "RestoreConfirmed", "OSC restore cannot be confirmed")
    note(key, "${operation(value.operation)}|${status(value.status)}|${emitted}|${issue(value.issue)}|${offset}|${restore(value.restore)}")
    note("${key}.session", "${sessionId}")
    capability("${key}.cap", value.capability)
    note("${key}.steps", "${steps.size}")
    for (i in 0..value.steps.size) {
        let step: SessionStepResult = value.steps[i]
        let count: Int64 = step.emittedBytes
        note("${key}.step${i}", "${operation(step.operation)}|${status(step.status)}|${count}|${issue(step.issue)}")
    }
}
func capabilities(key: String, app: Application): Unit {
    let value: SessionCapabilities = app.sessionCapabilities().getOrThrow()
    let sessionId: Int64 = value.sessionId
    note("${key}.id", "${sessionId}")
    capability("${key}.clipboard", value.clipboard)
    capability("${key}.title", value.title)
    capability("${key}.titleStack", value.titleStack)
    capability("${key}.imageIcon", value.imageIcon)
}
func cleanup(app: Application): Unit {
    let entries: Array<SessionResult> = app.sessionCleanupResults()
    note("cleanup.count", "${entries.size}")
    for (i in 0..entries.size) { result("cleanup.${i}", entries[i]) }
    if (entries.size > 0) {
        let original = entries[0]
        // Both outer-array and nested-step mutations must not poison stored ledger.
        if (original.steps.size > 0) {
            if (let Some(replacement) <- aliasStep) { original.steps[0] = replacement }
        }
        let replacement = app.copyLocalText("inactive")
        entries[0] = replacement
        let again = app.sessionCleanupResults()
        check(again.size == 1, "cleanup outer copy")
        result("cleanup.again", again[0])
    }
}
