package cjtui

import cjtui.text.graphemeIterator

func editingClusterCount(value: String): Int64 {
    let iterator = graphemeIterator(value)
    var count: Int64 = 0
    while (iterator.next().isSome()) {
        count++
    }
    count
}

func editingFactory(value: Observable<String>, controller: ?TextEditController, limits: TextEditLimits, multiline: Bool,
    onChange: (String) -> Unit, onSubmit: (String) -> Unit, onIssue: (TextEditIssue) -> Unit): Component {
    let owner = TextEditOwner()
    let component = Canvas(
        {
            constraints =>
                let text = if (let Some(edit) <- owner.session) {
                    edit.text
                } else {
                    value.get()
                }
                var width: Int64 = 0;
                var line: Int64 = 0;
                var height: Int64 = 1
                let iterator = graphemeIterator(text)
                while (true) {
                    match (iterator.next()) {
                        case None => break
                        case Some(item) =>
                            let cluster = item.toString()
                            if (cluster == "\n") {
                                width = greater(width, line + 1)
                                line = 0
                                height++
                            } else {
                                line += constraints.textWidth(cluster)
                            }
                    }
                }
                Size(greater(width, line + 1), height)
        },
        {
            context => if (let Some(edit) <- owner.session) {
                let lo = lesser(edit.selection.anchor, edit.selection.caret);
                let hi = greater(edit.selection.anchor, edit.selection.caret)
                var x: Int64 = 0;
                var y: Int64 = 0
                let clip = context.clip
                context.fill(Rect(clip.x, clip.y, clip.width, clip.height))
                let iterator = graphemeIterator(edit.text)
                var count: Int64 = 0
                while (true) {
                    match (iterator.next()) {
                        case None => break
                        case Some(item) =>
                            let cluster = item.toString()
                            if (count == edit.selection.caret) {
                                context.caret(x, y)
                            }
                            if (cluster == "\n") {
                                if (count >= lo && count < hi && y >= clip.y && y < clip.y + clip.height) {
                                    context.put(x, y, " ", selected: true)
                                }
                                x = 0
                                y++
                            } else {
                                let width = context.textWidth(cluster)
                                if (y >= clip.y && y < clip.y + clip.height && x >= clip.x && x + width <= clip.x + clip
                                    .width) {
                                    context.put(x, y, cluster, selected: count >= lo && count < hi)
                                }
                                x += width
                            }
                            count++
                    }
                }
                if (edit.selection.caret == count) {
                    context.caret(x, y)
                }
            }
        }
    )
    component.themeRole(if (multiline) {
        ThemeRole.TextArea
    } else {
        ThemeRole.TextInput
    })
    component.focusable(true).viewport(if (multiline) {
        ScrollAxes.Both
    } else {
        ScrollAxes.Horizontal
    })
    component.bind(
        "editing-source",
        ChangeKind.Layout,
        {
            =>
                value.get()
                if (let Some(edit) <- owner.session) {
                    edit.sync()
                }
        }
    )
    component.intrinsicMountEffect = Some(
        {
            ref =>
                let edit = TextEditSession(ref, value, limits, multiline, onChange, onSubmit, onIssue)
                if (let Some(control) <- controller) {
                    control.attach(edit)
                }
                owner.session = Some(edit)
                {
                    =>
                        if (let Some(control) <- controller) {
                            control.detach(edit)
                        }
                        owner.session = None
                }
        }
    )
    component.defaultAction({
        event => if (let Some(edit) <- owner.session) {
            edit.handle(event)
        }
    })
    component
}
