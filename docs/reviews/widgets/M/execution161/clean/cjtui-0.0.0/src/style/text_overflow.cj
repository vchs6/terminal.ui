package cjtui.style

public enum TextOverflow <: Equatable<TextOverflow> {
    | Clip | Ellipsis
    public operator func ==(other: TextOverflow): Bool {
        match ((this, other)) {
            case (Clip, Clip) | (Ellipsis, Ellipsis) => true
            case _ => false
        }
    }
}
