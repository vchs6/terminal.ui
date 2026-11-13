package cjtui

public class SessionCapabilities {
    public let sessionId: Int64
    public let clipboard: SessionCapability
    public let title: SessionCapability
    public let titleStack: SessionCapability
    public let imageIcon: SessionCapability

    init(sessionId: Int64, clipboard: SessionCapability, title: SessionCapability, titleStack: SessionCapability,
        imageIcon: SessionCapability) {
        this.sessionId = sessionId
        this.clipboard = clipboard
        this.title = title
        this.titleStack = titleStack
        this.imageIcon = imageIcon
    }
}
