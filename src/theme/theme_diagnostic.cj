package cjtui.theme
public struct ThemeDiagnostic {
    public let code: String
    public let source: String
    public let keyPath: String
    public let message: String
    public let location: ?ThemeLocation
    public let locationScope: String
    public init(code: String, source: String, keyPath: String, message: String, location: ?ThemeLocation, locationScope: String) {
        this.code = code; this.source = source; this.keyPath = keyPath; this.message = message
        this.location = location; this.locationScope = locationScope
    }
}
