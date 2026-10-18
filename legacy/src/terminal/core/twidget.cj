package acnl.terminal.core

import std.collection.ArrayList
import std.collection.HashMap

public open class TWidget <: TObject & Focusable {
    public var onGetRender: ()->Option<Render> = { => None }

    private var _rect: TRect = TRect(TPoint(0, 0), 0, 0)

    private let _border: TBorder = TBorder()
    private var _background: AnsiColor = AnsiColor.BLACK
    private var _foreground: AnsiColor = AnsiColor.WHITE
    private var _caption: String = ""

    private var shadow: Option<AnsiColor> = None //阴影色，无时表示没有阴影

    private var _tabIndex: Int64 = -1  // -1 表示不可接受焦点
    private var _visible: Bool = true
    private var _focused: Bool = false
    private var _enabled: Bool = true

    public var _onEnter: Option<()->Unit> = None
    public var _onExit: Option<()->Unit> = None
    public var _onEnabled: Option<()->Unit> = None
    public var _onDisabled: Option<()->Unit> = None

    protected var _scrollable: Bool = false
    protected var _offsetX: Int64 = 0
    protected var _offsetY: Int64 = 0

    private let _listeners = HashMap<String, (TEvent)->Unit>()

    private var _parent: Option<TComponent> = None
    private var _children = ArrayList<TWidget>()

    public init() {
        super()
        _visible = false
        _enabled = false
    }

    public init(col: Int64, row: Int64, width!: Int64 = 0, height!: Int64 = 0) {
        super()
        _rect = TRect((col, row), (width, height))
    }

    public func getOwner(): Option<TComponent> {
        _parent
    }

    public func setOwner(component: Option<TComponent>): Unit {
        if (let Some(parent) <- _parent && let Some(obj) <- component) {
            if (parent == obj) {
                return
            }
        }
        if (let Some(parent) <- _parent) {
            parent.remove(this)
        }
        _parent = component
        if (let Some(parent) <- _parent) {
            parent.add(this)
        }
    }

    public open func getRender<T>(): Option<T> where T <: Render {
        if (let Some(R) <- onGetRender()) {
            R as T
        } else if (let Some(P) <- _parent) {
            P.getRender()
        } else {
            None
        }
    }

    public func moveTo(col: Int64, row: Int64): Unit {
        _rect.left = col
        _rect.top = row
        updated()
    }

    public func resized(width: Int64, height: Int64): Unit {
        _rect.width= width
        _rect.height = height
        updated()
    }

    public func setScrollable(value: Bool): Unit {
        if (_scrollable == value) { return }
        _scrollable = value
        if (border.style != TBorderStyle.NONE) { return }
        if (let Some(render) <- getRender()) {
            let rect = getConsoleRect()
            let client = getClientRect()
            let w = min(client.width + 2, rect.width)
            let h = min(client.height + 2, rect.height)
            drawBorder(TRect(TPoint(rect.left, rect.top), w, h), render)
        }
    }

    public func scrollTo(cIndex: Int64, rIndex: Int64): Unit {        
        if (! _visible || _rect.width == 0 || _rect.height == 0) { return }
        if (let Some(render) <- getRender()) {
            let rect = getConsoleRect()
            let client = getClientRect()
            if (_offsetX == cIndex && _offsetY == rIndex) { return }
            _offsetX = min(cIndex, client.width)
            _offsetY = min(rIndex, client.height)
            drawScrollBar(TRect(TPoint(rect.left, rect.top), min(client.width + 2, rect.width), min(client.height + 2, rect.height)), render)
            drawClient(TRect(TPoint(rect.left + client.left, rect.top + client.top), client.width, client.height), render)
        }
    }

    public func scrollUp(rows: Int64): Unit { //负数向左移动，正数向右移动
        scrollTo(_offsetX, max(_offsetY - rows, 0))
    }

    public func scrollDown(rows: Int64): Unit { //负数向左移动，正数向右移动
        scrollTo(_offsetX, _offsetY + rows)
    }

    public func scrollLeft(cols: Int64): Unit { //负数向上移动，正数向下移动
        scrollTo(max(_offsetX - cols, 0), _offsetY)
    }
    
    public func scrollRight(cols: Int64): Unit { //负数向上移动，正数向下移动
        scrollTo(_offsetX + cols, _offsetY)
    }

    public open func render(): Unit {
        if (! _visible) { return }
        var render: Render
        if (let Some(R) <- getRender()) {
            render = R
        } else {
            return 
        }

        let rect = getConsoleRect()
        let client = getClientRect()

        let w = min(client.width + 2, rect.width)
        let h = min(client.height + 2, rect.height)
        render.beginChange()
        drawShadow(rect, render)
        drawBorder(TRect(TPoint(rect.left, rect.top), w, h), render)
        drawClient(TRect(TPoint(rect.left + client.left, rect.top + client.top), client.width, client.height), render)
        render.endChange()
    }

    public open func drawClient<T>(rect: TRect, render: T): Unit where T <: Render {
        render.setBackground(background)
        render.setForeground(foreground)
        clear(rect, render)
        for(c in _children) {
            c.render()
        }
    }

    protected open func drawShadow<T>(rect: TRect, render: T): Unit where T <: Render {
        if (let Some(color) <- shadow) {
            render.setForeground(color)
            render.setBackground(AnsiColor.BLACK)
            render.write(rect.right, rect.top, String(r'▖'))
            for (i in 1 .. rect.height) {
                render.write(rect.right, rect.top + i, String(r'▌'))
            }
            let rs = Array<Rune>(rect.width, repeat: r'▀')
            rs[0] = r'▝'
            rs[rect.width - 1] = r'▘'
            render.write(rect.left, rect.bottom, String(rs))
        }
    }

    public func clear<T>(rect: TRect, render: T): Unit where T <: Render {
        for (i in 0 .. rect.height) {
            render.write(rect.left, rect.top + i, StringBuilder(r' ', rect.width).toString())
        }
    }

    protected open func drawBorder<T>(rect: TRect, render: T): Unit where T <: Render {
        if (_border.style == TBorderStyle.NONE) { return }
        if (_focused) {
            render.setBackground(_border.foreground)
            render.setForeground(_border.background)
        } else {
            render.setBackground(_border.background)
            render.setForeground(_border.foreground)
        }
        let chars = _border.borderChars().toRuneArray()
        var t = 0
        if (rect.height > 1) {
            let buffer = Array<Rune>(rect.width, repeat: chars[1])
            if (buffer.size > 1) { buffer[0] = chars[0] }
            if (buffer.size > 1) { buffer[buffer.size - 1] = chars[2] }
            render.write(rect.left, rect.top, String(buffer))
            t = 1
        }
        for(i in t .. rect.height) {
            render.write(rect.left, rect.top + i, "${chars[3]}")
//            println("debug(${i}):   ${rect.left} ${rect.top} ${rect.right} ${rect.bottom} ${rect.width} ${rect.height}")
            render.write(rect.right, rect.top + i, "${chars[7]}") 
        }
        if (rect.height > 1) {
            let buffer = Array<Rune>(rect.width, repeat: chars[5])
            if (buffer.size > 1) { buffer[0] = chars[4] }
            if (buffer.size > 1) { buffer[buffer.size - 1] = chars[6] }
            render.write(rect.left,  rect.bottom, String(buffer))
        }
        //drawCaption()
        if (rect.width > 4 && _caption !="") {   //标题显示在上边框线上
            render.write(rect.left + 2, rect.top, Text(_caption).left(rect.width - 4).toString())
        }
        if (_scrollable) { drawScrollBar(rect, render) }
    }

    public open func drawScrollBar<T>(rect: TRect, render: T): Unit where T <: Render {
        if (_border.style == TBorderStyle.NONE) { return }
        if (_focused) {
            render.setBackground(_border.foreground)
            render.setForeground(_border.background)
        } else {
            render.setBackground(_border.background)
            render.setForeground(_border.foreground)
        }

        //  ░ ⏴ ⏵ ⏶ ⏷  ← ↑ → ↓ ∎  ▲ ▼ ◄ ►  ⋯ ⋮ ⋇ ▒
        if (rect.height > 1) { 
            render.write(rect.right, rect.top + 1, "▲")
        }
        if (rect.height >= 2) {
            render.write(rect.right, rect.bottom - 1, "▼")
        }
        if (rect.height >= 3) {
            render.write(rect.right, rect.top + 2, "▒")
        }
        if (rect.height == 1) {
            render.write(rect.left,  rect.bottom, "⁅")
            render.write(rect.right, rect.bottom, "⁆")
        } else {
            if (rect.width > 1) {
                render.write(rect.left + 1,  rect.bottom, "◄")
            }
            if (rect.width > 2) {
                render.write(rect.right - 1, rect.bottom, "►")
            }
            if (rect.width >= 4) {
                render.write(rect.left + 2,  rect.bottom, "▒")
            }
        }
    }

    public func setShadowColor(value: AnsiColor): Unit {
        if (let Some(c) <- shadow) {
            if (c == value) { return }
        }
        shadow = value
        updated()
    }

    public mut prop visible: Bool {
        get() { _visible && ! _rect.isEmpty() }
        set(v) {
            if (v == _visible) { return }
            _visible = v
            updated()
        }
    }

    public prop border: TBorder {
        get() {
            if (_border.onUpdated.isNone()) { _border.onUpdated = updated}
            _border
        }
    }

    public mut prop background: AnsiColor {
        get() { _background }
        set(v) {
            if (v == _background) { return }
            _background = v
            updated()
        }
    }

    public mut prop foreground: AnsiColor {
        get() { _foreground }
        set(v) {
            if (v == _foreground) { return }
            _foreground = v
            updated()
        }
    }


    public mut prop col: Int64 {
        get() { 
            _rect.left
        }
        set(v) {
            if (_rect.left == v) { return }
            _rect.left = v
            updated()
        }
    }

    public mut prop row: Int64 {
        get() { 
            _rect.top
        }
        set(v) {
            if (_rect.top == v) { return }
            _rect.top = v
            updated()
        }
    }

    public mut prop width: Int64 {
        get() { 
            _rect.width
        }
        set(v) {
            if (_rect.width == v) { return }
            _rect.width = v
            updated()
        }
    }

    public mut prop height: Int64 {
        get() { 
            _rect.height
        }
        set(v) {
            if (_rect.height == v) { return }
            _rect.height = v
            updated()
        }
    }

    public mut prop caption: String {
        get() { _caption }
        set(v) {
            if (_caption == v) { return }
            _caption = v
            updated()
        }
    }

    public open func getClientRect(): TRect {
        var rect = getConsoleRect()
        rect.left = 0
        rect.top = 0
        if (_border.style != TBorderStyle.NONE) {
            rect.left = 1
            rect.top = 1
            rect.width -= 2
            rect.height -= 2
        }
        if (shadow.isSome()) {
            rect.width --
            rect.height --
        }
        if (rect.width < 0) { rect.width = 0 }
        if (rect.height < 0) { rect.height = 0 }
        rect
    }

    public open func getConsoleRect(): TRect { //组件占用的控制台区域
        var cr = TRect(TPoint(_rect.left, _rect.top), _rect.width, _rect.height)
        if (let Some(p) <- _parent) {
            let pClient = p.getClientRect()
            //widht和height不能超过父组件的客户区域
            cr.width = min(cr.width, pClient.width - cr.left)
            cr.height = min(cr.height, pClient.height - cr.top)
            //转换为控制台的坐标
            let pRect = p.getConsoleRect()
            cr.top += pRect.top + pClient.top
            cr.left += pRect.left + pClient.left
        }
        cr
    }

    //Focusable
    public func isFocused(): Bool {
        _focused
    }

    public open func setFocused(value: Bool): Unit {
        if (value == _focused || _tabIndex == -1) { return }
        _focused = value
        if (! _focused) {
            if (let Some(exit) <- _onExit) { exit() }
            if (let Some(obj) <- _parent) { obj.setFocused(true) }
        } else {
            if (let Some(enter) <- _onEnter) { enter() }
        }
        updated()
    }

    public mut prop enabled: Bool {
        get() { _enabled }
        set(v) {
            _enabled = v
            if (_enabled && let Some(fn) <- _onEnabled) { fn() }
            if (!_enabled && let Some(fn) <- _onDisabled) { fn() }
        }
    }

    public mut prop tabIndex: Int64 { // tabIndex 从1开始，0表示不停止
        get() { _tabIndex }
        set(v) {
            _tabIndex = v
        }
    }

    //EventProcessor
    public func notify(event: TEvent): Unit {
        _listeners[event.eventType](event)
    }

    public func addEventProcessor(event: TEvent, callback: (TEvent)->Unit): Unit {
        _listeners.add(event.eventType, callback)
    }

    public func removeEventProcessor(event: TEvent): Unit {
        _listeners.remove(event.eventType)
    }
}
                    