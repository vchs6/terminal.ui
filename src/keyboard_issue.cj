package cjtui

public enum KeyboardIssue <: Equatable<KeyboardIssue> {
    | UnsupportedSequence | MalformedSequence | SequenceTooLong | InvalidUtf8
    | IncompleteInput | PasteTooLarge | InvalidPasteEncoding | IncompletePaste
    | PasteTargetUnavailable
    public operator func ==(other: KeyboardIssue): Bool {
        match ((this, other)) {
            case (UnsupportedSequence, UnsupportedSequence) | (MalformedSequence, MalformedSequence)
                | (SequenceTooLong, SequenceTooLong) | (InvalidUtf8, InvalidUtf8)
                | (IncompleteInput, IncompleteInput) | (PasteTooLarge, PasteTooLarge)
                | (InvalidPasteEncoding, InvalidPasteEncoding) | (IncompletePaste, IncompletePaste)
                | (PasteTargetUnavailable, PasteTargetUnavailable) => true
            case _ => false
        }
    }
}
