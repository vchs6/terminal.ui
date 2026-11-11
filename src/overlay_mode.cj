package cjtui
public enum OverlayMode <: Equatable<OverlayMode> {
    | Modal | NonModal | Passive
    public operator func ==(other: OverlayMode): Bool {
        match ((this,other)) { case (Modal,Modal) | (NonModal,NonModal) | (Passive,Passive) => true; case _ => false }
    }
}
