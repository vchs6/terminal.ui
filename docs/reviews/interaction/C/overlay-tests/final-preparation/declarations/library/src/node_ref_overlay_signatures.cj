package language_only
import cjtui.{Component}
// Member signature projection, not a replacement or extension of actual NodeRef.
public abstract class NodeRefOverlaySignatures {
    // SDK1.2 forbids defaults on abstract members. This sole sentinel body
    // permits exact default-parameter type checking; NEVER EXECUTED.
    public func openOverlay(content:Component,options!:OverlayOptions=OverlayOptions()):OverlayHandle {
        throw Exception("NOT_EXECUTED LANGUAGE_ONLY declaration sentinel")
    }
}
