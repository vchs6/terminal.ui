package cjtui.style

public enum TextWrap <: Equatable<TextWrap> {
    | None | Grapheme
    public operator func ==(other: TextWrap): Bool {
        match ((this, other)) {
            case (None, None) | (Grapheme, Grapheme) => true
            case _ => false
        }
    }
}
