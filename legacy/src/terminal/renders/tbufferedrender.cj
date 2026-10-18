package acnl.terminal.renders

import acnl.terminal.core.{TConsoleBuffer, Render}
import acnl.terminal.core.{AnsiColor, AnsiTextStyle, AnsiStyle}
import acnl.terminal.core.{TObject, AnsiConsole}
import acnl.terminal.core.{TPoint, TRect, TSize}


public open class TBufferedRender <: TObject & Render {
    public static var CONSOLE: Option<AnsiConsole> = None

    private var _autoWrap: Bool = false
    private var _cursor: Bool = true
    private var fixedTopRows: Int64 = 0
    private var fixedBottomRows: Int64 = 0

    private let _buffer: TConsoleBuffer

    private var style = AnsiStyle()

    public init(cols: Int64, rows: Int64) {
        _buffer = TConsoleBuffer(TSize(cols, rows))
    }

    public func showCursor(value: Bool): Unit {
        _cursor = value
        if (let Some(console) <- TBufferedRender.CONSOLE) {
            console.showCursor(_cursor)
        }
    }

    public override func updated(): Unit {
        if (onUpdated.isNone()) {
            onUpdated = { =>
                if (let Some(console) <- TBufferedRender.CONSOLE) {
                    buffer.flush(console)
                }
            }
        }
        super.updated()
    }

    public func getConsole(): Option<AnsiConsole> {
        CONSOLE
    }

    public func setFixedRows(top: Int64, bottom: Int64): Unit {
        fixedTopRows = top
        fixedBottomRows = bottom
    }

    public func setForeground(color: AnsiColor): Unit {     //设置前景色
        style.foreground = color
    }

    public func setBackground(color: AnsiColor): Unit {     //设置背景色
        style.background = color
    }

    public func setTextStyles(styles: Array<AnsiTextStyle>): Unit {     //设置文本样式
        style.setStyle(styles)
    }


    public func setStyle(fg: AnsiColor, bg: AnsiColor, styles: Array<AnsiTextStyle>): Unit {
        style.foreground = fg
        style.background = bg
        style.setStyle(styles)
    }

    public func setPostion(col: Int64, row: Int64): Unit {
        buffer.position = TPoint(row, col)
    }

    public func write(char: Rune): Unit {
        buffer.put(char, style: style)
    }

    public func write(text: String): Unit {
        buffer.puts(text, style: style)
    }

    public func write(col: Int64, row: Int64, text: String): Unit {
        buffer.set(col, row, text, style: style)
    }

    public func write(rect: TRect, text: Array<String>): Unit {
        buffer.beginChange()
        for (i in rect.top .. rect.height) {
            buffer.set(rect.left, i, text[i], style: style)
        }
        buffer.endChange()
    }

    public func resize(cols: Int64, rows: Int64): Unit {
        buffer.resize(cols, rows)
    }

    public func clear(): Unit {
        buffer.clear()
    }

    public func clear(rect!: TRect): Unit {
       buffer.clear(rect)
    }

    public func flush(): Unit {
        updated()
    }

    public prop buffer: TConsoleBuffer {
        get() {
            if (_buffer.onUpdated.isNone()) {
                _buffer.onUpdated = { =>
                    this.updated()
                    this.showCursor(_cursor)
                }
            }
            _buffer
        }
    }

    public prop width: Int64 {  //当前可渲染的行数和列数
        get() { buffer.width }
    }

    public prop height: Int64 {  //当前可渲染的行数和列数
        get() { buffer.height }
    }

    public prop col: Int64 {   //当前光标所在的列号
        get() { buffer.position.col }
    }

    public prop row: Int64 {   //当前光标所在的行号
        get() { buffer.position.row }
    }

    public mut prop autoWrap: Bool {    //是否自动换行
        get() { _autoWrap }
        set(v) { _autoWrap = v }
    }
}