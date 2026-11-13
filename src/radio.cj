package cjtui

public func Radio(selected: () -> Bool, onSelect: () -> Unit, label!: String = ""): Component {
    Radio(selected, onSelect, label: {=> label})
}

public func Radio(selected: () -> Bool, onSelect: () -> Unit, label!: () -> String): Component {
    Text({
        => widgetMarkedCaption(if (selected()) {
        "(*)"
    } else {
        "( )"
    }, label())
    })
        .themeRole(ThemeRole.Radio)
        .focusable(true)
        .visualStates({=> VisualStates(selected: selected())})
        .defaultAction({
            event => if (widgetActivation(event)) {
                event.preventDefault();
                if (!selected()) {
                    onSelect()
                }
            }
        })
}
