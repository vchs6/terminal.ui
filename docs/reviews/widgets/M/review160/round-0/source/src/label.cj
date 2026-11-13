package cjtui

public func Label(value: String): Component {
    Label({=> value})
}

public func Label(value: () -> String): Component {
    Text({=> widgetCaption(value())}).themeRole(ThemeRole.Label)
}
