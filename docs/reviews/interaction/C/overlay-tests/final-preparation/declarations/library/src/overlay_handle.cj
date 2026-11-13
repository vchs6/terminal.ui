package language_only
import cjtui.{NodeRef}
// Abstract declaration projection only: no overlay behavior or constructor.
public abstract class OverlayHandle {
    public func isOpen():Bool
    public func content():?NodeRef
    public func close():Unit
    public func closeReason():?OverlayCloseReason
}
