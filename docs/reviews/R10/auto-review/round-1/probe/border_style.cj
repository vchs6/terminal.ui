package cjtui

public enum BorderStyle <: Equatable<BorderStyle> {
    | None | Single | Rounded | Double | Ascii

    public operator func ==(other: BorderStyle): Bool {
        match ((this, other)) {
            case (None, None) | (Single, Single) | (Rounded, Rounded) | (Double, Double) | (Ascii, Ascii) => true
            case _ => false
        }
    }
}
