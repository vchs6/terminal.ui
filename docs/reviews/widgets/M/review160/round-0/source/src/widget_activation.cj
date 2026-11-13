package cjtui

func widgetActivation(event: UIKeyEvent): Bool {
    let key = event.key
    if (key.ctrl || key.alt || key.shift) {
        return false
    }
    if (key.code != "enter" && !(key.code == "text" && key.text == " ")) {
        return false
    }
    event.target.isFocused()
}
