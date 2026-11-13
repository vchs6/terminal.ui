package language_only
import cjtui.{Component}
// Member signature projection, not a replacement or extension of actual NodeRef.
public abstract class NodeRefOverlaySignatures {
    public func openOverlay(content:Component,options!:OverlayOptions=OverlayOptions()):OverlayHandle
}
