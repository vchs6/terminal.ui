package cjtui

public struct MenuEntry {
    public let key: String
    public let label: String
    public let enabled: Bool
    public init(key: String, label: String, enabled!: Bool = true) {
        if (key.isEmpty()) {
            throw UIException("InvalidKey", "list key cannot be empty")
        }
        this.key = key
        this.label = widgetCaption(label)
        this.enabled = enabled
    }
}
