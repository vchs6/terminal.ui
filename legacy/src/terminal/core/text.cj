package acnl.terminal.core

import std.convert.Parsable
import std.collection.ArrayList

public struct Text <: Parsable<Text> & Collection<Character> & Comparable<Text> & ToString & Hashable {
    public static var UnicodeVersion: String = "17.0.0"
    private var data: Array<Rune>
    private var widths: Array<Byte>
    private var _width: Int64 = 0

    private init(value: Array<Rune>, ws: Array<Byte>, w: Int64) {
        data = value
        widths = ws
        _width = w
    }

    public init() {
        data = Array<Rune>()
        widths = Array<Byte>()
        _width = 0
    }

    public init(value: String) {
        let runes = value.toRuneArray()
        data = runes
        widths = runes.map<Byte>({ch => ch.width(version: UnicodeVersion)})
        _width = widths.iterator().fold<Int64>(0, {r, w => r + Int64(w)})
    }

    public init(value: Array<Rune>) {
        data = value
        widths = value.map<Byte>({ch => ch.width(version: UnicodeVersion)})
        _width = widths.iterator().fold<Int64>(0, {r, w => r + Int64(w)})
    }

    public init(value: Character, w: Int64) {
        let cw = w / Int64(value.width)
        data = Array<Rune>(cw, repeat: value.char)
        widths = Array<Byte>(cw, repeat: value.width)
        _width = cw * Int64(value.width)
    }

    public mut func set(char: Rune, pos: Int64): Unit {
        let w = widths[pos]
        data[pos] = char
        _width -= Int64(w)
        _width += Int64(char.width(version: UnicodeVersion))
    }

    public func isBlank(): Bool {
        _width == 0
    }

    public func lines(): Iterator<Text> {
        let ts = ArrayList<Text>()
        var left = 0
        var right = -1
        while (right < size - 1) {
            right ++
            if (data[right] != r'\n' && data[right] != r'\r') {
                continue
            }
            if (left == right) {
                ts.add(Text())
            } else {
                let ws = widths[left .. right]
                let w = ws.iterator().fold(0, {r, w => r + Int64(w)})
                ts.add(Text(data[left .. right], ws, w))
            }
            if (data[right] == r'\r' && data[right + 1] == r'\n') {
                right++
            }
            left = right + 1
        }
        if (left < size) {
            let ws = widths[left .. size]
            let w = ws.iterator().fold(0, {r, w => r + Int64(w)})
            ts.add(Text(data[left .. size], ws, w))
        }
        ts.iterator()
    }

    public func clone(): Text {
        Text(data, widths, _width)
    }

    public func concat(value: Text): Text {
        Text(data.concat(value.data), widths.concat(value.widths), _width + value._width)
    }

    public func padStart(w: Int64, char!: Character=Character(r' ')): Text {
        if (w <= _width) { return this.clone()}
        Text(char, w).concat(this)
    }

    public func padEnd(w: Int64, char!: Character=Character(r' ')): Text {
        if (w <= _width) { return this.clone()}
        this.concat(Text(char, w))
    }

    public func pad(w: Int64, char!: Character=Character(r' ')): Text {
        if (w <= _width) { return this.clone()}
        padStart(w / 2, char: char).padEnd(w / 2, char: char)
    }

    public func get(idx: Int64): Option<Character> {
        if (idx >= 0 && idx < data.size) {
            Character(data[idx], widths[idx])
        } else {
            None
        }
    }

    public func endIndexOfWidth(w: Int64): Int64 {
        if (w >= _width) { return data.size - 1}
        var ei = -1
        var cw = 0
        while((ei < widths.size - 1)  && (cw < w)) {
            ei++
            cw += Int64(widths[ei])
        }
        if (cw > w) { ei - 1 } else { ei }
    }

    public func startIndexOfWidth(w: Int64): Int64 {
        if (w >= _width) { return 0}
        var si = widths.size
        var cw = 0
        while(si > 0 && cw < w) {
            si --
            cw += Int64(widths[si])
        }
        if (cw > w) { si + 1} else { si }
    }

    public func left(w: Int64): Text {
        if (w == 0) { return Text()}
        if (w >= _width) {
            this.clone()
        } else {
            let right = endIndexOfWidth(w)
            let cw = widths[0 ..= right].iterator().fold<Int64>(0, {r, w => r + Int64(w)})
            Text(data[0 ..= right], widths[0 ..= right], cw)
        }
    }

    public func right(w: Int64): Text {
        if (w == 0) { return Text()}
        if (w >= _width) {
            this.clone()
        } else {
            let left = startIndexOfWidth(w)
            let cw = widths[left .. data.size].iterator().fold<Int64>(0, {r, w => r + Int64(w)})
            Text(data[left .. data.size], widths[left .. data.size], cw)
        }
    }

    public func center(w: Int64): Text {
        if (w == 0) { return Text()}
        if (w >= _width) { return this.clone() }
        let lw = (_width - w) / 2
        let left = endIndexOfWidth(lw) + 1
        let right = endIndexOfWidth(lw + w)
        let cw = widths[left ..= right].iterator().fold<Int64>(0, {r, w => r + Int64(w)})
        Text(data[left ..= right], widths[left ..= right], cw)
    }

    public func split(w: Int64, removeEmpty!: Bool = false): Array<Text> {
        if (w == 0) { return [] }
        if (w >= _width) { [this] }
        let ps = ArrayList<Text>()
        var left: Int64 = 0
        var cw: Int64 = 0   // cjlint-ignore !G.VAR.02 description
        var right: Int64 = -1
        while (right < size - 1) {
            right ++
            cw += Int64(widths[right])
            if (cw <= w) { continue }
            if (!removeEmpty || left < right) {
                let ws = this.widths[left .. right]
                let ww = ws.iterator().fold<Int64>(0, {r, w => r + Int64(w)})
                ps.add(Text(data[left .. right], ws, ww))
            }
            left = right
            cw = Int64(widths[right])
        }
        if (removeEmpty || (!removeEmpty && left < right)) {
            let ws = this.widths[left .. size]
            let ww = ws.iterator().fold<Int64>(0, {r, w => r + Int64(w)})
            ps.add(Text(data[left .. size], ws, ww))
        }
        ps.toArray()
    }

    public func toArray(): Array<Character> {
        Array<Character>(data.size, {i => Character(data[i], widths[i])})
    }

    public static func parse(value: String): Text {
        Text(value)
    }

    public func toRuneArray(): Array<Rune> {
        data
    }

    public func toString(): String {
        String(data)
    }

    public func isEmpty(): Bool {
        data.isEmpty()
    }

    public func iterator(): Iterator<Character> {
        TextIterator(this)
    }

    public static func tryParse(value: String): Option<Text> {
        try {
            parse(value)
        } catch (_) {
            None
        }
    }

    public func compare(rhs: Text): Ordering {
        toString().compare(rhs.toString())
    }

    public func hashCode(): Int64 {
        toString().hashCode()
    }

    public prop size: Int64 {
        get() { data.size }
    }

    public prop width: Int64 {
        get() { _width }
    }
}

public class TextIterator <: Iterator<Character> {
    private let text: Text
    private var index: Int64
    init(text: Text) {
        this.text = text
        index = 0
    }

    public func next(): Option<Character> {
        let result = text.get(index)
        index ++
        result
    }
}