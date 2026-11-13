package cjtui

public class KeyEvent {
    public let code: String
    public let text: String
    public let ctrl: Bool
    public let alt: Bool
    public let shift: Bool
    public init(code: String, text!: String = "", ctrl!: Bool = false, alt!: Bool = false, shift!: Bool = false) {
        this.code = code; this.text = text; this.ctrl = ctrl; this.alt = alt; this.shift = shift
    }
}
