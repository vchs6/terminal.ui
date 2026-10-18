package acnl.terminal.core

import acnl.unicode.Calculator

extend Rune {
    public func width(version!: String = "17.0.0"): Byte {
        UInt8(max(Calculator.getWidth(this, version: version), 0))
    }


    public func isCombiningMark(version!: String = "17.0.0"): Bool {
        Calculator.isCombiningMark(this, version: version)
    }
}

public struct Character /*<: Hashable & Equatable<WideChar> & Comparable<WideChar> & ToString*/ {
    public static var UnicodeVersion: String = "17.0.0"
    private var _char: Rune
    private var _width: Byte

    internal init(ch: Rune, w: Byte) {
        _char = ch
        _width = w
    }

    public init(ch: Rune) {
        _char = ch
        _width = _char.width(version: UnicodeVersion)
    }

    public func toString(): String {
        _char.toString()
    }

    public prop width: Byte {
        get() { _width }
    }

    public mut prop char: Rune {
        get() { _char }
        set(v) {
            if (v != _char) {
                _char = v
                _width = _char.width(version: UnicodeVersion)
            }
        }
    }
}
