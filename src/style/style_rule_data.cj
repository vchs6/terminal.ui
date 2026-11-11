package cjtui.style

class StyleRuleData {
    let colorValues: Array<StyleValue<Color>>
    let boolValues: Array<StyleValue<Bool>>
    let int64Values: Array<StyleValue<Int64>>
    let alignmentValues: Array<StyleValue<Alignment>>
    let dimensionValues: Array<StyleValue<Dimension>>
    let borderstyleValues: Array<StyleValue<BorderStyle>>
    let textwrapValues: Array<StyleValue<TextWrap>>
    let textoverflowValues: Array<StyleValue<TextOverflow>>
    init() {
        colorValues = Array<StyleValue<Color>>(20, repeat: StyleValue<Color>.Unset)
        boolValues = Array<StyleValue<Bool>>(52, repeat: StyleValue<Bool>.Unset)
        int64Values = Array<StyleValue<Int64>>(40, repeat: StyleValue<Int64>.Unset)
        alignmentValues = Array<StyleValue<Alignment>>(12, repeat: StyleValue<Alignment>.Unset)
        dimensionValues = Array<StyleValue<Dimension>>(8, repeat: StyleValue<Dimension>.Unset)
        borderstyleValues = Array<StyleValue<BorderStyle>>(4, repeat: StyleValue<BorderStyle>.Unset)
        textwrapValues = Array<StyleValue<TextWrap>>(4, repeat: StyleValue<TextWrap>.Unset)
        textoverflowValues = Array<StyleValue<TextOverflow>>(4, repeat: StyleValue<TextOverflow>.Unset)
    }
    init(other: StyleRuleData) {
        colorValues = Array<StyleValue<Color>>(other.colorValues.size, {i => other.colorValues[i]})
        boolValues = Array<StyleValue<Bool>>(other.boolValues.size, {i => other.boolValues[i]})
        int64Values = Array<StyleValue<Int64>>(other.int64Values.size, {i => other.int64Values[i]})
        alignmentValues = Array<StyleValue<Alignment>>(other.alignmentValues.size, {i => other.alignmentValues[i]})
        dimensionValues = Array<StyleValue<Dimension>>(other.dimensionValues.size, {i => other.dimensionValues[i]})
        borderstyleValues = Array<StyleValue<BorderStyle>>(other.borderstyleValues.size, {i => other.borderstyleValues[i]})
        textwrapValues = Array<StyleValue<TextWrap>>(other.textwrapValues.size, {i => other.textwrapValues[i]})
        textoverflowValues = Array<StyleValue<TextOverflow>>(other.textoverflowValues.size, {i => other.textoverflowValues[i]})
    }
    func same(other: StyleRuleData): Bool {
        for (i in 0..colorValues.size) { if (colorValues[i] != other.colorValues[i]) { return false } }
        for (i in 0..boolValues.size) { if (boolValues[i] != other.boolValues[i]) { return false } }
        for (i in 0..int64Values.size) { if (int64Values[i] != other.int64Values[i]) { return false } }
        for (i in 0..alignmentValues.size) { if (alignmentValues[i] != other.alignmentValues[i]) { return false } }
        for (i in 0..dimensionValues.size) { if (dimensionValues[i] != other.dimensionValues[i]) { return false } }
        for (i in 0..borderstyleValues.size) { if (borderstyleValues[i] != other.borderstyleValues[i]) { return false } }
        for (i in 0..textwrapValues.size) { if (textwrapValues[i] != other.textwrapValues[i]) { return false } }
        for (i in 0..textoverflowValues.size) { if (textoverflowValues[i] != other.textoverflowValues[i]) { return false } }
        true
    }
}
