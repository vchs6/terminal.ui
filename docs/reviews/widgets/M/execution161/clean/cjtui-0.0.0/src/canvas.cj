package cjtui

public func Canvas(measure: (Constraints) -> Size, draw: (PaintContext) -> Unit): Component {
    let component = Component(3, "")
    component.canvas = Some(CanvasState(measure,draw))
    component.bind("canvas-measure",ChangeKind.Layout,{=> component.markChanged(ChangeKind.Layout)})
    component.bind("canvas-draw",ChangeKind.Style,{=> component.markChanged(ChangeKind.Style)})
    attach(component)
    component
}
