package cjtui.style
public struct StyleRule <: Equatable<StyleRule> {
    private let data: StyleRuleData
    public init() { data = StyleRuleData() }
    private init(data: StyleRuleData) { this.data = data }
    public func withValue<T>(key: StyleKey<T>, value: StyleValue<T>, state!: VisualState = VisualState.Normal): StyleRule {
        key.validate(value)
        let copy = StyleRuleData(data)
        key.write(copy, stateIndex(state), value)
        StyleRule(copy)
    }
    public func value<T>(key: StyleKey<T>, state!: VisualState = VisualState.Normal): StyleValue<T> {
        key.read(data, stateIndex(state))
    }
    public operator func ==(other: StyleRule): Bool { data.same(other.data) }
}
func stateIndex(state: VisualState): Int64 {
    match (state) { case VisualState.Normal => 0; case VisualState.Focused => 1; case VisualState.Selected => 2; case VisualState.Disabled => 3 }
}
