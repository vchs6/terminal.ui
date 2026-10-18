package acnl.terminal.core

public open class TBorder <: TObject {
    private var _style: TBorderStyle
    private var bg: AnsiColor
    private var fg: AnsiColor

    private var connerChars: Array<Rune> = Array<Rune>(4, repeat: Rune(0))

    public init(style!: TBorderStyle = TBorderStyle.NONE, bgColor!: AnsiColor = AnsiColor.BLACK, fgColor!: AnsiColor = AnsiColor.WHITE) {
        super()
        _style = style
        bg = bgColor
        fg = fgColor
    }

    public func borderChars(): String {
        match(_style) {
            case SINGLE  => "┌─┐│└─┘│"
            case DOUBLIE => "╔═╗║╚═╝║"
            case DOTTED  => "┌.┐│└.┘│"
            case DASHED  => "┌╌┐│└╌┘│"
            case THICK   => "┏━┓┃┗━┛┃"
            case ROUNDED => "╭─╮│╰─╯│"
            case NONE    => ""
            case CUSTOM(x)  => x
        }
    }

    public mut prop style: TBorderStyle {
        get() { _style }
        set(v) {
            if (v == _style) { return }
            _style = v
            updated()
        }
    }

    public mut prop background: AnsiColor {
        get() { bg }
        set(v) {
            if (v == bg) { return }
            bg = v
            updated()
        }
    }

    public mut prop foreground: AnsiColor {
        get() { fg }
        set(v) {
            if (v == fg) { return }
            fg = v
            updated()
        }
    }
}