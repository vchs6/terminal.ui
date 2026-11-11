package cjtui.theme

import cjtui.style.*
import std.unicode.*
import std.collection.*
import stdx.serialization.serialization.*

class ThemeDecoder {
    let source: String
    let root: DataModelStruct
    let schema: ThemeSchema
    let literal: ThemeLiteral
    let roles = Array<StyleRule>(17, { _ => StyleRule() })
    let names = ArrayList<String>()
    let named = ArrayList<StyleRule>()
    var text = StyleRule()
    var decoration = StyleRule()
    var spacing = StyleRule()
    init(source: String, root: DataModelStruct) {
        this.source = source; this.root = root; this.literal = ThemeLiteral(source)
        let vars = root.get("variables")
        let varTable = if (vars is DataModelNull) { DataModelStruct() } else { literalTable(vars,"variables") }
        this.schema = ThemeSchema(source,varTable)
    }
    func fail(code: String,path: String): Nothing { throw themeFailure(code,source,path,"invalid theme value at ${path}") }
    func decode(path: ?String): Theme {
        let ver = root.get("schema_version")
        if (ver is DataModelNull) { fail("MissingRequired","schema_version") }
        if (literal.integer(ver,"schema_version",false) != 1) { fail("UnsupportedVersion","schema_version") }
        let nameValue = root.get("name")
        if (nameValue is DataModelNull) { fail("MissingRequired","name") }
        let name = literal.str(nameValue,"name")
        if (name.trim().isEmpty()) { fail("InvalidValue","name") }
        for (entry in root.getFields()) {
            let k = entry.getName(); let v = entry.getData()
            match (k) {
                case "schema_version" | "name" => ()
                case "variables" => validateVariables(v)
                case "text" => text = schema.category(StyleRule(),k,v,k,VisualState.Normal)
                case "decoration" => decoration = schema.category(StyleRule(),k,v,k,VisualState.Normal)
                case "spacing" => spacing = schema.category(StyleRule(),k,v,k,VisualState.Normal)
                case "styles" =>
                    let list = schema.table(v,k).getFields()
                    if (list.size > 4096) { fail("CapacityExceeded",k) }
                    for (field in list) {
                        let label = field.getName(); let p = "styles." + label
                        if (!validThemeName(label)) { fail("InvalidName",p) }
                        names.add(label); named.add(rule(field.getData(),p,-1))
                    }
                case "components" =>
                    for (field in schema.table(v,k).getFields()) {
                        let label = field.getName(); let p = "components." + label
                        let i = roleIndex(label)
                        if (i < 0) { fail("UnknownRole",p) }
                        roles[i] = rule(field.getData(),p,i)
                    }
                case _ => fail("UnknownKey",k)
            }
        }
        Theme(name,path,source,text,decoration,spacing,roles,names.toArray(),named.toArray())
    }
    func validateVariables(dm: DataModel): Unit {
        let entries = schema.table(dm,"variables").getFields()
        if (entries.size > 4096) { fail("CapacityExceeded","variables") }
        for (entry in entries) {
            let p = "variables." + entry.getName()
            if (!validThemeName(entry.getName())) { fail("InvalidName",p) }
            let rec = schema.table(entry.getData(),p)
            for (f in rec.getFields()) { if (f.getName() != "type" && f.getName() != "value") { fail("UnknownKey",p + "." + f.getName()) } }
            let t = rec.get("type"); let v = rec.get("value")
            if (t is DataModelNull) { fail("MissingRequired",p + ".type") }
            if (v is DataModelNull) { fail("MissingRequired",p + ".value") }
            let valuePath = p + ".value"
            match (literal.str(t,p + ".type")) {
                case "color" => let _ = literal.color(v,valuePath)
                case "bool" => let _ = literal.boolean(v,valuePath)
                case "cells" => let _ = literal.integer(v,valuePath,true)
                case "offset" => let _ = literal.integer(v,valuePath,false)
                case "dimension" => let _ = literal.dimension(v,valuePath)
                case "alignment" => let _ = literal.alignment(v,valuePath,true)
                case "text_alignment" => let _ = literal.alignment(v,valuePath,false)
                case "border" => let _ = literal.border(v,valuePath)
                case "wrap" => let _ = literal.wrap(v,valuePath)
                case "overflow" => let _ = literal.overflow(v,valuePath)
                case _ => fail("InvalidValue",p + ".type")
            }
        }
    }
    func rule(dm: DataModel,path: String,role: Int64): StyleRule {
        let rec = schema.table(dm,path)
        let seen = HashSet<String>()
        var result = StyleRule()
        for (f in rec.getFields()) {
            let k = f.getName(); let v = f.getData()
            if (k == "states") {
                for (sf in schema.table(v,path + ".states").getFields()) {
                    let sp = path + ".states." + sf.getName()
                    let state = match (sf.getName()) {
                        case "normal" => VisualState.Normal
                        case "focused" => VisualState.Focused
                        case "selected" => VisualState.Selected
                        case "disabled" => VisualState.Disabled
                        case _ => fail("UnknownState",sp)
                    }
                    for (cf in schema.table(sf.getData(),sp).getFields()) {
                        result = ruleCategory(result,cf.getName(),cf.getData(),sp + "." + cf.getName(),state,role,seen)
                    }
                }
            } else { result = ruleCategory(result,k,v,path + "." + k,VisualState.Normal,role,seen) }
        }
        result
    }
    func ruleCategory(rule: StyleRule,cat: String,dm: DataModel,path: String,state: VisualState,role: Int64,seen: HashSet<String>): StyleRule {
        if (cat != "text" && cat != "decoration" && cat != "spacing") { fail("UnknownKey",path) }
        var result = rule
        for (f in schema.table(dm,path).getFields()) {
            let key = cat + "." + f.getName(); let p = path + "." + f.getName()
            if (state == VisualState.Normal) {
                if (seen.contains(key)) { fail("DuplicateProperty",p) }
                seen.add(key)
            }
            if (role > 0) {
                let textLayout = key == "text.align" || key == "text.wrap" || key == "text.overflow"
                let containerLayout = key == "spacing.gap" || key == "spacing.align_items" || key == "spacing.justify_content"
                let isText = role == 1 || role == 4 || role == 5 || role == 6 || role == 7 || role == 13
                let isContainer = role == 2 || role == 3 || role == 11 || role == 12 || role == 14 || role == 15 || role == 16
                if ((textLayout && !isText) || (containerLayout && !isContainer)) { fail("UnsupportedProperty",p) }
            }
            result = schema.property(result,cat,f.getName(),f.getData(),p,state)
        }
        result
    }
}
func literalTable(dm: DataModel,path: String): DataModelStruct {
    if (let Some(v) <- (dm as DataModelStruct)) { return v }
    throw themeFailure("InvalidType","<memory>",path,"expected table")
}
func roleIndex(name: String): Int64 {
    match (name) {
        case "generic" => 0; case "text" => 1; case "row" => 2; case "column" => 3
        case "label" => 4; case "button" => 5; case "radio" => 6; case "checkbox" => 7
        case "progress" => 8; case "text_input" => 9; case "text_area" => 10
        case "horizontal_menu" => 11; case "popup_menu" => 12; case "menu_item" => 13
        case "status_bar" => 14; case "modal" => 15; case "split_pane" => 16
        case _ => -1
    }
}
