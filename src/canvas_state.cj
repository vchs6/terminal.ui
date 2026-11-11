package cjtui

// Callbacks and their last measured value belong to the Canvas declaration.
class CanvasState {
    let measure: (Constraints) -> Size
    let draw: (PaintContext) -> Unit
    var measured = Size(0,0)
    init(measure: (Constraints) -> Size, draw: (PaintContext) -> Unit) {
        this.measure = measure; this.draw = draw
    }
}
