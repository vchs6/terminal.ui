package cjtui

public func StatusBar(body: () -> Unit): Component {
    Row(body).themeRole(ThemeRole.StatusBar)
}
