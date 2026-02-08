package acnl.terminal.core

// 事件： closed resized Keypress MouseMove MouserClick
public open class TWindow <: TComponent {
    private var menuBar: Option<TWidget> = None
    private var stateBar: Option<TWidget> = None
    private var _icon: String = "👩\u{200D}👨\u{200D}👦"

    public var onClosed: Option<()->Unit> = None

    protected init() {
        super()
    }

    public init(col: Int64, row: Int64, width!: Int64 = 0, height!: Int64 = 0) {
        super(col, row, width: width, height: height)
    }

    public static func newInstance(): TWindow {
        let win = TWindow()
        win.beginChange()

        win.endChange()
        win
    }

    public override func getRender<T>(): Option<T> where T <: Render {
        super.getRender()
    }

    public override func getClientRect(): TRect {
        var rect = super.getClientRect()
        if (menuBar.isSome()) { rect.height -= 1}
        if (stateBar.isSome()) { rect.height -= 1}
        rect
    }

    protected open func drawTitle<T>(rect: TRect, render: T): Unit where T <: Render {
        render.setForeground(AnsiColor.WHITE)
        render.setBackground(AnsiColor.BLUE)
        let chars = border.borderChars().toRuneArray()
        var str = Text(String(chars[0]) + "[" + _icon + "]" + String(chars[1]) + caption)
        str = str.left(min(rect.width - 3, str.width))
        str = str.concat(Text(Character(chars[1]), rect.width - 3 - str.width))
        str = str.concat(Text(r'X', chars[1], chars[2]))
        render.write(rect.left, rect.top, str.toString())
    }

    protected open func drawBorder<T>(rect: TRect, render: T): Unit where T <: Render {
        super.drawBorder(rect, render)
        drawTitle(rect, render)
    }

    public func show(): Unit {
        if (visible) { render() }
    }

    public func close(): Unit {
        //清理

        if (let Some(fn) <- onClosed) {
            fn()
        }

    }

    public mut prop icon: String {
        get() { _icon }
        set(v) {
            if (v == _icon) { return }
            if (let Some(render) <- getRender()) {
                let rect = getConsoleRect()
                drawTitle(rect, render)
            }
        }
    }

}