package cjtui

public func ScrollView(body: () -> Unit): Component { ScrollView(ScrollAxes.Vertical,body) }
public func ScrollView(axes: ScrollAxes, body: () -> Unit): Component {
    Column(body).viewport(axes).focusable(true)
}
