package cjtui.text

public class AnsiTextBatch {
    private let content: Array<TextSpan>
    private let issues: Array<AnsiTextDiagnostic>
    init(spans: Array<TextSpan>, diagnostics: Array<AnsiTextDiagnostic>) {
        content = spans.clone()
        issues = diagnostics.clone()
    }
    public prop spans: Array<TextSpan> {
        get() {
            content.clone()
        }
    }
    public prop diagnostics: Array<AnsiTextDiagnostic> {
        get() {
            issues.clone()
        }
    }
}
