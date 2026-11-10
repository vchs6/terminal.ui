package terminal_width_probe
import cjtui.*
import cjtui.text.*

main(): Int64 {
    let labels = ["ascii", "cjk", "combining", "woman", "laptop", "zwj", "flag", "heart_text", "heart_vs16", "sun_text", "sun_vs16", "keycap", "zwj_suffix", "flag_suffix", "vs16_suffix", "combined_suffix"]
    let values = ["A", "界", "é", "👩", "💻", "👩‍💻", "🇨🇳", "❤", "❤️", "☀", "☀️", "1️⃣", "👩‍💻Z", "🇨🇳Z", "❤️Z", "é and 界 👩‍💻Z"]
    for (i in 0..values.size) {
        println("${labels[i]}\t${displayWidth(values[i])}\t${graphemeClusters(values[i]).size}")
    }
    let frame = Frame(100, 1)
    frame.put(0, 0, "é and 界 👩‍💻")
    for (x in 0..16) {
        let c = frame.cellAt(x, 0)
        println("cell\t${x}\t${c.width}\t${c.continuation}\t${c.grapheme}")
    }
    return 0
}
