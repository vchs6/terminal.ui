package cjtui.style

public enum VisualState <: Equatable<VisualState> {
    | Normal | Focused | Selected | Disabled
    public operator func ==(other: VisualState): Bool {
        match ((this, other)) {
            case (Normal, Normal) | (Focused, Focused) | (Selected, Selected) | (Disabled, Disabled) => true
            case _ => false
        }
    }
}
