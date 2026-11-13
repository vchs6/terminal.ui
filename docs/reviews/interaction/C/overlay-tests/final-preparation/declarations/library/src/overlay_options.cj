package language_only
import cjtui.{NodeRef}
// LANGUAGE_ONLY value-declaration initialization; NOT_EXECUTED.
public struct OverlayOptions {
    public let mode:OverlayMode
    public let host:?NodeRef
    public let anchor:?NodeRef
    public let placement:OverlayPlacement
    public let closeOnEscape:Bool
    public let takeFocus:Bool
    public init(mode!:OverlayMode=OverlayMode.NonModal,
        host!:?NodeRef=None,anchor!:?NodeRef=None,
        placement!:OverlayPlacement=OverlayPlacement.Center,
        closeOnEscape!:Bool=true,takeFocus!:Bool=true) {
        this.mode=mode;this.host=host;this.anchor=anchor;this.placement=placement
        this.closeOnEscape=closeOnEscape;this.takeFocus=takeFocus
    }
}
