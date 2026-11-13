package interaction_c

import cjtui.*

// Exact formal declarations only; these are not substitutes for actual source.
// Kept separate from business consumers so missing/changed public types cannot
// be hidden behind a private adapter. This is not a standard Modal wrapper.
func publicShapes(): Unit {
    let defaults = OverlayOptions()
    check(defaults.host.isNone() && defaults.anchor.isNone() && defaults.closeOnEscape && defaults.takeFocus,
        "S01 public defaults and immutable option fields")
    match (defaults.mode) {
        case OverlayMode.NonModal => ()
        case _ => throw Exception("S01 wrong default mode")
    }
    match (defaults.placement) {
        case OverlayPlacement.Center => ()
        case _ => throw Exception("S01 wrong default placement")
    }
    // Compile all public enum constructors without adding equality requirements.
    let placements = [OverlayPlacement.Center, OverlayPlacement.BelowStart, OverlayPlacement.AboveStart,
        OverlayPlacement.RightStart, OverlayPlacement.LeftStart]
    check(placements.size == 5, "S02 exact public placement constructors")
    let source = Text("shape").surface(SurfaceMode.Opaque).surface({=> SurfaceMode.Transparent}).overlayHost(true)
    check(source.reference().isNone(), "S03 both surface overloads preserve an unmounted component")
}
