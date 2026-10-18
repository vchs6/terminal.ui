package acnl.terminal.core

public struct TPlaceHolder <: Equatable<TPlaceHolder> & ToString {
    public var style: AnsiStyle
    public var isDirty: Bool = true
    private var _char: Rune
    private var _combiningMarks: String = ""
    private var _width: Byte

    public init(ch: Rune) {
        _char = ch
        style = AnsiStyle()
        _width = Character(ch).width
    }

    public init(ch: Rune, style: AnsiStyle) {
        _char = ch
        this.style = style
        _width = Character(ch).width
    }

    public mut prop char: Rune {
        get() { _char }
        set(v) {
            _combiningMarks = ""
            _char = v
            _width = Character(_char).width
        }
    }

    public func isNone(): Bool {
        _char == r'\0' &&  style.isNone()
    }

    public mut func addCombiningMark(rune: Rune): Unit {
        _combiningMarks += String(rune)
    }

    public mut func clearCombiningMark(): Unit {
        _combiningMarks = ""
    }

    public func toString(): String {
        String(_char) + _combiningMarks
    }

    public operator func ==(ot: TPlaceHolder): Bool {
        char == ot.char && style == ot.style && _combiningMarks == ot._combiningMarks
    }

    public prop width: Byte {
        get() { _width }
    }
}
