package cjtui

public func Button(label: String, onClick: () -> Unit): Component {
    Button({=> label}, onClick)
}

public func Button(label: () -> String, onClick: () -> Unit): Component {
    Text({=> widgetCaption(label())}).themeRole(ThemeRole.Button).focusable(true).defaultAction({
        event => if (widgetActivation(event)) {
            event.preventDefault();
            onClick()
        }
    })
}
