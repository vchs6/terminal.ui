package cjtui

public enum TextEditIssue <: Equatable<TextEditIssue> {
    | MultilinePasteRejected | ControlCharacterRejected | InputTooLarge | ClipboardUnavailable | PasteFromTerminalRequired
    | CutUnconfirmed | CutStale | ConcurrentValueChanged

    public operator func ==(other: TextEditIssue): Bool {
        match ((this, other)) {
            case (MultilinePasteRejected, MultilinePasteRejected) | (ControlCharacterRejected, ControlCharacterRejected)
                | (InputTooLarge, InputTooLarge) | (ClipboardUnavailable, ClipboardUnavailable)
                | (PasteFromTerminalRequired, PasteFromTerminalRequired) | (CutUnconfirmed, CutUnconfirmed)
                | (CutStale, CutStale) | (ConcurrentValueChanged, ConcurrentValueChanged) => true
            case _ => false
        }
    }
}
