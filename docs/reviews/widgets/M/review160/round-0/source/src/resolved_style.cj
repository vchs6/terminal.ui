package cjtui

// Node-owned values produced by the one style resolver.
class ResolvedStyle {
    var style = Style()
    var explicit = TextStylePatch()
    var fill: Int64 = 0 // 0 absent, 1 root seed background, 2 local background
    var fillStyle = Style()
    var fixedW: ?Int64 = None
    var fixedH: ?Int64 = None
    var minW: Int64 = 0
    var minH: Int64 = 0
    var weight: Int64 = 0
    var padLeft: Int64 = 0
    var padTop: Int64 = 0
    var padRight: Int64 = 0
    var padBottom: Int64 = 0
    var spacing: Int64 = 0
    var align = Alignment.Start
    var justify = Alignment.Start
    var textAlignment = Alignment.Start
    var wrap = TextWrap.None
    var overflow = TextOverflow.Clip
    var borderStyle = BorderStyle.None
    var borderFg = Color.Default
    var shadowEnabled = false
    var shadowX: Int64 = 1
    var shadowY: Int64 = 1
    var shadowStyle = Style()
}

// One comparison for the layout-affecting part of resolved style.
func layoutStyleDiff(old: ResolvedStyle, next: ResolvedStyle): Bool {
    old.fixedW != next.fixedW || old.fixedH != next.fixedH || old.minW != next.minW || old.minH != next.minH ||
    old.weight != next.weight || old.padLeft != next.padLeft || old.padTop != next.padTop ||
    old.padRight != next.padRight || old.padBottom != next.padBottom || old.spacing != next.spacing ||
    old.align != next.align || old.justify != next.justify || old.wrap != next.wrap ||
    (old.borderStyle == BorderStyle.None) != (next.borderStyle == BorderStyle.None)
}
