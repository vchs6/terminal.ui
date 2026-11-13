package language_only_consumer
import language_only.*
import cjtui.{NodeRef,Component}

// Compile-only cross-package use. No main, concrete receiver or execution path.
public func signatureCalls(actual:NodeRef,content:Component,
    component:ComponentOverlaySignatures,owner:NodeRefOverlaySignatures,handle:OverlayHandle):Unit {
    let defaults=OverlayOptions()
    let full=OverlayOptions(mode:OverlayMode.Modal,host:Some(actual),anchor:Some(actual),
        placement:OverlayPlacement.Center,closeOnEscape:false,takeFocus:true)
    let mode:OverlayMode=defaults.mode
    let host:?NodeRef=full.host
    let anchor:?NodeRef=full.anchor
    let placement:OverlayPlacement=full.placement
    let closeOnEscape:Bool=defaults.closeOnEscape
    let takeFocus:Bool=defaults.takeFocus
    let modes=[OverlayMode.Modal,OverlayMode.NonModal,OverlayMode.Passive]
    let placements=[OverlayPlacement.Center,OverlayPlacement.BelowStart,OverlayPlacement.AboveStart,
        OverlayPlacement.RightStart,OverlayPlacement.LeftStart]
    let reasons=[OverlayCloseReason.Requested,OverlayCloseReason.Escape,OverlayCloseReason.OwnerGone,
        OverlayCloseReason.OwnerHidden,OverlayCloseReason.AnchorGone]
    let opaque:Component=component.surface(SurfaceMode.Opaque)
    let transparent:Component=component.surface({=>SurfaceMode.Transparent})
    let hosted:Component=component.overlayHost(true)
    let first:OverlayHandle=owner.openOverlay(content)
    let second:OverlayHandle=owner.openOverlay(content,options:full)
    let open:Bool=handle.isOpen()
    let reference:?NodeRef=handle.content()
    let reason:?OverlayCloseReason=handle.closeReason()
    handle.close()
    // Returned Component/NodeRef really belong to fixed620, not language_only.
    let mounted:?NodeRef=opaque.reference()
    actual.isValid()
}
