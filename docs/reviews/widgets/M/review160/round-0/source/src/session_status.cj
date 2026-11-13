package cjtui

public enum SessionStatus <: Equatable<SessionStatus> {
    Applied | SentUnconfirmed | Unsupported | Unknown | Failed

    public operator func ==(other: SessionStatus): Bool {
        match ((this, other)) {
            case (Applied, Applied) | (SentUnconfirmed, SentUnconfirmed) | (Unsupported, Unsupported)
                | (Unknown, Unknown) | (Failed, Failed) => true
            case _ => false
        }
    }
}
