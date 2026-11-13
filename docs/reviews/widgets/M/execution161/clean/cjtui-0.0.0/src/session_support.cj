package cjtui

public enum SessionSupport <: Equatable<SessionSupport> {
    Supported | Unsupported | Unknown

    public operator func ==(other: SessionSupport): Bool {
        match ((this, other)) {
            case (Supported, Supported) | (Unsupported, Unsupported) | (Unknown, Unknown) => true
            case _ => false
        }
    }
}
