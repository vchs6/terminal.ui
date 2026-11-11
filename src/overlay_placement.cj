package cjtui
public enum OverlayPlacement <: Equatable<OverlayPlacement> {
    | Center | BelowStart | AboveStart | RightStart | LeftStart
    public operator func ==(other: OverlayPlacement): Bool {
        match ((this,other)) { case (Center,Center) | (BelowStart,BelowStart) | (AboveStart,AboveStart) |
            (RightStart,RightStart) | (LeftStart,LeftStart) => true; case _ => false }
    }
}
