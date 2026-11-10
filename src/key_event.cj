package cjtui

public class KeyEvent {
    public let code: String
    public let text: String
    init(code: String, text: String) {
        this.code = code
        this.text = text
    }
    init(code: String) {
        this.code = code
        this.text = ""
    }
}
