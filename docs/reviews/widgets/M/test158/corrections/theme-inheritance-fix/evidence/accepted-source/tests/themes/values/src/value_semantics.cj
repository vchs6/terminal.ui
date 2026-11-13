package theme_values_contract
import cjtui.style.*
import cjtui.theme.*
func valueSemantics(): Unit {
    let empty = StyleRule()
    let zero = empty.withValue(StyleKeys.paddingLeft, StyleValue<Int64>.Value(0))
    let noBold = empty.withValue(StyleKeys.bold, StyleValue<Bool>.Value(false))
    let defaultFg = empty.withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.Default))
    let reset = empty.withValue(StyleKeys.foreground, StyleValue<Color>.Reset)
    check(empty == StyleRule(), "empty rule has value equality")
    check(zero != empty && noBold != empty && defaultFg != empty, "0 false Default retain declaration presence")
    check(reset != defaultFg, "Reset is not Value(Default)")
    check(reset.withValue(StyleKeys.foreground, StyleValue<Color>.Unset) == empty, "Unset removes a declaration")
    check(noBold.withValue(StyleKeys.bold, StyleValue<Bool>.Value(true)) != noBold, "withValue returns a changed rule")
    check(noBold == StyleRule().withValue(StyleKeys.bold, StyleValue<Bool>.Value(false)), "withValue leaves original rule immutable")
    let orderA = noBold.withValue(StyleKeys.paddingLeft, StyleValue<Int64>.Value(0))
    let orderB = zero.withValue(StyleKeys.bold, StyleValue<Bool>.Value(false))
    check(orderA == orderB, "rule equality is content-based, not insertion order")
    check(noBold != empty.withValue(StyleKeys.bold, StyleValue<Bool>.Value(false), state: VisualState.Disabled), "state participates in equality")
    check(StyleValue<Int64>.Value(0) != StyleValue<Int64>.Reset, "StyleValue conditional equality")
    check(StyleUse.Inline(orderA) == StyleUse.Inline(orderB), "StyleUse Inline equality")
    check(StyleUse.Named("title") == StyleUse.Named("title") && StyleUse.Named("Title") != StyleUse.Named("title"), "StyleUse name equality is case-sensitive")
    check(VisualStates(selected: true) == VisualStates(selected: true), "VisualStates equality")
    check(VisualState.Focused != VisualState.Disabled && ThemeRole.Text != ThemeRole.Row, "state and role equality")
    check(TextWrap.Grapheme != TextWrap.None && TextOverflow.Ellipsis != TextOverflow.Clip, "text enums equality")
    check(Dimension.Cells(0) != Dimension.Auto && Dimension.Cells(3) == Dimension.Cells(3), "Dimension equality")
    let direct=empty.withValue(StyleKeys.foreground,StyleValue<Color>.Value(Color.Red))
    check(direct.value(StyleKeys.foreground,state:VisualState.Disabled)==StyleValue<Color>.Unset,"value queries requested original slot without normal fallback")
    check(reset.value(StyleKeys.foreground)==StyleValue<Color>.Reset,"read-only value preserves Reset declaration")
    check(noBold.value(StyleKeys.bold)==StyleValue<Bool>.Value(false),"read-only value preserves Value(false)")
    illegalRule({=>empty.withValue(StyleKeys.paddingLeft,StyleValue<Int64>.Value(-1));()},"negative programmatic cells")
    illegalRule({=>empty.withValue(StyleKeys.width,StyleValue<Dimension>.Value(Dimension.Cells(-1)));()},"negative programmatic dimension")
    illegalRule({=>empty.withValue(StyleKeys.textAlign,StyleValue<Alignment>.Value(Alignment.Stretch));()},"programmatic text alignment rejects Stretch")
    illegalRule({=>empty.withValue(StyleKeys.justifyContent,StyleValue<Alignment>.Value(Alignment.Stretch));()},"programmatic justify alignment rejects Stretch")
    check(ThemePreset.Dark != ThemePreset.Classic, "preset equality")
}

func illegalRule(action: () -> Unit, name: String): Unit {
    var rejected=false
    try {action()} catch(_:IllegalArgumentException){rejected=true}
    check(rejected,name)
}
