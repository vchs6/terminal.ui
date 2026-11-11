package cjtui.theme

import cjtui.style.*
import std.collection.*
import stdx.serialization.serialization.*
import cangjie_toml.cangjie_toml.parser.*

class ThemeSchema {
    let source: String
    let literal: ThemeLiteral
    var variables: DataModelStruct
    let errors = ArrayList<ThemeException>()
    init(source: String, variables: DataModelStruct, parser: Parser) { this.source = source; literal = ThemeLiteral(source,parser); this.variables = variables }
    func fail(code: String, path: String): Nothing { throw themeFailure(code,source,path,"invalid theme value at ${path}") }
    func table(dm: DataModel, path: String): DataModelStruct {
        if (let Some(v) <- (dm as DataModelStruct)) { return v }
        fail("InvalidType",path)
    }
    func property(rule: StyleRule, category: String, name: String, dm: DataModel, path: String, state: VisualState): StyleRule {
        let field = category + "." + name
        let expected = match (field) {
            case "text.foreground" => "color"
            case "text.background" => "color"
            case "text.bold" => "bool"
            case "text.dim" => "bool"
            case "text.italic" => "bool"
            case "text.underline" => "bool"
            case "text.inverse" => "bool"
            case "text.strikethrough" => "bool"
            case "text.align" => "text_alignment"
            case "text.wrap" => "wrap"
            case "text.overflow" => "overflow"
            case "decoration.border" => "border"
            case "decoration.border_foreground" => "color"
            case "decoration.shadow_enabled" => "bool"
            case "decoration.shadow_offset_x" => "offset"
            case "decoration.shadow_offset_y" => "offset"
            case "decoration.shadow_foreground" => "color"
            case "decoration.shadow_background" => "color"
            case "decoration.shadow_bold" => "bool"
            case "decoration.shadow_dim" => "bool"
            case "decoration.shadow_italic" => "bool"
            case "decoration.shadow_underline" => "bool"
            case "decoration.shadow_inverse" => "bool"
            case "decoration.shadow_strikethrough" => "bool"
            case "spacing.width" => "dimension"
            case "spacing.height" => "dimension"
            case "spacing.min_width" => "cells"
            case "spacing.min_height" => "cells"
            case "spacing.padding_left" => "cells"
            case "spacing.padding_top" => "cells"
            case "spacing.padding_right" => "cells"
            case "spacing.padding_bottom" => "cells"
            case "spacing.gap" => "cells"
            case "spacing.weight" => "cells"
            case "spacing.align_items" => "alignment"
            case "spacing.justify_content" => "text_alignment"
            case _ => fail("UnknownKey",path)
        }
        var value = dm
        var reset = false
        if (let Some(record) <- (dm as DataModelStruct)) {
            let f = record.getFields()
            if (f.size == 1 && f[0].getName() == "reset") {
                if (!literal.boolean(f[0].getData(),path)) { fail("InvalidValue",path) }
                reset = true
            } else if (f.size == 1 && f[0].getName() == "ref") {
                let ref = literal.str(f[0].getData(),path,metadataPath: path + ".ref")
                if (!validThemeName(ref)) { fail("InvalidValue",path) }
                let v = variables.get(ref)
                if (v is DataModelNull) { fail("UnknownReference",path) }
                let rec = table(v,"variables." + ref)
                let t = literal.str(rec.get("type"),"variables." + ref + ".type")
                if (t != expected) { fail("ReferenceTypeMismatch",path) }
                value = rec.get("value")
            } else if (!(expected == "color" && f.size == 1 && f[0].getName() == "indexed")) {
                fail("InvalidValue",path)
            }
        }
        match (field) {
            case "text.foreground" => if (reset) { rule.withValue(StyleKeys.foreground,StyleValue<Color>.Reset,state:state) } else { rule.withValue(StyleKeys.foreground,StyleValue<Color>.Value(literal.color(value,path)),state:state) }
            case "text.background" => if (reset) { rule.withValue(StyleKeys.background,StyleValue<Color>.Reset,state:state) } else { rule.withValue(StyleKeys.background,StyleValue<Color>.Value(literal.color(value,path)),state:state) }
            case "text.bold" => if (reset) { rule.withValue(StyleKeys.bold,StyleValue<Bool>.Reset,state:state) } else { rule.withValue(StyleKeys.bold,StyleValue<Bool>.Value(literal.boolean(value,path)),state:state) }
            case "text.dim" => if (reset) { rule.withValue(StyleKeys.dim,StyleValue<Bool>.Reset,state:state) } else { rule.withValue(StyleKeys.dim,StyleValue<Bool>.Value(literal.boolean(value,path)),state:state) }
            case "text.italic" => if (reset) { rule.withValue(StyleKeys.italic,StyleValue<Bool>.Reset,state:state) } else { rule.withValue(StyleKeys.italic,StyleValue<Bool>.Value(literal.boolean(value,path)),state:state) }
            case "text.underline" => if (reset) { rule.withValue(StyleKeys.underline,StyleValue<Bool>.Reset,state:state) } else { rule.withValue(StyleKeys.underline,StyleValue<Bool>.Value(literal.boolean(value,path)),state:state) }
            case "text.inverse" => if (reset) { rule.withValue(StyleKeys.inverse,StyleValue<Bool>.Reset,state:state) } else { rule.withValue(StyleKeys.inverse,StyleValue<Bool>.Value(literal.boolean(value,path)),state:state) }
            case "text.strikethrough" => if (reset) { rule.withValue(StyleKeys.strikethrough,StyleValue<Bool>.Reset,state:state) } else { rule.withValue(StyleKeys.strikethrough,StyleValue<Bool>.Value(literal.boolean(value,path)),state:state) }
            case "text.align" => if (reset) { rule.withValue(StyleKeys.textAlign,StyleValue<Alignment>.Reset,state:state) } else { rule.withValue(StyleKeys.textAlign,StyleValue<Alignment>.Value(literal.alignment(value,path,false)),state:state) }
            case "text.wrap" => if (reset) { rule.withValue(StyleKeys.textWrap,StyleValue<TextWrap>.Reset,state:state) } else { rule.withValue(StyleKeys.textWrap,StyleValue<TextWrap>.Value(literal.wrap(value,path)),state:state) }
            case "text.overflow" => if (reset) { rule.withValue(StyleKeys.textOverflow,StyleValue<TextOverflow>.Reset,state:state) } else { rule.withValue(StyleKeys.textOverflow,StyleValue<TextOverflow>.Value(literal.overflow(value,path)),state:state) }
            case "decoration.border" => if (reset) { rule.withValue(StyleKeys.border,StyleValue<BorderStyle>.Reset,state:state) } else { rule.withValue(StyleKeys.border,StyleValue<BorderStyle>.Value(literal.border(value,path)),state:state) }
            case "decoration.border_foreground" => if (reset) { rule.withValue(StyleKeys.borderForeground,StyleValue<Color>.Reset,state:state) } else { rule.withValue(StyleKeys.borderForeground,StyleValue<Color>.Value(literal.color(value,path)),state:state) }
            case "decoration.shadow_enabled" => if (reset) { rule.withValue(StyleKeys.shadowEnabled,StyleValue<Bool>.Reset,state:state) } else { rule.withValue(StyleKeys.shadowEnabled,StyleValue<Bool>.Value(literal.boolean(value,path)),state:state) }
            case "decoration.shadow_offset_x" => if (reset) { rule.withValue(StyleKeys.shadowOffsetX,StyleValue<Int64>.Reset,state:state) } else { rule.withValue(StyleKeys.shadowOffsetX,StyleValue<Int64>.Value(literal.integer(value,path,false)),state:state) }
            case "decoration.shadow_offset_y" => if (reset) { rule.withValue(StyleKeys.shadowOffsetY,StyleValue<Int64>.Reset,state:state) } else { rule.withValue(StyleKeys.shadowOffsetY,StyleValue<Int64>.Value(literal.integer(value,path,false)),state:state) }
            case "decoration.shadow_foreground" => if (reset) { rule.withValue(StyleKeys.shadowForeground,StyleValue<Color>.Reset,state:state) } else { rule.withValue(StyleKeys.shadowForeground,StyleValue<Color>.Value(literal.color(value,path)),state:state) }
            case "decoration.shadow_background" => if (reset) { rule.withValue(StyleKeys.shadowBackground,StyleValue<Color>.Reset,state:state) } else { rule.withValue(StyleKeys.shadowBackground,StyleValue<Color>.Value(literal.color(value,path)),state:state) }
            case "decoration.shadow_bold" => if (reset) { rule.withValue(StyleKeys.shadowBold,StyleValue<Bool>.Reset,state:state) } else { rule.withValue(StyleKeys.shadowBold,StyleValue<Bool>.Value(literal.boolean(value,path)),state:state) }
            case "decoration.shadow_dim" => if (reset) { rule.withValue(StyleKeys.shadowDim,StyleValue<Bool>.Reset,state:state) } else { rule.withValue(StyleKeys.shadowDim,StyleValue<Bool>.Value(literal.boolean(value,path)),state:state) }
            case "decoration.shadow_italic" => if (reset) { rule.withValue(StyleKeys.shadowItalic,StyleValue<Bool>.Reset,state:state) } else { rule.withValue(StyleKeys.shadowItalic,StyleValue<Bool>.Value(literal.boolean(value,path)),state:state) }
            case "decoration.shadow_underline" => if (reset) { rule.withValue(StyleKeys.shadowUnderline,StyleValue<Bool>.Reset,state:state) } else { rule.withValue(StyleKeys.shadowUnderline,StyleValue<Bool>.Value(literal.boolean(value,path)),state:state) }
            case "decoration.shadow_inverse" => if (reset) { rule.withValue(StyleKeys.shadowInverse,StyleValue<Bool>.Reset,state:state) } else { rule.withValue(StyleKeys.shadowInverse,StyleValue<Bool>.Value(literal.boolean(value,path)),state:state) }
            case "decoration.shadow_strikethrough" => if (reset) { rule.withValue(StyleKeys.shadowStrikethrough,StyleValue<Bool>.Reset,state:state) } else { rule.withValue(StyleKeys.shadowStrikethrough,StyleValue<Bool>.Value(literal.boolean(value,path)),state:state) }
            case "spacing.width" => if (reset) { rule.withValue(StyleKeys.width,StyleValue<Dimension>.Reset,state:state) } else { rule.withValue(StyleKeys.width,StyleValue<Dimension>.Value(literal.dimension(value,path)),state:state) }
            case "spacing.height" => if (reset) { rule.withValue(StyleKeys.height,StyleValue<Dimension>.Reset,state:state) } else { rule.withValue(StyleKeys.height,StyleValue<Dimension>.Value(literal.dimension(value,path)),state:state) }
            case "spacing.min_width" => if (reset) { rule.withValue(StyleKeys.minWidth,StyleValue<Int64>.Reset,state:state) } else { rule.withValue(StyleKeys.minWidth,StyleValue<Int64>.Value(literal.integer(value,path,true)),state:state) }
            case "spacing.min_height" => if (reset) { rule.withValue(StyleKeys.minHeight,StyleValue<Int64>.Reset,state:state) } else { rule.withValue(StyleKeys.minHeight,StyleValue<Int64>.Value(literal.integer(value,path,true)),state:state) }
            case "spacing.padding_left" => if (reset) { rule.withValue(StyleKeys.paddingLeft,StyleValue<Int64>.Reset,state:state) } else { rule.withValue(StyleKeys.paddingLeft,StyleValue<Int64>.Value(literal.integer(value,path,true)),state:state) }
            case "spacing.padding_top" => if (reset) { rule.withValue(StyleKeys.paddingTop,StyleValue<Int64>.Reset,state:state) } else { rule.withValue(StyleKeys.paddingTop,StyleValue<Int64>.Value(literal.integer(value,path,true)),state:state) }
            case "spacing.padding_right" => if (reset) { rule.withValue(StyleKeys.paddingRight,StyleValue<Int64>.Reset,state:state) } else { rule.withValue(StyleKeys.paddingRight,StyleValue<Int64>.Value(literal.integer(value,path,true)),state:state) }
            case "spacing.padding_bottom" => if (reset) { rule.withValue(StyleKeys.paddingBottom,StyleValue<Int64>.Reset,state:state) } else { rule.withValue(StyleKeys.paddingBottom,StyleValue<Int64>.Value(literal.integer(value,path,true)),state:state) }
            case "spacing.gap" => if (reset) { rule.withValue(StyleKeys.gap,StyleValue<Int64>.Reset,state:state) } else { rule.withValue(StyleKeys.gap,StyleValue<Int64>.Value(literal.integer(value,path,true)),state:state) }
            case "spacing.weight" => if (reset) { rule.withValue(StyleKeys.layoutWeight,StyleValue<Int64>.Reset,state:state) } else { rule.withValue(StyleKeys.layoutWeight,StyleValue<Int64>.Value(literal.integer(value,path,true)),state:state) }
            case "spacing.align_items" => if (reset) { rule.withValue(StyleKeys.alignItems,StyleValue<Alignment>.Reset,state:state) } else { rule.withValue(StyleKeys.alignItems,StyleValue<Alignment>.Value(literal.alignment(value,path,true)),state:state) }
            case "spacing.justify_content" => if (reset) { rule.withValue(StyleKeys.justifyContent,StyleValue<Alignment>.Reset,state:state) } else { rule.withValue(StyleKeys.justifyContent,StyleValue<Alignment>.Value(literal.alignment(value,path,false)),state:state) }
            case _ => fail("UnknownKey",path)
        }
    }
    func category(rule: StyleRule, cat: String, dm: DataModel, path: String, state: VisualState): StyleRule {
        var result = rule
        for (field in table(dm,path).getFields()) {
            try { result = property(result,cat,field.getName(),field.getData(),path + "." + field.getName(),state) }
            catch (e: ThemeException) { errors.add(e) }
        }
        result
    }
}

func validThemeName(name: String): Bool {
    if (name.size == 0 || name.size > 128) { return false }
    var first = true
    for (ch in name.toArray()) {
        let letter = (ch >= b'A' && ch <= b'Z') || (ch >= b'a' && ch <= b'z') || ch == b'_'
        if (!letter && (first || !((ch >= b'0' && ch <= b'9') || ch == b'-'))) { return false }
        first = false
    }
    true
}
