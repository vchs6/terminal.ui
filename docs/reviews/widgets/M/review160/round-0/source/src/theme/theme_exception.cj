package cjtui.theme
public class ThemeException <: Exception {
    public let diagnostic: ThemeDiagnostic
    public init(diagnostic: ThemeDiagnostic) {
        super(diagnostic.message)
        this.diagnostic = diagnostic
    }
}
