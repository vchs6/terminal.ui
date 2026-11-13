package cjtui

public func SplitPane(axis!: SplitAxis = SplitAxis.Horizontal, body!: () -> Unit): Component {
    let root = match (axis) {
        case SplitAxis.Horizontal => Row(body)
        case SplitAxis.Vertical => Column(body)
    }
    root.themeRole(ThemeRole.SplitPane)
}
