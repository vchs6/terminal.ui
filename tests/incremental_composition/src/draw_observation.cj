package incremental_composition

import cjtui.*

struct DrawObservation {
    let width: Int64
    let height: Int64
    let clip: Rect
    let style: Style
    init(width: Int64, height: Int64, clip: Rect, style!: Style = Style()) {
        this.width = width; this.height = height; this.clip = clip; this.style = style
    }
    func agrees(other: DrawObservation): Bool {
        width == other.width && height == other.height && clip.x == other.clip.x &&
            clip.y == other.clip.y && clip.width == other.clip.width && clip.height == other.clip.height && style == other.style
    }
}
