package acnl.terminal.core

public class TKeyEvent <: TEvent {
    private let key: Rune
    public var ctrlDown: Bool = false
    public var atlDonw: Bool = false
    public var shiftDown: Bool = false

    public init(key: Rune, source!: ?TWidget = None) {
        super("KeyEvent", source: source)
        this.key = key
    }

    protected func getData(): String {
        "KeyPressed<${key}>The key ${key} is pressed."
    }
}