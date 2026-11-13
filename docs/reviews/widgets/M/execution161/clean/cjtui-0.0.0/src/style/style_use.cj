package cjtui.style
public enum StyleUse <: Equatable<StyleUse> {
    | Named(String) | Inline(StyleRule)
    public operator func ==(other: StyleUse): Bool {
        match ((this, other)) {
            case (Named(a), Named(b)) => a == b
            case (Inline(a), Inline(b)) => a == b
            case _ => false
        }
    }
}
