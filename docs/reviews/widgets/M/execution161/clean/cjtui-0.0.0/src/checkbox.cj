package cjtui

public func Checkbox(checked: () -> Bool, onChange: (Bool) -> Unit, label!: String = ""): Component {
    Checkbox(checked, onChange, label: {=> label})
}

public func Checkbox(checked: () -> Bool, onChange: (Bool) -> Unit, label!: () -> String): Component {
    Text({
        => widgetMarkedCaption(if (checked()) {
        "[x]"
    } else {
        "[ ]"
    }, label())
    })
        .themeRole(ThemeRole.Checkbox)
        .focusable(true)
        .visualStates({=> VisualStates(selected: checked())})
        .defaultAction({
            event => if (widgetActivation(event)) {
                event.preventDefault();
                onChange(!checked())
            }
        })
}
