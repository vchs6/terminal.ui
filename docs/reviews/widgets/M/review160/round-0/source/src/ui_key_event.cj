package cjtui

public class UIKeyEvent {
    public let key: KeyEvent
    public let target: NodeRef
    private var current: NodeRef
    private var prevented = false
    var stopped = false
    var active = true
    public prop currentTarget: NodeRef { get() { current } }
    public prop defaultPrevented: Bool { get() { prevented } }
    init(key: KeyEvent, target: NodeRef) { this.key = key; this.target = target; current = target }
    func setCurrent(value: NodeRef): Unit { current = value }
    func checkActive(): Unit { if (!active) { throw UIException("ExpiredEvent", "event dispatch has ended") } }
    public func preventDefault(): Unit { checkActive(); prevented = true }
    public func stopPropagation(): Unit { checkActive(); stopped = true }
    public func consume(): Unit { preventDefault(); stopPropagation() }
}
