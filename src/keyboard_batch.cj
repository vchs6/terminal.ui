package cjtui

public class KeyboardBatch {
    private let keys: Array<KeyEvent>
    private let issues: Array<KeyboardDiagnostic>
    init(events: Array<KeyEvent>, diagnostics: Array<KeyboardDiagnostic>) {
        keys = events.clone(); issues = diagnostics.clone()
    }
    public prop events: Array<KeyEvent> { get() { keys.clone() } }
    public prop diagnostics: Array<KeyboardDiagnostic> { get() { issues.clone() } }
}
