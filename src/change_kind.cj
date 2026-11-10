package cjtui

public enum ChangeKind <: Equatable<ChangeKind> {
    | Bindings | Content | Style | Layout | Structure | All // cjlint-ignore !G.ENU.01 Public ChangeKind.Style is distinct from the existing Style type.
    public operator func ==(other: ChangeKind): Bool {
        match ((this, other)) {
            case (Bindings, Bindings) | (Content, Content) | (Style, Style) | (Layout, Layout) | (Structure, Structure) | (All, All) => true
            case _ => false
        }
    }
}
