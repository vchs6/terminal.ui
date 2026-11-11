package cjtui

// Resolve each property independently: declaration, reversed styles, role,
// projected global defaults, then inheritance or the framework default.
func stateValue<T>(rule: StyleRule, key: StyleKey<T>, states: VisualStates): StyleValue<T> {
    if (states.disabled) { let v = rule.value(key,state:VisualState.Disabled); if (isDeclared(v)) { return v } }
    if (states.selected) { let v = rule.value(key,state:VisualState.Selected); if (isDeclared(v)) { return v } }
    if (states.focused) { let v = rule.value(key,state:VisualState.Focused); if (isDeclared(v)) { return v } }
    rule.value(key)
}
func isDeclared<T>(value: StyleValue<T>): Bool {
    match (value) { case StyleValue.Unset => false; case _ => true }
}
func declaredValue<T>(value: StyleValue<T>, defaultValue: T): T {
    match (value) { case StyleValue.Value(v) => v; case _ => defaultValue }
}
func chooseStyle<T>(c: Component, theme: Theme, key: StyleKey<T>, fallback: T, reset: T, global: ?StyleRule): (T, Bool, Bool) {
    var value = stateValue(c.styleDeclaration,key,c.styleStates)
    if (isDeclared(value)) { return (declaredValue(value,reset),true,true) }
    var i = c.styleUses.size
    while (i > 0) {
        i--
        let rule = styleUseRule(c.styleUses[i],theme)
        value = stateValue(rule,key,c.styleStates)
        if (isDeclared(value)) { return (declaredValue(value,reset),false,true) }
    }
    value = stateValue(theme.componentRule(c.styleRole),key,c.styleStates)
    if (isDeclared(value)) { return (declaredValue(value,reset),false,true) }
    if (let Some(rule) <- global) {
        value = rule.value(key)
        if (isDeclared(value)) { return (declaredValue(value,reset),false,false) }
    }
    (fallback,false,false)
}
func styleUseRule(use: StyleUse, theme: Theme): StyleRule {
    match (use) {
        case StyleUse.Inline(rule) => rule
        case StyleUse.Named(name) =>
            match (theme.namedStyle(name)) {
                case Some(rule) => rule
                case None => throw UIException("InvalidProperty","unknown or invalid named style")
            }
    }
}
func verifyStyleTarget(c: Component, rule: StyleRule): Unit {
    for (state in [VisualState.Normal,VisualState.Focused,VisualState.Selected,VisualState.Disabled]) {
        if (c.kind == 0) {
            let gap = isDeclared(rule.value(StyleKeys.gap,state:state))
            let align = isDeclared(rule.value(StyleKeys.alignItems,state:state))
            let justify = isDeclared(rule.value(StyleKeys.justifyContent,state:state))
            if (gap || align || justify) { throw UIException("InvalidProperty","container style applied to text") }
        } else {
            let align = isDeclared(rule.value(StyleKeys.textAlign,state:state))
            let wrap = isDeclared(rule.value(StyleKeys.textWrap,state:state))
            let overflow = isDeclared(rule.value(StyleKeys.textOverflow,state:state))
            if (align || wrap || overflow) { throw UIException("InvalidProperty","text style applied to container") }
        }
    }
}
func themeSeed(theme: Theme): Style {
    let r = theme.textDefaults()
    Style(foreground:declaredValue(r.value(StyleKeys.foreground),Color.Default),
        background:declaredValue(r.value(StyleKeys.background),Color.Default),
        bold:declaredValue(r.value(StyleKeys.bold),false),dim:declaredValue(r.value(StyleKeys.dim),false),
        italic:declaredValue(r.value(StyleKeys.italic),false),underline:declaredValue(r.value(StyleKeys.underline),false),
        inverse:declaredValue(r.value(StyleKeys.inverse),false),strikethrough:declaredValue(r.value(StyleKeys.strikethrough),false))
}
func resolveStyle(c: Component, theme: Theme, inherited: Style, isRoot: Bool): ResolvedStyle {
    for (use in c.styleUses) { verifyStyleTarget(c,styleUseRule(use,theme)) }
    verifyStyleTarget(c,theme.componentRule(c.styleRole))
    let result = ResolvedStyle()
    let (foreground, foregroundExplicit, _) = chooseStyle(c,theme,StyleKeys.foreground,inherited.foreground,Color.Default,Option<StyleRule>.None)
    let (background, backgroundExplicit, backgroundLocal) = chooseStyle(c,theme,StyleKeys.background,inherited.background,Color.Default,Option<StyleRule>.None)
    let (bold, boldExplicit, _) = chooseStyle(c,theme,StyleKeys.bold,inherited.bold,false,Option<StyleRule>.None)
    let (dim, dimExplicit, _) = chooseStyle(c,theme,StyleKeys.dim,inherited.dim,false,Option<StyleRule>.None)
    let (italic, italicExplicit, _) = chooseStyle(c,theme,StyleKeys.italic,inherited.italic,false,Option<StyleRule>.None)
    let (underline, underlineExplicit, _) = chooseStyle(c,theme,StyleKeys.underline,inherited.underline,false,Option<StyleRule>.None)
    let (inverse, inverseExplicit, _) = chooseStyle(c,theme,StyleKeys.inverse,inherited.inverse,false,Option<StyleRule>.None)
    let (strikethrough, strikethroughExplicit, _) = chooseStyle(c,theme,StyleKeys.strikethrough,inherited.strikethrough,false,Option<StyleRule>.None)
    result.style = Style(foreground:foreground, background:background, bold:bold, dim:dim, italic:italic, underline:underline, inverse:inverse, strikethrough:strikethrough)
    result.explicit = TextStylePatch(foreground: if (foregroundExplicit) { Some(foreground) } else { Option<Color>.None }, background: if (backgroundExplicit) { Some(background) } else { Option<Color>.None }, bold: if (boldExplicit) { Some(bold) } else { Option<Bool>.None }, dim: if (dimExplicit) { Some(dim) } else { Option<Bool>.None }, italic: if (italicExplicit) { Some(italic) } else { Option<Bool>.None }, underline: if (underlineExplicit) { Some(underline) } else { Option<Bool>.None }, inverse: if (inverseExplicit) { Some(inverse) } else { Option<Bool>.None }, strikethrough: if (strikethroughExplicit) { Some(strikethrough) } else { Option<Bool>.None })
    let seedBackgroundDeclared = isDeclared(theme.textDefaults().value(StyleKeys.background))
    if (backgroundLocal) { result.fill = 2; result.fillStyle = result.style }
    else if (isRoot && seedBackgroundDeclared) {
        result.fill = 1; result.fillStyle = Style(background:inherited.background)
    }
    let (fixedWValue, _, _) = chooseStyle(c,theme,StyleKeys.width,Dimension.Auto,Dimension.Auto,Some(theme.spacingDefaults()))
    result.fixedW = match (fixedWValue) { case Dimension.Cells(v) => Some(v); case Dimension.Auto => Option<Int64>.None }
    let (fixedHValue, _, _) = chooseStyle(c,theme,StyleKeys.height,Dimension.Auto,Dimension.Auto,Some(theme.spacingDefaults()))
    result.fixedH = match (fixedHValue) { case Dimension.Cells(v) => Some(v); case Dimension.Auto => Option<Int64>.None }
    let (minWValue, _, _) = chooseStyle(c,theme,StyleKeys.minWidth,0,0,Some(theme.spacingDefaults()))
    result.minW = minWValue
    let (minHValue, _, _) = chooseStyle(c,theme,StyleKeys.minHeight,0,0,Some(theme.spacingDefaults()))
    result.minH = minHValue
    let (weightValue, _, _) = chooseStyle(c,theme,StyleKeys.layoutWeight,0,0,Some(theme.spacingDefaults()))
    result.weight = weightValue
    let (padLeftValue, _, _) = chooseStyle(c,theme,StyleKeys.paddingLeft,0,0,Some(theme.spacingDefaults()))
    result.padLeft = padLeftValue
    let (padTopValue, _, _) = chooseStyle(c,theme,StyleKeys.paddingTop,0,0,Some(theme.spacingDefaults()))
    result.padTop = padTopValue
    let (padRightValue, _, _) = chooseStyle(c,theme,StyleKeys.paddingRight,0,0,Some(theme.spacingDefaults()))
    result.padRight = padRightValue
    let (padBottomValue, _, _) = chooseStyle(c,theme,StyleKeys.paddingBottom,0,0,Some(theme.spacingDefaults()))
    result.padBottom = padBottomValue
    let (spacingValue, _, _) = chooseStyle(c,theme,StyleKeys.gap,0,0,if (c.kind != 0) { Some(theme.spacingDefaults()) } else { Option<StyleRule>.None })
    result.spacing = spacingValue
    let (alignValue, _, _) = chooseStyle(c,theme,StyleKeys.alignItems,Alignment.Start,Alignment.Start,if (c.kind != 0) { Some(theme.spacingDefaults()) } else { Option<StyleRule>.None })
    result.align = alignValue
    let (justifyValue, _, _) = chooseStyle(c,theme,StyleKeys.justifyContent,Alignment.Start,Alignment.Start,if (c.kind != 0) { Some(theme.spacingDefaults()) } else { Option<StyleRule>.None })
    result.justify = justifyValue
    let (textAlignmentValue, _, _) = chooseStyle(c,theme,StyleKeys.textAlign,Alignment.Start,Alignment.Start,if (c.kind == 0) { Some(theme.textDefaults()) } else { Option<StyleRule>.None })
    result.textAlignment = textAlignmentValue
    let (wrapValue, _, _) = chooseStyle(c,theme,StyleKeys.textWrap,TextWrap.None,TextWrap.None,if (c.kind == 0) { Some(theme.textDefaults()) } else { Option<StyleRule>.None })
    result.wrap = wrapValue
    let (overflowValue, _, _) = chooseStyle(c,theme,StyleKeys.textOverflow,TextOverflow.Clip,TextOverflow.Clip,if (c.kind == 0) { Some(theme.textDefaults()) } else { Option<StyleRule>.None })
    result.overflow = overflowValue
    let (borderStyleValue, _, _) = chooseStyle(c,theme,StyleKeys.border,BorderStyle.None,BorderStyle.None,Some(theme.decorationDefaults()))
    result.borderStyle = borderStyleValue
    let (borderFgValue, _, _) = chooseStyle(c,theme,StyleKeys.borderForeground,foreground,foreground,Some(theme.decorationDefaults()))
    result.borderFg = borderFgValue
    let (shadowEnabledValue, _, _) = chooseStyle(c,theme,StyleKeys.shadowEnabled,false,false,Some(theme.decorationDefaults()))
    result.shadowEnabled = shadowEnabledValue
    let (shadowXValue, _, _) = chooseStyle(c,theme,StyleKeys.shadowOffsetX,1,1,Some(theme.decorationDefaults()))
    result.shadowX = shadowXValue
    let (shadowYValue, _, _) = chooseStyle(c,theme,StyleKeys.shadowOffsetY,1,1,Some(theme.decorationDefaults()))
    result.shadowY = shadowYValue
    let (shadowForeground, _, _) = chooseStyle(c,theme,StyleKeys.shadowForeground,Color.Default,Color.Default,Some(theme.decorationDefaults()))
    let (shadowBackground, _, _) = chooseStyle(c,theme,StyleKeys.shadowBackground,Color.Default,Color.Default,Some(theme.decorationDefaults()))
    let (shadowBold, _, _) = chooseStyle(c,theme,StyleKeys.shadowBold,false,false,Some(theme.decorationDefaults()))
    let (shadowDim, _, _) = chooseStyle(c,theme,StyleKeys.shadowDim,false,false,Some(theme.decorationDefaults()))
    let (shadowItalic, _, _) = chooseStyle(c,theme,StyleKeys.shadowItalic,false,false,Some(theme.decorationDefaults()))
    let (shadowUnderline, _, _) = chooseStyle(c,theme,StyleKeys.shadowUnderline,false,false,Some(theme.decorationDefaults()))
    let (shadowInverse, _, _) = chooseStyle(c,theme,StyleKeys.shadowInverse,false,false,Some(theme.decorationDefaults()))
    let (shadowStrikethrough, _, _) = chooseStyle(c,theme,StyleKeys.shadowStrikethrough,false,false,Some(theme.decorationDefaults()))
    result.shadowStyle = Style(foreground:shadowForeground, background:shadowBackground, bold:shadowBold, dim:shadowDim, italic:shadowItalic, underline:shadowUnderline, inverse:shadowInverse, strikethrough:shadowStrikethrough)
    result
}
