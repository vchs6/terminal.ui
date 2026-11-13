package cjtui

public class SessionCapability {
    public let support: SessionSupport
    public let basis: SessionBasis
    public let reason: SessionIssue
    public let route: SessionRoute
    public let candidate: String

    init(support: SessionSupport, basis: SessionBasis, reason: SessionIssue, route: SessionRoute, candidate: String) {
        this.support = support
        this.basis = basis
        this.reason = reason
        this.route = route
        this.candidate = candidate
    }
}
