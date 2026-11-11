package cjtui.theme

import cjtui.style.StyleRule
import cangjie_toml.cangjie_toml.parser.*
import std.fs.*
import std.env.getWorkingDirectory
import std.collection.ArrayList

// A validated theme is a snapshot: arrays are copied and never exposed.
public class Theme {
    public let name: String
    public let schemaVersion: Int64
    public let sourcePath: ?String
    public let sourceName: String
    private let text: StyleRule
    private let decoration: StyleRule
    private let spacing: StyleRule
    private let roles: Array<StyleRule>
    private let names: Array<String>
    private let named: Array<StyleRule>

    internal init(name: String, sourcePath: ?String, sourceName: String, text: StyleRule,
        decoration: StyleRule, spacing: StyleRule, roles: Array<StyleRule>,
        names: Array<String>, named: Array<StyleRule>) {
        this.name = name; this.schemaVersion = 1; this.sourcePath = sourcePath; this.sourceName = sourceName
        this.text = text; this.decoration = decoration; this.spacing = spacing
        this.roles = Array<StyleRule>(roles.size, {i => roles[i]})
        this.names = Array<String>(names.size, {i => names[i]})
        this.named = Array<StyleRule>(named.size, {i => named[i]})
    }
    public static func parse(text: String, sourceName!: String = "<memory>"): Theme {
        parseTheme(text,sourceName,Option<String>.None)
    }
    public static func readFile(path: String): Theme {
        if (path.isEmpty() || path.contains("\u{0}")) { throw themeFailure("InvalidPath",path,"","invalid path") }
        let absolute = if (path.startsWith("/")) { path } else { getWorkingDirectory().toString() + "/" + path }
        var data: Array<UInt8> = []
        try {
            let file = File(absolute,OpenMode.Read)
            try {
                let bytes = ArrayList<UInt8>()
                let buffer = Array<UInt8>(8192,repeat:0u8)
                while (true) {
                    let n = file.read(buffer)
                    if (n == 0) { break }
                    for (i in 0..n) {
                        bytes.add(buffer[i])
                        if (bytes.size > 1048576) { throw themeFailure("CapacityExceeded",absolute,"","theme exceeds byte budget") }
                    }
                }
                data = bytes.toArray()
            } finally { file.close() }
        } catch (e: ThemeException) { throw e } catch (e: Exception) { throw themeFailure("ReadFailed",absolute,"",e.message) }
        let input = try { String.fromUtf8(data) } catch (_: IllegalArgumentException) { throw themeFailure("InvalidUtf8",absolute,"","invalid UTF-8") }
        parseTheme(input,absolute,Some(absolute))
    }
    public static func preset(value: ThemePreset): Theme {
        let (slug,input) = themePresetText(value)
        parseTheme(input,"<preset:" + slug + ">",Option<String>.None)
    }
    public func textDefaults(): StyleRule { text }
    public func decorationDefaults(): StyleRule { decoration }
    public func spacingDefaults(): StyleRule { spacing }
    public func componentRule(role: ThemeRole): StyleRule { roles[themeRoleIndex(role)] }
    public func namedStyle(name: String): ?StyleRule {
        for (i in 0..names.size) { if (names[i] == name) { return Some(named[i]) } }
        None
    }
}

func parseTheme(input: String, source: String, path: ?String): Theme {
    checkThemeBudget(input,source)
    let parser = Parser(input)
    try { parser.parse() } catch (e: ParseException) {
        let p = e.position
        let location = ThemeLocation(p.line,p.col,p.start,p.len)
        let code = if (e.err.startsWith("expected integer value")) { "OutOfRange" } else { "SyntaxError" }
        throw ThemeException(ThemeDiagnostic(code,source,e.lastKey,e.message,Some(location),"value"))
    }
    try { ThemeDecoder(source,parser.result).decode(path) } catch (e: ThemeException) {
        let d = e.diagnostic
        var lookup = d.keyPath
        if (d.code == "UnknownReference" || d.code == "ReferenceTypeMismatch") { lookup += ".ref" }
        var scope = "value"
        while (!lookup.isEmpty()) {
            if (let Some(i) <- parser.keyInfo.get(lookup)) {
                let p = i.pos.withCol(input.toRuneArray())
                if (p.len > 0) {
                    let location = ThemeLocation(p.line,p.col,p.start,p.len)
                    throw ThemeException(ThemeDiagnostic(d.code,source,d.keyPath,d.message,Some(location),scope))
                }
            }
            match (lookup.lastIndexOf(b'.')) {
                case Some(index) => lookup = lookup[..index]; scope = "table"
                case _ => break
            }
        }
        throw e
    }
}
