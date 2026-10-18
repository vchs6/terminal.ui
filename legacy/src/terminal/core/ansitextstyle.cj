package acnl.terminal.core


public enum AnsiTextStyle <: ToString & Equatable<AnsiTextStyle> & Hashable {
    | NONE
    | ITALIC
    | BOLD
    | DELETEDLINE
    | UNDERLINE
    | BLINK
    | REVERSE
    | FAINT
    | STRIKETHROUGH

    public func toString(): String {
        match(this) {
            case NONE        => "none"
            case ITALIC      => "Italic"
            case BOLD        => "Bold"
            case DELETEDLINE => "DeletedLine"
            case UNDERLINE   => "UnderLine"
            case BLINK       => "Blink"
            case REVERSE     => "Reverse"
            case FAINT       => "Faint"
            case STRIKETHROUGH  => "StrikeThrough"
        }
    }

    public operator func ==(other: AnsiTextStyle): Bool {
        toString() == other.toString()
    }

    public func hashCode(): Int64 {
        toString().hashCode()
    }
}