package theme_values_contract
import cjtui.style.*
import cjtui.theme.*
func schemaFields(): Unit {
    field_text_foreground()
    field_text_background()
    field_text_bold()
    field_text_dim()
    field_text_italic()
    field_text_underline()
    field_text_inverse()
    field_text_strikethrough()
    field_text_align()
    field_text_wrap()
    field_text_overflow()
    field_decoration_border()
    field_decoration_border_foreground()
    field_decoration_shadow_foreground()
    field_decoration_shadow_background()
    field_decoration_shadow_enabled()
    field_decoration_shadow_offset_x()
    field_decoration_shadow_offset_y()
    field_decoration_shadow_bold()
    field_decoration_shadow_dim()
    field_decoration_shadow_italic()
    field_decoration_shadow_underline()
    field_decoration_shadow_inverse()
    field_decoration_shadow_strikethrough()
    field_spacing_width()
    field_spacing_height()
    field_spacing_min_width()
    field_spacing_min_height()
    field_spacing_weight()
    field_spacing_padding_left()
    field_spacing_padding_right()
    field_spacing_padding_top()
    field_spacing_padding_bottom()
    field_spacing_gap()
    field_spacing_align_items()
    field_spacing_justify_content()
    check(parseBody("text={ foreground=\"red\" }").textDefaults() == StyleRule().withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.Red)), "inline table resolves literal")
    check(parseBody("\"text\".\"foreground\"=\"red\"").textDefaults() == StyleRule().withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.Red)), "quoted dotted keys resolve literal")
}

func field_text_foreground(): Unit {
    let expected = StyleRule().withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.Rgb(18, 171, 205)))
    check(StyleKeys.foreground.name == "foreground", "typed key read-only name foreground")
    check(expected.value(StyleKeys.foreground) == StyleValue<Color>.Value(Color.Rgb(18, 171, 205)), "typed read-only declaration value foreground")
    let direct = parseBody("[text]\nforeground=\"#12aBcD\"\n")
    check(direct.textDefaults() == expected, "schema literal text.foreground")
    let state = parseBody("[styles.test.states.disabled.text]\nforeground=\"#12aBcD\"\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.foreground, StyleValue<Color>.Value(Color.Rgb(18, 171, 205)), state: VisualState.Disabled), "schema state text.foreground")
    check(named(state,"test").value(StyleKeys.foreground,state:VisualState.Disabled) == StyleValue<Color>.Value(Color.Rgb(18, 171, 205)), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.foreground) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[text]\nforeground={reset=true}\n").textDefaults() == StyleRule().withValue(StyleKeys.foreground, StyleValue<Color>.Reset), "schema reset text.foreground")
    invalid("[text]\nforeground=false", "InvalidType", "text.foreground")
}

func field_text_background(): Unit {
    let expected = StyleRule().withValue(StyleKeys.background, StyleValue<Color>.Value(Color.Indexed(255)))
    check(StyleKeys.background.name == "background", "typed key read-only name background")
    check(expected.value(StyleKeys.background) == StyleValue<Color>.Value(Color.Indexed(255)), "typed read-only declaration value background")
    let direct = parseBody("[text]\nbackground={ indexed=255 }\n")
    check(direct.textDefaults() == expected, "schema literal text.background")
    let state = parseBody("[styles.test.states.disabled.text]\nbackground={ indexed=255 }\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.background, StyleValue<Color>.Value(Color.Indexed(255)), state: VisualState.Disabled), "schema state text.background")
    check(named(state,"test").value(StyleKeys.background,state:VisualState.Disabled) == StyleValue<Color>.Value(Color.Indexed(255)), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.background) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[text]\nbackground={reset=true}\n").textDefaults() == StyleRule().withValue(StyleKeys.background, StyleValue<Color>.Reset), "schema reset text.background")
    invalid("[text]\nbackground=false", "InvalidType", "text.background")
}

func field_text_bold(): Unit {
    let expected = StyleRule().withValue(StyleKeys.bold, StyleValue<Bool>.Value(true))
    check(StyleKeys.bold.name == "bold", "typed key read-only name bold")
    check(expected.value(StyleKeys.bold) == StyleValue<Bool>.Value(true), "typed read-only declaration value bold")
    let direct = parseBody("[text]\nbold=true\n")
    check(direct.textDefaults() == expected, "schema literal text.bold")
    let state = parseBody("[styles.test.states.disabled.text]\nbold=true\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.bold, StyleValue<Bool>.Value(true), state: VisualState.Disabled), "schema state text.bold")
    check(named(state,"test").value(StyleKeys.bold,state:VisualState.Disabled) == StyleValue<Bool>.Value(true), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.bold) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[text]\nbold={reset=true}\n").textDefaults() == StyleRule().withValue(StyleKeys.bold, StyleValue<Bool>.Reset), "schema reset text.bold")
    invalid("[text]\nbold=\"bad\"", "InvalidType", "text.bold")
    check(parseBody("[text]\nbold=false").textDefaults() == StyleRule().withValue(StyleKeys.bold,StyleValue<Bool>.Value(false)), "false presence text.bold")
}

func field_text_dim(): Unit {
    let expected = StyleRule().withValue(StyleKeys.dim, StyleValue<Bool>.Value(true))
    check(StyleKeys.dim.name == "dim", "typed key read-only name dim")
    check(expected.value(StyleKeys.dim) == StyleValue<Bool>.Value(true), "typed read-only declaration value dim")
    let direct = parseBody("[text]\ndim=true\n")
    check(direct.textDefaults() == expected, "schema literal text.dim")
    let state = parseBody("[styles.test.states.disabled.text]\ndim=true\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.dim, StyleValue<Bool>.Value(true), state: VisualState.Disabled), "schema state text.dim")
    check(named(state,"test").value(StyleKeys.dim,state:VisualState.Disabled) == StyleValue<Bool>.Value(true), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.dim) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[text]\ndim={reset=true}\n").textDefaults() == StyleRule().withValue(StyleKeys.dim, StyleValue<Bool>.Reset), "schema reset text.dim")
    invalid("[text]\ndim=\"bad\"", "InvalidType", "text.dim")
    check(parseBody("[text]\ndim=false").textDefaults() == StyleRule().withValue(StyleKeys.dim,StyleValue<Bool>.Value(false)), "false presence text.dim")
}

func field_text_italic(): Unit {
    let expected = StyleRule().withValue(StyleKeys.italic, StyleValue<Bool>.Value(true))
    check(StyleKeys.italic.name == "italic", "typed key read-only name italic")
    check(expected.value(StyleKeys.italic) == StyleValue<Bool>.Value(true), "typed read-only declaration value italic")
    let direct = parseBody("[text]\nitalic=true\n")
    check(direct.textDefaults() == expected, "schema literal text.italic")
    let state = parseBody("[styles.test.states.disabled.text]\nitalic=true\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.italic, StyleValue<Bool>.Value(true), state: VisualState.Disabled), "schema state text.italic")
    check(named(state,"test").value(StyleKeys.italic,state:VisualState.Disabled) == StyleValue<Bool>.Value(true), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.italic) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[text]\nitalic={reset=true}\n").textDefaults() == StyleRule().withValue(StyleKeys.italic, StyleValue<Bool>.Reset), "schema reset text.italic")
    invalid("[text]\nitalic=\"bad\"", "InvalidType", "text.italic")
    check(parseBody("[text]\nitalic=false").textDefaults() == StyleRule().withValue(StyleKeys.italic,StyleValue<Bool>.Value(false)), "false presence text.italic")
}

func field_text_underline(): Unit {
    let expected = StyleRule().withValue(StyleKeys.underline, StyleValue<Bool>.Value(true))
    check(StyleKeys.underline.name == "underline", "typed key read-only name underline")
    check(expected.value(StyleKeys.underline) == StyleValue<Bool>.Value(true), "typed read-only declaration value underline")
    let direct = parseBody("[text]\nunderline=true\n")
    check(direct.textDefaults() == expected, "schema literal text.underline")
    let state = parseBody("[styles.test.states.disabled.text]\nunderline=true\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.underline, StyleValue<Bool>.Value(true), state: VisualState.Disabled), "schema state text.underline")
    check(named(state,"test").value(StyleKeys.underline,state:VisualState.Disabled) == StyleValue<Bool>.Value(true), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.underline) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[text]\nunderline={reset=true}\n").textDefaults() == StyleRule().withValue(StyleKeys.underline, StyleValue<Bool>.Reset), "schema reset text.underline")
    invalid("[text]\nunderline=\"bad\"", "InvalidType", "text.underline")
    check(parseBody("[text]\nunderline=false").textDefaults() == StyleRule().withValue(StyleKeys.underline,StyleValue<Bool>.Value(false)), "false presence text.underline")
}

func field_text_inverse(): Unit {
    let expected = StyleRule().withValue(StyleKeys.inverse, StyleValue<Bool>.Value(true))
    check(StyleKeys.inverse.name == "inverse", "typed key read-only name inverse")
    check(expected.value(StyleKeys.inverse) == StyleValue<Bool>.Value(true), "typed read-only declaration value inverse")
    let direct = parseBody("[text]\ninverse=true\n")
    check(direct.textDefaults() == expected, "schema literal text.inverse")
    let state = parseBody("[styles.test.states.disabled.text]\ninverse=true\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.inverse, StyleValue<Bool>.Value(true), state: VisualState.Disabled), "schema state text.inverse")
    check(named(state,"test").value(StyleKeys.inverse,state:VisualState.Disabled) == StyleValue<Bool>.Value(true), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.inverse) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[text]\ninverse={reset=true}\n").textDefaults() == StyleRule().withValue(StyleKeys.inverse, StyleValue<Bool>.Reset), "schema reset text.inverse")
    invalid("[text]\ninverse=\"bad\"", "InvalidType", "text.inverse")
    check(parseBody("[text]\ninverse=false").textDefaults() == StyleRule().withValue(StyleKeys.inverse,StyleValue<Bool>.Value(false)), "false presence text.inverse")
}

func field_text_strikethrough(): Unit {
    let expected = StyleRule().withValue(StyleKeys.strikethrough, StyleValue<Bool>.Value(true))
    check(StyleKeys.strikethrough.name == "strikethrough", "typed key read-only name strikethrough")
    check(expected.value(StyleKeys.strikethrough) == StyleValue<Bool>.Value(true), "typed read-only declaration value strikethrough")
    let direct = parseBody("[text]\nstrikethrough=true\n")
    check(direct.textDefaults() == expected, "schema literal text.strikethrough")
    let state = parseBody("[styles.test.states.disabled.text]\nstrikethrough=true\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.strikethrough, StyleValue<Bool>.Value(true), state: VisualState.Disabled), "schema state text.strikethrough")
    check(named(state,"test").value(StyleKeys.strikethrough,state:VisualState.Disabled) == StyleValue<Bool>.Value(true), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.strikethrough) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[text]\nstrikethrough={reset=true}\n").textDefaults() == StyleRule().withValue(StyleKeys.strikethrough, StyleValue<Bool>.Reset), "schema reset text.strikethrough")
    invalid("[text]\nstrikethrough=\"bad\"", "InvalidType", "text.strikethrough")
    check(parseBody("[text]\nstrikethrough=false").textDefaults() == StyleRule().withValue(StyleKeys.strikethrough,StyleValue<Bool>.Value(false)), "false presence text.strikethrough")
}

func field_text_align(): Unit {
    let expected = StyleRule().withValue(StyleKeys.textAlign, StyleValue<Alignment>.Value(Alignment.End))
    check(StyleKeys.textAlign.name == "textAlign", "typed key read-only name textAlign")
    check(expected.value(StyleKeys.textAlign) == StyleValue<Alignment>.Value(Alignment.End), "typed read-only declaration value textAlign")
    let direct = parseBody("[text]\nalign=\"end\"\n")
    check(direct.textDefaults() == expected, "schema literal text.align")
    let state = parseBody("[styles.test.states.disabled.text]\nalign=\"end\"\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.textAlign, StyleValue<Alignment>.Value(Alignment.End), state: VisualState.Disabled), "schema state text.align")
    check(named(state,"test").value(StyleKeys.textAlign,state:VisualState.Disabled) == StyleValue<Alignment>.Value(Alignment.End), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.textAlign) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[text]\nalign={reset=true}\n").textDefaults() == StyleRule().withValue(StyleKeys.textAlign, StyleValue<Alignment>.Reset), "schema reset text.align")
    invalid("[text]\nalign=false", "InvalidType", "text.align")
}

func field_text_wrap(): Unit {
    let expected = StyleRule().withValue(StyleKeys.textWrap, StyleValue<TextWrap>.Value(TextWrap.Grapheme))
    check(StyleKeys.textWrap.name == "textWrap", "typed key read-only name textWrap")
    check(expected.value(StyleKeys.textWrap) == StyleValue<TextWrap>.Value(TextWrap.Grapheme), "typed read-only declaration value textWrap")
    let direct = parseBody("[text]\nwrap=\"grapheme\"\n")
    check(direct.textDefaults() == expected, "schema literal text.wrap")
    let state = parseBody("[styles.test.states.disabled.text]\nwrap=\"grapheme\"\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.textWrap, StyleValue<TextWrap>.Value(TextWrap.Grapheme), state: VisualState.Disabled), "schema state text.wrap")
    check(named(state,"test").value(StyleKeys.textWrap,state:VisualState.Disabled) == StyleValue<TextWrap>.Value(TextWrap.Grapheme), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.textWrap) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[text]\nwrap={reset=true}\n").textDefaults() == StyleRule().withValue(StyleKeys.textWrap, StyleValue<TextWrap>.Reset), "schema reset text.wrap")
    invalid("[text]\nwrap=false", "InvalidType", "text.wrap")
}

func field_text_overflow(): Unit {
    let expected = StyleRule().withValue(StyleKeys.textOverflow, StyleValue<TextOverflow>.Value(TextOverflow.Ellipsis))
    check(StyleKeys.textOverflow.name == "textOverflow", "typed key read-only name textOverflow")
    check(expected.value(StyleKeys.textOverflow) == StyleValue<TextOverflow>.Value(TextOverflow.Ellipsis), "typed read-only declaration value textOverflow")
    let direct = parseBody("[text]\noverflow=\"ellipsis\"\n")
    check(direct.textDefaults() == expected, "schema literal text.overflow")
    let state = parseBody("[styles.test.states.disabled.text]\noverflow=\"ellipsis\"\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.textOverflow, StyleValue<TextOverflow>.Value(TextOverflow.Ellipsis), state: VisualState.Disabled), "schema state text.overflow")
    check(named(state,"test").value(StyleKeys.textOverflow,state:VisualState.Disabled) == StyleValue<TextOverflow>.Value(TextOverflow.Ellipsis), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.textOverflow) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[text]\noverflow={reset=true}\n").textDefaults() == StyleRule().withValue(StyleKeys.textOverflow, StyleValue<TextOverflow>.Reset), "schema reset text.overflow")
    invalid("[text]\noverflow=false", "InvalidType", "text.overflow")
}

func field_decoration_border(): Unit {
    let expected = StyleRule().withValue(StyleKeys.border, StyleValue<BorderStyle>.Value(BorderStyle.Double))
    check(StyleKeys.border.name == "border", "typed key read-only name border")
    check(expected.value(StyleKeys.border) == StyleValue<BorderStyle>.Value(BorderStyle.Double), "typed read-only declaration value border")
    let direct = parseBody("[decoration]\nborder=\"double\"\n")
    check(direct.decorationDefaults() == expected, "schema literal decoration.border")
    let state = parseBody("[styles.test.states.disabled.decoration]\nborder=\"double\"\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.border, StyleValue<BorderStyle>.Value(BorderStyle.Double), state: VisualState.Disabled), "schema state decoration.border")
    check(named(state,"test").value(StyleKeys.border,state:VisualState.Disabled) == StyleValue<BorderStyle>.Value(BorderStyle.Double), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.border) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[decoration]\nborder={reset=true}\n").decorationDefaults() == StyleRule().withValue(StyleKeys.border, StyleValue<BorderStyle>.Reset), "schema reset decoration.border")
    invalid("[decoration]\nborder=false", "InvalidType", "decoration.border")
}

func field_decoration_border_foreground(): Unit {
    let expected = StyleRule().withValue(StyleKeys.borderForeground, StyleValue<Color>.Value(Color.Cyan))
    check(StyleKeys.borderForeground.name == "borderForeground", "typed key read-only name borderForeground")
    check(expected.value(StyleKeys.borderForeground) == StyleValue<Color>.Value(Color.Cyan), "typed read-only declaration value borderForeground")
    let direct = parseBody("[decoration]\nborder_foreground=\"cyan\"\n")
    check(direct.decorationDefaults() == expected, "schema literal decoration.border_foreground")
    let state = parseBody("[styles.test.states.disabled.decoration]\nborder_foreground=\"cyan\"\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.borderForeground, StyleValue<Color>.Value(Color.Cyan), state: VisualState.Disabled), "schema state decoration.border_foreground")
    check(named(state,"test").value(StyleKeys.borderForeground,state:VisualState.Disabled) == StyleValue<Color>.Value(Color.Cyan), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.borderForeground) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[decoration]\nborder_foreground={reset=true}\n").decorationDefaults() == StyleRule().withValue(StyleKeys.borderForeground, StyleValue<Color>.Reset), "schema reset decoration.border_foreground")
    invalid("[decoration]\nborder_foreground=false", "InvalidType", "decoration.border_foreground")
}

func field_decoration_shadow_foreground(): Unit {
    let expected = StyleRule().withValue(StyleKeys.shadowForeground, StyleValue<Color>.Value(Color.Cyan))
    check(StyleKeys.shadowForeground.name == "shadowForeground", "typed key read-only name shadowForeground")
    check(expected.value(StyleKeys.shadowForeground) == StyleValue<Color>.Value(Color.Cyan), "typed read-only declaration value shadowForeground")
    let direct = parseBody("[decoration]\nshadow_foreground=\"cyan\"\n")
    check(direct.decorationDefaults() == expected, "schema literal decoration.shadow_foreground")
    let state = parseBody("[styles.test.states.disabled.decoration]\nshadow_foreground=\"cyan\"\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.shadowForeground, StyleValue<Color>.Value(Color.Cyan), state: VisualState.Disabled), "schema state decoration.shadow_foreground")
    check(named(state,"test").value(StyleKeys.shadowForeground,state:VisualState.Disabled) == StyleValue<Color>.Value(Color.Cyan), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.shadowForeground) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[decoration]\nshadow_foreground={reset=true}\n").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowForeground, StyleValue<Color>.Reset), "schema reset decoration.shadow_foreground")
    invalid("[decoration]\nshadow_foreground=false", "InvalidType", "decoration.shadow_foreground")
}

func field_decoration_shadow_background(): Unit {
    let expected = StyleRule().withValue(StyleKeys.shadowBackground, StyleValue<Color>.Value(Color.Cyan))
    check(StyleKeys.shadowBackground.name == "shadowBackground", "typed key read-only name shadowBackground")
    check(expected.value(StyleKeys.shadowBackground) == StyleValue<Color>.Value(Color.Cyan), "typed read-only declaration value shadowBackground")
    let direct = parseBody("[decoration]\nshadow_background=\"cyan\"\n")
    check(direct.decorationDefaults() == expected, "schema literal decoration.shadow_background")
    let state = parseBody("[styles.test.states.disabled.decoration]\nshadow_background=\"cyan\"\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.shadowBackground, StyleValue<Color>.Value(Color.Cyan), state: VisualState.Disabled), "schema state decoration.shadow_background")
    check(named(state,"test").value(StyleKeys.shadowBackground,state:VisualState.Disabled) == StyleValue<Color>.Value(Color.Cyan), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.shadowBackground) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[decoration]\nshadow_background={reset=true}\n").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowBackground, StyleValue<Color>.Reset), "schema reset decoration.shadow_background")
    invalid("[decoration]\nshadow_background=false", "InvalidType", "decoration.shadow_background")
}

func field_decoration_shadow_enabled(): Unit {
    let expected = StyleRule().withValue(StyleKeys.shadowEnabled, StyleValue<Bool>.Value(true))
    check(StyleKeys.shadowEnabled.name == "shadowEnabled", "typed key read-only name shadowEnabled")
    check(expected.value(StyleKeys.shadowEnabled) == StyleValue<Bool>.Value(true), "typed read-only declaration value shadowEnabled")
    let direct = parseBody("[decoration]\nshadow_enabled=true\n")
    check(direct.decorationDefaults() == expected, "schema literal decoration.shadow_enabled")
    let state = parseBody("[styles.test.states.disabled.decoration]\nshadow_enabled=true\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.shadowEnabled, StyleValue<Bool>.Value(true), state: VisualState.Disabled), "schema state decoration.shadow_enabled")
    check(named(state,"test").value(StyleKeys.shadowEnabled,state:VisualState.Disabled) == StyleValue<Bool>.Value(true), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.shadowEnabled) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[decoration]\nshadow_enabled={reset=true}\n").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowEnabled, StyleValue<Bool>.Reset), "schema reset decoration.shadow_enabled")
    invalid("[decoration]\nshadow_enabled=\"bad\"", "InvalidType", "decoration.shadow_enabled")
    check(parseBody("[decoration]\nshadow_enabled=false").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowEnabled,StyleValue<Bool>.Value(false)), "false presence decoration.shadow_enabled")
}

func field_decoration_shadow_offset_x(): Unit {
    let expected = StyleRule().withValue(StyleKeys.shadowOffsetX, StyleValue<Int64>.Value(-2))
    check(StyleKeys.shadowOffsetX.name == "shadowOffsetX", "typed key read-only name shadowOffsetX")
    check(expected.value(StyleKeys.shadowOffsetX) == StyleValue<Int64>.Value(-2), "typed read-only declaration value shadowOffsetX")
    let direct = parseBody("[decoration]\nshadow_offset_x=-2\n")
    check(direct.decorationDefaults() == expected, "schema literal decoration.shadow_offset_x")
    let state = parseBody("[styles.test.states.disabled.decoration]\nshadow_offset_x=-2\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.shadowOffsetX, StyleValue<Int64>.Value(-2), state: VisualState.Disabled), "schema state decoration.shadow_offset_x")
    check(named(state,"test").value(StyleKeys.shadowOffsetX,state:VisualState.Disabled) == StyleValue<Int64>.Value(-2), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.shadowOffsetX) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[decoration]\nshadow_offset_x={reset=true}\n").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowOffsetX, StyleValue<Int64>.Reset), "schema reset decoration.shadow_offset_x")
    invalid("[decoration]\nshadow_offset_x=\"bad\"", "InvalidType", "decoration.shadow_offset_x")
}

func field_decoration_shadow_offset_y(): Unit {
    let expected = StyleRule().withValue(StyleKeys.shadowOffsetY, StyleValue<Int64>.Value(-2))
    check(StyleKeys.shadowOffsetY.name == "shadowOffsetY", "typed key read-only name shadowOffsetY")
    check(expected.value(StyleKeys.shadowOffsetY) == StyleValue<Int64>.Value(-2), "typed read-only declaration value shadowOffsetY")
    let direct = parseBody("[decoration]\nshadow_offset_y=-2\n")
    check(direct.decorationDefaults() == expected, "schema literal decoration.shadow_offset_y")
    let state = parseBody("[styles.test.states.disabled.decoration]\nshadow_offset_y=-2\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.shadowOffsetY, StyleValue<Int64>.Value(-2), state: VisualState.Disabled), "schema state decoration.shadow_offset_y")
    check(named(state,"test").value(StyleKeys.shadowOffsetY,state:VisualState.Disabled) == StyleValue<Int64>.Value(-2), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.shadowOffsetY) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[decoration]\nshadow_offset_y={reset=true}\n").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowOffsetY, StyleValue<Int64>.Reset), "schema reset decoration.shadow_offset_y")
    invalid("[decoration]\nshadow_offset_y=\"bad\"", "InvalidType", "decoration.shadow_offset_y")
}

func field_decoration_shadow_bold(): Unit {
    let expected = StyleRule().withValue(StyleKeys.shadowBold, StyleValue<Bool>.Value(true))
    check(StyleKeys.shadowBold.name == "shadowBold", "typed key read-only name shadowBold")
    check(expected.value(StyleKeys.shadowBold) == StyleValue<Bool>.Value(true), "typed read-only declaration value shadowBold")
    let direct = parseBody("[decoration]\nshadow_bold=true\n")
    check(direct.decorationDefaults() == expected, "schema literal decoration.shadow_bold")
    let state = parseBody("[styles.test.states.disabled.decoration]\nshadow_bold=true\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.shadowBold, StyleValue<Bool>.Value(true), state: VisualState.Disabled), "schema state decoration.shadow_bold")
    check(named(state,"test").value(StyleKeys.shadowBold,state:VisualState.Disabled) == StyleValue<Bool>.Value(true), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.shadowBold) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[decoration]\nshadow_bold={reset=true}\n").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowBold, StyleValue<Bool>.Reset), "schema reset decoration.shadow_bold")
    invalid("[decoration]\nshadow_bold=\"bad\"", "InvalidType", "decoration.shadow_bold")
    check(parseBody("[decoration]\nshadow_bold=false").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowBold,StyleValue<Bool>.Value(false)), "false presence decoration.shadow_bold")
}

func field_decoration_shadow_dim(): Unit {
    let expected = StyleRule().withValue(StyleKeys.shadowDim, StyleValue<Bool>.Value(true))
    check(StyleKeys.shadowDim.name == "shadowDim", "typed key read-only name shadowDim")
    check(expected.value(StyleKeys.shadowDim) == StyleValue<Bool>.Value(true), "typed read-only declaration value shadowDim")
    let direct = parseBody("[decoration]\nshadow_dim=true\n")
    check(direct.decorationDefaults() == expected, "schema literal decoration.shadow_dim")
    let state = parseBody("[styles.test.states.disabled.decoration]\nshadow_dim=true\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.shadowDim, StyleValue<Bool>.Value(true), state: VisualState.Disabled), "schema state decoration.shadow_dim")
    check(named(state,"test").value(StyleKeys.shadowDim,state:VisualState.Disabled) == StyleValue<Bool>.Value(true), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.shadowDim) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[decoration]\nshadow_dim={reset=true}\n").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowDim, StyleValue<Bool>.Reset), "schema reset decoration.shadow_dim")
    invalid("[decoration]\nshadow_dim=\"bad\"", "InvalidType", "decoration.shadow_dim")
    check(parseBody("[decoration]\nshadow_dim=false").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowDim,StyleValue<Bool>.Value(false)), "false presence decoration.shadow_dim")
}

func field_decoration_shadow_italic(): Unit {
    let expected = StyleRule().withValue(StyleKeys.shadowItalic, StyleValue<Bool>.Value(true))
    check(StyleKeys.shadowItalic.name == "shadowItalic", "typed key read-only name shadowItalic")
    check(expected.value(StyleKeys.shadowItalic) == StyleValue<Bool>.Value(true), "typed read-only declaration value shadowItalic")
    let direct = parseBody("[decoration]\nshadow_italic=true\n")
    check(direct.decorationDefaults() == expected, "schema literal decoration.shadow_italic")
    let state = parseBody("[styles.test.states.disabled.decoration]\nshadow_italic=true\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.shadowItalic, StyleValue<Bool>.Value(true), state: VisualState.Disabled), "schema state decoration.shadow_italic")
    check(named(state,"test").value(StyleKeys.shadowItalic,state:VisualState.Disabled) == StyleValue<Bool>.Value(true), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.shadowItalic) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[decoration]\nshadow_italic={reset=true}\n").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowItalic, StyleValue<Bool>.Reset), "schema reset decoration.shadow_italic")
    invalid("[decoration]\nshadow_italic=\"bad\"", "InvalidType", "decoration.shadow_italic")
    check(parseBody("[decoration]\nshadow_italic=false").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowItalic,StyleValue<Bool>.Value(false)), "false presence decoration.shadow_italic")
}

func field_decoration_shadow_underline(): Unit {
    let expected = StyleRule().withValue(StyleKeys.shadowUnderline, StyleValue<Bool>.Value(true))
    check(StyleKeys.shadowUnderline.name == "shadowUnderline", "typed key read-only name shadowUnderline")
    check(expected.value(StyleKeys.shadowUnderline) == StyleValue<Bool>.Value(true), "typed read-only declaration value shadowUnderline")
    let direct = parseBody("[decoration]\nshadow_underline=true\n")
    check(direct.decorationDefaults() == expected, "schema literal decoration.shadow_underline")
    let state = parseBody("[styles.test.states.disabled.decoration]\nshadow_underline=true\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.shadowUnderline, StyleValue<Bool>.Value(true), state: VisualState.Disabled), "schema state decoration.shadow_underline")
    check(named(state,"test").value(StyleKeys.shadowUnderline,state:VisualState.Disabled) == StyleValue<Bool>.Value(true), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.shadowUnderline) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[decoration]\nshadow_underline={reset=true}\n").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowUnderline, StyleValue<Bool>.Reset), "schema reset decoration.shadow_underline")
    invalid("[decoration]\nshadow_underline=\"bad\"", "InvalidType", "decoration.shadow_underline")
    check(parseBody("[decoration]\nshadow_underline=false").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowUnderline,StyleValue<Bool>.Value(false)), "false presence decoration.shadow_underline")
}

func field_decoration_shadow_inverse(): Unit {
    let expected = StyleRule().withValue(StyleKeys.shadowInverse, StyleValue<Bool>.Value(true))
    check(StyleKeys.shadowInverse.name == "shadowInverse", "typed key read-only name shadowInverse")
    check(expected.value(StyleKeys.shadowInverse) == StyleValue<Bool>.Value(true), "typed read-only declaration value shadowInverse")
    let direct = parseBody("[decoration]\nshadow_inverse=true\n")
    check(direct.decorationDefaults() == expected, "schema literal decoration.shadow_inverse")
    let state = parseBody("[styles.test.states.disabled.decoration]\nshadow_inverse=true\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.shadowInverse, StyleValue<Bool>.Value(true), state: VisualState.Disabled), "schema state decoration.shadow_inverse")
    check(named(state,"test").value(StyleKeys.shadowInverse,state:VisualState.Disabled) == StyleValue<Bool>.Value(true), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.shadowInverse) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[decoration]\nshadow_inverse={reset=true}\n").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowInverse, StyleValue<Bool>.Reset), "schema reset decoration.shadow_inverse")
    invalid("[decoration]\nshadow_inverse=\"bad\"", "InvalidType", "decoration.shadow_inverse")
    check(parseBody("[decoration]\nshadow_inverse=false").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowInverse,StyleValue<Bool>.Value(false)), "false presence decoration.shadow_inverse")
}

func field_decoration_shadow_strikethrough(): Unit {
    let expected = StyleRule().withValue(StyleKeys.shadowStrikethrough, StyleValue<Bool>.Value(true))
    check(StyleKeys.shadowStrikethrough.name == "shadowStrikethrough", "typed key read-only name shadowStrikethrough")
    check(expected.value(StyleKeys.shadowStrikethrough) == StyleValue<Bool>.Value(true), "typed read-only declaration value shadowStrikethrough")
    let direct = parseBody("[decoration]\nshadow_strikethrough=true\n")
    check(direct.decorationDefaults() == expected, "schema literal decoration.shadow_strikethrough")
    let state = parseBody("[styles.test.states.disabled.decoration]\nshadow_strikethrough=true\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.shadowStrikethrough, StyleValue<Bool>.Value(true), state: VisualState.Disabled), "schema state decoration.shadow_strikethrough")
    check(named(state,"test").value(StyleKeys.shadowStrikethrough,state:VisualState.Disabled) == StyleValue<Bool>.Value(true), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.shadowStrikethrough) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[decoration]\nshadow_strikethrough={reset=true}\n").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowStrikethrough, StyleValue<Bool>.Reset), "schema reset decoration.shadow_strikethrough")
    invalid("[decoration]\nshadow_strikethrough=\"bad\"", "InvalidType", "decoration.shadow_strikethrough")
    check(parseBody("[decoration]\nshadow_strikethrough=false").decorationDefaults() == StyleRule().withValue(StyleKeys.shadowStrikethrough,StyleValue<Bool>.Value(false)), "false presence decoration.shadow_strikethrough")
}

func field_spacing_width(): Unit {
    let expected = StyleRule().withValue(StyleKeys.width, StyleValue<Dimension>.Value(Dimension.Cells(7)))
    check(StyleKeys.width.name == "width", "typed key read-only name width")
    check(expected.value(StyleKeys.width) == StyleValue<Dimension>.Value(Dimension.Cells(7)), "typed read-only declaration value width")
    let direct = parseBody("[spacing]\nwidth=7\n")
    check(direct.spacingDefaults() == expected, "schema literal spacing.width")
    let state = parseBody("[styles.test.states.disabled.spacing]\nwidth=7\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.width, StyleValue<Dimension>.Value(Dimension.Cells(7)), state: VisualState.Disabled), "schema state spacing.width")
    check(named(state,"test").value(StyleKeys.width,state:VisualState.Disabled) == StyleValue<Dimension>.Value(Dimension.Cells(7)), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.width) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[spacing]\nwidth={reset=true}\n").spacingDefaults() == StyleRule().withValue(StyleKeys.width, StyleValue<Dimension>.Reset), "schema reset spacing.width")
    invalid("[spacing]\nwidth=false", "InvalidType", "spacing.width")
}

func field_spacing_height(): Unit {
    let expected = StyleRule().withValue(StyleKeys.height, StyleValue<Dimension>.Value(Dimension.Cells(7)))
    check(StyleKeys.height.name == "height", "typed key read-only name height")
    check(expected.value(StyleKeys.height) == StyleValue<Dimension>.Value(Dimension.Cells(7)), "typed read-only declaration value height")
    let direct = parseBody("[spacing]\nheight=7\n")
    check(direct.spacingDefaults() == expected, "schema literal spacing.height")
    let state = parseBody("[styles.test.states.disabled.spacing]\nheight=7\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.height, StyleValue<Dimension>.Value(Dimension.Cells(7)), state: VisualState.Disabled), "schema state spacing.height")
    check(named(state,"test").value(StyleKeys.height,state:VisualState.Disabled) == StyleValue<Dimension>.Value(Dimension.Cells(7)), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.height) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[spacing]\nheight={reset=true}\n").spacingDefaults() == StyleRule().withValue(StyleKeys.height, StyleValue<Dimension>.Reset), "schema reset spacing.height")
    invalid("[spacing]\nheight=false", "InvalidType", "spacing.height")
}

func field_spacing_min_width(): Unit {
    let expected = StyleRule().withValue(StyleKeys.minWidth, StyleValue<Int64>.Value(3))
    check(StyleKeys.minWidth.name == "minWidth", "typed key read-only name minWidth")
    check(expected.value(StyleKeys.minWidth) == StyleValue<Int64>.Value(3), "typed read-only declaration value minWidth")
    let direct = parseBody("[spacing]\nmin_width=3\n")
    check(direct.spacingDefaults() == expected, "schema literal spacing.min_width")
    let state = parseBody("[styles.test.states.disabled.spacing]\nmin_width=3\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.minWidth, StyleValue<Int64>.Value(3), state: VisualState.Disabled), "schema state spacing.min_width")
    check(named(state,"test").value(StyleKeys.minWidth,state:VisualState.Disabled) == StyleValue<Int64>.Value(3), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.minWidth) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[spacing]\nmin_width={reset=true}\n").spacingDefaults() == StyleRule().withValue(StyleKeys.minWidth, StyleValue<Int64>.Reset), "schema reset spacing.min_width")
    invalid("[spacing]\nmin_width=\"bad\"", "InvalidType", "spacing.min_width")
}

func field_spacing_min_height(): Unit {
    let expected = StyleRule().withValue(StyleKeys.minHeight, StyleValue<Int64>.Value(3))
    check(StyleKeys.minHeight.name == "minHeight", "typed key read-only name minHeight")
    check(expected.value(StyleKeys.minHeight) == StyleValue<Int64>.Value(3), "typed read-only declaration value minHeight")
    let direct = parseBody("[spacing]\nmin_height=3\n")
    check(direct.spacingDefaults() == expected, "schema literal spacing.min_height")
    let state = parseBody("[styles.test.states.disabled.spacing]\nmin_height=3\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.minHeight, StyleValue<Int64>.Value(3), state: VisualState.Disabled), "schema state spacing.min_height")
    check(named(state,"test").value(StyleKeys.minHeight,state:VisualState.Disabled) == StyleValue<Int64>.Value(3), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.minHeight) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[spacing]\nmin_height={reset=true}\n").spacingDefaults() == StyleRule().withValue(StyleKeys.minHeight, StyleValue<Int64>.Reset), "schema reset spacing.min_height")
    invalid("[spacing]\nmin_height=\"bad\"", "InvalidType", "spacing.min_height")
}

func field_spacing_weight(): Unit {
    let expected = StyleRule().withValue(StyleKeys.layoutWeight, StyleValue<Int64>.Value(3))
    check(StyleKeys.layoutWeight.name == "layoutWeight", "typed key read-only name layoutWeight")
    check(expected.value(StyleKeys.layoutWeight) == StyleValue<Int64>.Value(3), "typed read-only declaration value layoutWeight")
    let direct = parseBody("[spacing]\nweight=3\n")
    check(direct.spacingDefaults() == expected, "schema literal spacing.weight")
    let state = parseBody("[styles.test.states.disabled.spacing]\nweight=3\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.layoutWeight, StyleValue<Int64>.Value(3), state: VisualState.Disabled), "schema state spacing.weight")
    check(named(state,"test").value(StyleKeys.layoutWeight,state:VisualState.Disabled) == StyleValue<Int64>.Value(3), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.layoutWeight) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[spacing]\nweight={reset=true}\n").spacingDefaults() == StyleRule().withValue(StyleKeys.layoutWeight, StyleValue<Int64>.Reset), "schema reset spacing.weight")
    invalid("[spacing]\nweight=\"bad\"", "InvalidType", "spacing.weight")
}

func field_spacing_padding_left(): Unit {
    let expected = StyleRule().withValue(StyleKeys.paddingLeft, StyleValue<Int64>.Value(3))
    check(StyleKeys.paddingLeft.name == "paddingLeft", "typed key read-only name paddingLeft")
    check(expected.value(StyleKeys.paddingLeft) == StyleValue<Int64>.Value(3), "typed read-only declaration value paddingLeft")
    let direct = parseBody("[spacing]\npadding_left=3\n")
    check(direct.spacingDefaults() == expected, "schema literal spacing.padding_left")
    let state = parseBody("[styles.test.states.disabled.spacing]\npadding_left=3\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.paddingLeft, StyleValue<Int64>.Value(3), state: VisualState.Disabled), "schema state spacing.padding_left")
    check(named(state,"test").value(StyleKeys.paddingLeft,state:VisualState.Disabled) == StyleValue<Int64>.Value(3), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.paddingLeft) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[spacing]\npadding_left={reset=true}\n").spacingDefaults() == StyleRule().withValue(StyleKeys.paddingLeft, StyleValue<Int64>.Reset), "schema reset spacing.padding_left")
    invalid("[spacing]\npadding_left=\"bad\"", "InvalidType", "spacing.padding_left")
}

func field_spacing_padding_right(): Unit {
    let expected = StyleRule().withValue(StyleKeys.paddingRight, StyleValue<Int64>.Value(3))
    check(StyleKeys.paddingRight.name == "paddingRight", "typed key read-only name paddingRight")
    check(expected.value(StyleKeys.paddingRight) == StyleValue<Int64>.Value(3), "typed read-only declaration value paddingRight")
    let direct = parseBody("[spacing]\npadding_right=3\n")
    check(direct.spacingDefaults() == expected, "schema literal spacing.padding_right")
    let state = parseBody("[styles.test.states.disabled.spacing]\npadding_right=3\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.paddingRight, StyleValue<Int64>.Value(3), state: VisualState.Disabled), "schema state spacing.padding_right")
    check(named(state,"test").value(StyleKeys.paddingRight,state:VisualState.Disabled) == StyleValue<Int64>.Value(3), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.paddingRight) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[spacing]\npadding_right={reset=true}\n").spacingDefaults() == StyleRule().withValue(StyleKeys.paddingRight, StyleValue<Int64>.Reset), "schema reset spacing.padding_right")
    invalid("[spacing]\npadding_right=\"bad\"", "InvalidType", "spacing.padding_right")
}

func field_spacing_padding_top(): Unit {
    let expected = StyleRule().withValue(StyleKeys.paddingTop, StyleValue<Int64>.Value(3))
    check(StyleKeys.paddingTop.name == "paddingTop", "typed key read-only name paddingTop")
    check(expected.value(StyleKeys.paddingTop) == StyleValue<Int64>.Value(3), "typed read-only declaration value paddingTop")
    let direct = parseBody("[spacing]\npadding_top=3\n")
    check(direct.spacingDefaults() == expected, "schema literal spacing.padding_top")
    let state = parseBody("[styles.test.states.disabled.spacing]\npadding_top=3\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.paddingTop, StyleValue<Int64>.Value(3), state: VisualState.Disabled), "schema state spacing.padding_top")
    check(named(state,"test").value(StyleKeys.paddingTop,state:VisualState.Disabled) == StyleValue<Int64>.Value(3), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.paddingTop) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[spacing]\npadding_top={reset=true}\n").spacingDefaults() == StyleRule().withValue(StyleKeys.paddingTop, StyleValue<Int64>.Reset), "schema reset spacing.padding_top")
    invalid("[spacing]\npadding_top=\"bad\"", "InvalidType", "spacing.padding_top")
}

func field_spacing_padding_bottom(): Unit {
    let expected = StyleRule().withValue(StyleKeys.paddingBottom, StyleValue<Int64>.Value(3))
    check(StyleKeys.paddingBottom.name == "paddingBottom", "typed key read-only name paddingBottom")
    check(expected.value(StyleKeys.paddingBottom) == StyleValue<Int64>.Value(3), "typed read-only declaration value paddingBottom")
    let direct = parseBody("[spacing]\npadding_bottom=3\n")
    check(direct.spacingDefaults() == expected, "schema literal spacing.padding_bottom")
    let state = parseBody("[styles.test.states.disabled.spacing]\npadding_bottom=3\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.paddingBottom, StyleValue<Int64>.Value(3), state: VisualState.Disabled), "schema state spacing.padding_bottom")
    check(named(state,"test").value(StyleKeys.paddingBottom,state:VisualState.Disabled) == StyleValue<Int64>.Value(3), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.paddingBottom) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[spacing]\npadding_bottom={reset=true}\n").spacingDefaults() == StyleRule().withValue(StyleKeys.paddingBottom, StyleValue<Int64>.Reset), "schema reset spacing.padding_bottom")
    invalid("[spacing]\npadding_bottom=\"bad\"", "InvalidType", "spacing.padding_bottom")
}

func field_spacing_gap(): Unit {
    let expected = StyleRule().withValue(StyleKeys.gap, StyleValue<Int64>.Value(3))
    check(StyleKeys.gap.name == "gap", "typed key read-only name gap")
    check(expected.value(StyleKeys.gap) == StyleValue<Int64>.Value(3), "typed read-only declaration value gap")
    let direct = parseBody("[spacing]\ngap=3\n")
    check(direct.spacingDefaults() == expected, "schema literal spacing.gap")
    let state = parseBody("[styles.test.states.disabled.spacing]\ngap=3\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.gap, StyleValue<Int64>.Value(3), state: VisualState.Disabled), "schema state spacing.gap")
    check(named(state,"test").value(StyleKeys.gap,state:VisualState.Disabled) == StyleValue<Int64>.Value(3), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.gap) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[spacing]\ngap={reset=true}\n").spacingDefaults() == StyleRule().withValue(StyleKeys.gap, StyleValue<Int64>.Reset), "schema reset spacing.gap")
    invalid("[spacing]\ngap=\"bad\"", "InvalidType", "spacing.gap")
}

func field_spacing_align_items(): Unit {
    let expected = StyleRule().withValue(StyleKeys.alignItems, StyleValue<Alignment>.Value(Alignment.Stretch))
    check(StyleKeys.alignItems.name == "alignItems", "typed key read-only name alignItems")
    check(expected.value(StyleKeys.alignItems) == StyleValue<Alignment>.Value(Alignment.Stretch), "typed read-only declaration value alignItems")
    let direct = parseBody("[spacing]\nalign_items=\"stretch\"\n")
    check(direct.spacingDefaults() == expected, "schema literal spacing.align_items")
    let state = parseBody("[styles.test.states.disabled.spacing]\nalign_items=\"stretch\"\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.alignItems, StyleValue<Alignment>.Value(Alignment.Stretch), state: VisualState.Disabled), "schema state spacing.align_items")
    check(named(state,"test").value(StyleKeys.alignItems,state:VisualState.Disabled) == StyleValue<Alignment>.Value(Alignment.Stretch), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.alignItems) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[spacing]\nalign_items={reset=true}\n").spacingDefaults() == StyleRule().withValue(StyleKeys.alignItems, StyleValue<Alignment>.Reset), "schema reset spacing.align_items")
    invalid("[spacing]\nalign_items=false", "InvalidType", "spacing.align_items")
}

func field_spacing_justify_content(): Unit {
    let expected = StyleRule().withValue(StyleKeys.justifyContent, StyleValue<Alignment>.Value(Alignment.Center))
    check(StyleKeys.justifyContent.name == "justifyContent", "typed key read-only name justifyContent")
    check(expected.value(StyleKeys.justifyContent) == StyleValue<Alignment>.Value(Alignment.Center), "typed read-only declaration value justifyContent")
    let direct = parseBody("[spacing]\njustify_content=\"center\"\n")
    check(direct.spacingDefaults() == expected, "schema literal spacing.justify_content")
    let state = parseBody("[styles.test.states.disabled.spacing]\njustify_content=\"center\"\n")
    check(named(state, "test") == StyleRule().withValue(StyleKeys.justifyContent, StyleValue<Alignment>.Value(Alignment.Center), state: VisualState.Disabled), "schema state spacing.justify_content")
    check(named(state,"test").value(StyleKeys.justifyContent,state:VisualState.Disabled) == StyleValue<Alignment>.Value(Alignment.Center), "disabled slot is directly inspectable")
    check(named(state,"test").value(StyleKeys.justifyContent) == StyleValue.Unset, "read-only value does not resolve state fallback")
    check(parseBody("[spacing]\njustify_content={reset=true}\n").spacingDefaults() == StyleRule().withValue(StyleKeys.justifyContent, StyleValue<Alignment>.Reset), "schema reset spacing.justify_content")
    invalid("[spacing]\njustify_content=false", "InvalidType", "spacing.justify_content")
}
