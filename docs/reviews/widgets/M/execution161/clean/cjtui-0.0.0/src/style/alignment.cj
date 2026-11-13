package cjtui.style

public enum Alignment <: Equatable<Alignment> {
    | Start | Center | End | Stretch

    public operator func ==(other: Alignment): Bool {
        match ((this, other)) {
            case (Start, Start) | (Center, Center) | (End, End) | (Stretch, Stretch) => true
            case _ => false
        }
    }
}
