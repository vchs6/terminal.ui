package cjtui

// Reject malformed reserved events before user callbacks or session mutation.
func validateKeyboardEvent(key: KeyEvent): Unit {
    if (key.code == "text" || key.code == "paste") {
        try { String.fromUtf8(key.text.toArray()) } catch (_: IllegalArgumentException) {
            throw IllegalArgumentException("invalid keyboard UTF-8")
        }
        if (key.code == "paste") {
            if (key.ctrl || key.alt || key.shift) { throw IllegalArgumentException("paste modifiers") }
        } else {
            for (scalar in key.text.runes()) {
                let value = UInt32(scalar)
                if (value < 32 || (value >= 127 && value <= 159)) { throw IllegalArgumentException("control in text event") }
            }
        }
        return
    }
    let reserved = ["interrupt", "escape", "enter", "tab", "backtab", "backspace", "up", "down", "left", "right",
        "home", "end", "insert", "delete", "pageup", "pagedown", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12"]
    for (name in reserved) {
        if (key.code == name && !key.text.isEmpty()) { throw IllegalArgumentException("text on reserved key") }
    }
    if (key.ctrl && !key.text.isEmpty()) {
        for (name in ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]) {
            if (key.code == name) { throw IllegalArgumentException("text on control key") }
        }
    }
}
