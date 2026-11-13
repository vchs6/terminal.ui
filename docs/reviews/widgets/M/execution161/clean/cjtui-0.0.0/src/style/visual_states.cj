package cjtui.style
public struct VisualStates <: Equatable<VisualStates> {
    public let focused: Bool
    public let selected: Bool
    public let disabled: Bool
    public init(focused!: Bool = false, selected!: Bool = false, disabled!: Bool = false) {
        this.focused = focused; this.selected = selected; this.disabled = disabled
    }
    public operator func ==(other: VisualStates): Bool {
        focused == other.focused && selected == other.selected && disabled == other.disabled
    }
}
