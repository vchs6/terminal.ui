package acnl.terminal.core

import std.collection.ArrayList
import std.sort.sort


//组件容器类，子组件的tabIndex越大越先获得焦点

public open class TComponent <: TWidget {
    private let _children = ArrayList<TWidget>()
    private var _actived: UInt64 = 0      //焦点组件ID
    private var needResort: Bool = false

    protected init() {
        super()
    }

    public init(col: Int64, row: Int64, width!: Int64 = 0, height!: Int64 = 0) {
        super(col, row, width: width, height: height)
    }

    //部件中能包含一个组件集
    public open func drawClient<T>(rect: TRect, render: T): Unit where T <: Render {
        super.drawClient(rect, render)
        for (c in _children) {
            c.render()
        }
    }

    public func contains(widget: TWidget): Int64 {
        var idx: Int64 = -1
        for(i in 0 .. _children.size) {
            if (widget.id == _children[i].id) {
                idx = i
                break
            }
        }
        idx
    }

    public func add(widget: TWidget): Unit {
        let idx = contains(widget)
        if (idx >= 0) { return }
        _children.add(widget)
        widget.setOwner(this)
        needResort = true
        updated()
    }

    public func remove(widget: TWidget): Unit {
        let count = _children.size
        _children.removeIf({w => w.id == widget.id})
        if (count != _children.size) {
            widget.setOwner(None)
            updated()
        }
    }

    public open func setFocused(value: Bool): Unit {
        if (value) {
            if (_children.isEmpty()) {
                return setFocused(false)
            }
            if (needResort) {
                sort(_children, lessThan: {x, y => x.tabIndex < y.tabIndex}, stable: true, descending: true)
                needResort = false
            }
            var idx = 0
            while (idx < _children.size) {
                if (_children[idx].id == _actived) {
                    break
                }
                idx ++
            }
            idx ++
            if (idx < _children.size) {
                _actived = _children[idx].id
                _children[idx].setFocused(true)
            } else {
                setFocused(false)
            }
        } else {
            if (let Some(p) <- getOwner()) {
                p.setFocused(true)
            } else {
                super.setFocused(false)
            }
        }
    }
}