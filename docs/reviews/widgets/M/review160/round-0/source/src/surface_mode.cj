package cjtui
public enum SurfaceMode <: Equatable<SurfaceMode> {
    | Transparent | Opaque
    public operator func ==(other: SurfaceMode): Bool {
        match ((this,other)) { case (Transparent,Transparent) | (Opaque,Opaque) => true; case _ => false }
    }
}
