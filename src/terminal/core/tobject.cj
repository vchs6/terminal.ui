package acnl.terminal.core

public open class TObject <: Updatable & Equatable<TObject> {
    private static var GID: UInt64 = 0
    private let _id: UInt64

    private var changecount: UInt64 = 0
    public var onUpdated: Option<()->Unit> = None

    public init() {
        GID ++
        _id = GID
    }

    public static func getClassName(): String {
        "TObject"
    }

    public open func updated(): Unit {
        if (let Some(executor) <- onUpdated && changecount == 0) {
            executor()
        }
    }

    public func beginChange(): Unit {
        changecount ++
    }

    public func endChange(): Unit {
        if (changecount == 0) { return }
        changecount --
        updated()
    }

    public prop id: UInt64 {
        get() { _id }
    }

    public operator func ==(ot: TObject): Bool {
        _id == ot._id
    }
}