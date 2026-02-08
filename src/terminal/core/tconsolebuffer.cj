package acnl.terminal.core

import std.collection.ArrayList

public class TConsoleBuffer <: TObject & Equatable<TConsoleBuffer> {
    private var buffer: Array<Array<TPlaceHolder>>
    private var dirty: Array<Bool>
    private var pos: TPoint
    private var size: TSize

    public init(size: TSize) {
        this.size = size
        buffer = Array<Array<TPlaceHolder>>(size.height, {_ => Array<TPlaceHolder>(size.width, repeat: TPlaceHolder(r'\0'))})
        dirty = Array<Bool>(size.height, repeat: true)
        pos = TPoint(0, 0)
    }

    public func isDirty(): Bool {
        var res: Bool = false
        var i = 0
        while (!res && i < size.height) {
            res = dirty[i]
            i++
        }
        res
    }

    private func flush<T>(row: Int64, console: T): Unit where T <: AnsiConsole {
        var i = 0
        var str = ""
        while (i < buffer[row].size) {
            if (! buffer[row][i].isDirty) {
                i++
                continue
            }

            var style = buffer[row][i].style
            str += console.getCursorSetCode(i + 1, row + 1)  //控制台行列的序号是从1开始的
            str += console.getEscapeSequence(style.foreground, style.background, style.getStyles())

            while(i < buffer[row].size && buffer[row][i].isDirty) {
                var ph = buffer[row][i]
                ph.isDirty = false
                buffer[row][i] = ph

                if (style != ph.style) {
                    style = buffer[row][i].style
                    str += console.getEscapeSequence(style.foreground, style.background, style.getStyles())
                }
                str += buffer[row][i].toString()
                i += Int64(ph.width)
            }
        }
        console.write(str)
    }

    public func flush<T>(console: T): Unit where T <: AnsiConsole {
        let rows = getDirtyRows()
        for(r in rows) {
            flush(r, console)
            dirty[r] = false
        }
    }

    public func get(col: Int64, row: Int64): TPlaceHolder {
        buffer[row][col]
    }

    public func getDirtyRows(): Array<Int64> {
        let res = ArrayList<Int64>()
        for (i in 0 .. size.height) {
            if (dirty[i]) {
                res.add(i)
            }
        }
        res.toArray()
    }

    public func getLine(row: Int64): Array<TPlaceHolder> {
        buffer[row]
    }

    public func clone(from!: TPoint = TPoint(0, 0), size!: TSize = this.size): TConsoleBuffer {
        let res = TConsoleBuffer(size)
        for (i in 0 .. size.height) {
            buffer[from.row + i].copyTo(res.buffer[i], from.col, 0, size.width)
        }
        dirty.copyTo(res.dirty, from.row, 0, size.height)
        res
    }

    private func getPrevious(col: Int64, row: Int64): (Int64, Int64) {
        var (c, r): (Int64, Int64) = (col - 1, row)
        if (c < 0) {
            c = width - 1
            r --
        }
        if (buffer[r][c].char == r'\0') {
            c --
        }
        return (c, r)
    }

    // In class IllegalArgumentException
    public func put(char: Rune, style!: AnsiStyle = AnsiStyle(0)): Unit {
        var crw = char.width(version: Character.UnicodeVersion)

        if (UInt8(width - pos.col) < crw) {
            throw IllegalArgumentException("no enough places!")
        }
        if (crw == 0 && char.isCombiningMark()) {
            let (c, r) = getPrevious(pos.col, pos.row)
            var ph = buffer[r][c]
            ph.addCombiningMark(char)
            ph.isDirty = true
            buffer[r][c] = ph
            dirty[r] = true
        } else {
            buffer[pos.row][pos.col] = TPlaceHolder(char, style)
            if (crw > 1) {
                buffer[pos.row][pos.col + 1] = TPlaceHolder(r'\0')
            }
            dirty[pos.row] = true
            pos.col += Int64(crw)
            if (pos.col >= width) {
                pos.col = 0
                pos.row ++
            }
        }
        updated()
    }

    public func puts(text: Array<Rune>, style!: AnsiStyle = AnsiStyle(0)): Unit {
        beginChange()
        for(ch in text) {
            put(ch, style: style)
        }
        endChange()
    }

    public func puts(text: String, style!: AnsiStyle = AnsiStyle(0)): Unit {
        puts(text.toRuneArray(), style: style)
    }

    public func set(col: Int64, row: Int64, char: Rune, style!: AnsiStyle = AnsiStyle(0)): Unit {
        pos.col = col 
        pos.row = row
        put(char, style: style)
    }

    public func set(col: Int64, row: Int64, text: Array<Rune>, style!: AnsiStyle = AnsiStyle(0)): Unit {
        pos.col = col 
        pos.row = row
        puts(text, style: style)
    }

    public func set(col: Int64, row: Int64, text: String, style!: AnsiStyle = AnsiStyle(0)): Unit {
        set(col, row, text.toRuneArray(), style: style)
    }

    public func clear(): Unit {
        beginChange()
        buffer = Array<Array<TPlaceHolder>>(size.height, {_ => Array<TPlaceHolder>(size.width, repeat: TPlaceHolder(r'\0'))})
        dirty = Array<Bool>(size.height, repeat: true)
        pos = TPoint(0, 0)
        endChange()
    }

    public func clear(rect: TRect): Unit {
        if (rect.width == 0 || rect.height == 0) { return }
        beginChange()
        let x = Array<TPlaceHolder>(rect.width, repeat: TPlaceHolder(r' ')) // cjlint-ignore !G.VAR.02 description
        for(i in 0 .. rect.height) {
            x.copyTo(buffer[rect.top + i], 0, rect.left, rect.width)
            dirty[rect.top + i] = true
        }
        endChange()
    }

    public func resize(width: Int64, height: Int64): Unit {
        if (size.width == width && size.height == height) { return }
        beginChange()
        let tb = Array<Array<TPlaceHolder>>(height, {_ => Array<TPlaceHolder>(width, repeat: TPlaceHolder(r'\0'))})
        for (i in 0 .. height) {
            if (size.height <= i) { break }
            buffer[i].copyTo(tb[i], 0, 0, min(width, size.width))
        }
        buffer = tb
        dirty = Array<Bool>(height, repeat: true)
        size = TSize(width, height)
        pos = TPoint(0, 0)
        endChange()
    }

    public operator func ==(ot: TConsoleBuffer): Bool {
        buffer == ot.buffer
    }

    public prop width: Int64 {
        get() { size.width}
    }

    public prop height: Int64 {
        get() { size.height}
    }

    public mut prop position: TPoint {
        get() { pos }
        set(p) {
            if (pos == p) { return }
            if (p.row >= buffer.size) {
                return 
            }
            var col = p.col
            if (p.col > 0 && buffer[p.row][col].isNone()) { 
                if (buffer[p.row][col - 1].width == 2) {
                    col++
                }
            }
            pos.col = col
            pos.row = p.row
            updated()
        }
    }
}