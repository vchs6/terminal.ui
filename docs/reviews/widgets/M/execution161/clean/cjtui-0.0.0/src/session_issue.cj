package cjtui

public enum SessionIssue <: Equatable<SessionIssue> {
    NoIssue | InvalidUtf8 | ForbiddenControl | PayloadTooLarge | WireTooLarge | Disabled | NoDevice | NoImageAdapter | NoSavedTitle
    | InvalidContext | SessionInactive | Cancelled | AllocationFailed | WriteFailed | ParserUnsynchronized | RestoreUnavailable
    | UnsupportedRoute

    public operator func ==(other: SessionIssue): Bool {
        match ((this, other)) {
            case (NoIssue, NoIssue) | (InvalidUtf8, InvalidUtf8) | (ForbiddenControl, ForbiddenControl)
                | (PayloadTooLarge, PayloadTooLarge) | (WireTooLarge, WireTooLarge) | (Disabled, Disabled)
                | (NoDevice, NoDevice) | (NoImageAdapter, NoImageAdapter) | (NoSavedTitle, NoSavedTitle)
                | (InvalidContext, InvalidContext) | (SessionInactive, SessionInactive) | (Cancelled, Cancelled)
                | (AllocationFailed, AllocationFailed) | (WriteFailed, WriteFailed)
                | (ParserUnsynchronized, ParserUnsynchronized) | (RestoreUnavailable, RestoreUnavailable)
                | (UnsupportedRoute, UnsupportedRoute) => true
            case _ => false
        }
    }
}
