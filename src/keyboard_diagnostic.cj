package cjtui

public class KeyboardDiagnostic {
    public let kind: KeyboardIssue
    public let offset: Int64
    init(kind: KeyboardIssue, offset: Int64) { this.kind = kind; this.offset = offset }
}
