package cjtui.text

public class AnsiTextResult {
    public let text: RichText
    private let issues: Array<AnsiTextDiagnostic>
    init(text: RichText, diagnostics: Array<AnsiTextDiagnostic>) {
        this.text = text
        issues = diagnostics.clone()
    }
    public prop diagnostics: Array<AnsiTextDiagnostic> {
        get() {
            issues.clone()
        }
    }
}
