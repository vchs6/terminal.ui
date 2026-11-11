package cjtui.style

public enum GlyphMode <: Equatable<GlyphMode> {
    | Auto | Unicode | Ascii
    public operator func ==(other: GlyphMode): Bool {
        match ((this, other)) {
            case (Auto, Auto) | (Unicode, Unicode) | (Ascii, Ascii) => true
            case _ => false
        }
    }
}
