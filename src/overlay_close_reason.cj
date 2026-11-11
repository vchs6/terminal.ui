package cjtui
public enum OverlayCloseReason <: Equatable<OverlayCloseReason> {
    | Requested | Escape | OwnerGone | OwnerHidden | AnchorGone
    public operator func ==(other: OverlayCloseReason): Bool {
        match ((this,other)) { case (Requested,Requested) | (Escape,Escape) | (OwnerGone,OwnerGone) |
            (OwnerHidden,OwnerHidden) | (AnchorGone,AnchorGone) => true; case _ => false }
    }
}
