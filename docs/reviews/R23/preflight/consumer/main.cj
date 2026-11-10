package glyph_advance_preflight
import cjtui.*
import cjtui.text.*

main(): Int64 {
    let labels = ["ascii", "combining", "cjk", "woman", "laptop", "flag", "zwj", "heart_vs16", "sun_vs16", "keycap"]
    let values = ["A", "e\u{0301}", "界", "👩", "💻", "🇨🇳", "👩\u{200D}💻", "❤\u{FE0F}", "☀\u{FE0F}", "1\u{FE0F}\u{20E3}"]
    for (i in 0..values.size) {
        var sum: Int64 = 0
        for (scalar in values[i].runes()) {
            let w = displayWidth(scalar.toString())
            sum += w
            println("scalar\t${labels[i]}\t${UInt32(scalar)}\t${w}")
        }
        let frame = Frame(20, 1)
        frame.put(0, 0, values[i])
        println("sample\t${labels[i]}\t${sum}\t${displayWidth(values[i])}\t${frame.cellAt(0, 0).width}\t${graphemeClusters(values[i]).size}")
    }
    return 0
}
