package acnl.terminal.core

public class TBorderLine /*<: TObject & Equal<TBorderLine> & Parsable<TBorderLine>*/ { 
/*
    private var _style: TBorderStyle
    private var _bg: AnsiColor
    private var _fg: AnsiColor

    public init() {
        _style = TBorderStyle.NONE
        _bg = AnsiColor.BLACK
        _fg = AnsiColor.WHITE
    }

    public init(style: TBorderStyle, bg!: AnsiColor = AnsiColor.BLACK, fg!: AnsiColor = AnsiColor.WHITE) {
        _style = style
        _bg = bg
        _fg = fg
    }

    public operator func ==(other: TBorderLine): Bool {
        _style == other._style && _bg == other._bg && _fg == other._fg
    }

    public static func tryParse(value: String): ?TBorderLine {
        try {
            parse(value)
        } catch(_) {
            None
        }
    }

    public static func parse(value: String): TBorderLine {
        let vs = value.split(" ")
        let obj = TBorderLine()
        for (v in vs) {
            if (v.startsWith("bg:") && let Some(c) <- AnsiColor.tryParse(v[3 .. v.size])) {
                obj._bg = c
            } else if (v.startsWith("bg:") && let Some(c) <- AnsiColor.tryParse(v[3 .. v.size])) {
                obj._fg = c
            } else if (let Some(s) <- TLineStyle.tryParse(v)) {
                obj._style = s
            }
        }
        obj
    }

    public mut prop background: AnsiColor {
        get() { _bg }
        set(v) {
            if (v == _bg) { return }
            _bg = v
            updated()
        }
    }

    public mut prop foreground: AnsiColor {
        get() { _fg }
        set(v) {
            if (v == _fg) { return }
            _fg = v
            updated()
        }
    }

    public mut prop style: TLineStyle {
        get() {
            _style
        }
        set(v) {
            if (v == _style) { return }
            _style = v
            updated()
        }
    }
*/
}