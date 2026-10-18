package acnl.terminal.widgets

import acnl.terminal.core.{TWidget, Render, Text}
import acnl.terminal.core.{TRect, TSize, TAlign, TVerticalAlign}

public class TLabel <: TWidget {
    private var _text: String
    private var _align: TAlign = TAlign.LEFT
    private var _valign: TVerticalAlign = TVerticalAlign.TOP

    public init(col: Int64, row: Int64, text: String, width!: Int64 = text.size) {
        super(col, row, width: width, height: 1)
        _text = text
    }

    public override func drawClient<T>(rect: TRect, render: T): Unit where T <: Render {
        super.drawClient(rect, render)

        if (_text.isEmpty()) { return }

        let Y = rect.top + if (rect.height > contentSize.height) {
            match(_valign) {
                case TOP    => 0
                case MIDDLE => (rect.height - contentSize.height) / 2
                case BOTTOM => rect.height - contentSize.height
            }
        } else { 0 }

        var X = rect.left

        var dt = Text(_text)
        if (_scrollable) {
            if (rect.width < dt.width) {
                dt = dt.right(dt.width - _offsetX).left(rect.width)
            }
        } else {
            match(_align) {
                case LEFT   =>
                    dt = dt.left(rect.width)
                case CENTER =>
                    dt = dt.center(rect.width)
                    X += (rect.width - dt.width) / 2
                case RIGHT  =>
                    dt = dt.right(rect.width)
                    X += rect.width - dt.width
            }
        }

        render.write(X, Y, dt.toString())
    }

    public mut prop text: String {
        get() { _text }
        set(v) {
            if (v == _text) { return }
            _text = v
            updated()
        }
    }

    public mut prop align: TAlign {
        get() { _align }
        set(v) {
            if (v == _align) { return }
            _align = v
            updated()
        }
    }

    public mut prop valign: TVerticalAlign {
        get() { _valign }
        set(v) {
            if (v == _valign) { return }
            _valign = v
            updated()
        }
    }

    public prop contentSize: TSize {
        get() { TSize(_text.size, 1) }
    }
}