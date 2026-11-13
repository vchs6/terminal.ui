package language_only
import cjtui.{Component}
// Member signatures projected onto an abstract receiver; never extends cjtui.
public abstract class ComponentOverlaySignatures {
    public func surface(value:SurfaceMode):Component
    public func surface(value:()->SurfaceMode):Component
    public func overlayHost(value:Bool):Component
}
