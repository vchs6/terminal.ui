package acnl.terminal.core

import std.collection.TreeMap
import std.convert.Parsable

public struct AnsiText <: Parsable<AnsiText> {
    private var _text: Text
    private let _styles = TreeMap<Int64, AnsiStyle>()
    private var default: AnsiStyle = AnsiStyle()

    public init(text: String) {
        _text = Text(text)
    }

    public mut func setDefaultStyle(style: AnsiStyle): Unit {
        default = style
    }

    public func getStyle(pos: Int64): AnsiStyle {
        _styles[pos]
    }

    public func setStyleFrom(pos: Int64, style!: AnsiStyle = default): Unit {
        _styles[pos] = style
    }

    public static func tryParse(value: String): ?AnsiText {
        try {
            parse(value)
        } catch(_) {
            None
        }
    }

    public static func parse(value: String): AnsiText {
        let str = value

        AnsiText(str)
    }
}