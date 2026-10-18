package acnl.terminal.core

import std.time.DateTime

public abstract class TEvent <: ToString {
    private let _type: String
    private let _source: ?TWidget
    private let _timestamp: Duration = DateTime.now().toUnixTimeStamp()

    public init(eType: String, source!: ?TWidget = None) {
        _type = eType
        _source = source
    }

    protected open func getData(): String

    public func toString(): String {
        var result: String = timestamp.toString() + "<"
        if (let Some(obj) <- _source) {
            result += obj.id.toString()
        }
        result + "><" + getData() + ">"
    }

    public prop eventType: String {
        get() { _type }
    }

    public prop source: ?TWidget {
        get() { _source }
    }

    public prop timestamp: Duration {
        get() { _timestamp }
    }
}