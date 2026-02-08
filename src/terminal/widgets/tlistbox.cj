package acnl.terminal.widgets

import std.collection.ArrayList

import acnl.terminal.core.{TWidget, TRect, Render, Text}

public open class TListBox <: TWidget {
    private let lines = ArrayList<Text>()
    private var maxWidth: Int64 = 0

    public init(col: Int64, row: Int64, width!: Int64 = 12, height!: Int64 = 2) {
        super(col, row, width: width, height: height)
    }

    public override func drawClient<T>(rect: TRect, render: T): Unit where T <: Render {
        super.drawClient(rect, render)
        if (lines.isEmpty()) { return }
        if (rect.height >= lines.size) {
            _offsetY = 0
        } else {
            _offsetY = min(_offsetY, lines.size - rect.height)
        }
        
        if (rect.width >= maxWidth) {
            _offsetX = 0
        } else {
            _offsetX = min(_offsetX, maxWidth - rect.width)
        }
        for (i in _offsetY .. lines.size) {
            if (i >= rect.height) { break }
            if (_offsetX < lines[i].width) {
                render.write(rect.left, rect.top + i, lines[i].right(lines[i].width - _offsetX).left(rect.width).toString())
            }
        }
    }

    public func append(text: Text): Unit {
        lines.add(text)
        maxWidth = max(text.width, maxWidth)
    }

    public func append(line: String): Unit {
        line.split("\n").iterator().forEach({l => append(Text(l))})
        updated()
    }

    public func remove(idx: Int64): Unit {
        lines.remove(at: idx)
        maxWidth = lines.iterator().fold<Int64>(0, {r, t => max(r, t.width)})
    }

    public func remove(range: Range<Int64>): Unit {
        lines.remove(range)
        maxWidth = lines.iterator().fold<Int64>(0, {r, t => max(r, t.width)})
        updated()
    }

    public mut prop text: String {
        get() { String.join(lines.toArray().map<String>({l => l.toString()}), delimiter: "\n")}
        set(v) {
            lines.clear()
            append(v)
            updated()
        }
    }
}