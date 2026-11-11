package theme_values_contract
import cjtui.style.*
import cjtui.theme.*
import std.fs.File

func keyBudgetRepeat(text: String, count: Int64): String {
    let result = StringBuilder()
    for (_ in 0..count) { result.append(text) }
    result.toString()
}
func keyBudgetInput(stem: String): String {
    String.fromUtf8(File.readFrom("../.scratch/key-budget-" + stem + ".toml"))
}
// Independently transcribed semantic keys, not decoded with a test parser.
func keyBudgetDecoded(encoding: String, size: Int64): String {
    if (encoding == "unicode" || encoding == "unicode-literal") {
        return keyBudgetRepeat("界",341) + keyBudgetRepeat("a",size-1023)
    }
    if (encoding == "mixed") { return keyBudgetRepeat("界",170) + keyBudgetRepeat("a",size-510) }
    if (encoding == "escape-short") { return keyBudgetRepeat("a",170+size-1020) }
    if (encoding == "escape-long") { return keyBudgetRepeat("a",102+size-1020) }
    if (encoding == "quote") { return keyBudgetRepeat("\"",512) + keyBudgetRepeat("a",size-1024) }
    if (encoding == "backslash") { return keyBudgetRepeat("\\",512) + keyBudgetRepeat("a",size-1024) }
    if (encoding == "punctuation") { return keyBudgetRepeat("a.[{}]",170) + keyBudgetRepeat("a",size-1020) }
    keyBudgetRepeat("a",size)
}
func keyBudgetSourceRunes(encoding: String, size: Int64): Int64 {
    if (encoding == "bare") { return size }
    if (encoding == "unicode" || encoding == "unicode-literal") { return 341+size-1023+2 }
    if (encoding == "mixed") { return 170+size-510+2 }
    size+2
}
func keyBudgetStart(context: String): Int64 {
    // PREFIX is 29 Runes; all generic keys occur on line3.
    match (context) {
        case "ordinary" => 29
        case "dotted" => 34
        case "table" => 30
        case "array-table" => 31
        case "inline" => 35
        case "array-inline" => 36
        case _ => throw Exception("unknown key context")
    }
}
func keyBudgetFailure(stem: String, code: String, path: String, keyStart: Int64, keyRunes: Int64): Unit {
    let input = keyBudgetInput(stem)
    let source = "key-budget:" + stem
    try { Theme.parse(input,sourceName:source) }
    catch (e: ThemeException) {
        let d = e.diagnostic
        check(d.code == code,"${stem}: ${d.code}, expected ${code}")
        check(d.source == source && d.message.size > 0,"${stem}: source and diagnostic context")
        if (code != "CapacityExceeded") {
            check(d.keyPath == path,"${stem}: downstream decoded keyPath")
        } else {
            // Guard does not semantically decode keyPath. Require a real lexical
            // location overlapping the offending spelling, not invented (1,1).
            match (d.location) {
                case Some(loc) =>
                    let runes = input.toRuneArray()
                    check(loc.runeStart >= 0 && loc.runeLength > 0 && loc.runeStart+loc.runeLength <= runes.size,"${stem}: bounded Rune location")
                    check(loc.runeStart >= 29 && loc.runeStart < keyStart+keyRunes && loc.runeStart+loc.runeLength > keyStart,"${stem}: location overlaps oversized key")
                    var line: Int64 = 1
                    var column: Int64 = 1
                    for (i in 0..loc.runeStart) {
                        if (runes[i] == r'\n') { line++;column=1 } else { column++ }
                    }
                    check(loc.line == line && loc.column == column,"${stem}: coordinates use source Runes")
                case None => throw Exception("${stem}: missing lexical budget location")
            }
        }
        return
    }
    throw Exception("${stem}: expected ${code}")
}
func encodedKeyBudgetBoundaries(): Unit {
    let contexts = ["ordinary","dotted","table","array-table","inline","array-inline"]
    let encodings = ["bare","basic","literal","unicode","unicode-literal","mixed","escape-short","escape-long","quote","backslash","punctuation"]
    for (context in contexts) {
        for (encoding in encodings) {
            let stem = "${context}-${encoding}-1024"
            let decoded = keyBudgetDecoded(encoding,1024)
            let path = if (context == "array-inline") { "text" }
                else if (context == "dotted" || context == "inline") { "text."+decoded }
                else { decoded }
            let code = if (context == "array-inline") { "InvalidType" } else { "UnknownKey" }
            keyBudgetFailure(stem,code,path,keyBudgetStart(context),keyBudgetSourceRunes(encoding,1024))
            keyBudgetFailure("${context}-${encoding}-1025","CapacityExceeded","",keyBudgetStart(context),keyBudgetSourceRunes(encoding,1025))
        }
    }
    let bold = StyleRule().withValue(StyleKeys.bold,StyleValue<Bool>.Value(true))
    for (kind in ["styles","variables"]) {
        for (spelling in ["direct-103","escaped-1024"]) {
            let value = Theme.parse(keyBudgetInput("${kind}-${spelling}"))
            let length: Int64 = if (spelling == "direct-103") { 103 } else { 106 }
            if (kind == "styles") {
                check(named(value,keyBudgetRepeat("a",length)) == bold,"${kind}-${spelling}: valid decoded name and typed rule")
            } else {
                check(value.textDefaults() == bold,"${kind}-${spelling}: valid decoded variable reference")
            }
        }
        let start: Int64 = if (kind == "styles") { 38 } else { 41 }
        keyBudgetFailure("${kind}-escaped-103","CapacityExceeded","",start,1032)
        keyBudgetFailure("${kind}-escaped-1025","CapacityExceeded","",start,1027)
    }
    for (spelling in ["bare","literal","escaped-short","escaped-long","inline","table"]) {
        check(Theme.parse(keyBudgetInput("equivalent-"+spelling)).textDefaults() == bold,"within-budget equivalent ${spelling}")
    }
    check(Theme.parse(keyBudgetInput("value-escaped-1030")).name == keyBudgetRepeat("a",103),"1030 raw value bytes are not key bytes")
    check(Theme.parse(keyBudgetInput("value-literal-1025")).name == keyBudgetRepeat("a",1025),"literal value exceeds key budget legally")
    check(Theme.parse(keyBudgetInput("value-unicode-1026")).name == keyBudgetRepeat("界",342),"Unicode value bytes do not become key bytes")
    check(Theme.parse(keyBudgetInput("comment-1030")).name == "Case","comment escape spelling is inert")
    check(Theme.parse(keyBudgetInput("comment-punctuation")).textDefaults() == bold,"comment punctuation does not affect key/path/depth")
}
