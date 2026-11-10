package cjtui.text

public enum AnsiTextIssue <: Equatable<AnsiTextIssue> {
    | UnsupportedSequence | MalformedSequence | SequenceTooLong | IncompleteSequence

    public operator func ==(other: AnsiTextIssue): Bool {
        match ((this, other)) {
            case (UnsupportedSequence, UnsupportedSequence) | (MalformedSequence, MalformedSequence)
                | (SequenceTooLong, SequenceTooLong) | (IncompleteSequence, IncompleteSequence) => true
            case _ => false
        }
    }
}
