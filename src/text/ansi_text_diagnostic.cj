package cjtui.text

public class AnsiTextDiagnostic {
    public let kind: AnsiTextIssue
    public let offset: Int64
    init(kind: AnsiTextIssue, offset: Int64) {
        this.kind = kind
        this.offset = offset
    }
}
