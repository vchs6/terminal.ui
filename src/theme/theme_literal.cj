package cjtui.theme

import cjtui.style.*
import stdx.serialization.serialization.*
import cangjie_toml.cangjie_toml.parser.*

// Converts already parsed TOML values; the upstream parser remains syntax owner.
class ThemeLiteral {
    let source: String
    let parser: Parser
    init(source: String, parser: Parser) { this.source = source; this.parser = parser }
    func fail(code: String, path: String): Nothing { throw themeFailure(code, source, path, "invalid theme value at ${path}") }
    func str(dm: DataModel, path: String, metadataPath!: String = ""): String {
        let lookup = if (metadataPath.isEmpty()) { path } else { metadataPath }
        if (let Some(info) <- parser.keyInfo.get(lookup)) {
            if (info.tomlType.toString() == "TomlDateTime") { fail("InvalidType",path) }
        }
        if (let Some(v) <- (dm as DataModelString)) { return v.getValue() }
        fail("InvalidType", path)
    }
    func boolean(dm: DataModel, path: String): Bool {
        if (let Some(v) <- (dm as DataModelBool)) { return v.getValue() }
        fail("InvalidType", path)
    }
    func integer(dm: DataModel, path: String, nonnegative: Bool): Int64 {
        if (let Some(v) <- (dm as DataModelInt)) {
            let n = v.getValue()
            if (nonnegative && n < 0) { fail("OutOfRange", path) }
            return n
        }
        fail("InvalidType", path)
    }
    func dimension(dm: DataModel, path: String): Dimension {
        if (let Some(v) <- (dm as DataModelString)) {
            if (str(dm,path) == "auto") { return Dimension.Auto }
            fail("InvalidValue", path)
        }
        Dimension.Cells(integer(dm, path, true))
    }
    func alignment(dm: DataModel, path: String, stretch: Bool): Alignment {
        match (str(dm, path)) {
            case "start" => Alignment.Start
            case "center" => Alignment.Center
            case "end" => Alignment.End
            case "stretch" => if (stretch) { Alignment.Stretch } else { fail("InvalidValue", path) }
            case _ => fail("InvalidValue", path)
        }
    }
    func border(dm: DataModel, path: String): BorderStyle {
        match (str(dm,path)) {
            case "none" => BorderStyle.None
            case "single" => BorderStyle.Single
            case "rounded" => BorderStyle.Rounded
            case "double" => BorderStyle.Double
            case "ascii" => BorderStyle.Ascii
            case _ => fail("InvalidValue",path)
        }
    }
    func wrap(dm: DataModel, path: String): TextWrap {
        match (str(dm,path)) { case "none" => TextWrap.None; case "grapheme" => TextWrap.Grapheme; case _ => fail("InvalidValue",path) }
    }
    func overflow(dm: DataModel, path: String): TextOverflow {
        match (str(dm,path)) { case "clip" => TextOverflow.Clip; case "ellipsis" => TextOverflow.Ellipsis; case _ => fail("InvalidValue",path) }
    }
    func color(dm: DataModel, path: String): Color {
        if (let Some(table) <- (dm as DataModelStruct)) {
            let fields = table.getFields()
            if (fields.size != 1 || fields[0].getName() != "indexed") { fail("InvalidValue", path) }
            let index = integer(fields[0].getData(), path, true)
            if (index > 255) { fail("OutOfRange",path) }
            return Color.Indexed(UInt8(index))
        }
        let s = str(dm,path)
        match (s) {
            case "default" => return Color.Default
            case "black" => return Color.Black
            case "red" => return Color.Red
            case "green" => return Color.Green
            case "yellow" => return Color.Yellow
            case "blue" => return Color.Blue
            case "magenta" => return Color.Magenta
            case "cyan" => return Color.Cyan
            case "white" => return Color.White
            case "bright-black" => return Color.BrightBlack
            case "bright-red" => return Color.BrightRed
            case "bright-green" => return Color.BrightGreen
            case "bright-yellow" => return Color.BrightYellow
            case "bright-blue" => return Color.BrightBlue
            case "bright-magenta" => return Color.BrightMagenta
            case "bright-cyan" => return Color.BrightCyan
            case "bright-white" => return Color.BrightWhite
            case _ => ()
        }
        if (s.size != 7 || s[0] != b'#') { fail("InvalidValue",path) }
        var n: Int64 = 0
        for (i in 1..7) {
            let c = s[i]
            let d: Int64 = if (c >= b'0' && c <= b'9') { Int64(c - b'0') } else if (c >= b'a' && c <= b'f') {
                Int64(c - b'a') + 10
            } else if (c >= b'A' && c <= b'F') { Int64(c - b'A') + 10 } else { fail("InvalidValue",path) }
            n = n * 16 + d
        }
        Color.Rgb(UInt8(n / 65536), UInt8((n / 256) % 256), UInt8(n % 256))
    }
}
